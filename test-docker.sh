#!/bin/bash
set -e

echo "🧪 Testing SeedBox Lite Docker Image"
echo "====================================="

# Configuration
IMAGE_TAG=${1:-"seedbox-lite:test"}
TEST_PORT=${2:-"9999"}
CONTAINER_NAME="seedbox-test-$(date +%s)"

echo "📦 Building Docker image..."
docker build -t "$IMAGE_TAG" .

echo "🚀 Starting container..."
CONTAINER_ID=$(docker run -d -p "$TEST_PORT:80" --name "$CONTAINER_NAME" "$IMAGE_TAG")

echo "⏳ Waiting for container to start..."
sleep 10

echo "🔍 Running health checks..."

# Test frontend
echo -n "Frontend: "
if curl -sf "http://localhost:$TEST_PORT/" > /dev/null; then
    echo "✅ OK"
else
    echo "❌ FAILED"
    exit 1
fi

# Test nginx health
echo -n "Nginx health: "
if curl -sf "http://localhost:$TEST_PORT/health" > /dev/null; then
    echo "✅ OK"
else
    echo "❌ FAILED"
    exit 1
fi

# Test backend health
echo -n "Backend health: "
if curl -sf "http://localhost:$TEST_PORT/api/health" > /dev/null; then
    echo "✅ OK"
else
    echo "❌ FAILED"
    exit 1
fi

# Test API endpoint
echo -n "API endpoint: "
if curl -sf "http://localhost:$TEST_PORT/api/torrents" > /dev/null; then
    echo "✅ OK"
else
    echo "❌ FAILED"
    exit 1
fi

echo "🧹 Cleaning up..."
docker stop "$CONTAINER_NAME" > /dev/null
docker rm "$CONTAINER_NAME" > /dev/null

echo "🎉 All tests passed!"
echo "Container is ready for production deployment."