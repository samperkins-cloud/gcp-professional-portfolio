variable "project_id" {
  description = "The GCP project ID where the foundational resources will be created."
  type        = string
}

variable "app_name" {
  description = "The base name for the application, used to name the secret."
  type        = string
}

variable "app_api_key" {
  description = "The secret API key for the application."
  type        = string
  sensitive   = true
}
