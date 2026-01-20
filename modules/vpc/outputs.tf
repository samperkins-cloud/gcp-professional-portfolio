output "network_name" {
  description = "The name of the VPC network."
  value       = google_compute_network.custom_vpc.name
}

output "subnet_id" {
  description = "The ID of the private subnet."
  value       = google_compute_subnetwork.private_subnet.id
}