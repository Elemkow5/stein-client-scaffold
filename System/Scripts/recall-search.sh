#!/bin/bash
# recall-search.sh — Multi-pass keyword search across the vault
# Usage: recall-search.sh "query string" [--recency-only] [--section SECTION] [--project PROJECT] [--days N]
# Output: JSON array of results sorted by score

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT="$(cd "$SCRIPT_DIR/../.." && pwd)"

QUERY="$1"
RECENCY_ONLY=false
SECTION_FILTER=""
PROJECT_FILTER=""
DAYS_FILTER=0

shift
while [[ $# -gt 0 ]]; do
  case "$1" in
    --recency-only) RECENCY_ONLY=true ;;
    --section) SECTION_FILTER="$2"; shift ;;
    --project) PROJECT_FILTER="$2"; shift ;;
    --days) DAYS_FILTER="$2"; shift ;;
  esac
  shift
done

if [ -z "$QUERY" ]; then
  echo "[]"
  exit 0
fi

# Extract individual keywords (strip common stopwords)
STOPWORDS="the a an and or but in on at to for of with that this is was are were be been"
KEYWORDS=()
for word in $QUERY; do
  lower=$(echo "$word" | tr '[:upper:]' '[:lower:]' | tr -d '[:punct:]')
  skip=false
  for stop in $STOPWORDS; do
    [ "$lower" = "$stop" ] && skip=true && break
  done
  [ "$skip" = false ] && [ ${#lower} -gt 2 ] && KEYWORDS+=("$lower")
done

# Search paths — ordered by signal quality
SEARCH_PATHS=(
  "$VAULT/Brain/Knowledge"
  "$VAULT/Brain/Topics"
  "$VAULT/Brain/Projects"
  "$VAULT/Brain/Decisions"
  "$VAULT/Brain/People"
  "$VAULT/Brain/Plans"
  "$VAULT/Brain/Session_Logs"
  "$VAULT/Goals"
)

# Apply project filter — restrict to matching project files and sessions
if [ -n "$PROJECT_FILTER" ]; then
  SEARCH_PATHS=("$VAULT/Brain/Projects" "$VAULT/Brain/Session_Logs" "$VAULT/Brain/Plans")
fi

# Apply days filter — find only recently modified files
FIND_MTIME=""
if [ "$DAYS_FILTER" -gt 0 ] 2>/dev/null; then
  FIND_MTIME="-mtime -${DAYS_FILTER}"
fi

# Collect all candidate .md files
ALL_FILES=$(find "${SEARCH_PATHS[@]}" -name "*.md" $FIND_MTIME 2>/dev/null | sort)

if [ -z "$ALL_FILES" ]; then
  echo "[]"
  exit 0
fi

# Score each file
python3 - <<PYEOF
import os, re, json
from datetime import datetime, timezone
from pathlib import Path

vault = "$VAULT"
query = """$QUERY"""
keywords = [k.lower() for k in """${KEYWORDS[*]}""".split() if k]
section_filter = """$SECTION_FILTER""".lower()
project_filter = """$PROJECT_FILTER""".lower()
recency_only = "$RECENCY_ONLY" == "true"

files_raw = """$ALL_FILES"""
files = [f for f in files_raw.strip().split('\n') if f.strip() and f.endswith('.md')]

now = datetime.now(timezone.utc).timestamp()
results = []

for filepath in files:
    try:
        stat = os.stat(filepath)
        mtime = stat.st_mtime
        age_days = (now - mtime) / 86400
    except:
        continue

    try:
        content = Path(filepath).read_text(errors='ignore')
    except:
        continue

    content_lower = content.lower()

    if project_filter:
        if project_filter not in content_lower and project_filter not in filepath.lower():
            continue

    search_content = content_lower
    if section_filter:
        pattern = rf'## {re.escape(section_filter)}.*?(?=\n## |\Z)'
        m = re.search(pattern, content_lower, re.DOTALL)
        search_content = m.group(0) if m else ''
        if not search_content:
            continue

    exact_match = query.lower() in search_content
    all_kw_match = all(kw in search_content for kw in keywords) if keywords else False
    kw_hits = sum(search_content.count(kw) for kw in keywords) if keywords else 0
    any_kw_match = kw_hits > 0

    if not (exact_match or all_kw_match or any_kw_match):
        continue

    best_section = ''
    best_excerpt = ''
    best_section_score = 0

    lines = content.split('\n')
    current_section = ''
    for i, line in enumerate(lines):
        if line.startswith('## '):
            current_section = line.strip()

        line_lower = line.lower()
        hit = (query.lower() in line_lower) or any(kw in line_lower for kw in keywords)
        if not hit:
            continue

        sec_lower = current_section.lower()
        if 'decisions made' in sec_lower:
            sec_score = 3
        elif 'tasks completed' in sec_lower:
            sec_score = 2
        elif 'session log' in sec_lower:
            sec_score = 1
        else:
            sec_score = 0

        if sec_score > best_section_score or not best_excerpt:
            best_section_score = sec_score
            best_section = current_section
            excerpt = line.strip()
            if i + 1 < len(lines) and lines[i+1].strip():
                excerpt += ' ' + lines[i+1].strip()
            best_excerpt = excerpt[:180]

    if age_days <= 7:
        recency_score = 3
    elif age_days <= 30:
        recency_score = 2
    elif age_days <= 90:
        recency_score = 1
    else:
        recency_score = 0

    density = min(kw_hits, 10) / 10 * 3

    if exact_match:
        confidence = 3
    elif all_kw_match:
        confidence = 2
    else:
        confidence = 1

    total_score = recency_score + density + best_section_score + confidence

    fname = os.path.basename(filepath)
    date_match = re.match(r'(\d{4}-\d{2}-\d{2})', fname)
    file_date = date_match.group(1) if date_match else datetime.fromtimestamp(mtime).strftime('%Y-%m-%d')

    try:
        rel_path = os.path.relpath(filepath, vault)
    except:
        rel_path = filepath

    results.append({
        'score': total_score,
        'date': file_date,
        'file': rel_path,
        'filepath': filepath,
        'section': best_section,
        'excerpt': best_excerpt,
        'confidence': confidence,
        'recency_score': recency_score,
        'mtime': mtime
    })

if recency_only:
    results.sort(key=lambda x: x['mtime'], reverse=True)
    results = results[:1]
else:
    results.sort(key=lambda x: (x['score'], x['mtime']), reverse=True)

print(json.dumps(results[:20]))
PYEOF
