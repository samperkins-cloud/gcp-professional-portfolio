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

# 3. CREATE THE ARTIFACT REGISTRY REPOSITORY
resource "google_artifact_registry_repository" "docker_repo" {
  project       = var.project_id
  location      = var.location
  repository_id = var.repo_id
  format        = "DOCKER"
}

# 4. CREATE THE CLOUD BUILD TRIGGER
resource "google_cloudbuild_trigger" "github_trigger" {
  # ... other arguments like project, name, location, service_account ...

  # This tells Cloud Build what to do when triggered
  build {
    # --- ADD THIS BLOCK TO FIX THE LOGGING ERROR ---
    options {
      logging = "CLOUD_LOGGING_ONLY"
    }
    # -------------------------------------------------

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
  # This ensures the trigger is not created until the SA has its permissions, preventing race conditions.
  depends_on = [
    google_project_iam_member.registry_writer,
    google_project_iam_member.run_developer,
    google_project_iam_member.sa_user
  ]
}