# Release Branch Workflow Guide

## 🎯 Branch Strategy

**Development Branch:** `node-migration`  
**Production Branch:** `release`  
**Legacy Branch:** `main` / `master`

## 📋 Workflow

### 1. Develop on node-migration
```bash
git checkout node-migration
# Make your changes
git add .
git commit -m "Your commit message"
git push origin node-migration
```

### 2. Merge to release to trigger deployment
```bash
# Make sure you're on node-migration with latest changes
git checkout node-migration
git pull origin node-migration

# Switch to release branch
git checkout release
git pull origin release

# Merge node-migration into release
git merge node-migration

# Push to trigger deployment
git push origin release
```

### 3. Monitor deployment
```bash
gh run watch
```

## 🚀 What Happens When You Push to Release

The GitHub Actions workflow will automatically:
1. ✅ Run tests
2. ✅ Build Docker image
3. ✅ Deploy to EC2
4. ✅ Start container (health check disabled)

## ⚡ Quick Commands

### Fast merge to release:
```bash
git checkout release && \
git pull origin release && \
git merge node-migration && \
git push origin release && \
git checkout node-migration
```

### Check workflow status:
```bash
gh run list --workflow=deploy.yml --limit 5
```

### Manual trigger (if needed):
```bash
gh workflow run deploy.yml --ref release
```

## 📊 Current Configuration

- **Workflow triggers on:** `push` to `release` branch
- **Manual trigger:** Available via `workflow_dispatch`
- **Build job condition:** `github.ref == 'refs/heads/release'`
- **Deploy job condition:** `github.ref == 'refs/heads/release'`

## ⚠️ Important Notes

1. **Only push to release when ready to deploy** - Every push triggers deployment
2. **Health check is disabled** - Container will start even if app has issues
3. **Test locally first** - Make sure changes work on node-migration before merging
4. **Keep branches in sync** - Regularly merge release back to node-migration if needed

## 🔄 Rollback (if needed)

If deployment fails, you can rollback:
```bash
# On release branch
git reset --hard HEAD~1  # Go back one commit
git push origin release --force  # Force push (triggers new deployment)
```

## ✅ Verification

After deployment, verify on EC2:
```bash
ssh -i ~/Downloads/triz-server-pin-mumbai.pem ubuntu@ec2-13-204-138-62.ap-south-1.compute.amazonaws.com
docker ps
docker logs application-service
```
