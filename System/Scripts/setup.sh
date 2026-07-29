#!/bin/bash
# Stein for Clients — Setup Script
# Run once per client. Copies the scaffold, checks dependencies,
# starts the dashboard, and installs auto-start agents.
# Usage: bash setup.sh

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'
BOLD='\033[1m'

log()   { echo -e "${CYAN}▸${RESET} $1"; }
ok()    { echo -e "${GREEN}✓${RESET} $1"; }
warn()  { echo -e "${YELLOW}⚠${RESET} $1"; }
error() { echo -e "${RED}✗${RESET} $1"; exit 1; }
header(){ echo -e "\n${BOLD}$1${RESET}"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCAFFOLD_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# ── Welcome ───────────────────────────────────────────────────────────────────

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${BOLD}  Stein for Clients — Setup${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

# ── Client name ───────────────────────────────────────────────────────────────

header "1. Client Info"
read -rp "  Client first name (used to name the vault folder): " CLIENT_FIRST
read -rp "  Client last name: " CLIENT_LAST
CLIENT_NAME="${CLIENT_FIRST}_${CLIENT_LAST}"
log "Vault will be named: ${CLIENT_NAME}_AI"

# ── Vault location ────────────────────────────────────────────────────────────

header "2. Vault Location"
echo "  Where should the vault live?"
echo "  1) iCloud Drive (recommended for Mac)"
echo "  2) Google Drive for Desktop"
echo "  3) Custom path"
read -rp "  Choice [1/2/3]: " LOCATION_CHOICE

case "$LOCATION_CHOICE" in
  1)
    VAULT_DIR="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/${CLIENT_NAME}_AI"
    ;;
  2)
    # Find Google Drive mount point
    # Resolve the glob first — an unquoted glob inside [ -d ] errors out when it
    # matches zero or several accounts instead of falling through to the prompt.
    GDRIVE="$(ls -d "$HOME/Library/CloudStorage/GoogleDrive-"*/"My Drive" 2>/dev/null | head -1)"
    if [ -d "$HOME/Google Drive/My Drive" ]; then
      VAULT_DIR="$HOME/Google Drive/My Drive/${CLIENT_NAME}_AI"
    elif [ -n "$GDRIVE" ] && [ -d "$GDRIVE" ]; then
      VAULT_DIR="${GDRIVE}/${CLIENT_NAME}_AI"
    else
      warn "Google Drive not found at expected path."
      read -rp "  Enter Google Drive 'My Drive' path: " GDRIVE
      VAULT_DIR="${GDRIVE}/${CLIENT_NAME}_AI"
    fi
    ;;
  3)
    read -rp "  Full path for vault folder: " VAULT_DIR
    ;;
  *)
    error "Invalid choice"
    ;;
esac

log "Vault path: $VAULT_DIR"

# ── Check Node.js ─────────────────────────────────────────────────────────────

header "3. Checking Dependencies"
# Resolve the real node path and USE it. Do not hardcode — Intel Macs put node
# at /usr/local/bin, Apple Silicon at /opt/homebrew/bin. Hardcoding /usr/local
# is why the LaunchAgents silently failed to start on every M-series machine.
NODE_BIN="$(command -v node || true)"
if [ -n "$NODE_BIN" ]; then
  NODE_VER=$("$NODE_BIN" --version)
  ok "Node.js $NODE_VER  ($NODE_BIN)"
else
  error "Node.js not found. Install from https://nodejs.org (LTS version) and re-run this script."
fi

# ── Check Obsidian ────────────────────────────────────────────────────────────

if [ -d "/Applications/Obsidian.app" ] || [ -d "$HOME/Applications/Obsidian.app" ]; then
  ok "Obsidian is installed"
else
  warn "Obsidian not found in /Applications."
  echo "  Download Obsidian from https://obsidian.md and install it, then press Enter to continue."
  read -rp "  Press Enter when Obsidian is installed: "
fi

# ── Copy scaffold ─────────────────────────────────────────────────────────────

header "4. Copying Scaffold"
if [ -d "$VAULT_DIR" ]; then
  warn "Folder already exists at $VAULT_DIR"
  read -rp "  Overwrite? This will delete existing content. [y/N]: " CONFIRM
  [[ "$CONFIRM" =~ ^[Yy]$ ]] || error "Aborted."
  rm -rf "$VAULT_DIR"
fi

