#!/usr/bin/env bash
set -e

# Healthcheck HTTP para Render (no tocar)
python3 -m http.server ${PORT:-10000} &

# Detecta IP pública para --external-ip (evita candidatos inválidos detrás de NAT)
PUBLIC_IP="$(getent ahostsv4 turn-tortillatv.onrender.com | awk '{print $1; exit}')"
if [ -z "$PUBLIC_IP" ]; then
  # fallback DNS público
  PUBLIC_IP="$(dig +short myip.opendns.com @resolver1.opendns.com || true)"
fi
if [ -z "$PUBLIC_IP" ]; then
  echo "⚠️  No pude detectar PUBLIC_IP; intenta fijarla con la env TURN_PUBLIC_IP"
  PUBLIC_IP="${TURN_PUBLIC_IP}"
fi

echo "Using PUBLIC_IP=${PUBLIC_IP}"

# Variables (puedes sobreescribir en Render env vars)
REALM="${TURN_REALM:-tortillatv.com}"
USER_NAME="${TURN_USER:-tortilla}"
USER_PASS="${TURN_PASS:-Cl4uD1@2025}"

echo "Starting TURN on TCP 3478 (no UDP), realm=${REALM}"

# Importante: --external-ip para que el peer reciba candidatos válidos.
# Solo TCP (–-no-udp). Sin TLS por ahora (–-no-tls) para evitar certs.
turnserver \
  --listening-ip=0.0.0.0 \
  --relay-ip=0.0.0.0 \
  --listening-port=3478 \
  --min-port=49160 --max-port=49200 \
  --external-ip="${PUBLIC_IP}" \
  --realm="${REALM}" \
  --user="${USER_NAME}:${USER_PASS}" \
  --fingerprint \
  --lt-cred-mech \
  --no-tls \
  --no-udp \
  --no-cli \
  --prod \
  --verbose \
  --log-file=stdout
