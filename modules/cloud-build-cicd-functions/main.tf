# modules/cloud-build-cicd-functions/main.tf

# 1. CREATE THE ARTIFACT REGISTRY REPOSITORY
resource "google_artifact_registry_repository" "docker_repo" {
  project       = var.project_id
  location      = var.location
  repository_id = "${var.app_name}-repo"
  description   = "Docker repository for the ${var.app_name} application"
  format        = "DOCKER"
  docker_config {
    immutable_tags = true
  }
}

# 2. CREATE THE MAIN BRANCH ("PRODUCTION") TRIGGER
resource "google_cloudbuild_trigger" "github_trigger" {
  project  = var.project_id
  name     = "deploy-${var.app_name}-on-push-to-main"
  location = var.location
  # This now uses the SA provided by the platform
  service_account = var.pipeline_service_account_id
  included_files = [
    "projects/08-automated-functions-deployment/apps/**"
  ]

  repository_event_config {
    repository = "projects/${var.project_id}/locations/${var.connection_region}/connections/${var.connection_name}/repositories/${var.github_owner}-${var.github_repo_name}"
    push {
      branch = var.branch_name
    }
  }

  build {
    options {
      logging = "CLOUD_LOGGING_ONLY"
    }
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "-t", "${var.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/${var.app_name}:$SHORT_SHA", var.app_source_path]
    }
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["push", "${var.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/${var.app_name}:$SHORT_SHA"]
    }
    step {
      name       = "gcr.io/google.com/cloudsdktool/cloud-sdk"
      entrypoint = "gcloud"
      args = [
        "run", "deploy", var.app_name,
        "--image", "${var.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/${var.app_name}:$SHORT_SHA",
        "--region", var.location,
        "--allow-unauthenticated",
        "--set-secrets=API_KEY=${var.secret_id}:latest",
        # This now uses the RUNTIME SA provided by the platform
        "--service-account=${var.runtime_service_account_email}"
      ]
    }
  }
}

# 3. CREATE THE PULL REQUEST ("PREVIEW") TRIGGER
resource "google_cloudbuild_trigger" "github_trigger_pr" {
  project     = var.project_id
  name        = "deploy-${var.app_name}-preview-on-pr"
  description = "Deploys a preview environment for pull requests."
  location    = var.location
  # This now uses the SA provided by the platform
  service_account = var.pipeline_service_account_id
  included_files = [
    "projects/08-automated-functions-deployment/apps/**"
  ]

  repository_event_config {
    repository = "projects/${var.project_id}/locations/${var.connection_region}/connections/${var.connection_name}/repositories/${var.github_owner}-${var.github_repo_name}"
    pull_request {
      branch          = "^main$"
      comment_control = "COMMENTS_ENABLED_FOR_EXTERNAL_CONTRIBUTORS_ONLY"
    }
  }

  build {
    options {
      logging = "CLOUD_LOGGING_ONLY"
    }
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "-t", "${var.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/${var.app_name}:pr-$${_PR_NUMBER}-$SHORT_SHA", var.app_source_path]
    }
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["push", "${var.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/${var.app_name}:pr-$${_PR_NUMBER}-$SHORT_SHA"]
    }
    step {
      name       = "gcr.io/google.com/cloudsdktool/cloud-sdk"
      entrypoint = "gcloud"
      args = [
        "run", "deploy", "${var.app_name}-pr-$${_PR_NUMBER}",
        "--image", "${var.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/${var.app_name}:pr-$${_PR_NUMBER}-$SHORT_SHA",
        "--region", var.location,
        "--allow-unauthenticated",
        "--set-secrets=API_KEY=${var.secret_id}:latest",
        # This now uses the RUNTIME SA provided by the platform
        "--service-account=${var.runtime_service_account_email}"
      ]
    }
  }
}