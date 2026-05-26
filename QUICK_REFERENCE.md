# Quick Reference Guide

## Multi-Environment Pipeline at a Glance

### Environment Comparison

```
┌─────────────┬──────────────────┬────────────────────┬──────────────────┐
│ Environment │ Trigger          │ Build File         │ Artifact Path    │
├─────────────┼──────────────────┼────────────────────┼──────────────────┤
│ Dev         │ Manual           │ cloudbuild.yaml    │ gs://bucket/dev/ │
│ Stage       │ PR to stage      │ cloudbuild-stage   │ gs://bucket/st./ │
│ Prod        │ Manual (copy)    │ cloudbuild-prod    │ gs://bucket/pr./ │
└─────────────┴──────────────────┴────────────────────┴──────────────────┘
```

### One-Line Summary
- **Dev**: Manual trigger, fresh build
- **Stage**: PR trigger, fresh build (validation environment)
- **Prod**: Manual trigger, copy artifacts (safe promotion)

---

## Common Tasks

### 🎯 Deploy to Stage
```bash
# 1. Create feature branch
git checkout -b feature/my-changes

# 2. Make changes to dfs-ai-agent/
# 3. Push and create PR to stage
git add dfs-ai-agent/
git commit -m "feat: update agent config"
git push origin feature/my-changes

# 4. Create PR on GitHub (from feature → stage)
# → Build triggers automatically
# → Check Cloud Build console for logs
```

### 🚀 Promote to Production
```bash
# After stage PR is merged and approved:
gcloud builds submit \
  --config=cloudbuild-prod.yaml \
  --no-source \
  --region=us-central1

# Or use Cloud Build UI:
# Cloud Build → Triggers → prod-manual-trigger → Run
```

### 🔍 Check Build Status
```bash
# List recent builds
gcloud builds list --limit=10

# Stream specific build logs
gcloud builds log BUILD_ID --stream

# Cloud Build UI
# https://console.cloud.google.com/cloud-build/builds
```

### 📦 List Artifacts
```bash
# Dev artifacts
gsutil ls -R gs://<your-bucket>/dev/

# Stage artifacts
gsutil ls -R gs://<your-bucket>/stage/

# Prod artifacts
gsutil ls -R gs://<your-bucket>/prod/
```

---

## Build Failure Troubleshooting

### Stage build failed
```
1. Check Cloud Build logs
2. Fix issue in feature branch
3. Push update → PR update triggers rebuild
```

### Prod build failed
```
1. Check if stage artifacts exist:
   gsutil ls gs://<your-bucket>/stage/

2. If missing, re-run stage build:
   - Create dummy PR to stage
   - Or manually trigger stage build

3. Then retry prod build
```

---

## Important Files Reference

| File | Purpose |
|---|---|
| `cloudbuild.yaml` | Dev build (manual) |
| `cloudbuild-stage.yaml` | Stage build (PR-triggered) |
| `cloudbuild-prod.yaml` | Prod build (manual, copy strategy) |
| `terraform/main.tf` | GCS bucket, service account, triggers |
| `terraform/variables.tf` | Configuration variables |
| `terraform/outputs.tf` | Output values (bucket, SA email, trigger IDs) |
| `DEPLOYMENT.md` | Full deployment documentation |
| `dfs-ai-agent/` | Agent config (app.json, environment.json, etc.) |

---

## Key Decisions

✅ **Stage triggers on PR**: Allows full validation before merge
✅ **Prod copies artifacts**: Ensures tested code goes to production
✅ **Prod is manual-only**: Prevents accidental production deployments
✅ **GCS versioning enabled**: Easy rollback if needed
✅ **Service account with minimal perms**: Security best practice

---

## Terraform Quick Setup

```bash
cd terraform
terraform init      # Initialize
terraform plan      # Review changes
terraform apply     # Create resources

# Then verify outputs
terraform output
```

**Created resources**:
- ✓ GCS bucket (versioning, lifecycle)
- ✓ Cloud Build service account
- ✓ Stage trigger (PR-based)
- ✓ Prod trigger (manual)
- ✓ IAM roles
- ✓ Secret Manager

---

## Monitoring

### Cloud Build Console
https://console.cloud.google.com/cloud-build

### Cloud Storage Browser
https://console.cloud.google.com/storage/

### Secret Manager
https://console.cloud.google.com/security/secret-manager

### CX Agent Studio
https://studio.example.com

---

## Team Workflows

### PR Reviewers
1. Review code changes
2. Check stage build logs in PR
3. Verify stage deployment works
4. Approve and merge

### DevOps/Release Engineer
1. Monitor stage deployments
2. Validate stage environment
3. Trigger prod build when ready
4. Monitor prod deployment

### Developers
1. Create feature branches
2. Open PR to stage
3. Monitor build in Cloud Build console
4. Respond to build failures

---

## Safety Mechanisms

1. **Stage artifacts verified** - Prod build checks stage artifacts exist
2. **Manual prod trigger** - Prevents accidental production deployments
3. **GCS versioning** - Can rollback to previous artifact versions
4. **Build logs archived** - Full audit trail of all deployments
5. **Service account separation** - Explicit permissions, not broad access

---

## Cost Optimization

- GCS versioning: Delete old versions after 30 days
- Build artifacts: Stored in existing bucket (no extra costs)
- Cloud Build: Only charged for build minutes (not storage)
- Service account: No direct costs

---

## FAQ

**Q: What if stage build fails?**
A: Fix the issue in your feature branch, push update → PR rebuild triggers automatically

**Q: How do I rollback prod?**
A: Re-run prod build (it copies latest stage artifacts) OR restore GCS version

**Q: Can I deploy to prod without going through stage?**
A: Not recommended. Modify cloudbuild-prod.yaml if you need direct deploy

**Q: How are service accounts managed?**
A: Terraform creates and manages them. Use `terraform output` to get email

**Q: What if I need to change app IDs?**
A: Update `_APP_ID` in the respective cloudbuild*.yaml file or use substitutions

---

**Documentation**: See `DEPLOYMENT.md` for complete guide
**Implementation Summary**: See `IMPLEMENTATION_SUMMARY.md` for details
**Last Updated**: 2026-05-23
