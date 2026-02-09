# projects/09-platform-foundations/outputs.tf

output "app_secret_id" {
  description = "The short ID of the application's API key secret."
  value       = google_secret_manager_secret.app_secret.secret_id
}
