variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "location" {
  description = "The primary GCP region for all resources."
  type        = string
  default     = "us-central1"
}

variable "pipeline_name" {
  description = "A unique name for this MLOps pipeline, used as a prefix for resources."
  type        = string
  default     = "intelligent-api"
}