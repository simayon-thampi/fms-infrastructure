# Quick CI/CD Setup Checklist

Use this checklist when setting up CI/CD for a new microservice.

## Pre-Setup (5 minutes)

- [ ] Gather service information:
  - [ ] Service name
  - [ ] GitHub repository URL
  - [ ] EC2 host address
  - [ ] Application port
  - [ ] Health check endpoint
  - [ ] Required environment variables

- [ ] Verify EC2 access:
  - [ ] SSH key available
  - [ ] Can SSH into EC2
  - [ ] Docker installed on EC2
  - [ ] Security group allows SSH from GitHub

## GitHub Setup (10 minutes)

- [ ] Install GitHub CLI: `gh auth login`
- [ ] Set GitHub secrets:
  ```bash
  gh secret set EC2_SSH_PRIVATE_KEY < ~/.ssh/your-key.pem
  gh secret set EC2_HOST --body "ec2-xx-xxx-xxx-xx.region.compute.amazonaws.com"
  gh secret set EC2_USERNAME --body "ubuntu"
  ```
- [ ] Verify secrets: `gh secret list`

## Repository Setup (15 minutes)

- [ ] Create `.github/workflows/deploy.yml`
  - [ ] Copy from template
  - [ ] Update service name
  - [ ] Update branch names
  - [ ] Update test commands

- [ ] Create `scripts/deploy.sh`
  - [ ] Copy from template
  - [ ] Update image name
  - [ ] Update container name
  - [ ] Update health endpoint
  - [ ] Update port/network settings

- [ ] Make script executable: `chmod +x scripts/deploy.sh`

- [ ] Commit and push to development branch

## EC2 Setup (10 minutes)

- [ ] SSH into EC2
- [ ] Create service directory:
  ```bash
  sudo mkdir -p /home/ubuntu/SERVICE_NAME
  sudo chown ubuntu:ubuntu /home/ubuntu/SERVICE_NAME
  mkdir -p /home/ubuntu/SERVICE_NAME/uploads
  ```

- [ ] Create .env file:
  ```bash
  nano /home/ubuntu/SERVICE_NAME/.env
  ```

- [ ] Add all required environment variables
- [ ] Verify .env file: `cat /home/ubuntu/SERVICE_NAME/.env`

## Testing (15 minutes)

- [ ] Trigger workflow manually:
  ```bash
  gh workflow run deploy.yml --ref PRODUCTION_BRANCH
  ```

- [ ] Monitor workflow: `gh run watch`

- [ ] Check each job:
  - [ ] Test job passes
  - [ ] Build job passes
  - [ ] Deploy job passes

- [ ] Verify on EC2:
  ```bash
  ssh user@ec2-host
  docker ps
  docker logs CONTAINER_NAME
  curl http://localhost:PORT/health
  ```

## Documentation (5 minutes)

- [ ] Create RELEASE_GUIDE.md with:
  - [ ] Branch strategy
  - [ ] Merge commands
  - [ ] Rollback procedure

- [ ] Update README.md with:
  - [ ] Deployment instructions
  - [ ] Environment variables list
  - [ ] Health check endpoint

## Troubleshooting Checklist

If deployment fails:

- [ ] Check workflow logs: `gh run view --log-failed`
- [ ] Check EC2 logs: `docker logs CONTAINER_NAME`
- [ ] Verify .env file exists and has correct variables
- [ ] Check EC2 security group allows SSH
- [ ] Verify Docker is running on EC2
- [ ] Check disk space on EC2: `df -h`

## Common Fixes

**SSH timeout:**
```bash
# Update EC2 security group to allow SSH from 0.0.0.0/0
```

**Health check fails:**
```bash
# Disable health check in deploy.sh (comment out check_health call)
```

**Container won't start:**
```bash
# Check logs: docker logs CONTAINER_NAME
# Verify .env file: cat /home/ubuntu/SERVICE_NAME/.env
```

**Permission denied:**
```bash
# Fix ownership: sudo chown -R ubuntu:ubuntu /home/ubuntu/SERVICE_NAME
```

## Success Criteria

✅ Workflow runs without errors  
✅ All three jobs pass (Test, Build, Deploy)  
✅ Container is running on EC2  
✅ Health endpoint responds (if enabled)  
✅ Application logs show no errors  

## Total Time: ~60 minutes

- Pre-setup: 5 min
- GitHub setup: 10 min
- Repository setup: 15 min
- EC2 setup: 10 min
- Testing: 15 min
- Documentation: 5 min
