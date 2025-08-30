# Multi-stage build for combined frontend and backend
FROM node:18-alpine AS frontend-builder

# Set working directory for frontend
WORKDIR /app/client

# Copy frontend package files
COPY client/package*.json ./

# Install frontend dependencies
RUN npm ci && npm cache clean --force

# Copy frontend source code
COPY client/ ./

# Build arguments for frontend
ARG VITE_API_BASE_URL=/api
ENV VITE_API_BASE_URL=$VITE_API_BASE_URL

# Build the frontend application
RUN npm run build

# Backend builder stage
FROM node:18-alpine AS backend-builder

# Set working directory for backend
WORKDIR /app/server

# Copy backend package files
COPY server/package*.json ./

# Install backend dependencies (production only)
RUN npm ci --only=production && npm cache clean --force

# Copy backend source code
COPY server/ ./

# Production stage - Combined image
FROM node:18-alpine AS production

# Install nginx and curl for serving frontend and health checks
RUN apk add --no-cache nginx curl

# Create app user and nginx directories
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    adduser -D -s /bin/sh nginx || true

# Set working directory
WORKDIR /app

# Copy backend from builder stage
COPY --from=backend-builder --chown=nodejs:nodejs /app/server ./

# Copy environment configuration for production
COPY server/.env.docker .env

# Copy frontend build from builder stage
COPY --from=frontend-builder /app/client/dist /usr/share/nginx/html

# Copy nginx configuration for combined setup
COPY nginx-combined.conf /etc/nginx/nginx.conf

# Create directories for data, cache, and logs
RUN mkdir -p /app/data /app/cache /app/logs && chown -R nodejs:nodejs /app

# Set proper permissions for nginx
RUN mkdir -p /var/cache/nginx /var/log/nginx /etc/nginx/conf.d && \
    chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid

# Copy startup script
COPY start.sh /app/start.sh

RUN chmod +x /app/start.sh

# Expose port 80 (nginx serves both frontend and proxies backend)
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:80/health || exit 1

# Start both services
CMD ["/app/start.sh"]