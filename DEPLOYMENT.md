# Multi-Environment Deployment Workflow

## Overview

This document explains how to use the multi-environment CI/CD pipeline for the AI Agent Chatbot project. The pipeline supports three environments:

- **Dev**: For development and testing
- **Stage**: For pre-production validation (triggers on PR)
- **Prod**: Production environment (manual trigger only)

## Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                   Git Repository                             │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  Feature Branch  →  PR to Stage  →  Merge to Stage           │
│                        ↓                                       │
│                   (AUTO TRIGGER)                              │
│                   cloudbuild-stage.yaml                       │
│                        ↓                                       │
│          Stage CX Studio + GCS: gs://<your-bucket>/stage/     │
│                        ↓ (manual approval)                    │
│                   When ready for prod...                      │
│                        ↓                                       │
│         gcloud builds submit --config=cloudbuild-prod.yaml    │
│                        ↓                                       │
│          Prod CX Studio + GCS: gs://<your-bucket>/prod/       │
└──────────────────────────────────────────────────────────────┘
```

## Artifacts and Promotion Strategy

### Generated Artifacts
Each environment build generates:
1. **embed.html** - Chat messenger embed code for websites
2. **chatbot-ui-fixes.js** - UI customization script

### Storage by Environment
- **Dev**: `gs://<your-bucket>/dev/`
- **Stage**: `gs://<your-bucket>/stage/`
- **Prod**: `gs://<your-bucket>/prod/`

### Promotion Flow
- **Dev → Stage**: Manual (via PR)
- **Stage → Prod**: Copy verified artifacts (no rebuild)
  - Ensures prod uses tested artifacts
  - Faster deployment
  - Reduced deployment risk

## Development Workflow

### 1. Development on Feature Branch

```bash
# Create feature branch
git checkout -b feature/my-feature

# Make changes to dfs-ai-agent/ config
# Update app.json, environment.json, etc.

# Commit changes
git add dfs-ai-agent/
git commit -m "feat: update agent configuration"

# Push to remote
git push origin feature/my-feature
```

### 2. Create PR to Stage Branch

```bash
# Create pull request to stage branch on GitHub
# This triggers cloudbuild-stage.yaml automatically
```

When you create a PR, the **stage build** runs:
- ✅ Validates configuration (JSON, custom validation)
- ✅ Deploys to Stage CX Agent Studio
- ✅ Generates embed code
- ✅ Uploads artifacts to `gs://<your-bucket>/stage/`

