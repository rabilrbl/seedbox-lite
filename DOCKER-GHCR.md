# 🐳 Docker Deployment Guide

## Quick Start with GHCR Image

The easiest way to run SeedBox Lite is using the pre-built Docker image from GitHub Container Registry:

```bash
# Pull and run the latest image
docker run -d \
  --name seedbox-lite \
  -p 8080:80 \
  -v seedbox_data:/app/data \
  -v seedbox_cache:/app/cache \
  -e ACCESS_PASSWORD=your_secure_password \
  ghcr.io/rabilrbl/seedbox-lite:latest
```

## Combined Architecture

This Docker image combines both frontend and backend in a single container:

- **Frontend**: React application served by nginx on port 80
- **Backend**: Node.js API server running on port 3001
- **Reverse Proxy**: nginx handles routing between frontend and API

## Environment Variables

Key environment variables you can customize:

| Variable | Default | Description |
|----------|---------|-------------|
| `ACCESS_PASSWORD` | `seedbox123` | Password for application access |
| `MAX_CACHE_SIZE` | `5368709120` | Maximum cache size in bytes (5GB) |
| `SERVER_HOST` | `0.0.0.0` | Server binding address |
| `SERVER_PORT` | `3001` | Backend server port |

## Docker Compose Example

```yaml
version: '3.8'
services:
  seedbox:
    image: ghcr.io/rabilrbl/seedbox-lite:latest
    ports:
      - "8080:80"
    volumes:
      - seedbox_data:/app/data
      - seedbox_cache:/app/cache
    environment:
      - ACCESS_PASSWORD=your_secure_password
    restart: unless-stopped

volumes:
  seedbox_data:
  seedbox_cache:
```

## Multi-Architecture Support

The image supports both:
- `linux/amd64` (Intel/AMD 64-bit)
- `linux/arm64` (ARM 64-bit, including Apple Silicon and Raspberry Pi)

## Health Checks

The container includes built-in health checks:
- Frontend health: `GET /health`
- Backend health: `GET /api/health`

## Automatic Updates

The image is automatically built and updated when:
- New code is pushed to the main branch
- Upstream repository has new commits (checked hourly)

## Building Locally

To build the image yourself:

```bash
git clone https://github.com/rabilrbl/seedbox-lite.git
cd seedbox-lite
docker build -t seedbox-lite .
```

## Ports

- **Port 80**: Main application (nginx serves frontend and proxies API)
- **Port 3001**: Internal backend port (not exposed externally)

## Volumes

- `/app/data`: Torrent data storage
- `/app/cache`: Application cache
- `/app/logs`: Application logs

For more detailed deployment options, see [DOCKER.md](DOCKER.md).