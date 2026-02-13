# projects/08-automated-functions-deployment/main.tf

terraform {
  cloud {
    organization = "samperkins-cloud-org"

    workspaces {
      name = "project-08-functions-deployment"
    }
  }
}

provider "google" {
  project = var.project_id
}

# --- 1. Enable APIs using the reusable module ---
module "project_apis" {
  source     = "../../modules/project-apis"
  project_id = var.project_id
  api_list   = var.api_list
}

# --- 2. Automated CI/CD Deployment Pipeline for Cloud Functions ---
module "cicd_pipeline" {
  source                        = "../../modules/cloud-build-cicd-functions"
  project_id                    = var.project_id
  location                      = var.location
  app_name                      = var.app_name
  github_owner                  = var.github_owner
  github_repo_name              = var.github_repo_name
  app_source_path               = var.app_source_path
  connection_name               = var.connection_name
  connection_region             = var.location
  depends_on                    = [module.project_apis]
  secret_id                     = data.terraform_remote_state.platform.outputs.app_secret_id
  runtime_service_account_email = data.terraform_remote_state.platform.outputs.app_service_account_email
}
