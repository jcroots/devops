# Instance Template
resource "google_compute_instance_template" "default" {
  name_prefix = "instance-template-"
  description = "Instance template for managed instance group"

  machine_type = var.instance_type

  disk {
    source_image = "debian-cloud/debian-11"
    disk_type    = "pd-standard"
    disk_size_gb = 20
  }

  network_interface {
    network = google_compute_network.default.name
  }

  metadata = {
    enable-oslogin = "true"
  }

  service_account {
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }

  tags = ["http-server", "load-balanced"]

  lifecycle {
    create_before_destroy = true
  }
}

# Instance Group Manager (Managed Instance Group)
resource "google_compute_instance_group_manager" "default" {
  name               = "instance-group-manager"
  base_instance_name = "instance"
  zone               = var.zone
  target_size        = var.min_instances

  version {
    instance_template = google_compute_instance_template.default.id
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.default.id
    initial_delay_sec = 300
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Autoscaling Policy
resource "google_compute_autoscaler" "default" {
  name   = "instance-group-autoscaler"
  zone   = var.zone
  target = google_compute_instance_group_manager.default.id

  autoscaling_policy {
    min_replicas    = var.min_instances
    max_replicas    = var.max_instances
    cooldown_period = 300

    cpu_utilization {
      target = 0.75
    }
  }
}

# Health Check
resource "google_compute_health_check" "default" {
  name = "instance-health-check"

  http_health_check {
    port              = 80
    request_path      = "/"
    check_interval_sec = 10
    timeout_sec       = 5
  }
}

# Backend Service for HTTP(S) Load Balancer
resource "google_compute_backend_service" "default" {
  name            = "backend-service"
  protocol        = "HTTP"
  timeout_sec     = 30
  health_checks   = [google_compute_health_check.default.id]
  session_affinity = "NONE"

  backend {
    group                 = google_compute_instance_group_manager.default.instance_group
    balancing_mode        = "RATE"
    max_rate_per_instance = 100
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Google-Managed SSL Certificate
resource "google_compute_managed_ssl_certificate" "default" {
  name            = "managed-ssl-cert"
  managed {
    domains = var.domain_names
  }

  lifecycle {
    create_before_destroy = true
  }
}

# HTTPS Target Proxy with Google-Managed Certificate
resource "google_compute_target_https_proxy" "default" {
  name             = "https-proxy"
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
}

# HTTP to HTTPS redirect URL Map
resource "google_compute_url_map" "http_redirect" {
  name = "http-redirect-url-map"

  default_url_redirect {
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
    https_redirect         = true
  }
}

# HTTP Target Proxy (for redirect)
resource "google_compute_target_http_proxy" "default" {
  name    = "http-proxy"
  url_map = google_compute_url_map.http_redirect.id
}

# URL Map for HTTPS
resource "google_compute_url_map" "default" {
  name            = "url-map"
  default_service = google_compute_backend_service.default.id
}

# HTTPS Forwarding Rule
resource "google_compute_global_forwarding_rule" "https" {
  name                  = "https-forwarding-rule"
  load_balancing_scheme = "EXTERNAL"
  ip_protocol           = "TCP"
  ports                 = ["443"]
  target                = google_compute_target_https_proxy.default.id
}

# HTTP Forwarding Rule (for redirect)
resource "google_compute_global_forwarding_rule" "http" {
  name                  = "http-forwarding-rule"
  load_balancing_scheme = "EXTERNAL"
  ip_protocol           = "TCP"
  ports                 = ["80"]
  target                = google_compute_target_http_proxy.default.id
}

# Network
resource "google_compute_network" "default" {
  name                    = "instance-group-network"
  auto_create_subnetworks = true
}

# Firewall Rule for HTTP
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = google_compute_network.default.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

# Firewall Rule for HTTPS
resource "google_compute_firewall" "allow_https" {
  name    = "allow-https"
  network = google_compute_network.default.name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

# Firewall Rule for Health Checks
resource "google_compute_firewall" "allow_health_checks" {
  name    = "allow-health-checks"
  network = google_compute_network.default.name

  allow {
    protocol = "tcp"
  }

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  target_tags   = ["load-balanced"]
}

# Service Account
resource "google_service_account" "default" {
  account_id   = "instance-group-sa"
  display_name = "Instance Group Service Account"
}

# Outputs
output "instance_group_manager_id" {
  description = "Instance Group Manager ID"
  value       = google_compute_instance_group_manager.default.id
}

output "instance_group_manager_name" {
  description = "Instance Group Manager name"
  value       = google_compute_instance_group_manager.default.name
}

output "autoscaler_id" {
  description = "Autoscaler ID"
  value       = google_compute_autoscaler.default.id
}

output "backend_service_id" {
  description = "Backend Service ID"
  value       = google_compute_backend_service.default.id
}

output "managed_ssl_certificate_id" {
  description = "Google-Managed SSL Certificate ID"
  value       = google_compute_managed_ssl_certificate.default.id
}

output "http_forwarding_rule_ip" {
  description = "HTTP Forwarding Rule IP address"
  value       = google_compute_global_forwarding_rule.http.ip_address
}

output "https_forwarding_rule_ip" {
  description = "HTTPS Forwarding Rule IP address"
  value       = google_compute_global_forwarding_rule.https.ip_address
}

output "load_balancer_ip" {
  description = "Load Balancer IP address (HTTPS)"
  value       = google_compute_global_forwarding_rule.https.ip_address
}

output "managed_certificate_status" {
  description = "Google-Managed Certificate Status"
  value       = google_compute_managed_ssl_certificate.default.managed[0]
}

output "network_name" {
  description = "Network name"
  value       = google_compute_network.default.name
}
