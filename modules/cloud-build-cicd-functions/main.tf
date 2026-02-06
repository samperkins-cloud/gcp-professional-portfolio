# modules/cloud-build-cicd/main.tf

# 1. CREATE THE DEDICATED SERVICE ACCOUNT
resource "google_service_account" "trigger_sa" {
  project      = var.project_id
  account_id   = "${var.app_name}-trigger-sa"
  display_name = "Cloud Build Trigger SA for ${var.app_name}"
}

# 2. GRANT THE NECESSARY PERMISSIONS TO THE SERVICE ACCOUNT
resource "google_project_iam_member" "registry_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = google_service_account.trigger_sa.member
}

resource "google_project_iam_member" "run_developer" {
  project = var.project_id
  role    = "roles/run.developer"
  member  = google_service_account.trigger_sa.member
}

resource "google_project_iam_member" "sa_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = google_service_account.trigger_sa.member
}

resource "google_project_iam_member" "log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = google_service_account.trigger_sa.member
}

# Allows the SA to set IAM policies (like public access) on Cloud Run services.
resource "google_project_iam_member" "run_admin" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = google_service_account.trigger_sa.member
}

# 3. CREATE THE ARTIFACT REGISTRY REPOSITORY
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

# 4. CREATE THE MAIN BRANCH ("PRODUCTION") TRIGGER
resource "google_cloudbuild_trigger" "github_trigger" {
  project         = var.project_id
  name            = "deploy-${var.app_name}-on-push-to-main"
  location        = var.location
  service_account = google_service_account.trigger_sa.id

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

    # Step 1 & 2: Build and Push the container
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "-t", "${var.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/${var.app_name}:$SHORT_SHA", var.app_source_path]
    }
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["push", "${var.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/${var.app_name}:$SHORT_SHA"]
    }

    # Step 3: Deploy to Cloud Functions
    step {
      name       = "gcr.io/google.com/cloudsdktool/cloud-sdk"
      entrypoint = "gcloud"
      args       = ["run", "deploy", var.app_name, "--image", "${var.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/${var.app_name}:$SHORT_SHA", "--region", var.location, "--allow-unauthenticated"]
    }
  }

  depends_on = [
    google_project_iam_member.run_admin, # Ensure all permissions are set first
    google_project_iam_member.registry_writer,
    google_project_iam_member.run_developer,
    google_project_iam_member.sa_user,
    google_project_iam_member.log_writer
  ]
}

# 5. CREATE THE PULL REQUEST ("PREVIEW") TRIGGER
resource "google_cloudbuild_trigger" "github_trigger_pr" {
  project         = var.project_id
  name            = "deploy-${var.app_name}-preview-on-pr"
  description     = "Deploys a preview environment for pull requests."
  location        = var.location
  service_account = google_service_account.trigger_sa.id

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

    # Step 1 & 2 are correct: Build and Push a unique container
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "-t", "${var.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/${var.app_name}:pr-$${_PR_NUMBER}-$SHORT_SHA", var.app_source_path]
    }
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["push", "${var.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/${var.app_name}:pr-$${_PR_NUMBER}-$SHORT_SHA"]
    }
    
    # Step 3 is THE CHANGE: Deploy a unique preview function
    step {
      name       = "gcr.io/google.com/cloudsdktool/cloud-sdk"
      entrypoint = "gcloud"
      args = [
        "run", "deploy", "${var.app_name}-pr-$${_PR_NUMBER}",
        "--image", "${var.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/${var.app_name}:pr-$${_PR_NUMBER}-$SHORT_SHA",
        "--region", var.location,
        "--allow-unauthenticated"
      ]
    }
  }

  depends_on = [
    google_project_iam_member.run_admin,
    google_project_iam_member.registry_writer,
    google_project_iam_member.run_developer,
    google_project_iam_member.sa_user,
    google_project_iam_member.log_writer
  ]
}