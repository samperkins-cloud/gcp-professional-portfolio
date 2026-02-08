# --- Application Secrets ---
resource "google_secret_manager_secret" "app_secret" {
  project   = var.project_id
  secret_id = "${var.app_name}-api-key"

  replication {
    auto {} # This is the correct syntax for automatic replication
  }
}

resource "google_secret_manager_secret_version" "app_secret_version" {
  secret      = google_secret_manager_secret.app_secret.id
  secret_data = var.app_api_key
}