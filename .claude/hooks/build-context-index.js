#!/usr/bin/env node
// Builds the context injection index from Brain/Projects/ and Brain/Session_Logs/.
// Output: .claude/staging/context-index.json (per-vault, no global state)
// Run at session start by session-start.sh.

const fs = require('fs');
const path = require('path');

const VAULT = path.resolve(__dirname, '../..');
const OUTPUT = path.join(VAULT, '.claude/staging/context-index.json');
const PROJECTS_DIR = path.join(VAULT, 'Brain/Projects');
const SESSIONS_DIR = path.join(VAULT, 'Brain/Session_Logs');

const SKIP_NAMES = new Set(['_template', 'README']);

const index = {};
const stats = { projects: 0, sessions: 0 };

// --- Brain/Projects/ ---
// Each subfolder is a project. Index it by folder name and human-readable name.
try {
  const entries = fs.readdirSync(PROJECTS_DIR, { withFileTypes: true });
  for (const e of entries) {
    if (!e.isDirectory()) continue;
    if (SKIP_NAMES.has(e.name)) continue;
    const name = e.name.replace(/_/g, ' ');
    const projectMd = path.join(PROJECTS_DIR, e.name, 'Project.md');
    const target = fs.existsSync(projectMd)
      ? `Brain/Projects/${e.name}/Project.md`
      : `Brain/Projects/${e.name}`;
    index[name] = target;
    if (e.name !== name) index[e.name] = target;
    stats.projects++;
  }
} catch (e) {}

// --- Brain/Session_Logs/ — extract high-frequency [[wikilinks]] ---
// Topics mentioned 3+ times across last 30 days of sessions get indexed.
try {
  const cutoff = Date.now() - 30 * 24 * 60 * 60 * 1000;
  const sessionFiles = fs.readdirSync(SESSIONS_DIR)
    .filter(f => f.endsWith('.md'))
    .map(f => ({ f, mtime: fs.statSync(path.join(SESSIONS_DIR, f)).mtimeMs }))
    .filter(({ mtime }) => mtime > cutoff)
    .map(({ f }) => f);

  const freq = {};
  for (const f of sessionFiles) {
    const content = fs.readFileSync(path.join(SESSIONS_DIR, f), 'utf8');
    const links = content.match(/\[\[([^\]]+)\]\]/g) || [];
    for (const link of links) {
      const name = link.slice(2, -2).split('|')[0].trim();
      freq[name] = (freq[name] || 0) + 1;
    }
  }

  for (const [name, count] of Object.entries(freq)) {
    if (count < 3) continue;
    if (index[name]) continue; // already covered by Projects
    const projectPath = path.join(PROJECTS_DIR, name, 'Project.md');
    const projectPathUS = path.join(PROJECTS_DIR, name.replace(/ /g, '_'), 'Project.md');
    if (fs.existsSync(projectPath)) {
      index[name] = `Brain/Projects/${name}/Project.md`;
      stats.sessions++;
    } else if (fs.existsSync(projectPathUS)) {
      const folderName = name.replace(/ /g, '_');
      index[name] = `Brain/Projects/${folderName}/Project.md`;
      stats.sessions++;
    }
  }
} catch (e) {}

// Write output
fs.mkdirSync(path.dirname(OUTPUT), { recursive: true });
fs.writeFileSync(OUTPUT, JSON.stringify(index, null, 2));

const total = Object.keys(index).length;
process.stdout.write(
  `[context-index] Built: ${total} entries ` +
  `(${stats.projects} projects, ${stats.sessions} from session logs)\n`
);
