variable "project_id" {
  description = "The GCP project ID where the resources will be created."
  type        = string
}

variable "location" {
  description = "The primary GCP region for the Cloud Build trigger and Artifact Registry."
  type        = string
}

variable "app_name" {
  description = "A short, unique name for the application (e.g., 'frontend-app'). This is used to name the Artifact Registry repo and other resources."
  type        = string
}

variable "github_owner" {
  description = "The owner of the GitHub repository (user or organization name)."
  type        = string
}

variable "github_repo_name" {
  description = "The name of the target GitHub repository."
  type        = string
}

variable "branch_name" {
  description = "The regex pattern for the branch that will trigger the build."
  type        = string
  default     = "^main$"
}

variable "app_source_path" {
  description = "The path to the application's source code and Dockerfile within the GitHub repository."
  type        = string
  default     = "."
}

variable "connection_name" {
  description = "The name of the pre-existing Cloud Build GitHub host connection."
  type        = string
  default     = "github-connection"
}

variable "connection_region" {
  description = "The region where the Cloud Build GitHub host connection was created."
  type        = string
}

variable "secret_id" {
  description = "The full ID of the Secret Manager secret to inject."
  type        = string
}

variable "runtime_service_account_email" {
  description = "The email of the pre-created service account the Cloud Run service will run as."
  type        = string
}