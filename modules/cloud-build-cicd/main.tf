# modules/cloud-build-cicd/main.tf

# 1. CREATE THE DEDICATED SERVICE ACCOUNT
# This creates a unique, least-privilege SA for our trigger.
resource "google_service_account" "trigger_sa" {
  project      = var.project_id
  account_id   = "${var.app_name}-trigger-sa"
  display_name = "Cloud Build Trigger SA for ${var.app_name}"
}

# 2. GRANT THE NECESSARY PERMISSIONS TO THE SERVICE ACCOUNT
# Allows the SA to push images to Artifact Registry.
resource "google_project_iam_member" "registry_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = google_service_account.trigger_sa.member
}

# Allows the SA to deploy and manage the Cloud Run service.
resource "google_project_iam_member" "run_developer" {
  project = var.project_id
  role    = "roles/run.developer"
  member  = google_service_account.trigger_sa.member
}

# Allows the SA to act as the identity of other services (a required permission).
resource "google_project_iam_member" "sa_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = google_service_account.trigger_sa.member
}

# Allows the SA to write logs to Cloud Logging (a required permission).
resource "google_project_iam_member" "log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = google_service_account.trigger_sa.member
}

# 3. CREATE THE ARTIFACT REGISTRY REPOSITORY
# The repository ID is now derived from the app_name for consistency.
resource "google_artifact_registry_repository" "docker_repo" {
  project       = var.project_id
  location      = var.location
  repository_id = "${var.app_name}-repo"
  description   = "Docker repository for the ${var.app_name} application"
  format        = "DOCKER"

  # ADD THIS BLOCK to enforce immutable tags
  docker_config {
    immutable_tags = true
  }
}

# 4. CREATE THE CLOUD BUILD TRIGGER
resource "google_cloudbuild_trigger" "github_trigger" {
  project         = var.project_id
  name            = "deploy-${var.app_name}-on-push-to-main"
  location        = var.location
  service_account = google_service_account.trigger_sa.id

  repository_event_config {
    repository = "projects/${var.project_id}/locations/${var.connection_region}/connections/${var.connection_name}/repositories/${var.github_repo_name}"
    push {
      branch = var.branch_name
    }
  }
  # ---------------------------------------------------------

  # This tells Cloud Build what to do when triggered
  build {
    options {
      logging = "CLOUD_LOGGING_ONLY"
    }

    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "-t", "${var.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/${var.app_name}:latest", var.app_source_path]
    }
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["push", "${var.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/${var.app_name}:latest"]
    }
    step {
      name       = "gcr.io/google.com/cloudsdktool/cloud-sdk"
      entrypoint = "gcloud"
      args       = ["run", "deploy", var.cloud_run_service_name, "--image", "${var.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/${var.app_name}:latest", "--region", var.location]
    }
  }

  depends_on = [
    google_project_iam_member.registry_writer,
    google_project_iam_member.run_developer,
    google_project_iam_member.sa_user,
    google_project_iam_member.log_writer
  ]
}