resource "google_artifact_registry_repository" "function_repo" {
  project       = "my-portfolio-project-v2-484602"
  location      = "us-central1"
  repository_id = "my-etl-function-repo"
  description   = "Docker repository for the ETL function"
  format        = "DOCKER"


  cleanup_policies {
    id     = "delete-old-pr-images"
    action = "DELETE"
    condition {
      tag_state    = "UNTAGGED"
      older_than   = "259200s" # Deletes images older than 3 days
    }
  }
}
