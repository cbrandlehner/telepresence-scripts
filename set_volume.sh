#!/bin/bash
set -euo pipefail

HOST="cisco.home.arpa"
USER="john_doe"
PASS_FILE="$HOME/.mx300-pass"
PASSWORD=$(cat "$PASS_FILE")

# === Usage ===
if [ $# -ne 1 ]; then
    echo "Error: Exactly one parameter is required."
    exit 1
fi
# check if the parameter is a valid number between 0 and 100.
volume=$1
if [[ ! $volume =~ ^[0-9]+$ ]] || (( $volume < 0 )) || (( $volume > 100 )); then
    echo "Error: Volume must be a number between 0 and 100"
    exit 1
fi

result=$(
  {
    printf "xCommand Audio Volume Set Level: $volume\n"
    printf "bye\n"
  } | sshpass -p "$PASSWORD" ssh -tt \
    -o StrictHostKeyChecking=no \
    -o LogLevel=ERROR \
    "$USER@$HOST" 2>/dev/null
)

# === Check if it worked ===
if echo "$result" | grep -q 'status=Error'; then
  reason=$(echo "$result" | grep -o 'Reason: "[^"]*"' | sed 's/Reason: "//; s/"$//')
  echo "❌ Failed to change volume"
  echo "   Reason: $reason"
  exit 1
else
  echo "✅ Success!"
  echo ""
fi
