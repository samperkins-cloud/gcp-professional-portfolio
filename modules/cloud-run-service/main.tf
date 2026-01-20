# --- Cloud Run: The serverless service to run our container ---
resource "google_cloud_run_v2_service" "default" {
    project             = var.project_id
    name                = var.service_name
    location            = var.location
    deletion_protection = var.deletion_protection_enabled # Use the variable here

    template {
    containers {
        image = var.container_image_url
    }
    }
}

# --- IAM: Allow anyone to access the public Cloud Run URL ---
resource "google_cloud_run_v2_service_iam_member" "noauth" {
  project  = google_cloud_run_v2_service.default.project
  location = google_cloud_run_v2_service.default.location
  name     = google_cloud_run_v2_service.default.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}