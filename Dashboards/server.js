#!/usr/bin/env node
// Client AI System — Dashboard Server
// Mother dashboard + sub-dashboards. Client never needs to open Obsidian.
// All actions (task toggle, inbox process, people notes) write back to vault files.

'use strict';

const http = require('http');
const fs   = require('fs');
const path = require('path');

const PORT  = 7272;
const VAULT = path.resolve(__dirname, '..');

// ── Vault paths ───────────────────────────────────────────────────────────────

const P = {
  master:       path.join(VAULT, 'Brain/Master.md'),
  inbox:        path.join(VAULT, 'Brain/Inbox.md'),
  projects:     path.join(VAULT, 'Brain/Projects'),
  goals:        path.join(VAULT, 'Brain/Goals'),
  people:       path.join(VAULT, 'Brain/People'),
  knowledge:    path.join(VAULT, 'Brain/Knowledge'),
  skills:       path.join(VAULT, '.claude/skills'),
  name_file:    path.join(VAULT, 'Personality'),
  daily:        path.join(VAULT, 'Brain/Daily'),
  session_logs: path.join(VAULT, 'Brain/Session_Logs'),
  integrations: path.join(VAULT, 'System/integrations.yaml'),
};

// ── Nav registry ──────────────────────────────────────────────────────────────

const NAV = [
  { path: '/',        label: 'Home',        icon: '⬡' },
  { path: '/daily',   label: 'Daily Brief', icon: '☀' },
  { path: '/board',   label: 'Board',       icon: '☰' },
  { path: '/inbox',   label: 'Inbox',       icon: '⊡' },
  { path: '/library', label: 'Library',     icon: '◫' },
];

const LIBRARY_SUBNAV = [
  { path: '/library/artifacts', label: 'Artifacts', icon: '⬕' },
  { path: '/library/people',    label: 'People',    icon: '◎' },
  { path: '/library/projects',  label: 'Projects',  icon: '◻' },
  { path: '/library/knowledge', label: 'Knowledge', icon: '≡' },
  { path: '/library/skills',    label: 'Skills',    icon: '⌘' },
];

// ── Utilities ─────────────────────────────────────────────────────────────────

