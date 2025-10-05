#!/usr/bin/env bash
set -e

# Simple HTTP server on $PORT so Render sees the service as healthy
# It serves a static OK page.
mkdir -p /health
echo "OK" > /health/index.html
python3 -m http.server "${PORT:-10000}" --directory /health &

# Launch coturn in TCP on 443 (no UDP). Uses static snakeoil certs provided by base image if needed,
# but we'll default to non-TLS (turn:), so certs are not required.
exec turnserver \
  --listening-port 443 \
  --no-udp \
  --fingerprint \
  --lt-cred-mech \
  --user "${TURN_USER}:${TURN_PASS}" \
  --realm "${TURN_REALM}" \
  --no-cli \
  --no-loopback-peers \
  --no-multicast-peers \
  --no-tls \
  --min-port 49160 --max-port 49200 \
  --log-file stdout