FROM debian:bookworm-slim

# Arreglo permisos + instalación de coturn y Python (para healthcheck)
RUN set -eux; \
    mkdir -p /var/lib/apt/lists/partial; \
    chmod -R 0755 /var/lib/apt/lists; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      coturn \
      python3 \
      ca-certificates; \
    rm -rf /var/lib/apt/lists/*

# Copia el script de inicio
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expone puertos TURN y el de Render healthcheck
EXPOSE 3478 3478/udp 443/tcp 10000
EXPOSE 3478 443 10000

# Ejecuta el script
CMD ["/start.sh"]