function esc(s) {
  return String(s || '')
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

function readFile(p)          { try { return fs.readFileSync(p, 'utf8'); }  catch { return null; } }
function writeFile(p, content){ try { fs.writeFileSync(p, content, 'utf8'); return true; } catch { return false; } }
function readDir(p)           { try { return fs.readdirSync(p); }           catch { return []; } }
function isDir(p)             { try { return fs.statSync(p).isDirectory(); } catch { return false; } }
function fileStat(p)          { try { return fs.statSync(p); }              catch { return null; } }

function todayISO() {
  return new Date().toISOString().slice(0, 10);
}

function dateISO(d) {
  return d.toISOString().slice(0, 10);
}

function shiftDate(iso, days) {
  const d = new Date(iso + 'T12:00:00');
  d.setDate(d.getDate() + days);
  return dateISO(d);
}

function formatDateLong(iso) {
  return new Date(iso + 'T12:00:00').toLocaleDateString('en-US', {
    weekday: 'long', month: 'long', day: 'numeric', year: 'numeric'
  });
}

function formatDateShort(iso) {
  return new Date(iso + 'T12:00:00').toLocaleDateString('en-US', {
    month: 'short', day: 'numeric', year: 'numeric'
  });
}

function todayLong() {
  return new Date().toLocaleDateString('en-US', {
    weekday: 'long', year: 'numeric', month: 'long', day: 'numeric'
  });
}

function clientName() {
  for (const f of readDir(P.name_file)) {
    if (f === 'Mistake_Patterns.md' || f === 'Working_Preferences.md' || f === 'Priorities.yaml') continue;
    if (!f.endsWith('.md')) continue;
    const content = readFile(path.join(P.name_file, f));
    if (!content) continue;
    const m = content.match(/^# (.+)/m);
    if (m) {
      const name = m[1].replace(/\s*[—–-].+$/, '').trim();
      if (name && name !== '[Name]') return name;
    }
  }
  return 'Client';
}

function inboxCount() {
  const c = readFile(P.inbox);
  return c ? (c.match(/^- /mg) || []).length : 0;
}

function digestTime() {
  const yaml = readFile(P.integrations);
  if (!yaml) return '7:30 AM';
  const m = yaml.match(/time:\s*"?([^"\n]+)"?/);
  return m ? m[1].trim() : '7:30 AM';
}

function mdToHtml(md) {
  if (!md) return '<p class="empty">Nothing here yet.</p>';
  const lines = md.split('\n');
  const out = [];
  let inList = false;
  for (const raw of lines) {
    const line = raw.trimEnd();
    if (line.startsWith('# '))    { closeList(); out.push('<h1>' + esc(line.slice(2))  + '</h1>'); continue; }
    if (line.startsWith('## '))   { closeList(); out.push('<h2>' + esc(line.slice(3))  + '</h2>'); continue; }
    if (line.startsWith('### '))  { closeList(); out.push('<h3>' + esc(line.slice(4))  + '</h3>'); continue; }
    if (line.startsWith('#### ')) { closeList(); out.push('<h4>' + esc(line.slice(5))  + '</h4>'); continue; }
    if (line.match(/^---+$/) || line.match(/^\*\*\*+$/)) { closeList(); out.push('<hr>'); continue; }
    if (line.match(/^- \[x\]/i)) { openList(); out.push('<li class="task done"><span class="cb checked">✓</span>' + fmt(line.replace(/^- \[x\]\s*/i, '')) + '</li>'); continue; }
    if (line.match(/^- \[ \]/))  { openList(); out.push('<li class="task"><span class="cb"></span>' + fmt(line.replace(/^- \[ \]\s*/, '')) + '</li>'); continue; }
    if (line.match(/^[-*] /))    { openList(); out.push('<li>' + fmt(line.replace(/^[-*] /, '')) + '</li>'); continue; }
    closeList();
    if (line === '') { out.push('<p class="spacer"></p>'); continue; }
    out.push('<p>' + fmt(line) + '</p>');
  }
  closeList();
  return out.join('\n');

  function openList()  { if (!inList) { out.push('<ul>'); inList = true; } }
  function closeList() { if (inList)  { out.push('</ul>'); inList = false; } }
}

function fmt(s) {
  return esc(s)
    .replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>')
    .replace(/\*([^*]+)\*/g,     '<em>$1</em>')
    .replace(/`([^`]+)`/g,       '<code>$1</code>')
    .replace(/\[\[([^\]]+)\]\]/g,'<span class="wikilink">$1</span>');
}

// ── Layout ────────────────────────────────────────────────────────────────────

function layout(title, activePath, bodyHtml) {
  const name      = clientName();
  const ibCount   = inboxCount();
  const inLibrary = activePath.startsWith('/library');

  const navHtml = NAV.map(d => {
    const isActive = activePath === d.path || (d.path !== '/' && activePath.startsWith(d.path));
    const badge    = d.path === '/inbox' && ibCount > 0 ? `<span class="nav-badge">${ibCount}</span>` : '';
    return `<a href="${d.path}" class="nav-item${isActive ? ' active' : ''}">${d.icon} ${d.label}${badge}</a>`;
  }).join('\n');

  const subnavHtml = inLibrary ? `<div class="subnav">${
    LIBRARY_SUBNAV.map(s =>
      `<a href="${s.path}" class="subnav-item${activePath === s.path ? ' active' : ''}">${s.icon} ${s.label}</a>`
    ).join('\n')
  }</div>` : '';

  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${esc(title)} — ${esc(name)}</title>
  <link rel="stylesheet" href="/styles.css">
</head>
<body>
  <aside class="sidebar">
    <div class="sidebar-top">
      <div class="sidebar-name">${esc(name)}</div>
      <div class="sidebar-label">AI System</div>
    </div>
    <nav>${navHtml}</nav>
    ${subnavHtml}
    <div class="sidebar-footer"><span class="today-date">${todayLong()}</span></div>
  </aside>
  <main class="content">
    <div class="page-header"><h1 class="page-title">${esc(title)}</h1></div>
    <div class="page-body">${bodyHtml}</div>
  </main>
</body>
</html>`;
}

// ── Home ──────────────────────────────────────────────────────────────────────

function handleHome(req, res) {
  const name = clientName();
  let html = '';

  // Active Now — last 5 session log entries from today
  const sessionLog = readFile(path.join(P.session_logs, todayISO() + '.md'));
  const active = parseActiveNow(sessionLog);

  html += `<div class="home-active">
    <div class="home-active-label">⚡ Active Now</div>`;
  if (active.length > 0) {
    html += `<div class="active-items">`;
    for (const item of active) {
      html += `<div class="active-item">
        <span class="active-time">${esc(item.time)}</span>
        <span class="active-text">${esc(item.text)}</span>
      </div>`;
    }
    html += `</div>`;
  } else {
    html += `<p class="active-empty">No session activity yet today.</p>`;
  }
  html += `</div>`;

  // Nav cards
  const ibCount = inboxCount();
  const cards = [
    { path: '/daily',   icon: '☀', label: 'Daily Brief', desc: "Today's digest — calendar, tasks, priorities, email" },
    { path: '/board',   icon: '☰', label: 'Board',       desc: 'Master task board — open items across all projects' },
    { path: '/inbox',   icon: '⊡', label: 'Inbox',       desc: `${ibCount} item${ibCount !== 1 ? 's' : ''} waiting` },
    { path: '/library', icon: '◫', label: 'Library',     desc: 'Artifacts, people, projects, knowledge, skills' },
  ];

  html += `<div class="home-nav">`;
  for (const c of cards) {
    html += `<a href="${c.path}" class="home-card">
      <div class="home-card-icon">${c.icon}</div>
      <div class="home-card-label">${c.label}</div>
      <div class="home-card-desc">${esc(c.desc)}</div>
    </a>`;
  }
  html += `</div>`;

  send(res, 200, layout('Good morning, ' + name + '.', '/', html));
}

