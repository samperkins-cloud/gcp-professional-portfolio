output "enabled_apis" {
  description = "The list of APIs that were enabled."
  value       = [for s in google_project_service.apis : s.service]
}