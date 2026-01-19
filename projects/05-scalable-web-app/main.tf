provider "google" {
    project = var.project_id
    region  = "us-central1"
}

# --- Call the Reusable VPC Module ---
module "vpc" {
    source       = "../../modules/vpc" # This is the path to your module
    project_id   = var.project_id
    network_name = "scalable-app-vpc"
}

# --- Web Server Configuration ---

resource "google_compute_instance_template" "web_server_template" {
    project      = var.project_id
    name         = "web-server-template"
    machine_type = "e2-micro"
    tags         = ["web-server"]

    disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
    }

    network_interface {
    subnetwork = module.vpc.subnet_id
    access_config {}
    }
    
    metadata_startup_script = file("startup.sh")
}

resource "google_compute_instance_group_manager" "web_server_mig" {
    project            = var.project_id
    name               = "web-server-mig"
    zone               = "us-central1-a"
    base_instance_name = "web-server"
    
    version {
    instance_template = google_compute_instance_template.web_server_template.id
    }

    target_size = 2 

    auto_healing_policies {
    health_check      = google_compute_health_check.http_health_check.id
    initial_delay_sec = 30 
  }
}

# --- Load Balancer Configuration ---

resource "google_compute_health_check" "http_health_check" {
    project             = var.project_id
    name                = "http-health-check"
    check_interval_sec  = 5
    timeout_sec         = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    
    http_health_check {
    port = 80
    }
}

resource "google_compute_backend_service" "web_backend" {
    project          = var.project_id
    name             = "web-backend-service"
    protocol         = "HTTP"
    port_name        = "http"
    timeout_sec      = 10
    health_checks    = [google_compute_health_check.http_health_check.id]
    
    backend {
    group = google_compute_instance_group_manager.web_server_mig.instance_group
    }
}

resource "google_compute_url_map" "web_url_map" {
    project         = var.project_id
    name            = "web-url-map"
    default_service = google_compute_backend_service.web_backend.id
}

resource "google_compute_target_http_proxy" "http_proxy" {
    project = var.project_id
    name    = "http-proxy"
    url_map = google_compute_url_map.web_url_map.id
}

resource "google_compute_global_forwarding_rule" "http_forwarding_rule" {
    project      = var.project_id
    name         = "http-forwarding-rule"
    target       = google_compute_target_http_proxy.http_proxy.id
    port_range   = "80"
}

# --- Output the Load Balancer's IP Address ---
output "load_balancer_ip" {
    description = "The public IP address of the load balancer."
    value       = google_compute_global_forwarding_rule.http_forwarding_rule.ip_address
}