function parseActiveNow(content) {
  if (!content) return [];
  const items = [];
  for (const line of content.split('\n')) {
    const m = line.match(/^\*\*\[(\d{1,2}:\d{2})\]\*\*\s+(.+)/);
    if (m) items.push({ time: m[1], text: m[2].replace(/\[\[([^\]]+)\]\]/g, '$1').slice(0, 100) });
  }
  return items.slice(-5).reverse();
}

// ── Daily Brief ───────────────────────────────────────────────────────────────

function handleDaily(req, res, query) {
  const date    = query.date || todayISO();
  const isToday = date === todayISO();
  const content = readFile(path.join(P.daily, date + '.md'));
  const prevD   = shiftDate(date, -1);
  const nextD   = shiftDate(date,  1);
  const hasPrev = !!readFile(path.join(P.daily, prevD + '.md'));
  const hasNext = !isToday && !!readFile(path.join(P.daily, nextD + '.md'));

  let html = `<div class="date-nav">
    ${hasPrev ? `<a href="/daily?date=${prevD}" class="date-btn">← ${prevD}</a>` : '<span class="date-btn disabled">←</span>'}
    <span class="date-current">${esc(formatDateLong(date))}</span>
    ${hasNext ? `<a href="/daily?date=${nextD}" class="date-btn">${nextD} →</a>` : '<span class="date-btn disabled">→</span>'}
  </div>`;

  if (content) {
    html += `<div class="digest-body">${mdToHtml(content)}</div>`;
  } else if (isToday) {
    html += `<div class="digest-empty">
      <div class="digest-empty-icon">☀</div>
      <div class="digest-empty-title">No digest yet for today</div>
      <div class="digest-empty-sub">Scheduled to run at ${esc(digestTime())}. For it now, open Claude Code and run <code>/daily</code>.</div>
    </div>`;
  } else {
    html += `<div class="digest-empty">
      <div class="digest-empty-icon">◌</div>
      <div class="digest-empty-title">No digest for ${esc(date)}</div>
    </div>`;
  }

  send(res, 200, layout('Daily Brief', '/daily', html));
}

// ── Board ─────────────────────────────────────────────────────────────────────

function handleBoard(req, res) {
  const content = readFile(P.master);
  if (!content) {
    send(res, 200, layout('Board', '/board', '<p class="empty">Brain/Master.md not found.</p>'));
    return;
  }

  const sections = parseMasterSections(content);
  let html = '<div class="master-board">';

  const allTagSet = new Set();
  for (const s of sections)
    for (const t of allTasksFlat(s)) {
      const m = t.text.match(/\[([A-Za-z0-9_]+)\]/g);
      if (m) m.forEach(x => allTagSet.add(x.slice(1, -1)));
    }

  if (allTagSet.size > 0) {
    html += '<div class="filter-bar"><span class="filter-label">Filter:</span>';
    for (const tag of allTagSet)
      html += `<button class="filter-chip" onclick="filterByTag('${esc(tag)}')">${esc(tag)}</button>`;
    html += '<button class="filter-chip clear" onclick="clearFilter()">✕ Clear</button></div>';
  }

  for (const section of sections) {
    html += `<div class="master-section">
      <div class="master-section-title">${esc(section.title)}</div>`;
    for (const info of section.info)
      html += `<div class="section-info">${fmt(info)}</div>`;
    if (section.tasks.length) html += renderTasks(section.tasks);
    for (const sub of section.subsections) {
      html += `<div class="master-subsection">
        <div class="master-subsection-title">${esc(sub.title)}</div>
        ${renderTasks(sub.tasks)}
      </div>`;
    }
    if (!allTasksFlat(section).length) html += '<p class="empty">Nothing here.</p>';
    html += `</div>`;
  }

  html += `</div>
  <script>
    function toggleTask(text, isNowChecked) {
      fetch('/api/task/toggle', {
        method: 'POST',
        headers: {'Content-Type':'application/json'},
        body: JSON.stringify({text, done: isNowChecked})
      });
    }
    function filterByTag(tag) {
      document.querySelectorAll('.task-item').forEach(el => {
        el.style.display = el.dataset.tags && el.dataset.tags.includes(tag) ? '' : 'none';
      });
    }
    function clearFilter() {
      document.querySelectorAll('.task-item').forEach(el => el.style.display = '');
    }
  </script>`;

  send(res, 200, layout('Board', '/board', html));
}

