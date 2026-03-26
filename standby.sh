#!/bin/bash
set -euo pipefail

HOST="cisco.home-arpa"
USER="john_doe"
PASS_FILE="$HOME/.mx300-pass"
PASSWORD=$(cat "$PASS_FILE")

# Enable Standby
result=$(
  {
    printf "xCommand Presentation Stop\n"
    printf "xCommand Video Input SetMainVideoSource SourceId: 1\n"
    printf "xCommand Video Selfview Set Mode: Off FullscreenMode: Off\n"
    printf "xCommand Standby Activate\n"
    printf "bye\n"
  } | sshpass -p "$PASSWORD" ssh -tt \
    -o StrictHostKeyChecking=no \
    -o LogLevel=ERROR \
    "$USER@$HOST" 2>/dev/null
)

# Check result
if echo "$result" | grep -q 'status=Error'; then
  echo "❌ Something went wrong (check connection or firmware)"
else
  echo "✅ Standby activated!"
fi
