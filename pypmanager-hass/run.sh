#!/usr/bin/with-contenv bashio

# Create data directories
mkdir -p /data/transactions
ln -sf /data /app/data

# Configure for ingress
export PYPMANAGER_HOST="0.0.0.0"
export PYPMANAGER_PORT="8001"

# Start pypmanager
exec python3 -m uvicorn main:app \
    --host "${PYPMANAGER_HOST}" \
    --port "${PYPMANAGER_PORT}"