function renderTasks(tasks) {
  if (!tasks.length) return '';
  const sorted = [...tasks.filter(t => !t.done), ...tasks.filter(t => t.done)];
  return '<ul class="task-list">' + sorted.map(t => {
    const tags = (t.text.match(/\[([A-Za-z0-9_]+)\]/g) || []).map(x => x.slice(1,-1)).join(',');
    const safeText = t.text.replace(/\\/g,'\\\\').replace(/'/g,"\\'");
    return `<li class="task-item${t.done ? ' done' : ''}" data-tags="${esc(tags)}">
      <span class="cb${t.done ? ' checked' : ''}" onclick="
        const done = !this.classList.contains('checked');
        this.classList.toggle('checked');
        this.closest('.task-item').classList.toggle('done');
        toggleTask('${safeText}', done);
      "></span>
      <span class="task-text">${fmt(t.text)}</span>
    </li>`;
  }).join('') + '</ul>';
}

// ── Inbox ─────────────────────────────────────────────────────────────────────

function handleInbox(req, res) {
  const content = readFile(P.inbox);
  const items   = (content || '').split('\n').filter(l => l.match(/^- /)).map(l => l.replace(/^- /, '').trim()).filter(Boolean);

  let html = '';
  if (!items.length) {
    html = '<p class="empty">Inbox is clear. Drop files into your AI Inbox folder or run <code>/capture</code> to add items.</p>';
  } else {
    html += `<div class="inbox-header">${items.length} item${items.length !== 1 ? 's' : ''}</div>
    <div class="inbox-list">`;
    for (const item of items) {
      const safe = item.replace(/\\/g,'\\\\').replace(/'/g,"\\'");
      html += `<div class="inbox-item">
        <span class="inbox-text">${fmt(item)}</span>
        <button class="inbox-done-btn" onclick="processItem('${safe}', this)">Done ✓</button>
      </div>`;
    }
    html += `</div>`;
  }

  html += `<script>
    function processItem(text, btn) {
      btn.disabled = true;
      const row = btn.closest('.inbox-item');
      row.style.opacity = '0.4';
      fetch('/api/inbox/process', {
        method: 'POST',
        headers: {'Content-Type':'application/json'},
        body: JSON.stringify({text})
      }).then(r => r.json()).then(d => {
        if (d.ok) {
          row.remove();
          const remaining = document.querySelectorAll('.inbox-item').length;
          const hdr = document.querySelector('.inbox-header');
          if (hdr) hdr.textContent = remaining + ' item' + (remaining !== 1 ? 's' : '');
        }
      });
    }
  </script>`;

  send(res, 200, layout('Inbox', '/inbox', html));
}

// ── Library Hub ───────────────────────────────────────────────────────────────

function handleLibraryHub(req, res) {
  const artifactCount  = scanArtifacts().length;
  const peopleCount    = readDir(P.people).filter(f => f.endsWith('.md') && !f.startsWith('_')).length;
  const projectCount   = readDir(P.projects).filter(f => isDir(path.join(P.projects, f)) && !f.startsWith('_')).length;
  const knowledgeCount = readDir(P.knowledge).filter(f => f.endsWith('.md') && !f.startsWith('_')).length;

  const cards = [
    { path: '/library/artifacts', icon: '⬕', label: 'Artifacts', count: artifactCount,  desc: 'Decks, trackers, reports, and HTML outputs' },
    { path: '/library/people',    icon: '◎', label: 'People',    count: peopleCount,    desc: 'Key contacts, relationship context, open items' },
    { path: '/library/projects',  icon: '◻', label: 'Projects',  count: projectCount,   desc: 'Active projects and deliverables' },
    { path: '/library/knowledge', icon: '≡', label: 'Knowledge', count: knowledgeCount, desc: 'Ingested documents, research, and reference' },
    { path: '/library/skills',    icon: '⌘', label: 'Skills',    count: null,           desc: 'Every command and when to use it' },
  ];

  const html = `<div class="library-hub">${cards.map(c => `
    <a href="${c.path}" class="library-hub-card">
      <div class="lib-hub-icon">${c.icon}</div>
      <div class="lib-hub-label">${c.label}</div>
      ${c.count !== null ? `<div class="lib-hub-count">${c.count}</div>` : ''}
      <div class="lib-hub-desc">${esc(c.desc)}</div>
    </a>`).join('')}</div>`;

  send(res, 200, layout('Library', '/library', html));
}

// ── Library: Artifacts ────────────────────────────────────────────────────────

function handleLibraryArtifacts(req, res) {
  const artifacts = scanArtifacts();
  let html = '';

  if (!artifacts.length) {
    html = '<p class="empty">No artifacts yet. HTML outputs built during sessions will appear here.</p>';
  } else {
    const byProject = {};
    for (const a of artifacts) {
      if (!byProject[a.project]) byProject[a.project] = [];
      byProject[a.project].push(a);
    }
    for (const [project, items] of Object.entries(byProject)) {
      html += `<section class="dash-section">
        <h2 class="section-title">${esc(project)}</h2>
        <div class="artifact-grid">${items.map(a => `
          <a href="/artifact?path=${encodeURIComponent(a.relPath)}" class="artifact-card" target="_blank">
            <div class="artifact-icon">⬕</div>
            <div class="artifact-name">${esc(a.name)}</div>
            ${a.description ? `<div class="artifact-desc">${esc(a.description)}</div>` : ''}
            <div class="artifact-meta">${esc(a.date)}</div>
          </a>`).join('')}
        </div>
      </section>`;
    }
  }
  send(res, 200, layout('Artifacts', '/library/artifacts', html));
}

function scanArtifacts() {
  const results = [];
  const projectDirs = readDir(P.projects).filter(f => isDir(path.join(P.projects, f)) && !f.startsWith('_'));
  for (const proj of projectDirs) {
    const artifactsDir = path.join(P.projects, proj, 'Artifacts');
    if (!isDir(artifactsDir)) continue;
    const indexContent = readFile(path.join(artifactsDir, 'INDEX.md'));
    for (const f of readDir(artifactsDir).filter(f => f.endsWith('.html'))) {
      const fullPath = path.join(artifactsDir, f);
      const stat     = fileStat(fullPath);
      const date     = stat ? stat.mtime.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }) : '';
      let description = '';
      if (indexContent) {
        const base = f.replace('.html', '');
        const m = indexContent.match(new RegExp('\\|[^|]*' + base.replace(/[.*+?^${}()|[\]\\]/g,'\\$&') + '[^|]*\\|[^|]*\\|\\s*([^|\\n]+)'));
        if (m) description = m[1].trim();
      }
      results.push({
        project:     proj.replace(/_/g, ' '),
        name:        f.replace('.html', '').replace(/-/g, ' '),
        relPath:     'Brain/Projects/' + proj + '/Artifacts/' + f,
        description, date, fullPath,
      });
    }
  }
  return results.sort((a, b) => b.date.localeCompare(a.date));
}

