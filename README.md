# ai-agent-chatbot

A multi-environment CI/CD pipeline for AI Agent chatbot deployment with dev, stage, and production environments.

## Quick Start

See [DEPLOYMENT.md](./DEPLOYMENT.md) for the complete deployment workflow documentation.

### Key Files

- **cloudbuild.yaml** - Dev environment build
- **cloudbuild-stage.yaml** - Stage environment build (PR-triggered)
- **cloudbuild-prod.yaml** - Production environment build (manual-triggered)
- **terraform/main.tf** - Infrastructure as code for GCS, Cloud Build, and IAM
- **dfs-ai-agent/** - Agent configuration (app.json, environment.json, etc.)

### Deployment Flow

```
Feature Branch → PR to Stage → Merge → (Manual) → Production
                  ↓ AUTO BUILD          ↓ AUTO BUILD (copy artifacts)
            Stage CX Studio        Prod CX Studio
            + gs://bucket/stage/   + gs://bucket/prod/
```

## Environments

| Environment | Trigger | Build File | Status |
|---|---|---|---|
| **Dev** | Manual | `cloudbuild.yaml` | Testing |
| **Stage** | PR to stage branch | `cloudbuild-stage.yaml` | Pre-production testing |
| **Prod** | Manual trigger | `cloudbuild-prod.yaml` | Production |

## Getting Started

1. **Read the deployment guide**: See [DEPLOYMENT.md](./DEPLOYMENT.md)
2. **Set up Terraform**: `cd terraform && terraform init && terraform plan`
3. **Configure Cloud Build triggers**: Use Terraform or Cloud Build UI
4. **Make changes**: Create feature branches and PRs to stage
5. **Promote to prod**: Manually trigger production build when ready

---