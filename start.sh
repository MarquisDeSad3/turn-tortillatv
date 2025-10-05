#!/usr/bin/env bash
set -e

# Healthcheck HTTP para Render
python3 -m http.server ${PORT:-10000} &

echo "Starting TURN server on 3478 (TCP) and 443 (TLS fallback)..."

turnserver \
  --listening-ip=0.0.0.0 \
  --listening-port=3478 \
  --tls-listening-port=443 \
  --realm=${TURN_REALM:-tortillatv.com} \
  --user=${TURN_USER:-tortilla}:${TURN_PASS:-Cl4uD1@2025} \
  --fingerprint \
  --lt-cred-mech \
  --no-cli \
  --no-udp \
  --min-port=49160 --max-port=49200 \
  --log-file=stdout