// ── Library: People ───────────────────────────────────────────────────────────

function handleLibraryPeople(req, res, query) {
  if (query.file) return handlePersonDetail(req, res, query.file);

  const people = scanPeople();
  let html = '';
  if (!people.length) {
    html = '<p class="empty">No people files yet. Created automatically from email and calendar, or during /setup.</p>';
  } else {
    html = `<div class="people-grid">${people.map(p => `
      <a href="/library/people?file=${encodeURIComponent(p.relPath)}" class="person-card">
        <div class="person-name">${esc(p.name)}</div>
        ${p.role    ? `<div class="person-role">${esc(p.role)}</div>`       : ''}
        ${p.company ? `<div class="person-company">${esc(p.company)}</div>` : ''}
        ${p.openItems.length ? `<div class="person-open">${p.openItems.length} open item${p.openItems.length !== 1 ? 's' : ''}</div>` : ''}
        ${p.lastDate ? `<div class="person-last">Last: ${esc(p.lastDate)}</div>` : ''}
      </a>`).join('')}</div>`;
  }
  send(res, 200, layout('People', '/library/people', html));
}

function handlePersonDetail(req, res, relPath) {
  if (relPath.includes('..') || !relPath.startsWith('Brain/People/')) { send(res, 400, 'Invalid path'); return; }
  const content = readFile(path.join(VAULT, relPath));
  if (!content) { send(res, 404, 'Person not found'); return; }
  const name = path.basename(relPath, '.md').replace(/_/g, ' ');
  const safeRelPath = esc(relPath);
  const html = `
    <div class="doc-actions"><a href="/library/people" class="btn-back">← People</a></div>
    <div class="doc-body">${mdToHtml(content)}</div>
    <div class="person-note-form">
      <div class="note-form-label">Add a note</div>
      <textarea id="note-input" placeholder="What happened? What's open?" rows="3"></textarea>
      <button onclick="addNote()">Save note</button>
      <span id="note-status" class="note-status"></span>
    </div>
    <script>
      function addNote() {
        const note = document.getElementById('note-input').value.trim();
        const status = document.getElementById('note-status');
        if (!note) return;
        fetch('/api/people/note', {
          method: 'POST',
          headers: {'Content-Type':'application/json'},
          body: JSON.stringify({relPath: '${safeRelPath}', note})
        }).then(r => r.json()).then(d => {
          if (d.ok) { status.textContent = 'Saved.'; setTimeout(() => location.reload(), 800); }
          else status.textContent = 'Error: ' + d.error;
        });
      }
    </script>`;
  send(res, 200, layout(name, '/library/people', html));
}

