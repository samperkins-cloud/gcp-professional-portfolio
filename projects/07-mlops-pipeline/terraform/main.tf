provider "google" {
  project = var.project_id
}

# 1. Enable all necessary APIs for MLOps
module "project_apis" {
  source     = "../../../modules/project-apis" # Assuming modules are at the root
  project_id = var.project_id
  api_list = [
    "aiplatform.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com"
  ]
}

# 2. Create a dedicated Artifact Registry for ML component containers
resource "google_artifact_registry_repository" "ml_components_repo" {
  project       = var.project_id
  location      = var.location
  repository_id = "${var.pipeline_name}-components-repo"
  description   = "Repository for ML pipeline component Docker images"
  format        = "DOCKER"
  depends_on    = [module.project_apis]
}

# 3. Create a Cloud Storage bucket for pipeline artifacts (e.g., model files, compiled pipeline)
resource "google_storage_bucket" "pipeline_artifacts" {
  project                     = var.project_id
  name                        = "${var.project_id}-${var.pipeline_name}-artifacts"
  location                    = var.location
  uniform_bucket_level_access = true
  force_destroy               = true 
  depends_on                  = [module.project_apis]
}

# 4. Create a dedicated Service Account for Vertex AI Pipeline runs
resource "google_service_account" "vertex_pipeline_sa" {
  project      = var.project_id
  account_id   = "${var.pipeline_name}-sa"
  display_name = "Service Account for ${var.pipeline_name} Vertex AI Pipeline"
  depends_on   = [module.project_apis]
}

# 5. Grant necessary IAM permissions to the pipeline's Service Account
# This is a starting point and will likely be a source of debugging later.
resource "google_project_iam_member" "pipeline_sa_permissions" {
  project = var.project_id
  for_each = toset([
    "roles/aiplatform.user",         # To run Vertex AI jobs
    "roles/storage.objectAdmin",     # To read/write artifacts in the GCS bucket
    "roles/bigquery.dataViewer",     # To read training data from BigQuery
    "roles/iam.serviceAccountUser"   # To allow Vertex to act as this SA
  ])
  role   = each.key
  member = google_service_account.vertex_pipeline_sa.member
}