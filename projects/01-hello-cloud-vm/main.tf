# Specifies the required provider for this configuration.
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

# Provisions a Google Compute Engine virtual machine.
resource "google_compute_instance" "hello_world_vm" {
  name         = "hello-world-vm"
  machine_type = "e2-micro"
  zone         = "us-east4-a"

  # Configures the VM's boot disk with a Debian 11 image.
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  # Attaches the VM to the default network to enable connectivity.
  network_interface {
    network = "default"
  }
}