# --- Provider Configuration ---

# Specifies the required provider and version for this configuration.
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.6.0"
    }
  }
}

# Configures the Google Cloud provider with the target project and region.
provider "google" {
  project = "project-86a83b40-693f-4462-a18"
  region  = "us-east4"
}

# --- Network Resources ---

# Provisions a custom Virtual Private Cloud (VPC) network.
resource "google_compute_network" "the_fortress_vpc" {
  name                    = "the-fortress-vpc"
  auto_create_subnetworks = false
}

# Provisions a subnet within the custom VPC.
resource "google_compute_subnetwork" "private_subnet" {
  name          = "private-subnet-us-east4"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-east4"
  network       = google_compute_network.the_fortress_vpc.id
}

# This deny rule ensures that only explicitly allowed traffic can enter the network.
resource "google_compute_firewall" "deny_all_ingress" {
  name     = "the-fortress-deny-all-ingress"
  network  = google_compute_network.the_fortress_vpc.id
  priority = 1000

  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
}