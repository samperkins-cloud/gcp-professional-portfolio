# projects/09-platform-foundations/outputs.tf

output "app_secret_id" {
  description = "The short ID of the application's API key secret."
  value       = google_secret_manager_secret.app_secret.secret_id
}

output "app_service_account_email" {
  description = "The email of the dedicated runtime service account for the application."
  value       = google_service_account.app_sa.email
}

output "pipeline_service_account_id" {
  description = "The full ID of the service account for the Cloud Build trigger."
  value       = google_service_account.pipeline_sa.id
}