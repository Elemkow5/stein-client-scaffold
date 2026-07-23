#!/usr/bin/env node
// PreToolUse:Read hook — surgical context injection.
// When a .md file is read that mentions a known project or topic,
// injects that context page via <project_context> tags.
// Silent when no match found.

'use strict';

const fs = require('fs');
const path = require('path');

const VAULT = path.resolve(__dirname, '../..');
const INDEX_PATH = path.join(VAULT, '.claude/staging/context-index.json');
const MAX_MATCHES = 2;
const SCAN_CHARS = 2000;
const TRIM_CHARS = 1500;

function main() {
  let input = '';
  try {
    input = fs.readFileSync('/dev/stdin', 'utf8');
  } catch (e) {
    out({ continue: true });
    return;
  }

  let payload;
  try {
    payload = JSON.parse(input);
  } catch (e) {
    out({ continue: true });
    return;
  }

  const filePath = payload?.tool_input?.file_path || '';
  if (!filePath || !filePath.endsWith('.md')) {
    out({ continue: true });
    return;
  }

  // Load index
  let index;
  try {
    index = JSON.parse(fs.readFileSync(INDEX_PATH, 'utf8'));
  } catch (e) {
    out({ continue: true });
    return;
  }

  // Skip files that are themselves context files (avoid circular injection)
  const indexValues = new Set(Object.values(index).map(v => v.toLowerCase()));
  const relFilePath = filePath.replace(VAULT + '/', '').toLowerCase();
  if (indexValues.has(relFilePath)) {
    out({ continue: true });
    return;
  }

  // Extract [[wikilinks]] and **bold names** from the file's first SCAN_CHARS
  let wikilinks = new Set();
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    const head = content.slice(0, SCAN_CHARS);
    for (const m of (head.match(/\[\[([^\]|]+)/g) || [])) {
      wikilinks.add(m.slice(2).trim().toLowerCase());
    }
    for (const m of (head.match(/\*\*([^*]+)\*\*/g) || [])) {
      wikilinks.add(m.slice(2, -2).trim().toLowerCase());
    }
  } catch (e) {
    out({ continue: true });
    return;
  }

  // Match wikilinks against index (longest name first to prefer specific matches)
  const names = Object.keys(index).sort((a, b) => b.length - a.length);
  const matched = [];
  const seen = new Set();

  for (const name of names) {
    if (matched.length >= MAX_MATCHES) break;
    if (wikilinks.has(name.toLowerCase())) {
      const target = index[name];
      if (seen.has(target)) continue;
      seen.add(target);
      matched.push({ name, target });
    }
  }

  if (matched.length === 0) {
    out({ continue: true });
    return;
  }

  // Load matched context files and build injection blocks
  const blocks = [];
  for (const { name, target } of matched) {
    const fullPath = path.join(VAULT, target);
    let content;
    try {
      content = fs.readFileSync(fullPath, 'utf8');
    } catch (e) {
      continue;
    }
    if (content.length > TRIM_CHARS) {
      content = content.slice(0, TRIM_CHARS) + '\n...[truncated]';
    }
    blocks.push(`<project_context name="${name}" file="${target}">\n${content}\n</project_context>`);
  }

  if (blocks.length === 0) {
    out({ continue: true });
    return;
  }

  out({
    continue: true,
    hookSpecificOutput: {
      hookEventName: 'PreToolUse',
      additionalContext: blocks.join('\n\n')
    }
  });
}

function out(obj) {
  process.stdout.write(JSON.stringify(obj));
}

main();
