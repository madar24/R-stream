#!/bin/bash

echo "Starting Tailscale daemon in userspace networking mode..."
# Render doesn't allow /dev/net/tun, so userspace-networking is required
tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &

# Wait a few seconds for the daemon to initialize
sleep 5

echo "Authenticating Tailscale..."
# Use an ephemeral, reusable auth key provided via Render environment variables
if [ -z "$TAILSCALE_AUTHKEY" ]; then
  echo "Error: TAILSCALE_AUTHKEY environment variable is not set."
else
  tailscale up --authkey="${TAILSCALE_AUTHKEY}" --hostname="tailscale-server-singa" --ssh --accept-routes
  
echo "Configuring Tailscale serve..."

  tailscale serve localhost:8001 &
fi

echo "Starting the main application..."
uv run update.py && uv run -m Backend
