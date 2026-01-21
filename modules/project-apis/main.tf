resource "google_project_service" "apis" {
  project                    = var.project_id
  for_each                   = toset(var.api_list)
  service                    = each.key
  disable_dependent_services = true
}