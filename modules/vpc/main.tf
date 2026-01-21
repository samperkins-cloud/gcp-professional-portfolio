# 1. CREATE THE CUSTOM VPC
# This creates a custom VPC to provide an isolated network environment. Manual subnet
# creation is enabled for full control over the network topology, a security best practice.
resource "google_compute_network" "custom_vpc" {
  project                 = var.project_id
  name                    = var.network_name
  auto_create_subnetworks = false
}

# 2. CREATE THE PRIVATE SUBNET
# This defines a private subnet within the VPC where resources like virtual machines
# will be launched.
resource "google_compute_subnetwork" "private_subnet" {
  project       = var.project_id
  name          = "${var.network_name}-private-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.custom_vpc.id
}

# 3. CREATE THE FIREWALL RULES
# These rules define what kind of traffic is allowed to reach resources within the VPC.

# Allows incoming HTTP traffic from the internet to any VM with the "web-server" tag.
resource "google_compute_firewall" "allow_http" {
  project = var.project_id
  name    = "${var.network_name}-allow-http"
  network = google_compute_network.custom_vpc.id
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
}

# Allows traffic from Google Cloud's health checkers, which is critical for load
# balancers to determine instance health. This is more secure than allowing all traffic.
resource "google_compute_firewall" "allow_health_checks" {
  project = var.project_id
  name    = "${var.network_name}-allow-health-checks"
  network = google_compute_network.custom_vpc.id
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  # These are Google's official IP ranges for health checkers.
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  target_tags   = ["web-server"]
}

# Allows secure SSH access via Google's Identity-Aware Proxy (IAP), avoiding direct
# exposure of port 22 to the internet. The source range is specific to Google's IAP service.
resource "google_compute_firewall" "allow_iap_ssh" {
  project = var.project_id
  name    = "${var.network_name}-allow-iap-ssh"
  network = google_compute_network.custom_vpc.id
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]
}