# First, we need to look up the URL of our main production service
data "google_cloud_run_service" "main_function" {
  name     = var.app_name
  location = var.location
  project  = var.project_id
}

# Now, create the scheduler job
resource "google_cloud_scheduler_job" "etl_job" {
  project  = var.project_id
  region   = var.location
  name     = "${var.app_name}-job"
  schedule = "*/15 * * * *" # Every 15 minutes

  http_target {
    uri = data.google_cloud_run_service.main_function.status[0].url

    oidc_token {
      service_account_email = data.terraform_remote_state.platform.outputs.scheduler_service_account_email
    }
  }
}