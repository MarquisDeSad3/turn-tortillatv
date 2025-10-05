#!/usr/bin/env bash
set -e

# Render necesita algo que escuche en un puerto HTTP para healthcheck
python3 -m http.server ${PORT:-10000} &

echo "Starting TURN server on port 3478 (TCP, no UDP)..."

turnserver \
  --listening-port=3478 \
  --listening-ip=0.0.0.0 \
  --realm=${TURN_REALM:-tortillatv.com} \
  --user=${TURN_USER:-tortilla}:${TURN_PASS:-Cl4uD1@2025} \
  --no-cli \
  --fingerprint \
  --lt-cred-mech \
  --no-udp \
  --log-file=stdout
