output "gcs_bucket_name" {
  value       = google_storage_bucket.agent_artifacts.name
  description = "Name of the GCS bucket for agent artifacts"
}

output "gcs_bucket_url" {
  value       = "gs://${google_storage_bucket.agent_artifacts.name}"
  description = "GCS bucket URL"
}

output "cloud_build_service_account_email" {
  value       = google_service_account.cloud_build.email
  description = "Email of the Cloud Build service account"
}

output "cloud_build_service_account_id" {
  value       = google_service_account.cloud_build.name
  description = "ID of the Cloud Build service account"
}

output "stage_trigger_id" {
  value       = google_cloudbuild_trigger.stage_pr_trigger.id
  description = "Cloud Build trigger ID for stage (PR-based)"
}

output "stage_trigger_name" {
  value       = google_cloudbuild_trigger.stage_pr_trigger.name
  description = "Cloud Build trigger name for stage"
}

output "prod_trigger_id" {
  value       = google_cloudbuild_trigger.prod_manual_trigger.id
  description = "Cloud Build trigger ID for prod (manual)"
}

output "prod_trigger_name" {
  value       = google_cloudbuild_trigger.prod_manual_trigger.name
  description = "Cloud Build trigger name for prod"
}

output "cxas_api_key_secret_id" {
  value       = google_secret_manager_secret.cxas_api_key.id
  description = "Secret Manager secret ID for CXAS API key"
}

output "terraform_state_backend_config" {
  value = <<-EOT
    # Add this to terraform/main.tf backend block to enable remote state storage:
    backend "gcs" {
      bucket  = "${google_storage_bucket.agent_artifacts.name}-terraform-state"
      prefix  = "ai-agent-chatbot"
    }
  EOT
  description = "Backend configuration for remote Terraform state storage"
}
