variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "YOUR_GCP_PROJECT_ID"
}

variable "gcp_region" {
  description = "GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "gcs_bucket_name" {
  description = "Name of the GCS bucket for agent artifacts (must be globally unique)"
  type        = string
  default     = "your-artifacts-bucket"
}

variable "environment" {
  description = "Environment name (dev, stage, prod)"
  type        = string
  default     = "multi"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    project = "ai-agent-chatbot"
    managed = "terraform"
  }
}
