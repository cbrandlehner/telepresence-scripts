#!/bin/bash
set -euo pipefail
CERT_DIR="/home/john_doe/certs"
HOST="cisco.home.arpa" # If you use an IP instead of a full qualified hostname, activating the cert will fail
USER="john_doe"
PASS_FILE="$HOME/.mx300-pass"
PASSWORD=$(cat "$PASS_FILE")

echo "=== Starting certificate deployment to MX300 G2 ==="

# Update filenames if needed
cat "${CERT_DIR}/cisco.crt" "${CERT_DIR}/cisco.key.pem" > /tmp/combined.pem

# Upload (pipe + forced TTY = works on tsh shell)
{
  printf "xCommand Security Certificates Services Add\n"
  cat /tmp/combined.pem
  printf ".\nbye\n"
} | sshpass -p "$PASSWORD" ssh -tt -o StrictHostKeyChecking=no "$USER@$HOST"

rm -f /tmp/combined.pem
echo "Certificate uploaded. Retrieving fingerprint..."

# Get the output of the command to a variable
OUTPUT=$( {
  printf "xCommand Security Certificates Services Show\n"
  printf "bye\n"
} | sshpass -p "$PASSWORD" ssh -tt -o StrictHostKeyChecking=no "$USER@$HOST"
)

OUTPUT=$(echo "$OUTPUT" | tr -d '\r')
# following command requires the host to match the certificate subject
# If you use wildcard certificates or  if you have special setup, you can hardcode your certificate name here.
FINGERPRINT=$(echo "$OUTPUT" | awk -v host="$HOST" '
  /Details [0-9]+ Fingerprint:/ {
    fp=$NF
    gsub(/"/, "", fp)
  }
  /Details [0-9]+ SubjectName:/ {
    if ($0 ~ host) {
      print fp
      exit
    }
  }
')

# remove comments to enable debug
#echo "DEBUG fingerprint (hex):"
#echo -n "$FINGERPRINT" | hexdump -C

if [ -n "$FINGERPRINT" ]; then
  echo "Activating certificate (fingerprint: $FINGERPRINT)"

{
  printf "xCommand Security Certificates Services Activate Fingerprint: $FINGERPRINT Purpose: HTTPS\n"
  printf "bye\n"
} | sshpass -p "$PASSWORD" ssh -tt -o StrictHostKeyChecking=no "$USER@$HOST"

else
  echo "ERROR: Could not find fingerprint. Check manually with: xCommand Security Certificates Services Show"
  exit 1
fi

echo "✅ Certificate successfully uploaded and activated on MX300 G2! You have to restart the MX300 G2."
