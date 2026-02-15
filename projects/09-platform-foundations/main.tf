# projects/09-platform-foundations/main.tf

# -------------------------------------------------------------------
# --- 1. CI/CD Pipeline Identity & Permissions
# --- This is the identity the Cloud Build trigger itself will use.
# -------------------------------------------------------------------
resource "google_service_account" "pipeline_sa" {
  project      = var.project_id
  account_id   = "${var.app_name}-pipeline-sa"
  display_name = "CI/CD Pipeline SA for ${var.app_name}"
}

# --- Grant Permissions TO the Pipeline's Identity ---

# Allows the pipeline to build and push containers
resource "google_project_iam_member" "pipeline_sa_artifact_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = google_service_account.pipeline_sa.member
}

# Allows the pipeline to deploy Cloud Run services and manage IAM
resource "google_project_iam_member" "pipeline_sa_run_admin" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = google_service_account.pipeline_sa.member
}

# Allows the pipeline to manage Cloud Functions
resource "google_project_iam_member" "pipeline_sa_functions_developer" {
  project = var.project_id
  role    = "roles/cloudfunctions.developer"
  member  = google_service_account.pipeline_sa.member
}

# Allows the pipeline to write its own logs
resource "google_project_iam_member" "pipeline_sa_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = google_service_account.pipeline_sa.member
}

# Allows the pipeline to impersonate other service accounts (including itself)
resource "google_service_account_iam_member" "pipeline_sa_self_user" {
  service_account_id = google_service_account.pipeline_sa.name
  role               = "roles/iam.serviceAccountUser"
  member             = google_service_account.pipeline_sa.member
}


# -------------------------------------------------------------------
# --- 2. Application Runtime Identity & Permissions
# --- This is the identity the final deployed Cloud Run service will use.
# -------------------------------------------------------------------
resource "google_service_account" "app_sa" {
  project      = var.project_id
  account_id   = "${var.app_name}-runtime-sa"
  display_name = "Runtime SA for ${var.app_name}"
}

# --- Grant Permissions TO the Application's Identity ---

# Allows the running application to be invoked via its URL
resource "google_project_iam_member" "app_sa_run_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = google_service_account.app_sa.member
}

# Allows the running application to access its own secrets
resource "google_project_iam_member" "app_sa_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = google_service_account.app_sa.member
}