function scanPeople() {
  return readDir(P.people)
    .filter(f => f.endsWith('.md') && !f.startsWith('_'))
    .map(f => {
      const content = readFile(path.join(P.people, f));
      const name    = f.replace(/\.md$/, '').replace(/_/g, ' ');
      let role = '', company = '', lastDate = '';
      const openItems = [];
      if (content) {
        const rm = content.match(/\*\*Role[:\*]*\*?\*?\s*(.+)/i);
        if (rm) role = rm[1].replace(/\*+/g,'').trim().slice(0,60);
        const cm = content.match(/\*\*Company[:\*]*\*?\*?\s*(.+)/i);
        if (cm) company = cm[1].replace(/\*+/g,'').trim().slice(0,60);
        const dates = content.match(/## (\d{4}-\d{2}-\d{2})/g);
        if (dates) lastDate = dates[dates.length - 1].replace('## ','');
        let inOpen = false;
        for (const line of content.split('\n')) {
          if (/open items/i.test(line) && line.startsWith('#')) { inOpen = true; continue; }
          if (line.startsWith('#') && inOpen) { inOpen = false; continue; }
          if (inOpen && line.match(/^- \[ \]/)) openItems.push(line.replace(/^- \[ \]\s*/, '').trim());
        }
      }
      return { name, role, company, lastDate, openItems, relPath: 'Brain/People/' + f };
    })
    .sort((a, b) => a.name.localeCompare(b.name));
}

// ── Library: Projects ─────────────────────────────────────────────────────────

function handleLibraryProjects(req, res, query) {
  if (query.file) {
    const relPath = query.file;
    if (relPath.includes('..') || !relPath.startsWith('Brain/Projects/')) { send(res, 400, 'Invalid'); return; }
    const content = readFile(path.join(VAULT, relPath));
    if (!content) { send(res, 404, 'Not found'); return; }
    const name = path.basename(path.dirname(relPath)).replace(/_/g, ' ');
    const html = `<div class="doc-actions"><a href="/library/projects" class="btn-back">← Projects</a></div><div class="doc-body">${mdToHtml(content)}</div>`;
    send(res, 200, layout(name, '/library/projects', html));
    return;
  }

  const projects = readDir(P.projects)
    .filter(f => isDir(path.join(P.projects, f)) && !f.startsWith('_'))
    .map(d => {
      const content  = readFile(path.join(P.projects, d, 'Project.md'));
      let status = '', next = '';
      if (content) {
        const sm = content.match(/\*\*Status[:\*]*\*?\*?\s*(.+)/i);
        if (sm) status = sm[1].replace(/\*+/g,'').replace(/<!--.+?-->/g,'').trim().slice(0,60);
        const nm = content.match(/^- \[ \] (.+)/m);
        if (nm) next = nm[1].trim().slice(0,80);
      }
      return { name: d.replace(/_/g,' '), status, next, relPath: 'Brain/Projects/' + d + '/Project.md' };
    });

  let html = '';
  if (!projects.length) {
    html = '<p class="empty">No projects yet. Created during /setup or when you start a new initiative.</p>';
  } else {
    html = `<div class="card-grid">${projects.map(p => `
      <a href="/library/projects?file=${encodeURIComponent(p.relPath)}" class="card card-link">
        <div class="card-title">${esc(p.name)}</div>
        ${p.status ? `<div class="card-meta">${esc(p.status)}</div>` : ''}
        ${p.next   ? `<div class="card-next">→ ${esc(p.next)}</div>` : ''}
      </a>`).join('')}</div>`;
  }
  send(res, 200, layout('Projects', '/library/projects', html));
}

// ── Library: Knowledge ────────────────────────────────────────────────────────

function handleLibraryKnowledge(req, res, query) {
  if (query.file) {
    const relPath = query.file;
    if (relPath.includes('..') || !relPath.startsWith('Brain/Knowledge/')) { send(res, 400, 'Invalid'); return; }
    const content = readFile(path.join(VAULT, relPath));
    if (!content) { send(res, 404, 'Not found'); return; }
    const title = path.basename(relPath, '.md').replace(/-/g, ' ');
    const html = `<div class="doc-actions"><a href="/library/knowledge" class="btn-back">← Knowledge</a></div><div class="doc-body">${mdToHtml(content)}</div>`;
    send(res, 200, layout(title, '/library/knowledge', html));
    return;
  }

  const files = readDir(P.knowledge).filter(f => f.endsWith('.md') && !f.startsWith('_'));
  let html = '';
  if (!files.length) {
    html = '<p class="empty">No knowledge files yet. Drop documents into your AI Inbox folder and they\'ll appear here after ingestion.</p>';
  } else {
    html = '<div class="library-list">' + files.sort().reverse().map(f => {
      const content     = readFile(path.join(P.knowledge, f));
      const displayName = f.replace(/\.md$/, '').replace(/-/g, ' ');
      const summary     = content ? content.split('\n').find(l => l.trim() && !l.startsWith('#'))?.trim().slice(0,120) || '' : '';
      const stat        = fileStat(path.join(P.knowledge, f));
      const date        = stat ? stat.mtime.toLocaleDateString('en-US', { month:'short', day:'numeric', year:'numeric' }) : '';
      return `<div class="library-item">
        <div style="flex:1">
          <div class="library-item-name">${esc(displayName)}</div>
          ${summary ? `<div class="library-item-summary">${esc(summary)}</div>` : ''}
        </div>
        <div class="library-item-meta">${esc(date)}</div>
        <div class="library-item-actions">
          <a href="/library/knowledge?file=${encodeURIComponent('Brain/Knowledge/' + f)}" class="lib-btn">View</a>
        </div>
      </div>`;
    }).join('') + '</div>';
  }
  send(res, 200, layout('Knowledge', '/library/knowledge', html));
}

// ── Library: Skills ───────────────────────────────────────────────────────────

function handleLibrarySkills(req, res) {
  const defs = [
    { name: '/capture',  when: 'You have a thought or task mid-session.',     how: '/capture [what]',   does: 'Adds it instantly to Brain/Inbox.md — no friction.' },
    { name: '/inbox',    when: 'Ready to process what\'s accumulated.',        how: '/inbox',            does: 'Works through Inbox.md one item at a time, filing each.' },
    { name: '/planning', when: 'Start of a day, week, or quarter.',           how: '/planning',         does: 'Daily: calendar + priorities. Weekly: goals + top 3. Quarterly: full review.' },
    { name: '/daily',    when: 'Morning planning session.',                    how: '/daily',            does: 'Calendar, emails, priorities, tasks — the one thing that matters today.' },
    { name: '/wrap',     when: 'End of a session or day.',                     how: '/wrap',             does: 'Logs what got done, captures next steps, checks commitments.' },
    { name: '/recall',   when: 'You want to find something.',                  how: '/recall [topic]',   does: 'Searches Brain/, Goals/, Personality/. Returns ranked matches.' },
    { name: '/plan',     when: 'Before any complex or multi-step work.',       how: '/plan [task]',      does: 'Writes a structured execution plan. Saves to Brain/Plans/. Executes on go.' },
    { name: '/goal',     when: 'Setting a new goal.',                          how: '/goal',             does: 'Full goal session — framing, milestones, tasks. Syncs to calendar and Master.md.' },
  ];

  const html = `<div class="skills-grid">${defs.map(s => `
    <div class="skill-card">
      <div class="skill-name">${esc(s.name)}</div>
      <div class="skill-row"><span class="skill-label">When</span><span class="skill-value">${esc(s.when)}</span></div>
      <div class="skill-row"><span class="skill-label">How</span><code class="skill-cmd">${esc(s.how)}</code></div>
      <div class="skill-row"><span class="skill-label">Does</span><span class="skill-value">${esc(s.does)}</span></div>
    </div>`).join('')}</div>`;

  send(res, 200, layout('Skills', '/library/skills', html));
}

// ── Parsers ───────────────────────────────────────────────────────────────────

function parseMasterSections(content) {
  const sections = [];
  let cur = null, sub = null;
  for (const line of content.split('\n')) {
    if (line.startsWith('## '))       { cur = { title: line.slice(3).trim(), tasks: [], subsections: [], info: [] }; sub = null; sections.push(cur); }
    else if (line.startsWith('### ') && cur) { sub = { title: line.slice(4).trim(), tasks: [] }; cur.subsections.push(sub); }
    else if (line.match(/^- \[([ x])\]/) && cur) {
      const m = line.match(/^- \[([ x])\] (.+)/);
      if (m) (sub || cur).tasks.push({ done: m[1].toLowerCase() === 'x', text: m[2].trim() });
    } else if (line.startsWith('> ') && cur && !sub) {
      cur.info.push(line.slice(2).trim());
    }
  }
  return sections;
}

function allTasksFlat(section) {
  return [...section.tasks, ...section.subsections.flatMap(s => s.tasks)];
}

// ── API: write-back ───────────────────────────────────────────────────────────

function apiTaskToggle(body) {
  const { text, done } = body;
  if (!text) return { ok: false, error: 'Missing text' };
  const content = readFile(P.master);
  if (!content) return { ok: false, error: 'Master.md not found' };
  let updated = done
    ? content.replace('- [ ] ' + text, '- [x] ' + text)
    : content.replace('- [x] ' + text, '- [ ] ' + text);
  if (updated === content) {
    // Case-insensitive fallback
    updated = done
      ? content.replace(new RegExp('- \\[ \\] ' + text.replace(/[.*+?^${}()|[\]\\]/g,'\\$&')), '- [x] ' + text)
      : content.replace(new RegExp('- \\[x\\] ' + text.replace(/[.*+?^${}()|[\]\\]/g,'\\$&'), 'i'), '- [ ] ' + text);
  }
  if (updated === content) return { ok: false, error: 'Task not found' };
  return writeFile(P.master, updated) ? { ok: true } : { ok: false, error: 'Write failed' };
}

function apiInboxProcess(body) {
  const { text } = body;
  if (!text) return { ok: false, error: 'Missing text' };
  const content = readFile(P.inbox);
  if (!content) return { ok: false, error: 'Inbox.md not found' };
  const updated = content.split('\n').filter(l => l.trim() !== '- ' + text).join('\n');
  return writeFile(P.inbox, updated) ? { ok: true } : { ok: false, error: 'Write failed' };
}

function apiPeopleNote(body) {
  const { relPath, note } = body;
  if (!relPath || !note) return { ok: false, error: 'Missing relPath or note' };
  if (relPath.includes('..') || !relPath.startsWith('Brain/People/')) return { ok: false, error: 'Invalid path' };
  const fullPath = path.join(VAULT, relPath);
  const content  = readFile(fullPath);
  if (!content) return { ok: false, error: 'File not found' };
  const entry = `\n## ${todayISO()} Note\n${note.trim()}\n`;
  return writeFile(fullPath, content + entry) ? { ok: true } : { ok: false, error: 'Write failed' };
}

// ── Static & artifact serving ─────────────────────────────────────────────────

function serveStatic(res, file) {
  const full    = path.join(__dirname, path.basename(file));
  const content = readFile(full);
  if (!content) { send(res, 404, 'Not found'); return; }
  const mime = file.endsWith('.css') ? 'text/css' : 'application/javascript';
  res.writeHead(200, { 'Content-Type': mime });
  res.end(content);
}

function serveArtifact(res, query) {
  const relPath = query.path;
  if (!relPath || relPath.includes('..') || !relPath.match(/^Brain\/Projects\/.+\/Artifacts\/.+\.html$/)) {
    send(res, 403, 'Forbidden'); return;
  }
  const content = readFile(path.join(VAULT, relPath));
  if (!content) { send(res, 404, 'Artifact not found'); return; }
  res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
  res.end(content);
}

// ── send ──────────────────────────────────────────────────────────────────────

function send(res, code, body) {
  const isHtml = typeof body === 'string' && body.trimStart().startsWith('<!DOCTYPE');
  res.writeHead(code, { 'Content-Type': isHtml ? 'text/html; charset=utf-8' : 'text/plain' });
  res.end(body);
}

function sendJson(res, obj) {
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(obj));
}

