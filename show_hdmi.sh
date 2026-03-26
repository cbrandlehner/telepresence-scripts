#!/bin/bash
set -euo pipefail

HOST="cisco.home.arpa"
USER="john_doe"
PASS_FILE="$HOME/.mx300-pass"
PASSWORD=$(cat "$PASS_FILE")

# === Usage ===
if [ $# -eq 1 ]; then
  port=$1
  if [[ ! $port =~ ^[1-4]$ ]]; then
    echo "Error: Port must be 1-4"
    exit 1
  fi
else
  port=""   # auto-detect first connected HDMI (3 or 4)
fi

# === Fetch status (needed for SourceId + auto-detect) ===
raw=$(
  {
    printf 'xStatus Video Input Connector %d\n' {1..4}
    printf 'bye\n'
  } | sshpass -p "$PASSWORD" ssh -tt \
    -o StrictHostKeyChecking=no \
    -o LogLevel=ERROR \
    "$USER@$HOST" 2>/dev/null
)

output=$(echo "$raw" | tr -d '\r' | grep '^\*s ' || true)

# === Decide which port to use ===
if [ -z "$port" ]; then
  for p in 3 4; do
    connected=$(echo "$output" | grep "Video Input Connector $p Connected:" \
      | sed 's/.*Connected: *//; s/"//g; s/ *$//' | head -n1)
    port_type=$(echo "$output" | grep "Video Input Connector $p Type:" \
      | sed 's/.*Type: *//; s/"//g; s/ *$//' | head -n1)

    if [[ "$connected" == "True" && "$port_type" == *"HDMI"* ]]; then
      port=$p
      break
    fi
  done

  if [ -z "$port" ]; then
    echo "❌ No connected HDMI found on ports 3 or 4"
    echo "   Use: $0 3   or   $0 4"
    exit 1
  fi
fi

# === Get the correct SourceId for this port ===
source_id=$(echo "$output" | grep "Video Input Connector $port SourceId:" \
  | sed 's/.*SourceId: *//; s/"//g; s/ *$//' | head -n1)

if [ -z "$source_id" ]; then
  echo "❌ Could not read SourceId for port $port"
  exit 1
fi

echo "🔄 Enabling HDMI on Port $port (SourceId $source_id) ..."

# === Exact sequence that works for you ===
{
  printf "xCommand Video Input SetMainVideoSource SourceId: %d\n" "$source_id"
  printf "xCommand Presentation Start ConnectorId: %d\n" "$port"
  printf "xCommand Video Selfview Set Mode: On FullscreenMode: On\n"
  printf "bye\n"
} | sshpass -p "$PASSWORD" ssh -tt \
  -o StrictHostKeyChecking=no \
  -o LogLevel=ERROR \
  "$USER@$HOST" 2>/dev/null

echo "✅ HDMI input from Port $port is now shown full-screen"
echo ""
echo "To switch back to camera →   ./show_hdmi.sh 1"
echo "To stop presentation     →   ./stop_presentation.sh"
