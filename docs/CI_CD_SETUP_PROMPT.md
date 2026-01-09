# CI/CD Pipeline Setup Prompt for Microservices

Use this prompt with an LLM to set up GitHub Actions CI/CD pipeline for your microservices.

---

## PROMPT START

I need help setting up a GitHub Actions CI/CD pipeline for my microservice with automated deployment to AWS EC2. Here are the details:

### Project Information
- **Service Name**: [YOUR_SERVICE_NAME]
- **Technology Stack**: [e.g., Node.js/TypeScript, Python/FastAPI, etc.]
- **Repository**: [GITHUB_REPO_URL]
- **Development Branch**: [e.g., node-migration, develop]
- **Production Branch**: [e.g., release, main]

### EC2 Deployment Target
- **EC2 Host**: [e.g., ec2-XX-XXX-XXX-XX.region.compute.amazonaws.com]
- **EC2 Username**: [e.g., ubuntu]
- **SSH Key Path**: [e.g., ~/Downloads/your-key.pem]
- **Container Name**: [e.g., your-service-name]
- **Docker Image Name**: [e.g., your-service-name]
- **Application Port**: [e.g., 8000, 8003]
- **Health Check Endpoint**: [e.g., /api/health, /health]

### Environment Configuration
- **Environment File Location on EC2**: [e.g., /home/ubuntu/service-name/.env]
- **Uploads/Data Directory**: [e.g., /home/ubuntu/service-name/uploads]
- **Docker Network**: [e.g., service_network, bridge]
- **Required Environment Variables**: [List all required env vars]

### Deployment Preferences
- **Health Check**: [Enable/Disable - set to Disable if app has startup issues]
- **Rollback on Failure**: [Enable/Disable]
- **Zero-Downtime Deployment**: [Yes/No]
- **Keep Old Images**: [Number of old images to keep, e.g., 3]

### Requirements
Please help me set up:

1. **GitHub Actions Workflow** (`.github/workflows/deploy.yml`)
   - Trigger on push to production branch
   - Manual trigger option (workflow_dispatch)
   - Three jobs: Test, Build, Deploy
   - Conditional execution based on branch

2. **Deployment Script** (`scripts/deploy.sh`)
   - Load Docker image from artifact
   - Stop and remove old container
   - Start new container with environment variables
   - Health check (optional)
   - Automatic rollback on failure
   - Logging to `/var/log/deployments.log`
   - Cleanup old Docker images

3. **GitHub Secrets Configuration**
   - EC2_SSH_PRIVATE_KEY
   - EC2_HOST
   - EC2_USERNAME

4. **Branch Strategy Documentation**
   - Development workflow
   - Merge to production process
   - Rollback procedures

### Reference Implementation
Base the setup on this successful implementation:

**Workflow Structure:**
- Test job: Run tests and build TypeScript/compile code
- Build job: Build Docker image, save as artifact
- Deploy job: SSH to EC2, transfer image, run deployment script

**Deployment Script Features:**
- Environment variable loading from .env file
- Docker network detection
- Container health monitoring
- Automatic rollback mechanism
- Comprehensive logging
- Image cleanup

**Key Configurations:**
- Use `--env-file` for environment variables
- Mount persistent volumes for data
- Use Docker networks for service communication
- No port exposure if behind reverse proxy (Nginx)
- Disable health check if application has startup issues

### Specific Customizations Needed
[Add any specific requirements for your service, e.g.:]
- Database connection requirements
- External service dependencies
- Special build steps
- Custom health check logic
- Specific Docker network configuration

### Expected Deliverables
1. Complete `.github/workflows/deploy.yml` file
2. Complete `scripts/deploy.sh` deployment script
3. GitHub secrets setup commands (using GitHub CLI)
4. Branch workflow documentation
5. Troubleshooting guide for common issues

### Additional Context
- EC2 security group should allow SSH (port 22) from GitHub Actions IPs
- Ensure Docker is installed on EC2
- Ensure .env file exists on EC2 before first deployment
- Health check disabled by default (can be enabled later)

Please provide step-by-step implementation with all necessary files and commands.

## PROMPT END

---

## How to Use This Prompt

1. **Fill in the placeholders** with your service-specific information
2. **Copy the entire prompt** (from "PROMPT START" to "PROMPT END")
3. **Paste into your LLM** (ChatGPT, Claude, Gemini, etc.)
4. **Review the generated files** before committing
5. **Test the workflow** with a manual trigger first

## Quick Customization Guide

### For Different Tech Stacks

**Node.js/TypeScript:**
```yaml
- name: Build TypeScript
  run: npm run build
```

**Python/FastAPI:**
```yaml
- name: Run Tests
  run: pytest
```

**Go:**
```yaml
- name: Build
  run: go build -o app
```

### For Different Deployment Scenarios

**With Database:**
- Add database connection to .env
- Ensure database is accessible from container
- Add database health check

**Behind Nginx:**
- No port exposure in docker run
- Nginx proxies to container on Docker network

**Standalone Service:**
- Expose port: `-p 8003:8003`
- Configure security group for application port

## Reference Files

The following files from this repository can serve as templates:
- `.github/workflows/deploy.yml` - Workflow configuration
- `scripts/deploy.sh` - Deployment script
- `RELEASE_BRANCH_GUIDE.md` - Branch workflow
- `EC2_ENV_SETUP.md` - Environment setup

## Common Customizations

### Change Health Check Endpoint
In `deploy.sh`:
```bash
HEALTH_ENDPOINT="http://localhost:YOUR_PORT/YOUR_ENDPOINT"
```

### Change Docker Network
In `deploy.sh`:
```bash
NETWORK="your_network_name"
```

### Add Custom Build Steps
In `deploy.yml`:
```yaml
- name: Custom Build Step
  run: your-build-command
```

### Modify Rollback Behavior
In `deploy.sh`, edit the `rollback()` function

## Tips for Success

1. **Test locally first** - Use the deployment script locally before CI/CD
2. **Start simple** - Begin with health check disabled
3. **Monitor logs** - Check `/var/log/deployments.log` on EC2
4. **Use manual triggers** - Test with `workflow_dispatch` before auto-deploy
5. **Keep .env secure** - Never commit .env files to git

## Troubleshooting Reference

Common issues and solutions:
- **SSH timeout**: Check EC2 security group
- **Permission denied**: Use sudo for log writes or fix permissions
- **Health check fails**: Disable health check or fix endpoint
- **Container won't start**: Check .env file and Docker logs
- **Build fails**: Verify all source files are committed

---

## Example: Adapting for a New Service

If you have a service called "notification-service":

1. Replace `fms-application-service` with `notification-service`
2. Update port from `8003` to your service port
3. Update health endpoint path
4. Update environment variables list
5. Adjust Docker network if different
6. Modify test commands for your tech stack

That's it! The structure remains the same.
