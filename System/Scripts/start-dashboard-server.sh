#!/usr/bin/env bash
# Starts the client AI System dashboard at localhost:7272
# Run once — stays running in the background until you kill it

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SERVER="$VAULT_ROOT/Dashboards/server.js"
PORT=7272

# Check if already running
if lsof -i ":$PORT" -sTCP:LISTEN -t &>/dev/null; then
  echo "Dashboard already running at http://localhost:$PORT"
  exit 0
fi

# Check Node is available
if ! command -v node &>/dev/null; then
  echo "Error: Node.js is not installed."
  echo "Install it from https://nodejs.org (LTS version)"
  exit 1
fi

# Start server in background
nohup node "$SERVER" > "$VAULT_ROOT/.claude/staging/dashboard.log" 2>&1 &
SERVER_PID=$!
echo $SERVER_PID > "$VAULT_ROOT/.claude/staging/dashboard.pid"

# Wait briefly and confirm it started
sleep 1
if kill -0 "$SERVER_PID" 2>/dev/null; then
  echo "Dashboard running at http://localhost:$PORT"
  echo "PID: $SERVER_PID"
  echo "Log: $VAULT_ROOT/.claude/staging/dashboard.log"
  echo ""
  echo "To stop: kill $SERVER_PID"
else
  echo "Server failed to start. Check the log:"
  echo "  cat $VAULT_ROOT/.claude/staging/dashboard.log"
  exit 1
fi
