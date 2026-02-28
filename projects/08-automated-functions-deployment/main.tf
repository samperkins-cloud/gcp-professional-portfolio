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