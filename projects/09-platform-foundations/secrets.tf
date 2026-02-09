# --- Application Secrets ---
resource "google_secret_manager_secret" "app_secret" {
  project   = var.project_id
  secret_id = "${var.app_name}-api-key"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "app_secret_version" {
  secret      = google_secret_manager_secret.app_secret.id
  secret_data = var.app_api_key
}
