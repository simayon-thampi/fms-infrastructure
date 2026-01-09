# Git Setup and Submodule Guide

## Step 1: Initialize Git Repository

```bash
cd /home/trizlabz-5nbcet/Documents/WORK/cicd-pipeline/fms

# Initialize git
git init

# Add all essential files
git add .

# Create initial commit
git commit -m "feat: initial FMS infrastructure setup

- Add GitHub Actions deployment workflow
- Add docker-compose configuration for 11 services
- Add environment configuration (.env.example)
- Add deployment scripts
- Add comprehensive deployment guide"
```

## Step 2: Push to GitHub

```bash
# Add remote (replace with your GitHub repo URL)
git remote add origin https://github.com/YOUR_USERNAME/fms-infrastructure.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## Step 3: Add Service Submodules

Once the infrastructure repo is pushed, add your service repositories as submodules:

```bash
# Create services directory
mkdir -p services

# Add each service as a submodule
# Replace URLs with your actual service repository URLs

git submodule add https://github.com/YOUR_ORG/fms-application-service.git services/application-service
git submodule add https://github.com/YOUR_ORG/fms-user-service.git services/user-service
git submodule add https://github.com/YOUR_ORG/fms-device-core.git services/device-core
git submodule add https://github.com/YOUR_ORG/fms-mission-service.git services/mission-service
git submodule add https://github.com/YOUR_ORG/fms-deployment-service.git services/deployment-service
git submodule add https://github.com/YOUR_ORG/fms-dashboard-service.git services/dashboard-service
git submodule add https://github.com/YOUR_ORG/fms-alert-service.git services/alert-service
git submodule add https://github.com/YOUR_ORG/fms-traffic-management-service.git services/traffic-management-service
git submodule add https://github.com/YOUR_ORG/fms-analytics-service.git services/analytics-service
git submodule add https://github.com/YOUR_ORG/fms-log-service.git services/log-service
git submodule add https://github.com/YOUR_ORG/fms-fmscore-frontend.git services/fmscore-frontend

# Commit the submodule additions
git add .gitmodules services/
git commit -m "feat: add service repositories as submodules"
git push
```

## Step 4: Verify Submodules

```bash
# List all submodules
git submodule status

# Initialize and update submodules
git submodule init
git submodule update
```

## Step 5: Update .gitignore (if needed)

The `.gitignore` already excludes unnecessary files. Verify it includes:

```
.env
.env.local
logs/
certbot/
dockers/
```

## Working with Submodules

### Clone the repo with submodules
```bash
git clone --recurse-submodules https://github.com/YOUR_USERNAME/fms-infrastructure.git
```

### Update all submodules to latest
```bash
git submodule update --remote --merge
```

### Update specific submodule
```bash
cd services/application-service
git pull origin main
cd ../..
git add services/application-service
git commit -m "chore: update application-service submodule"
git push
```

## Important Notes

1. **Submodules are pointers**: They point to specific commits in the service repos
2. **Update carefully**: When updating submodules, commit the changes in the infrastructure repo
3. **CI/CD**: The workflow doesn't need the service code - it just deploys pre-built images

## What Gets Committed

**Infrastructure Repo**:
- ✅ Workflow files
- ✅ Docker compose
- ✅ Scripts
- ✅ Documentation
- ✅ .env.example (template)
- ✅ .gitmodules (submodule config)
- ❌ .env (gitignored - sensitive)
- ❌ Service source code (in submodules)

**Service Repos** (separate):
- ✅ Service source code
- ✅ Dockerfile
- ✅ package.json
- ✅ Tests
- ❌ Deployment config (in infrastructure repo)
