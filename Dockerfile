FROM coturn/coturn:latest

# Install a tiny HTTP server for Render's health check
RUN apt-get update && apt-get install -y --no-install-recommends python3 ca-certificates && rm -rf /var/lib/apt/lists/*

# Copy startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Environment (Render will overwrite with its dashboard values)
ENV TURN_USER=tortilla
ENV TURN_PASS=Cl4uD1@2025
ENV TURN_REALM=tortillatv.com
ENV PORT=10000

# Expose TURN TCP port (443) and the HTTP health port ($PORT)
EXPOSE 443
EXPOSE ${PORT}

CMD ["/start.sh"]