cp -r "$SCAFFOLD_ROOT" "$VAULT_DIR"
ok "Scaffold copied to $VAULT_DIR"

# ── Install the blank vault forms ─────────────────────────────────────────────
# The repo tracks blank templates in _skeleton/ and gitignores the live vault,
# so client data never lands in the shared repo. This puts the forms in place.

header "5. Installing Vault Skeleton"
bash "$VAULT_DIR/System/Scripts/install-skeleton.sh" "$VAULT_DIR"

# ── Start dashboard ───────────────────────────────────────────────────────────

header "6. Starting Dashboard"
DASHBOARD_DIR="$VAULT_DIR/Dashboards"
"$NODE_BIN" "$DASHBOARD_DIR/server.js" &
DASHBOARD_PID=$!
sleep 1

if kill -0 "$DASHBOARD_PID" 2>/dev/null; then
  ok "Dashboard running at http://localhost:7272 (PID $DASHBOARD_PID)"
else
  warn "Dashboard may not have started. Try: node Dashboards/server.js"
fi

# ── Install auto-start (Mac only) ─────────────────────────────────────────────

header "7. Auto-start on Login"
if [[ "$OSTYPE" == "darwin"* ]]; then
  LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
  mkdir -p "$LAUNCH_AGENTS_DIR"

  DASHBOARD_PLIST="$LAUNCH_AGENTS_DIR/com.stein.${CLIENT_NAME}.dashboard.plist"
  VAULT_DIR_ESCAPED="${VAULT_DIR//&/&amp;}"

  cat > "$DASHBOARD_PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.stein.${CLIENT_NAME}.dashboard</string>
  <key>ProgramArguments</key>
  <array>
    <string>${NODE_BIN}</string>
    <string>${VAULT_DIR}/Dashboards/server.js</string>
  </array>
  <key>WorkingDirectory</key>
  <string>${VAULT_DIR}/Dashboards</string>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>StandardOutPath</key>
  <string>${VAULT_DIR}/System/Logs/dashboard.log</string>
  <key>StandardErrorPath</key>
  <string>${VAULT_DIR}/System/Logs/dashboard-error.log</string>
</dict>
</plist>
EOF

  INBOX_PLIST="$LAUNCH_AGENTS_DIR/com.stein.${CLIENT_NAME}.inbox-watcher.plist"
  cat > "$INBOX_PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.stein.${CLIENT_NAME}.inbox-watcher</string>
  <key>ProgramArguments</key>
  <array>
    <string>${NODE_BIN}</string>
    <string>${VAULT_DIR}/System/Scripts/inbox-watcher.js</string>
  </array>
  <key>WorkingDirectory</key>
  <string>${VAULT_DIR}</string>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>StandardOutPath</key>
  <string>${VAULT_DIR}/System/Logs/inbox-watcher.log</string>
  <key>StandardErrorPath</key>
  <string>${VAULT_DIR}/System/Logs/inbox-watcher-error.log</string>
</dict>
</plist>
EOF

  # Create logs directory
  mkdir -p "$VAULT_DIR/System/Logs"

  # Load the agents
  launchctl load "$DASHBOARD_PLIST"  2>/dev/null || true
  launchctl load "$INBOX_PLIST"      2>/dev/null || true

  ok "Auto-start installed — dashboard and inbox watcher will start on every login"
else
  warn "Auto-start on Windows: open Task Scheduler and create a task to run:"
  warn "  node \"${VAULT_DIR}/Dashboards/server.js\" at logon"
fi

# ── Open Obsidian ─────────────────────────────────────────────────────────────

header "8. Open in Obsidian"
if [[ "$OSTYPE" == "darwin"* ]]; then
  log "Opening Obsidian..."
  open -a Obsidian "$VAULT_DIR" 2>/dev/null || warn "Couldn't open Obsidian automatically — open it manually and point it to $VAULT_DIR"
fi

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}${BOLD}  Setup complete.${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "  Dashboard: ${CYAN}http://localhost:7272${RESET}"
echo -e "  Vault:     ${CYAN}$VAULT_DIR${RESET}"
echo ""
echo "  Next steps:"
echo "  1. Open Claude Code and point it to the vault folder"
echo "  2. Connect MCPs (follow System/Setup/google-setup.md)"
echo "  3. Run /setup to start the live interview"
echo "  4. Run /Let's-Go at the end of the session"
echo ""
