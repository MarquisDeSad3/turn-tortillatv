# TURN for TortillaTV (Render)

Este repo levanta **coturn** en Render para funcionar como **TURN TCP (puerto 443)**,
ideal para usuarios con **VPN** o **NAT estrictos**.

> ⚠️ Render no soporta UDP en el proxy público. Por eso este contenedor usa **TCP 443** y desactiva UDP.
> Eso es suficiente para la mayoría de redes bloqueadas y VPN.

---

## Deploy (click-click)

1. Crea un repo con estos archivos (o usa este ZIP).
2. En Render → **New → Web Service** → **Build & deploy from a Git repo**.
3. Tipo: **Docker**. Plan sugerido: **Standard ($25)** o superior para evitar spin down.
4. Variables de entorno (en *Environment*):
   - `TURN_USER`: `tortilla`
   - `TURN_PASS`: `Cl4uD1@2025`
   - `TURN_REALM`: `tortillatv.com`
   - `PORT`: `10000` (HTTP health)
5. Deploy. Render te dará una URL tipo `https://turn-tortillatv.onrender.com`.
6. El **dominio** para tu TURN es **`turn-tortillatv.onrender.com`** (sin `https://`).

> El contenedor también expone un mini HTTP en `$PORT` (por defecto 10000) para que Render lo vea "healthy".
> TURN escucha en **443/TCP** sin TLS (`turn:`).

---

## Cómo integrarlo en tu WebRTC

Usa `turn:` (TCP) en vez de `turns:` (TLS) para evitar problemas de certificados.

```js
const iceServers = [
  { urls: 'stun:stun.l.google.com:19302' },
  {
    urls: ['turn:turn-tortillatv.onrender.com:443?transport=tcp'],
    username: 'tortilla',
    credential: 'Cl4uD1@2025'
  }
];

const pc = new RTCPeerConnection({ iceServers });
```

Si tu usuario está **en VPN** y quieres forzar TURN:
```js
const vpnMode = true;
const pc = new RTCPeerConnection({
  iceServers,
  iceTransportPolicy: vpnMode ? 'relay' : 'all'
});
```

---

## Probar que TURN funciona

- Herramienta web: <https://webrtc.github.io/samples/src/content/peerconnection/trickle-ice/>
  - Agrega un servidor:
    - URL: `turn:turn-tortillatv.onrender.com:443?transport=tcp`
    - Username: `tortilla`
    - Credential: `Cl4uD1@2025`
  - Si aparecen candidatos `relay`, ¡listo!

- CLI (opcional):
  ```bash
  npx webrtc-troubleshooter
  ```

---

## Rendimiento y costos

- Plan **Standard** suele ser suficiente para 1–3 relays concurrentes de calidad media.
- Si vas a tener más gente con VPN, sube a **Pro / Pro+**.
- TURN por TCP consume más CPU que UDP. Monitorea el uso en Render.

---

## TLS (opcional avanzado)

Si necesitas `turns:` (TLS) con validación de certificado del host TURN, Render no entrega certificados para tráfico TCP arbitrario.
Recomendaciones:
- Usa un **Load Balancer** externo que termine TLS y enrute a tu pod (más complejo), **o**
- Despliega en un proveedor que permita **UDP + TLS** directo (p. ej., Fly.io, DigitalOcean Droplet) y configura Let’s Encrypt.

Mientras tanto, `turn:` sobre **443/TCP** es suficiente para la mayoría de escenarios con VPN.

---

## Seguridad

- Cambia `TURN_USER` y `TURN_PASS` y **no** los publiques en el cliente si puedes evitarlo.
- Para producción, considera **TURN con short-term credentials** (REST API de coturn con HMAC).

---

## Estructura

```
.
├─ Dockerfile
├─ start.sh
├─ render.yaml
├─ .env.example
└─ README.md
```

¡Listo! 🚀