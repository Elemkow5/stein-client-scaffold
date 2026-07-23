#!/usr/bin/env python3
"""
Reads hooks.yaml and generates .claude/settings.json.
Never edit settings.json directly — always go through hooks.yaml → this script.

Usage: python3 System/Scripts/generate-claude-settings.py
Run from the vault root.
"""

import json
import os
import sys

try:
    import yaml
except ImportError:
    print("PyYAML not installed. Run: pip3 install pyyaml")
    sys.exit(1)

VAULT_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
HOOKS_YAML = os.path.join(VAULT_ROOT, "hooks.yaml")
SETTINGS_JSON = os.path.join(VAULT_ROOT, ".claude", "settings.json")

with open(HOOKS_YAML, "r") as f:
    spec = yaml.safe_load(f)

hooks_config = {}

for hook in spec.get("hooks", []):
    trigger = hook["trigger"]
    script = hook["script"]
    tool_matcher = hook.get("tool")  # optional — only for PostToolUse/PreToolUse

    # Determine command
    if script.endswith(".cjs") or script.endswith(".js"):
        command = f"node {script}"
    else:
        command = f"bash {script}"

    entry = {"type": "command", "command": command}

    if trigger not in hooks_config:
        hooks_config[trigger] = []

    if tool_matcher:
        # Find existing matcher group or create new one
        existing = next(
            (g for g in hooks_config[trigger] if g.get("matcher") == tool_matcher),
            None
        )
        if existing:
            existing["hooks"].append(entry)
        else:
            hooks_config[trigger].append({"matcher": tool_matcher, "hooks": [entry]})
    else:
        # No matcher — find existing no-matcher group or create one
        existing = next(
            (g for g in hooks_config[trigger] if "matcher" not in g),
            None
        )
        if existing:
            existing["hooks"].append(entry)
        else:
            hooks_config[trigger].append({"hooks": [entry]})

output = {"hooks": hooks_config}

os.makedirs(os.path.dirname(SETTINGS_JSON), exist_ok=True)
with open(SETTINGS_JSON, "w") as f:
    json.dump(output, f, indent=2)
    f.write("\n")

print(f"Generated {SETTINGS_JSON}")
print(f"  Triggers: {list(hooks_config.keys())}")
for trigger, groups in hooks_config.items():
    for g in groups:
        for h in g.get("hooks", []):
            matcher = g.get("matcher", "—")
            print(f"  [{trigger}] matcher={matcher}  cmd={h['command']}")
