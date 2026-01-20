output "trigger_id" {
  description = "The ID of the created Cloud Build trigger."
  value       = google_cloudbuild_trigger.github_trigger.id
}