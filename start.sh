#!/bin/sh
set -e

echo "Starting SeedBox Lite combined container..."

# Start nginx in background
echo "Starting nginx..."
nginx -g "daemon off;" &

# Give nginx a moment to start
sleep 2

# Start backend server
echo "Starting backend server..."
cd /app
exec node index.js