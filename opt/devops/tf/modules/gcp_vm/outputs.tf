output "instance_id" {
  description = "The ID of the instance"
  value       = google_compute_instance.vm.id
}

output "instance_name" {
  description = "The name of the instance"
  value       = google_compute_instance.vm.name
}

output "internal_ip" {
  description = "Internal IP of the instance"
  value       = google_compute_instance.vm.network_interface[0].network_ip
}

output "external_ip" {
  description = "External IP of the instance"
  value       = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}
