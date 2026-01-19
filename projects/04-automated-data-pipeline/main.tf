# This variable defines the GCP Project ID to use for all resources.
variable "project_id" {
  description = "The GCP project ID."
  type        = string
  default     = "my-portfolio-project-v2-484602" # Your current project ID
}

# This data block fetches the project number, which is needed for service agent emails.
data "google_project" "project" {}

# --- Provider Configuration ---
provider "google" {
  project = var.project_id
  region  = "us-central1"
}

# --- Core Infrastructure ---

# A Cloud Storage bucket to receive the raw data files.
resource "google_storage_bucket" "data_bucket" {
  name                        = "data-pipeline-bucket-${var.project_id}"
  location                    = "US-CENTRAL1"
  force_destroy               = true
  uniform_bucket_level_access = true
}

# A BigQuery Dataset to act as a container for our tables.
resource "google_bigquery_dataset" "portfolio_dataset" {
  dataset_id = "portfolio_dataset"
  location   = "US"
}

# The BigQuery Table that will store our processed data.
resource "google_bigquery_table" "user_data_table" {
  dataset_id          = google_bigquery_dataset.portfolio_dataset.dataset_id
  table_id            = "user_data"
  deletion_protection = false

  schema = jsonencode([
    { "name" : "id", "type" : "INTEGER", "mode" : "REQUIRED" },
    { "name" : "first_name", "type" : "STRING", "mode" : "NULLABLE" },
    { "name" : "last_name", "type" : "STRING", "mode" : "NULLABLE" },
    { "name" : "email", "type" : "STRING", "mode" : "NULLABLE" },
  ])
}

# --- Service Account for the Cloud Function ---

# A dedicated Service Account for the Cloud Function to give it a unique identity.
resource "google_service_account" "function_sa" {
  account_id   = "data-pipeline-function-sa"
  display_name = "Data Pipeline Cloud Function SA"
}

# --- IAM & Permissions ---

# Allows the function's service account to read the uploaded CSV from the GCS bucket.
resource "google_project_iam_member" "gcs_reader" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}

# Allows the function's service account to create jobs and write data to BigQuery.
resource "google_project_iam_member" "bigquery_writer" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}

# Allows the function's service account to receive events from Eventarc.
resource "google_project_iam_member" "eventarc_event_receiver" {
  project = var.project_id
  role    = "roles/eventarc.eventReceiver"
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}

# Allows the Cloud Build service to read the function's source code from the GCS bucket.
resource "google_project_iam_member" "cloudbuild_gcs_reader" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

# Allows the GCS service agent to publish messages to Pub/Sub for Eventarc.
resource "google_project_iam_member" "storage_to_pubsub" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:service-${data.google_project.project.number}@gs-project-accounts.iam.gserviceaccount.com"
}

# Allows the Eventarc service agent to read objects from the trigger bucket.
resource "google_storage_bucket_iam_member" "eventarc_trigger_permission" {
  bucket = google_storage_bucket.data_bucket.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-eventarc.iam.gserviceaccount.com"
}

# Allows the function's service account to invoke its own underlying Cloud Run service.
# This is required because the event trigger is configured to use the function's identity.
resource "google_cloud_run_service_iam_member" "eventarc_invoker" {
  location = google_cloudfunctions2_function.data_loader.location
  project  = google_cloudfunctions2_function.data_loader.project
  service  = google_cloudfunctions2_function.data_loader.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.function_sa.email}"
}

# Allows the function's service account to create and manage BigQuery jobs.
resource "google_project_iam_member" "bigquery_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}
# --- Cloud Function ---

# The Cloud Function that processes the data.
resource "google_cloudfunctions2_function" "data_loader" {
  name     = "data-loader-function"
  location = "us-central1"

  build_config {
    runtime     = "python311"
    entry_point = "load_csv_to_bigquery"
    source {
      storage_source {
        bucket = google_storage_bucket.data_bucket.name
        object = "src.zip"
      }
    }
  }

  service_config {
    service_account_email = google_service_account.function_sa.email
  }

  event_trigger {
    trigger_region        = "us-central1"
    event_type            = "google.cloud.storage.object.v1.finalized"
    retry_policy          = "RETRY_POLICY_RETRY"
    service_account_email = google_service_account.function_sa.email
    event_filters {
      attribute = "bucket"
      value     = google_storage_bucket.data_bucket.name
    }
  }
}