provider "google" {
  project = var.project_id
}

# --- 1. Enable APIs using the reusable module ---
module "project_apis" {
  source     = "../../modules/project-apis"
  project_id = var.project_id
  api_list   = var.api_list
}

# --- 2. Primary Web Application Service ---
module "app_service" {
  source                      = "../../modules/cloud-run-service"
  project_id                  = var.project_id
  location                    = var.location
  service_name                = var.app_name
  container_image_url         = "us-docker.pkg.dev/google-samples/containers/gke/hello-app:1.0"
  deletion_protection_enabled = false

  # This module will wait until the project_apis module is finished.
  depends_on = [module.project_apis]
}

# --- 3. Automated CI/CD Deployment Pipeline ---
module "cicd_pipeline" {
  source                 = "../../modules/cloud-build-cicd"
  project_id             = var.project_id
  location               = var.location
  app_name               = var.app_name
  github_owner           = var.github_owner
  github_repo_name       = var.github_repo_name
  cloud_run_service_name = module.app_service.service_name
  app_source_path        = var.app_source_path
  connection_region      = var.location
  connection_name        = var.connection_name
  depends_on             = [module.project_apis]
}