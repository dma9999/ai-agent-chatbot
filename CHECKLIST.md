# Implementation Checklist

## ✅ Completed
- [x] Create `cloudbuild-stage.yaml` (PR-triggered auto build)
- [x] Create `cloudbuild-prod.yaml` (manual build with artifact copying)
- [x] Create Terraform infrastructure code (`main.tf`, `variables.tf`, `outputs.tf`)
- [x] Create comprehensive deployment documentation (`DEPLOYMENT.md`)
- [x] Create implementation summary (`IMPLEMENTATION_SUMMARY.md`)
- [x] Create quick reference guide (`QUICK_REFERENCE.md`)
- [x] Update README.md with overview

---

## ⏭️ Next Steps (For Your Team)

### Phase 1: Infrastructure Setup (Week 1)
- [ ] **Review Terraform configuration**
  - File: `terraform/main.tf`
  - Verify GCP project ID and region are correct
  - Check bucket name is unique and available
  
- [ ] **Initialize Terraform**
  ```bash
  cd terraform
  terraform init
  terraform plan -out=tfplan
  # Review the plan output
  terraform apply tfplan
  ```
  
- [ ] **Verify resources created**
  ```bash
  terraform output
  # Should show:
  # - GCS bucket name
  # - Cloud Build service account email
  # - Stage trigger ID
  # - Prod trigger ID
  ```

- [ ] **Configure Terraform backend** (optional but recommended)
  - Uncomment backend block in `terraform/main.tf`
  - Create separate GCS bucket for state
  - Run `terraform init` to migrate state

### Phase 2: Cloud Build Configuration (Week 1)
- [ ] **Verify Cloud Build triggers created**
  - Go to: https://console.cloud.google.com/cloud-build/triggers
  - Confirm `stage-pr-trigger` exists
  - Confirm `prod-manual-trigger` exists

- [ ] **Connect repository to Cloud Build**
  - If not already connected, use Cloud Build UI to authorize GitHub repo
  - This allows automated triggers to work

- [ ] **Review substitution variables**
  - Check each `cloudbuild*.yaml` file
  - Verify `_APP_ID` values match your CX Studio app names
  - Update `_GCS_BUCKET` if using different bucket name

- [ ] **Test stage trigger manually** (optional first-time check)
  ```bash
  gcloud builds submit \
    --config=cloudbuild-stage.yaml \
    --no-source \
    --region=us-central1
  ```

### Phase 3: Testing & Validation (Week 1-2)
- [ ] **Create test feature branch**
  ```bash
  git checkout -b test/pipeline-validation
  # Make a small test change to dfs-ai-agent/
  git push origin test/pipeline-validation
  ```

- [ ] **Create PR to stage branch**
  - Go to GitHub
  - Create PR: `test/pipeline-validation` → `stage`
  - Watch for stage build to trigger automatically
  - Monitor Cloud Build console for logs

- [ ] **Verify stage build success**
  - Check Cloud Build logs
  - Verify deployment to Stage CX Studio
  - Check artifacts uploaded: `gsutil ls gs://bucket/stage/`

- [ ] **Merge PR to stage**
  - Approve PR on GitHub
  - Merge to stage branch

- [ ] **Test manual prod trigger**
  ```bash
  gcloud builds submit \
    --config=cloudbuild-prod.yaml \
    --no-source \
    --region=us-central1
  ```

- [ ] **Verify prod deployment**
  - Check Cloud Build logs
  - Verify deployment to Prod CX Studio
  - Check artifacts uploaded: `gsutil ls gs://bucket/prod/`

### Phase 4: Team Training (Week 2)
- [ ] **Document team access**
  - Who has Cloud Build access?
  - Who can manually trigger prod deployments?
  - Who reviews stage PRs?

- [ ] **Create team runbooks**
  - Print or share `QUICK_REFERENCE.md` with team
  - Share `DEPLOYMENT.md` for detailed procedures
  - Set up team Slack channel for deployment notifications

- [ ] **Establish release process**
  - Define who can approve stage PRs
  - Define who can trigger prod deployments
  - Create approval checklist

- [ ] **Set up monitoring**
  - Subscribe to Cloud Build notifications
  - Set up alerts for failed builds
  - Monitor GCS bucket usage

### Phase 5: Production Readiness (Week 2-3)
- [ ] **Smoke test complete workflow**
  - Feature branch → Stage PR → Approval → Merge → Prod trigger
  - Verify all steps work smoothly

