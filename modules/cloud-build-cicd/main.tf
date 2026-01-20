# --- Artifact Registry: A private place to store our Docker images ---
resource "google_artifact_registry_repository" "docker_repo" {
  project       = var.project_id
  location      = var.location
  repository_id = var.repo_id
  format        = "DOCKER"
}

# --- Cloud Build: The CI/CD trigger that connects GitHub to GCP ---
resource "google_cloudbuild_trigger" "github_trigger" {
  project  = var.project_id
  name     = "deploy-${var.app_name}-on-push-to-main"
  location = "global" # Cloud Build triggers can be global

  github {
    owner = var.github_owner
    name  = var.github_repo_name
    push {
      branch = var.branch_name
    }
  }

  build {
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
}