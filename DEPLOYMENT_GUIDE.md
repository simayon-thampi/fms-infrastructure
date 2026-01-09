# FMS CI/CD Deployment Guide

**Simple, step-by-step guide to deploy your FMS services**

---

## 🎯 What This Setup Does

Automatically deploys your 11 FMS microservices to AWS EC2 when you trigger a GitHub workflow.

---

## 📋 One-Time Setup (Do Once)

### Step 1: Configure GitHub Secrets

Add these secrets to your GitHub repository:

1. Go to: **GitHub repo → Settings → Secrets and variables → Actions**
2. Click **New repository secret**
3. Add these 3 secrets:

| Secret Name | Value | How to Get It |
|-------------|-------|---------------|
| `EC2_SSH_PRIVATE_KEY` | Your SSH private key | `cat ~/.ssh/your-key.pem` |
| `EC2_HOST` | Your EC2 IP or hostname | `your-ec2-ip` or `ec2.example.com` |
| `EC2_USERNAME` | EC2 username | Usually `ubuntu` |

### Step 2: Setup EC2 Server

SSH into your EC2 and run:

```bash
# Create directory
mkdir -p /home/ubuntu/fms

# Create Docker network
docker network create fmsnet

# Create storage directories
mkdir -p /home/ubuntu/FMS-localstorage/{app-icons,logos,license,zone_map,plant_image,zone_image,map_yaml,zones}
```

### Step 3: Configure Environment Variables

1. **On your local machine**, edit `.env` file:
   ```bash
   cd /home/trizlabz-5nbcet/Documents/WORK/cicd-pipeline/fms
   cp .env.example .env
   vim .env  # Update with your actual passwords and settings
   ```

2. **Copy `.env` to EC2**:
   ```bash
   scp .env ubuntu@your-ec2-host:/home/ubuntu/fms/.env
   ```

**Done!** ✅ Setup complete.

---

## 🚀 How to Deploy Services

### Method 1: Deploy via GitHub Web UI (Easiest)

1. Go to your GitHub repository
2. Click **Actions** tab
3. Click **Deploy FMS Services** workflow
4. Click **Run workflow** button
5. Choose what to deploy:
   - Type `all` → Deploys all 11 services
   - Type `application-service` → Deploys only that service
   - Type `application-service,user-service` → Deploys multiple services
6. Click **Run workflow**

**That's it!** GitHub will deploy your services.

### Method 2: Deploy via Command Line

```bash
# Deploy all services
gh workflow run deploy.yml -f services="all"

# Deploy one service
gh workflow run deploy.yml -f services="application-service"

# Deploy multiple services
gh workflow run deploy.yml -f services="application-service,user-service"
```

---

## 📊 What Happens When You Deploy

```
1. GitHub Actions starts
   ↓
2. Transfers files to EC2:
   - docker-compose.yml
   - .env
   - deploy.sh
   ↓
3. Runs on EC2:
   docker-compose --env-file .env up -d service-name
   ↓
4. Service starts running
   ↓
5. Done! ✅
```

---

## 🔍 How to Check if Deployment Worked

### Check GitHub Actions

1. Go to **Actions** tab
2. Click on the running workflow
3. Watch the progress
4. ✅ Green = Success
5. ❌ Red = Failed (check logs)

### Check on EC2

```bash
# SSH to EC2
ssh ubuntu@your-ec2-host

# Check if services are running
docker ps

# Check specific service
docker ps | grep application-service

# View logs
docker logs application-service
```

---

## 🛠️ Common Tasks

### Update a Service

1. Make changes to your service code (in service's own repo)
2. Build new Docker image
3. Push image to registry OR transfer to EC2
4. Deploy via GitHub Actions:
   ```bash
   gh workflow run deploy.yml -f services="your-service-name"
   ```

### Change Configuration

1. Edit `.env` file locally
2. Copy to EC2:
   ```bash
   scp .env ubuntu@your-ec2-host:/home/ubuntu/fms/.env
   ```
3. Redeploy affected services:
   ```bash
   gh workflow run deploy.yml -f services="all"
   ```

### Restart a Service

```bash
# SSH to EC2
ssh ubuntu@your-ec2-host

# Restart service
cd /home/ubuntu/fms
docker-compose restart application-service
```

### View Service Logs

```bash
# SSH to EC2
ssh ubuntu@your-ec2-host

# View logs
docker logs -f application-service
```

---

## 📁 Your Services

| Service Name | Port | What It Does |
|--------------|------|--------------|
| `application-service` | 8003 | App management |
| `user-service` | 8002 | User auth |
| `device-core` | 8004 | Device telemetry |
| `mission-service` | 8005 | Mission planning |
| `deployment-service` | 8006 | Zone management |
| `dashboard-service` | 8007 | Analytics |
| `alert-service` | 8008 | Alerts |
| `traffic-management-service` | 8009 | Traffic control |
| `analytics-service` | 8010 | Reporting |
| `log-service` | 8011 | Logging |
| `fmscore-frontend` | 3000 | Web UI |

---

## ❌ Troubleshooting

### Deployment Failed

**Check GitHub Actions logs**:
1. Go to Actions tab
2. Click failed workflow
3. Read error message

**Common fixes**:
- Check EC2 is accessible: `ssh ubuntu@your-ec2-host`
- Check `.env` exists on EC2: `ssh ubuntu@your-ec2-host "cat /home/ubuntu/fms/.env"`
- Check Docker is running: `ssh ubuntu@your-ec2-host "docker ps"`

### Service Won't Start

```bash
# SSH to EC2
ssh ubuntu@your-ec2-host

# Check logs
docker logs application-service

# Check if it's defined
grep "application-service:" /home/ubuntu/fms/docker-compose.yml
```

### Can't Connect to Service

1. Check service is running: `docker ps`
2. Check port mapping in `docker-compose.yml`
3. Check firewall/security groups on EC2

---

## 🎓 Quick Reference

### Deploy Commands

```bash
# All services
gh workflow run deploy.yml -f services="all"

# One service
gh workflow run deploy.yml -f services="application-service"

# Multiple services  
gh workflow run deploy.yml -f services="app-service,user-service"
```

### EC2 Commands

```bash
# View running services
docker ps

# View all services (including stopped)
docker ps -a

# View logs
docker logs service-name

# Restart service
docker-compose restart service-name

# Stop service
docker-compose stop service-name

# Start service
docker-compose start service-name
```

---

## 📞 Need Help?

1. **Check logs**: GitHub Actions logs or `docker logs service-name`
2. **Verify setup**: Ensure EC2 setup steps were completed
3. **Check .env**: Ensure `.env` file exists on EC2 with correct values

---

## ✅ Summary

**To deploy services**:
1. Go to GitHub → Actions → Deploy FMS Services
2. Click "Run workflow"
3. Enter service names (or "all")
4. Click "Run workflow"
5. Done!

**That's it!** The system handles everything else automatically.