- [ ] **Test rollback procedure**
  - Understand how to revert if needed
  - Document rollback steps

- [ ] **Review security**
  - Verify service account has minimal permissions
  - Check IAM roles are correct
  - Review Secret Manager setup

- [ ] **Performance validation**
  - Time each build step
  - Ensure stage builds complete within SLA
  - Verify artifact copy speed

---

## 📋 Configuration Checklist

Before going to production, ensure:

- [ ] GCP Project ID is correct in all files
- [ ] GCS bucket name is unique and available
- [ ] Cloud Build service account has proper permissions
- [ ] CX Studio app IDs are correct:
  - Dev: `dfs-ai-agent_DEV`
  - Stage: `dfs-ai-agent_STAGE`
  - Prod: `dfs-ai-agent_PROD`
- [ ] GitHub repository is connected to Cloud Build
- [ ] Cloud Build triggers are configured (Stage PR, Prod manual)
- [ ] IAM roles are correctly assigned
- [ ] Secret Manager secret created for API keys
- [ ] GCS bucket versioning is enabled
- [ ] Terraform backend is configured (optional)

---

## 📚 Documentation Checklist

Share with team:

- [ ] `README.md` - Overview and quick start
- [ ] `DEPLOYMENT.md` - Complete deployment guide
- [ ] `QUICK_REFERENCE.md` - Common commands and tasks
- [ ] `IMPLEMENTATION_SUMMARY.md` - Technical details
- [ ] This file - Implementation checklist

---

## 🎯 Success Criteria

✅ Pipeline is successful when:

1. **Stage Trigger Works**
   - PR to stage branch automatically triggers build
   - Build completes successfully
   - Artifacts uploaded to `gs://bucket/stage/`
   - Stage CX Studio app is updated

2. **Prod Trigger Works**
   - Manual trigger starts prod build
   - Verifies stage artifacts exist
   - Copies artifacts to `gs://bucket/prod/`
   - Deploys to Prod CX Studio app

3. **Team Can Use Pipeline**
   - Developers can create PRs to stage
   - Build logs are accessible
   - Artifacts can be downloaded
   - Prod deployments can be triggered

4. **Infrastructure Is Manageable**
   - Terraform can plan and apply changes
   - Service account has correct permissions
   - Secrets are safely stored
   - All resources are tagged and organized

---

## ⚠️ Common Issues & Fixes

### Build Fails Due to Missing App ID
- **Problem**: `cloudbuild-stage.yaml` references wrong `_APP_ID`
- **Fix**: Update `_APP_ID` in the yaml file to match your CX Studio app

### Prod Build Cannot Find Stage Artifacts
- **Problem**: Stage artifacts don't exist in `gs://bucket/stage/`
- **Fix**: Re-run stage build, verify it completes successfully

### Cloud Build Lacks Permissions
- **Problem**: Cloud Build fails with "permission denied"
- **Fix**: Check Terraform output for service account email, grant IAM roles

### Terraform State Lock Issues
- **Problem**: Terraform locked waiting for backend to unlock
- **Fix**: Ensure only one person runs `terraform apply` at a time

---

## 🆘 Getting Help

If you encounter issues:

1. **Check Cloud Build logs**
   - https://console.cloud.google.com/cloud-build/builds
   - Look for error messages in step outputs

2. **Check GCS bucket**
   - https://console.cloud.google.com/storage
   - Verify artifacts are being uploaded

3. **Review documentation**
   - `DEPLOYMENT.md` - Troubleshooting section
   - `QUICK_REFERENCE.md` - FAQ section

4. **Check Terraform state**
   ```bash
   terraform output
   terraform state show google_storage_bucket.agent_artifacts
   ```

5. **Test manually**
   ```bash
   # Test stage build
   gcloud builds submit --config=cloudbuild-stage.yaml --no-source

   # Test prod build
   gcloud builds submit --config=cloudbuild-prod.yaml --no-source
   ```

---

## 📞 Support Contacts

**For questions about:**
- **Cloud Build**: GCP Cloud Build documentation
- **Terraform**: Terraform GCP provider docs
- **CX Agent Studio**: Internal team / product team
- **Pipeline design**: DevOps team

---

**Last Updated**: 2026-05-23
**Status**: Ready for implementation
**Version**: 1.0
