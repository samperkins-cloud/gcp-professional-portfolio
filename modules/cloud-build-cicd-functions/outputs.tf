output "trigger_id" {
  description = "The unique ID of the created Cloud Build trigger."
  value       = google_cloudbuild_trigger.github_trigger.trigger_id
}

output "trigger_resource_id" {
  description = "The full resource path/ID of the created Cloud Build trigger."
  value       = google_cloudbuild_trigger.github_trigger.id
}

output "artifact_registry_repository_url" {
  description = "The full URL of the Artifact Registry repository created for the application's Docker images."
  value       = "${var.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}"
}

output "service_account_email" {
  description = "The email address of the service account created to run the Cloud Build trigger."
  value       = google_service_account.trigger_sa.email
}