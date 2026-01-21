provider "google" {
  project = var.project_id
}

# --- Enable APIs ---
# Enables all necessary APIs for the Cloud Run and Cloud Build services.
module "project_apis" {
  source     = "../../modules/project-apis"
  project_id = var.project_id
  api_list   = ["run.googleapis.com", "artifactregistry.googleapis.com", "cloudbuild.googleapis.com"]
}


# --- Enable APIs ---
resource "google_project_service" "apis" {
  project                    = var.project_id
  for_each                   = toset(["run.googleapis.com", "artifactregistry.googleapis.com", "cloudbuild.googleapis.com"])
  service                    = each.key
  disable_dependent_services = true
}

# --- Primary Web Application Service ---
# Defines the main containerized web application deployed on Cloud Run.
# This service will be publicly accessible and is the target for our CI/CD pipeline.
module "app_service" {
  source                      = "../../modules/cloud-run-service"
  project_id                  = var.project_id
  location                    = "us-central1"
  service_name                = "my-containerized-app"
  container_image_url         = "us-docker.pkg.dev/google-samples/containers/gke/hello-app:1.0"
  depends_on                  = [module.project_apis]
  deletion_protection_enabled = false
}

# --- Automated CI/CD Deployment Pipeline ---
# Creates a Cloud Build pipeline that automatically builds a new container image
# from the 'main' branch of the 'gcp-professional-portfolio' GitHub repository
# and deploys it to the Cloud Run service defined above.
module "cicd_pipeline" {
  source                 = "../../modules/cloud-build-cicd"
  project_id             = var.project_id
  location               = "us-central1"
  repo_id                = "my-app-repo"
  app_name               = "my-app"
  github_owner           = "samperkins-cloud"
  github_repo_name       = "gcp-professional-portfolio"
  branch_name            = "^main$"
  cloud_run_service_name = module.app_service.service_name
  app_source_path        = "./projects/06-automated-container-deployment/apps"
  depends_on             = [module.project_apis]
  connection_name        = "github-connection"
  connection_region      = "us-central1"
}

# --- Root Module Variable ---
variable "project_id" {
  description = "The GCP project ID."
  type        = string
}