variable "project_id" { type = string }
variable "location" { type = string }
variable "repo_id" {
  description = "The ID for the Artifact Registry repository."
  type        = string
}
variable "app_name" {
  description = "The name of the application, used for tagging the image."
  type        = string
}
variable "github_owner" { type = string }
variable "github_repo_name" { type = string }
variable "branch_name" { type = string }
variable "cloud_run_service_name" {
  description = "The name of the Cloud Run service to deploy to."
  type        = string
}
variable "app_source_path" {
  description = "The path to the application source code for the Docker build."
  type        = string
}