#!/usr/bin/env node
// Inbox Folder Watcher
// Watches the client's designated AI Inbox folder (from System/integrations.yaml)
// and appends new files to Brain/Inbox.md automatically.
// Runs as a background process — started by launchd on login (see inbox-watcher.plist).

'use strict';

const fs   = require('fs');
const path = require('path');

const VAULT = path.resolve(__dirname, '../..');

function readFile(p) { try { return fs.readFileSync(p, 'utf8'); } catch { return null; } }

function getInboxFolderPath() {
  const yaml = readFile(path.join(VAULT, 'System/integrations.yaml'));
  if (!yaml) { console.error('integrations.yaml not found'); process.exit(1); }
  const m = yaml.match(/local_path:\s*"?([^"\n]+)"?/);
  if (!m || !m[1].trim()) {
    console.error('inbox_folder.local_path is not set in integrations.yaml');
    console.error('Run /setup to configure the inbox folder.');
    process.exit(1);
  }
  return m[1].trim().replace(/^~/, process.env.HOME);
}

function todayISO() {
  return new Date().toISOString().slice(0, 10);
}

function appendToInbox(filename) {
  const inboxPath = path.join(VAULT, 'Brain/Inbox.md');
  const entry     = `- [${todayISO()}] ${filename} (dropped into AI Inbox)\n`;
  try {
    fs.appendFileSync(inboxPath, entry, 'utf8');
    console.log(`[${new Date().toISOString()}] Captured: ${filename}`);
  } catch (e) {
    console.error(`Failed to write to Inbox.md: ${e.message}`);
  }
}

function startWatcher(watchPath) {
  if (!fs.existsSync(watchPath)) {
    console.error(`Inbox folder not found: ${watchPath}`);
    console.error('Create the folder or update local_path in System/integrations.yaml');
    process.exit(1);
  }

  console.log(`[${new Date().toISOString()}] Watching: ${watchPath}`);
  console.log(`Vault: ${VAULT}`);

  // Track existing files so we only fire on genuinely new ones
  const seen = new Set(fs.readdirSync(watchPath));

  fs.watch(watchPath, { persistent: true }, (event, filename) => {
    if (!filename || event !== 'rename') return;
    if (seen.has(filename)) return; // already knew about this file

    const fullPath = path.join(watchPath, filename);
    // Brief delay to ensure file has finished copying
    setTimeout(() => {
      if (fs.existsSync(fullPath)) {
        seen.add(filename);
        appendToInbox(filename);
      }
    }, 500);
  });
}

const watchPath = getInboxFolderPath();
startWatcher(watchPath);
