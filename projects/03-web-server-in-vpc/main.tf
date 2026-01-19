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

# Configures the Google Cloud provider.
# Note: The region is set to us-east4 to match the resources below.
provider "google" {
  # TODO: Replace with your actual Google Cloud Project ID.
  project = "project-86a83b40-693f-4462-a18"
  region  = "us-east4"
}

# --- Network Resources ---

# Provisions a custom Virtual Private Cloud (VPC) for network isolation.
resource "google_compute_network" "the_fortress_vpc" {
  name                    = "the-fortress-vpc"
  auto_create_subnetworks = false # Enforces manual subnet creation for granular control.
}

# Defines a private subnet within the custom VPC.
resource "google_compute_subnetwork" "private_subnet" {
  name          = "private-subnet-us-east4"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-east4"
  network       = google_compute_network.the_fortress_vpc.id
}

# --- Identity and Access Management ---

# Provisions a dedicated service account for the web server VM.
# This grants the VM a unique identity, following the principle of least privilege.
resource "google_service_account" "web_server_sa" {
  account_id   = "web-server-sa"
  display_name = "Web Server Service Account"
}

# --- Firewall Rules ---

# Allows HTTP ingress traffic from any source to the web server.
# Targeting by service account is more secure and specific than using network tags.
resource "google_compute_firewall" "allow_http" {
  name    = "the-fortress-allow-http"
  network = google_compute_network.the_fortress_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  # Applies this rule only to instances associated with the specified service account.
  target_service_accounts = [google_service_account.web_server_sa.email]
}

# Allows SSH access via Google Cloud's Identity-Aware Proxy (IAP).
# This provides secure, identity-based access without exposing the SSH port to the public internet.
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "the-fortress-allow-iap-ssh"
  network = google_compute_network.the_fortress_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # This specific IP range is owned by Google for the IAP for TCP forwarding service.
  source_ranges = ["35.235.240.0/20"]
}

# --- Compute Resources ---

# Provisions the GCE virtual machine for the web server.
resource "google_compute_instance" "web_server" {
  name         = "lighthouse-vm"
  machine_type = "e2-micro"
  zone         = "us-east4-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  # Connects the VM to the private subnet and assigns a public IP.
  network_interface {
    subnetwork = google_compute_subnetwork.private_subnet.id
    access_config {} # An empty access_config block assigns an ephemeral public IP.
  }

  # Assigns the dedicated service account identity to the VM.
  service_account {
    email  = google_service_account.web_server_sa.email
    scopes = ["cloud-platform"]
  }

  # Executes a startup script from an external file on boot.
  metadata_startup_script = file("startup.sh")
}

# --- Outputs ---

# Outputs the public IP address of the web server.
output "web_server_ip" {
  description = "The public IP address of the web server."
  value       = google_compute_instance.web_server.network_interface[0].access_config[0].nat_ip
}