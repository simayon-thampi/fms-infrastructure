#!/bin/bash
set -e  # Exit on error

# ============================================================================
# FMS Universal Deployment Script
# ============================================================================
# Usage: bash deploy.sh <service_name>
# Example: bash deploy.sh application-service
# ============================================================================

SERVICE_NAME=$1

if [ -z "$SERVICE_NAME" ]; then
    echo "Error: No service name provided."
    echo "Usage: $0 <service_name>"
    exit 1
fi

# Configuration
COMPOSE_FILE="/home/ubuntu/fms/docker-compose.yml"
ENV_FILE="/home/ubuntu/fms/.env"

# Logging function
log() {
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log "Starting deployment for $SERVICE_NAME"

# Step 1: Verify docker-compose file exists
if [ ! -f "$COMPOSE_FILE" ]; then
    echo "Error: Docker Compose file not found: $COMPOSE_FILE"
    exit 1
fi

# Step 2: Verify service is defined in docker-compose.yml
if ! grep -q "  $SERVICE_NAME:" "$COMPOSE_FILE"; then
    echo "Error: Service '$SERVICE_NAME' not found in $COMPOSE_FILE"
    echo "Available services:"
    grep "^  [a-z].*:$" "$COMPOSE_FILE" | sed 's/://g' | sed 's/^/  - /'
    exit 1
fi

# Step 3: Deploy using Docker Compose
log "Deploying service with Docker Compose..."
cd /home/ubuntu/fms
docker compose --env-file "$ENV_FILE" up -d --no-deps "$SERVICE_NAME"

# Step 4: Wait for container to be healthy
log "Waiting for container to start..."
sleep 5

# Check if container is running
if docker ps | grep -q "$SERVICE_NAME"; then
    log "✓ Container $SERVICE_NAME is running"
    docker ps | grep "$SERVICE_NAME"
else
    log "✗ Warning: Container $SERVICE_NAME may not be running"
    docker ps -a | grep "$SERVICE_NAME" || true
fi

# Step 5: Prune old images to save space
log "Pruning dangling images..."
docker image prune -f

log "Deployment of $SERVICE_NAME completed successfully!"
