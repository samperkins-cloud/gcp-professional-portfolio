provider "google" {
  project = var.project_id
}

# --- Enable APIs ---
resource "google_project_service" "apis" {
  project                    = var.project_id
  for_each                   = toset(["run.googleapis.com", "artifactregistry.googleapis.com", "cloudbuild.googleapis.com"])
  service                    = each.key
  disable_dependent_services = true
}

# --- Application Service ---
# Deploy a standard Cloud Run service using our application module.
module "app_service" {
  source       = "../../modules/cloud-run-service"
  project_id   = var.project_id
  location     = "us-central1"
  service_name = "my-containerized-app"
  # This URL must match what Cloud Build will create.
  container_image_url         = "us-docker.pkg.dev/google-samples/containers/gke/hello-app:1.0"
  depends_on                  = [google_project_service.apis]
  deletion_protection_enabled = false
}

# --- CI/CD Pipeline ---
# Create an automated pipeline to build and deploy the service.
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
  depends_on             = [google_project_service.apis]
  connection_name        = "github-connection"
  connection_region      = "us-central1"     
}

# --- Root Module Variable ---
variable "project_id" {
  description = "The GCP project ID."
  type        = string
}