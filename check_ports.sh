#!/bin/bash
set -euo pipefail

HOST="cisco.home.arpa"
USER="john_doe"
PASS_FILE="$HOME/.mx300-pass"
PASSWORD=$(cat "$PASS_FILE")

# One SSH session for all 4 ports
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

# Header
printf "%-12s %-12s %s\n" "Port-Number" "Port-Type" "Status (connected)"
echo "------------------------------------------------------------"

for port in {1..4}; do
  # Robust extraction (works on macOS/Linux)
  port_type=$(echo "$output" | grep "Video Input Connector $port Type:" \
    | sed 's/.*Type: *//; s/"//g; s/ *$//' | head -n1)
  [ -z "$port_type" ] && port_type="Unknown"

  connected=$(echo "$output" | grep "Video Input Connector $port Connected:" \
    | sed 's/.*Connected: *//; s/"//g; s/ *$//' | head -n1)
  [ -z "$connected" ] && connected="False"

  if [[ "$connected" == "True" ]]; then
    status="connected"
  else
    status="disconnected"
  fi

  printf "%-12s %-12s %s\n" "$port" "$port_type" "$status"
done
