#!/bin/bash
# ============================================================================
# Rollback Script for FMS Application Service
# ============================================================================
# This script rolls back to a previous version of the application
# Usage: bash rollback.sh [image_tag]
# If no tag is provided, it will use the 'rollback' tag
# ============================================================================

set -e

IMAGE_NAME="fms-application-service"
CONTAINER_NAME="application-service"
ROLLBACK_TAG="${1:-rollback}"
HEALTH_ENDPOINT="http://localhost:8003/api/fms-app-server-health"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
}

# Health check
check_health() {
    local retries=0
    local max_retries=30
    
    while [ $retries -lt $max_retries ]; do
        if curl -f -s "$HEALTH_ENDPOINT" > /dev/null 2>&1; then
            log "Health check passed!"
            return 0
        fi
        retries=$((retries + 1))
        sleep 2
    done
    
    error "Health check failed"
    return 1
}

# Main rollback
main() {
    warn "=========================================="
    warn "Starting rollback to ${IMAGE_NAME}:${ROLLBACK_TAG}"
    warn "=========================================="
    
    # Check if rollback image exists
    if ! docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "${IMAGE_NAME}:${ROLLBACK_TAG}"; then
        error "Rollback image ${IMAGE_NAME}:${ROLLBACK_TAG} not found!"
        echo "Available images:"
        docker images "$IMAGE_NAME"
        exit 1
    fi
    
    # Get network configuration
    NETWORK=$(docker inspect --format='{{range $net,$v := .NetworkSettings.Networks}}{{$net}}{{end}}' "$CONTAINER_NAME" 2>/dev/null || echo "bridge")
    
    # Stop current container
    log "Stopping current container"
    docker stop "$CONTAINER_NAME" 2>/dev/null || true
    docker rm "$CONTAINER_NAME" 2>/dev/null || true
    
    # Start with rollback image
    log "Starting container with rollback image"
    docker run -d \
        --name "$CONTAINER_NAME" \
        --network "$NETWORK" \
        --restart unless-stopped \
        --env-file /home/ubuntu/fms/.env \
        -v /home/ubuntu/fms/uploads:/app/uploads \
        "${IMAGE_NAME}:${ROLLBACK_TAG}"
    
    # Wait and check health
    log "Waiting for service to start..."
    sleep 5
    
    if check_health; then
        log "=========================================="
        log "Rollback completed successfully!"
        log "=========================================="
    else
        error "Rollback failed health check - manual intervention required!"
        exit 1
    fi
}

main
