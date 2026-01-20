variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "network_name" {
  description = "The name for the VPC network."
  type        = string
  default     = "module-vpc"
}