#!/bin/bash

# 1. Force the dummy HTTP server to use IPv4 (0.0.0.0) so Render sees it instantly
python3 -m http.server ${PORT:-10000} --bind 0.0.0.0 --directory /tmp &

# 2. Start Tailscale background daemon
tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &
sleep 5

# 3. Authenticate to Tailscale (Make sure TAILSCALE_AUTHKEY is in Render environment variables)
tailscale up --auth-key="${TAILSCALE_AUTHKEY}" --hostname="render-r-stream" --ssh &
sleep 10

# 4. Auto-generate SSL certificates and save them with a fixed name
HOSTNAME=$(tailscale status --json | jq -r .Self.DNSName | sed 's/\.$//')
echo "Generating SSL certs for $HOSTNAME..."
tailscale cert --cert-file /app/ts.crt --key-file /app/ts.key "$HOSTNAME"

# 5. CRITICAL FIX: Override Render's PORT so your video server doesn't crash!
export PORT=8001

# 6. Start the R-stream bot directly
uv run -m Backend
