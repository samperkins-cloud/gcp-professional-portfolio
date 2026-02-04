variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "location" {
  description = "The primary GCP region for all resources."
  type        = string
  default     = "us-central1"
}

variable "app_name" {
  description = "The name of the application."
  type        = string
  default     = "my-containerized-app"
}

variable "api_list" {
  description = "The list of GCP APIs to enable for the project."
  type        = list(string)
  default = [
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com"
  ]
}

variable "github_owner" {
  description = "The owner of the GitHub repository."
  type        = string
}

variable "github_repo_name" {
  description = "The name of the GitHub repository."
  type        = string
}

variable "app_source_path" {
  description = "The path to the application source code within the repository."
  type        = string
}
variable "connection_name" {
  description = "The name of the Cloud Build connection to GitHub."
  type        = string
}