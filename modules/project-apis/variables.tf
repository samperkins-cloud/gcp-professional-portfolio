variable "project_id" {
  description = "The ID of the project to enable APIs on."
  type        = string
}

variable "api_list" {
  description = "A list of Google Cloud APIs to enable."
  type        = list(string)
  default     = []
}