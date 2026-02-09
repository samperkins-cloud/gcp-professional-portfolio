# projects/09-platform-foundations/backend.tf
terraform {
  cloud {
    organization = "samperkins-cloud-org"
    workspaces {
      name = "project-09-platform-foundations" // New workspace name
    }
  }
}
