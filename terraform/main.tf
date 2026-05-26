terraform {
  required_version = ">= 1.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  
  # IMPORTANT: Configure this backend to store state in GCS
  # Uncomment and update after first terraform init
  # backend "gcs" {
  #   bucket  = "your-terraform-state-bucket"
  #   prefix  = "ai-agent-chatbot"
  # }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# =====================================================================
# GCS Bucket for Agent Artifacts and Embed Codes
# =====================================================================

resource "google_storage_bucket" "agent_artifacts" {
  name          = var.gcs_bucket_name
  location      = var.gcp_region
  force_destroy = false

  labels = {
    environment = "multi-env"
    purpose     = "agent-artifacts"
  }

  # Versioning allows rollback to previous versions
  versioning {
    enabled = true
  }

  # Lifecycle policy: keep old versions for 30 days, then delete
  lifecycle_rule {
    action {
      type          = "Delete"
      storage_class = ["STANDARD"]
    }
    condition {
      num_newer_versions = 5
      days_since_noncurrent_time = 30
    }
  }

  # Uniform bucket-level access for consistent IAM
  uniform_bucket_level_access = true
}

# =====================================================================
# GCS Bucket Folders (by environment)
# =====================================================================
# Note: GCS doesn't have real folders, but we can create marker objects

resource "google_storage_bucket_object" "dev_folder" {
  name       = "dev/"
  bucket     = google_storage_bucket.agent_artifacts.name
  content    = ""
}

resource "google_storage_bucket_object" "stage_folder" {
  name       = "stage/"
  bucket     = google_storage_bucket.agent_artifacts.name
  content    = ""
}

resource "google_storage_bucket_object" "prod_folder" {
  name       = "prod/"
  bucket     = google_storage_bucket.agent_artifacts.name
  content    = ""
}

# =====================================================================
# Service Account for Cloud Build
# =====================================================================

resource "google_service_account" "cloud_build" {
  account_id   = "cloud-build-agent"
  display_name = "Cloud Build Service Account for AI Agent Chatbot"

  labels = {
    environment = "ci-cd"
  }
}

# =====================================================================
# IAM Roles for Cloud Build Service Account
# =====================================================================

# Allow Cloud Build to read from GCS
resource "google_storage_bucket_iam_member" "cloud_build_gcs_reader" {
  bucket = google_storage_bucket.agent_artifacts.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.cloud_build.email}"
}

# Allow Cloud Build to write to GCS
resource "google_storage_bucket_iam_member" "cloud_build_gcs_writer" {
  bucket = google_storage_bucket.agent_artifacts.name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${google_service_account.cloud_build.email}"
}

# Allow Cloud Build to delete from GCS (for cleanup/updates)
resource "google_storage_bucket_iam_member" "cloud_build_gcs_admin" {
  bucket = google_storage_bucket.agent_artifacts.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.cloud_build.email}"
}

# Allow Cloud Build to use Secret Manager (for API keys)
resource "google_project_iam_member" "cloud_build_secret_accessor" {
  project = var.gcp_project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.cloud_build.email}"
}

# =====================================================================
# Cloud Build Trigger for Dev (Existing - documented for reference)
# =====================================================================
# This is typically set up manually or via a separate trigger
# Documented here for completeness
# 
# Trigger: Manual or branch-based
# Branch: feature branches
# Config: cloudbuild.yaml

# =====================================================================
# Cloud Build Trigger for Stage (PR-based)
# =====================================================================

resource "google_cloudbuild_trigger" "stage_pr_trigger" {
  name            = "stage-pr-trigger"
  description     = "Triggers stage build on PR to stage branch"
  location        = var.gcp_region
  service_account = google_service_account.cloud_build.id

  # Trigger on pull requests to stage branch
  pull_request_filter {
    branches {
      name = "stage"
    }
  }

  filename = "cloudbuild-stage.yaml"

  substitutions = {
    _PROJECT_ID        = var.gcp_project_id
    _GCP_REGION        = var.gcp_region
    _APP_ID            = "dfs-ai-agent_STAGE"
    _GCS_BUCKET        = google_storage_bucket.agent_artifacts.name
    _LINT_RUN          = "false"
    _LINT_FAIL_ON_ERRORS = "true"
    _VALID_RUN         = "false"
    _VALID_FAIL_ON_ERRORS = "true"
  }

  tags = ["stage", "pr-trigger"]
}

# =====================================================================
# Cloud Build Trigger for Prod (Manual-only)
# =====================================================================

resource "google_cloudbuild_trigger" "prod_manual_trigger" {
  name            = "prod-manual-trigger"
  description     = "Manually triggered build to promote stage artifacts to prod"
  location        = var.gcp_region
  service_account = google_service_account.cloud_build.id

  # Manual trigger only - no automatic triggers
  manual_trigger = true

  filename = "cloudbuild-prod.yaml"

  substitutions = {
    _PROJECT_ID  = var.gcp_project_id
    _GCP_REGION  = var.gcp_region
    _APP_ID      = "dfs-ai-agent_PROD"
    _GCS_BUCKET  = google_storage_bucket.agent_artifacts.name
  }

  tags = ["prod", "manual-trigger"]
}

# =====================================================================
# Secret Manager Secrets (for API keys and credentials)
# =====================================================================

resource "google_secret_manager_secret" "cxas_api_key" {
  secret_id = "cxas-api-key"

  labels = {
    environment = "ci-cd"
    purpose     = "cxas-deployment"
  }

  replication {
    auto {}
  }
}

# Grant Cloud Build service account access to the secret
resource "google_secret_manager_secret_iam_member" "cxas_api_key_accessor" {
  secret_id = google_secret_manager_secret.cxas_api_key.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloud_build.email}"
}

# =====================================================================
# Outputs
# =====================================================================

output "cloud_build_service_account_email" {
  value       = google_service_account.cloud_build.email
  description = "Email of the Cloud Build service account"
}

output "gcs_bucket_name" {
  value       = google_storage_bucket.agent_artifacts.name
  description = "Name of the GCS bucket for artifacts"
}

output "stage_trigger_id" {
  value       = google_cloudbuild_trigger.stage_pr_trigger.id
  description = "ID of the stage PR trigger"
}

output "prod_trigger_id" {
  value       = google_cloudbuild_trigger.prod_manual_trigger.id
  description = "ID of the prod manual trigger"
}
