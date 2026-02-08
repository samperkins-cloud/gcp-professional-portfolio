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
  description = "The name of the application/function."
  type        = string
}

variable "api_list" {
  description = "The list of GCP APIs to enable for the project."
  type        = list(string)
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

# This variable is used by the module but we don't need to set it for this project.
# We still need to declare it so we can pass a value (even null).
variable "branch_name" {
  description = "The name of the main branch for the production trigger."
  type        = string
  default     = "^main$"
}

variable "app_api_key" {
  description = "The secret API key for the application."
  type        = string
  sensitive   = true
}