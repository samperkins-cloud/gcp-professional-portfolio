variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "location" {
  description = "The GCP region where the service will be deployed."
  type        = string
}

variable "service_name" {
  description = "The name of the Cloud Run service."
  type        = string
}

variable "container_image_url" {
  description = "The full URL of the container image to deploy."
  type        = string
}

variable "deletion_protection_enabled" {
    description = "Whether to enable deletion protection for the Cloud Run service."
    type        = bool
    default     = true # By default, all services should be protected.
}