**Review the build logs** in [Cloud Build Console](https://console.cloud.google.com/cloud-build/builds)

### 3. Review and Test

In the PR, you can:
- Review code changes
- Check build logs
- Test the stage chatbot embed
- Download files from `gs://<your-bucket>/stage/`

### 4. Merge to Stage

Once approved:
```bash
# Merge PR to stage branch on GitHub
# (Stage artifacts are now finalized)
```

## Promoting to Production

### Prerequisites
- [ ] PR has been merged to `stage` branch
- [ ] Stage build completed successfully
- [ ] Team has validated stage deployment
- [ ] CX Agent Studio stage app is working correctly

### Manual Trigger for Production

When ready to promote to production:

**Option 1: Cloud Build Console (Easiest)**
1. Go to [Cloud Build Console](https://console.cloud.google.com/cloud-build/triggers)
2. Find trigger named **"prod-manual-trigger"**
3. Click **Run Build**
4. Build starts immediately

**Option 2: gcloud CLI**
```bash
# List available triggers
gcloud builds list

# Manually trigger prod build
gcloud builds submit \
  --config=cloudbuild-prod.yaml \
  --no-source \
  --region=us-central1
```

**Option 3: GitHub Actions (if configured)**
```bash
# Push a tag to trigger automated workflows
git tag v1.0.0
git push origin v1.0.0
```

### What Happens in Prod Build

1. **Verify** stage artifacts exist
   - `gs://<your-bucket>/stage/embed.html`
   - `gs://<your-bucket>/stage/chatbot-ui-fixes.js`

2. **Copy** verified artifacts to prod
   - `gs://<your-bucket>/prod/embed.html`
   - `gs://<your-bucket>/prod/chatbot-ui-fixes.js`

3. **Deploy** to Production CX Agent Studio
   - Uses `dfs-ai-agent/` config
   - Updates prod CX Studio app

4. **Verify** deployment
   - Check [CX Agent Studio Dashboard](https://studio.example.com)
   - Verify all integrations working
   - Check logs for errors

## Troubleshooting

### Build Failures

**Stage build failed:**
```bash
# Check logs in Cloud Build Console
# Look for validation or deployment errors
# Fix issues in feature branch
# Push changes → PR update triggers build again
```

**Prod build failed:**
```bash
# Check if stage artifacts exist
gsutil ls -R gs://<your-bucket>/stage/

# Verify stage app is deployed correctly
# Re-run stage build if artifacts are missing
```

### Artifact Issues

**Stage artifacts missing:**
```bash
# Check stage GCS folder
gsutil ls -R gs://<your-bucket>/stage/

# Verify stage build completed successfully
# Look at Cloud Build logs
```

**Need to roll back prod:**
```bash
# Stage still has verified artifacts
# Run prod build again - it will re-copy latest stage artifacts
gcloud builds submit --config=cloudbuild-prod.yaml --no-source
```

## Infrastructure Management (Terraform)

### Initial Setup

```bash
# Navigate to terraform directory
cd terraform

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan resources
terraform plan -out=tfplan

# Apply configuration
terraform apply tfplan
```

### What Terraform Manages

- ✅ GCS bucket for artifacts
- ✅ Cloud Build service account
- ✅ Cloud Build triggers (stage PR, prod manual)
- ✅ IAM roles and permissions
- ✅ Secret Manager for API keys

### Updating Infrastructure

```bash
# Make changes to .tf files

# Plan changes
terraform plan

# Review and apply
terraform apply
```

### Environment Variables

Configure in `terraform.tfvars`:
```hcl
gcp_project_id  = "YOUR_GCP_PROJECT_ID"
gcp_region      = "us-central1"
gcs_bucket_name = "your-artifacts-bucket"
```

## Cloud Build Configuration

### Dev Build (`cloudbuild.yaml`)
- **Trigger**: Manual
- **Config**: Production-ready dev environment
- **Deployment**: Dev CX Agent Studio app
- **Artifacts**: `gs://bucket/dev/`

### Stage Build (`cloudbuild-stage.yaml`)
- **Trigger**: PR to `stage` branch
- **Config**: Same as dev, but with stage-specific settings
- **Deployment**: Stage CX Agent Studio app
- **Artifacts**: `gs://bucket/stage/`

### Prod Build (`cloudbuild-prod.yaml`)
- **Trigger**: Manual only
- **Strategy**: Copy + Deploy (no rebuild)
- **Deployment**: Prod CX Agent Studio app
- **Artifacts**: `gs://bucket/prod/`

## Best Practices

1. **Always test in stage first** before promoting to prod
2. **Use PRs for code review** - stage builds provide CI validation
3. **Monitor deployments** - check CX Agent Studio logs after promotion
4. **Document changes** - include what changed in PRs
5. **Rollback strategy** - keep stage artifacts as fallback
6. **Keep terraform state** - use GCS backend for team collaboration

## Quick Commands Reference

```bash
# Create feature branch
git checkout -b feature/my-feature

# Push and create PR to stage
git push origin feature/my-feature
# Then create PR on GitHub

# Check stage build logs
gcloud builds log [BUILD_ID] --stream

# List stage artifacts
gsutil ls -R gs://<your-bucket>/stage/

# Trigger prod manually
gcloud builds submit --config=cloudbuild-prod.yaml --no-source

# Monitor Terraform
terraform plan
terraform apply

# Rollback (re-copy stage artifacts)
gcloud builds submit --config=cloudbuild-prod.yaml --no-source
```

## Additional Resources

- [Cloud Build Documentation](https://cloud.google.com/build/docs)
- [Cloud Storage Documentation](https://cloud.google.com/storage/docs)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [CX Agent Studio Dashboard](https://studio.example.com)

---

**Last Updated**: 2026-05-23
**Version**: 1.0
