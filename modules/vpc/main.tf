resource "google_compute_network" "custom_vpc" {
    project                 = var.project_id
    name                    = var.network_name
    auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "private_subnet" {
    project       = var.project_id
    name          = "${var.network_name}-private-subnet"
    ip_cidr_range = "10.0.1.0/24"
    region        = "us-central1"
    network       = google_compute_network.custom_vpc.id
}

resource "google_compute_firewall" "allow_http" {
    project       = var.project_id
    name          = "${var.network_name}-allow-http"
    network       = google_compute_network.custom_vpc.id
    allow {
    protocol = "tcp"
    ports    = ["80"]
    }
    source_ranges = ["0.0.0.0/0"]
    target_tags   = ["web-server"]
}

resource "google_compute_firewall" "allow_health_checks" {
  project = var.project_id
  name    = "${var.network_name}-allow-health-checks"
  network = google_compute_network.custom_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  
  target_tags = ["web-server"]
}

resource "google_compute_firewall" "allow_iap_ssh" {
    project       = var.project_id
    name          = "${var.network_name}-allow-iap-ssh"
    network       = google_compute_network.custom_vpc.id
    allow {
    protocol = "tcp"
    ports    = ["22"]
    }
    source_ranges = ["35.235.240.0/20"]
}