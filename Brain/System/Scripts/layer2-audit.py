#!/usr/bin/env python3
"""
Layer 2 Audit — nightly extraction of knowledge from session logs into Brain/Knowledge and Brain/People.
Scheduled via launchd at 22:00. Also callable manually: python3 layer2-audit.py
Paths are detected dynamically from script location — no hardcoding needed.
"""

import subprocess
import shutil
import sys
from datetime import date, datetime
from pathlib import Path

# Dynamic path detection — script lives at Brain/System/Scripts/layer2-audit.py
SCRIPT_DIR = Path(__file__).resolve().parent
BRAIN = SCRIPT_DIR.parent.parent          # Brain/System/Scripts → Brain/System → Brain
VAULT = BRAIN.parent                      # Brain → vault root
LOG_FILE = BRAIN / "System/layer2-audit-log.md"
TODAY = date.today().isoformat()

# Detect claude binary
CLAUDE = shutil.which("claude") or "/usr/local/bin/claude"

PROMPT = """You are doing a Layer 2 knowledge extraction audit on today's session logs.

The system has two layers:
- Layer 1: session logs — everything captured as it happens, dense narrative
- Layer 2: Brain/Knowledge and Brain/People — organized by topic, built for retrieval

Your job: find content in the session logs worth moving to Layer 2.

Layer 2-WORTHY:
- Named frameworks or concepts explained with real depth (not just mentioned in passing)
- Competitive or market insights with actual detail
- Decisions with reasoning — the WHY, not just the WHAT was done
- Pricing references or business model observations with specifics
- People context worth remembering across sessions

NOT worth extracting:
- Task completions ("scheduled the meeting") — Layer 1 narrative
- Session log summaries or recap entries
- Thin observations with no retrieval value
- Things already well-documented in existing files

TODAY'S SESSION LOG CONTENT:
{session_content}

EXISTING KNOWLEDGE INDEX (shows what files already exist — prefer appending to existing ones):
{knowledge_index}

Output format — use EXACTLY this structure, nothing else:

=== EXTRACT: Brain/Knowledge/[subfolder]/[filename].md ===
[content — self-contained, readable without this conversation as context]
=== END ===

Or for people files:

=== EXTRACT: Brain/People/[Name].md ===
[content to append]
=== END ===

Rules:
- Start content immediately — no meta-commentary like "append this" or "add under section"
- Prefer appending to existing files over creating new ones
- 2–4 high-quality extracts max — be selective
- Content must stand alone without references to "this session" or "as we discussed"
- If nothing qualifies: output exactly NO_EXTRACTS
"""

def find_today_sessions():
    sessions_dir = BRAIN / "Session_Logs"
    return sorted(f for f in sessions_dir.glob(f"{TODAY}*.md") if f.is_file())

def extract_session_log_section(filepath):
    content = filepath.read_text(encoding="utf-8", errors="ignore")
    in_log = False
    lines = []
    for line in content.split("\n"):
        if line.strip() == "## Session Log":
            in_log = True
            continue
        if in_log and line.startswith("## ") and line.strip() != "## Session Log":
            break
        if in_log:
            lines.append(line)
    return "\n".join(lines).strip()

def get_knowledge_index():
    idx_path = BRAIN / "Knowledge/INDEX.md"
    if idx_path.exists():
        return idx_path.read_text(encoding="utf-8", errors="ignore")[:3000]
    return "(No Knowledge INDEX found — use Brain/Knowledge/ subdirs: AI_and_Agents, Business, Frameworks, Glossaries)"

def call_claude(prompt_text):
    result = subprocess.run(
        [CLAUDE, "-p", prompt_text],
        capture_output=True,
        text=True,
        timeout=180,
        cwd=str(VAULT),
    )
    if result.returncode != 0:
        return None, result.stderr[:500]
    return result.stdout.strip(), None

def parse_extracts(output):
    extracts = []
    current_file = None
    current_lines = []
    for line in output.split("\n"):
        if line.startswith("=== EXTRACT:"):
            current_file = line.replace("=== EXTRACT:", "").replace("===", "").strip()
            current_lines = []
        elif line.strip() == "=== END ===" and current_file:
            extracts.append((current_file, "\n".join(current_lines).strip()))
            current_file = None
            current_lines = []
        elif current_file is not None:
            current_lines.append(line)
    return extracts

def append_to_vault_file(rel_path, content):
    target = VAULT / rel_path
    target.parent.mkdir(parents=True, exist_ok=True)
    if target.exists():
        existing = target.read_text(encoding="utf-8")
        target.write_text(existing.rstrip() + "\n\n---\n\n" + content + "\n", encoding="utf-8")
    else:
        target.write_text(content + "\n", encoding="utf-8")

def write_audit_log(extracts, session_count, error=None):
    now = datetime.now().strftime("%Y-%m-%d %H:%M")
    if error:
        entry = f"\n## {now} — ERROR\nSessions scanned: {session_count}\nError: {error}\n"
    elif not extracts:
        entry = f"\n## {now}\nSessions: {session_count} — nothing qualified.\n"
    else:
        lines = [f"\n## {now}\nSessions: {session_count}, extracted {len(extracts)}:"]
        for fp, _ in extracts:
            lines.append(f"- `{fp}`")
        entry = "\n".join(lines) + "\n"

    LOG_FILE.parent.mkdir(parents=True, exist_ok=True)
    if LOG_FILE.exists():
        LOG_FILE.write_text(LOG_FILE.read_text(encoding="utf-8") + entry, encoding="utf-8")
    else:
        LOG_FILE.write_text(
            "# Layer 2 Audit Log\n\nNightly extraction from session logs to Knowledge/People.\n" + entry,
            encoding="utf-8",
        )

def main():
    sessions = find_today_sessions()
    if not sessions:
        print(f"No session files for {TODAY}.")
        return

    print(f"Scanning {len(sessions)} session file(s) for {TODAY}...")

    content_parts = []
    for sf in sessions:
        log = extract_session_log_section(sf)
        if log:
            content_parts.append(f"--- {sf.name} ---\n{log}")

    if not content_parts:
        print("Session files found but Session Log sections are empty.")
        write_audit_log([], len(sessions))
        return

    combined = "\n\n".join(content_parts)
    knowledge_index = get_knowledge_index()

    prompt = PROMPT.format(
        session_content=combined,
        knowledge_index=knowledge_index,
    )

    print("Calling Claude for extraction...")
    output, error = call_claude(prompt)

    if error:
        print(f"Error: {error}")
        write_audit_log([], len(sessions), error)
        sys.exit(1)

    if not output or output.strip() == "NO_EXTRACTS":
        print("No extracts — nothing qualified for Layer 2 today.")
        write_audit_log([], len(sessions))
        return

    extracts = parse_extracts(output)
    if not extracts:
        print("Claude responded but no valid extract blocks parsed.")
        write_audit_log([], len(sessions))
        return

    written = []
    for rel_path, content in extracts:
        if rel_path and content:
            append_to_vault_file(rel_path, content)
            print(f"✓ {rel_path}")
            written.append((rel_path, content))

    write_audit_log(written, len(sessions))
    print(f"\nDone. {len(written)} item(s) written to Layer 2.")

if __name__ == "__main__":
    main()