// ── Server ────────────────────────────────────────────────────────────────────

const server = http.createServer((req, res) => {
  const url      = new URL(req.url, 'http://localhost');
  const pathname = url.pathname;
  const query    = Object.fromEntries(url.searchParams);

  // Static assets
  if (pathname === '/styles.css') { serveStatic(res, 'styles.css'); return; }

  // Artifact serving
  if (pathname === '/artifact') { serveArtifact(res, query); return; }

  // POST API
  if (req.method === 'POST') {
    let body = '';
    req.on('data', c => { body += c; });
    req.on('end', () => {
      let parsed;
      try { parsed = JSON.parse(body); } catch { sendJson(res, { ok: false, error: 'Invalid JSON' }); return; }
      if (pathname === '/api/task/toggle')   { sendJson(res, apiTaskToggle(parsed));   return; }
      if (pathname === '/api/inbox/process') { sendJson(res, apiInboxProcess(parsed)); return; }
      if (pathname === '/api/people/note')   { sendJson(res, apiPeopleNote(parsed));   return; }
      sendJson(res, { ok: false, error: 'Unknown API route' });
    });
    return;
  }

  // GET routes
  if (pathname === '/')                    { handleHome(req, res, query);              return; }
  if (pathname === '/daily')               { handleDaily(req, res, query);             return; }
  if (pathname === '/board')               { handleBoard(req, res, query);             return; }
  if (pathname === '/inbox')               { handleInbox(req, res, query);             return; }
  if (pathname === '/library')             { handleLibraryHub(req, res, query);        return; }
  if (pathname === '/library/artifacts')   { handleLibraryArtifacts(req, res, query); return; }
  if (pathname === '/library/people')      { handleLibraryPeople(req, res, query);    return; }
  if (pathname === '/library/projects')    { handleLibraryProjects(req, res, query);  return; }
  if (pathname === '/library/knowledge')   { handleLibraryKnowledge(req, res, query); return; }
  if (pathname === '/library/skills')      { handleLibrarySkills(req, res, query);    return; }

  send(res, 404, layout('Not Found', '', '<p class="empty">Page not found. <a href="/">Go home</a></p>'));
});

server.listen(PORT, '127.0.0.1', () => {
  console.log(`Dashboard running at http://localhost:${PORT}`);
  console.log(`Vault: ${VAULT}`);
});
