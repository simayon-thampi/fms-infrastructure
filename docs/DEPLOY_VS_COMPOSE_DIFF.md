# Differences Between deploy.sh and docker-compose.prod.yml

## Key Discrepancies Found

### 1. **Environment Variables**
**docker-compose.prod.yml:**
- Uses explicit environment variables (lines 52-68)
- All env vars defined inline
- No --env-file flag

**deploy.sh:**
- Uses `--env-file /home/ubuntu/fms/.env`
- Loads from external file

**Impact:** Different environment loading mechanism

---

### 2. **Volume Mounts**
**docker-compose.prod.yml:**
```yaml
volumes:
  - ./certs/internal/application-service.crt:/etc/service-certs/cert.crt:ro
  - ./certs/internal/application-service.key:/etc/service-certs/cert.key:ro
  - /home/ubuntu/FMS-localstorage/app-icons:/app/uploads/app-icons
```

**deploy.sh:**
```bash
-v /home/ubuntu/fms/uploads:/app/uploads
```

**Impact:** 
- Missing SSL certificate mounts
- Different upload directory path
- Missing read-only flags

---

### 3. **Docker Network**
**docker-compose.prod.yml:**
- Network: `fmsnet` (custom bridge network)
- Part of multi-service stack

**deploy.sh:**
- Auto-detects network from existing container
- Falls back to `bridge`

**Impact:** May connect to wrong network

---

### 4. **Extra Hosts**
**docker-compose.prod.yml:**
```yaml
extra_hosts:
  - "host.docker.internal:host-gateway"
```

**deploy.sh:**
- Missing extra_hosts configuration

**Impact:** Cannot access host services (PostgreSQL, etc.)

---

### 5. **Container Name**
**docker-compose.prod.yml:**
- `container_name: application-service`

**deploy.sh:**
- `CONTAINER_NAME="application-service"` ✅ (matches)

---

### 6. **Image Name**
**docker-compose.prod.yml:**
- `image: fms-application-service:stable`

**deploy.sh:**
- `IMAGE_NAME="fms-application-service"` ✅ (matches)

---

## Recommended Changes to deploy.sh

### Option 1: Match docker-compose exactly (Recommended)
Update deploy.sh to use same configuration as docker-compose:

```bash
docker run -d \
    --name "$CONTAINER_NAME" \
    --network fmsnet \
    --restart unless-stopped \
    --add-host host.docker.internal:host-gateway \
    -v /home/ubuntu/fms/certs/internal/application-service.crt:/etc/service-certs/cert.crt:ro \
    -v /home/ubuntu/fms/certs/internal/application-service.key:/etc/service-certs/cert.key:ro \
    -v /home/ubuntu/FMS-localstorage/app-icons:/app/uploads/app-icons \
    -e NODE_ENV=production \
    -e PORT=8003 \
    -e DATABASE_URL=postgresql://admin:password@host.docker.internal:5432/applications \
    -e POSTGRES_HOST=host.docker.internal \
    -e POSTGRES_PORT=5432 \
    -e POSTGRES_USER=admin \
    -e POSTGRES_PASSWORD=password \
    -e POSTGRES_DB=applications \
    -e SECRET_KEY=Gy8-9R8myuWWxZjibPS63oXYrG_Zq9RmepKIRRUr91o \
    -e ALGORITHM=HS256 \
    -e ACCESS_TOKEN_EXPIRE_MINUTES=30 \
    -e MQTT_BROKER_HOST=localhost \
    -e MQTT_BROKER_PORT=1883 \
    -e API_STR=/api \
    -e BACKEND_CORS_ORIGINS=https://localhost:8443 \
    -e UPLOAD_DIRECTORY=/app/uploads/app-icons \
    "${IMAGE_NAME}:${IMAGE_TAG}"
```

### Option 2: Keep .env file but add missing mounts
```bash
docker run -d \
    --name "$CONTAINER_NAME" \
    --network fmsnet \
    --restart unless-stopped \
    --add-host host.docker.internal:host-gateway \
    --env-file /home/ubuntu/fms/.env \
    -v /home/ubuntu/fms/certs/internal/application-service.crt:/etc/service-certs/cert.crt:ro \
    -v /home/ubuntu/fms/certs/internal/application-service.key:/etc/service-certs/cert.key:ro \
    -v /home/ubuntu/FMS-localstorage/app-icons:/app/uploads/app-icons \
    "${IMAGE_NAME}:${IMAGE_TAG}"
```

---

## Critical Missing Elements

1. **SSL Certificates** - Not mounted in deploy.sh
2. **host.docker.internal** - Not configured (breaks DB access)
3. **Network** - Should be `fmsnet` not auto-detected
4. **Upload Directory** - Wrong path

---

## Questions to Resolve

1. Should deploy.sh use .env file or explicit env vars?
2. Where are SSL certs located on EC2?
3. Should we create fmsnet network if it doesn't exist?
4. Is /home/ubuntu/FMS-localstorage the correct path?

---

## Recommendation

**Use Option 2** (keep .env file but add missing mounts) because:
- Maintains security (secrets in .env file)
- Easier to manage environment variables
- Just needs to add missing volume mounts and network config
