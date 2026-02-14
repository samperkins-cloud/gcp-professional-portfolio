# projects/09-platform-foundations/main.tf

# --- Create the Application's Dedicated Identity ---
resource "google_service_account" "app_sa" {
  project      = var.project_id
  account_id   = "${var.app_name}-runtime-sa"
  display_name = "Runtime SA for ${var.app_name}"
}

# --- Grant Permissions TO the Application's Identity ---
resource "google_project_iam_member" "app_sa_run_invoker" {
  project = var.project_id
  role    = "roles/run.invoker" # Basic permission to be invoked
  member  = google_service_account.app_sa.member
}

resource "google_project_iam_member" "app_sa_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = google_service_account.app_sa.member
}