# projects/08-automated-functions-deployment/data.tf

data "terraform_remote_state" "platform" {
  backend = "remote"

  config = {
    organization = "samperkins-cloud-org"
    workspaces = {
      name = "project-09-platform-foundations"
    }
  }
}
