# Allow the scheduler's service account (from the platform) to invoke our main function
resource "google_cloud_run_service_iam_member" "scheduler_invoker" {
  location = "us-central1" # Or your region
  project  = var.project_id
  service  = var.app_name # The name of your main function, e.g., "my-etl-function"
  role     = "roles/run.invoker"
  member   = "serviceAccount:${data.terraform_remote_state.platform.outputs.scheduler_service_account_email}"
}