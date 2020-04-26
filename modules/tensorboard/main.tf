resource "google_compute_subnetwork" "tensorboard_subnet" {
  name          = "tensorboard-subnet"
  project       = var.gcp_project
  region        = var.gcp_region
  network       = var.network
  ip_cidr_range = "10.0.3.0/28"
}

resource "google_compute_instance" "tensorboard" {

  name                      = "tensorboard"
  zone                      = "europe-west2-b"
  machine_type              = "n1-standard-2"
  project                   = var.gcp_project
  allow_stopping_for_update = true
  metadata_startup_script   = data.template_file.tensorboard_startup.rendered
  service_account {
    scopes = ["cloud-platform"]
  }
  tags = ["tensorboard"]
  network_interface {
    network    = google_compute_subnetwork.tensorboard_subnet.network
    subnetwork = google_compute_subnetwork.tensorboard_subnet.self_link
    access_config {}
  }
  boot_disk {
    initialize_params {
      image = "ubuntu-1910-eoan-v20191114"
    }
  }
}

resource "google_compute_instance_group" "tensorboard" {
  name    = "tensorboard-group"
  project = var.gcp_project
  zone    = "europe-west2-b"
  instances = [
    google_compute_instance.tensorboard.self_link
  ]

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_health_check" "tensorboard" {
  name    = "tensorboard-http-health-check"
  project = var.gcp_project

  healthy_threshold   = 1
  unhealthy_threshold = 10
  check_interval_sec  = 60
  timeout_sec         = 20

  http_health_check {
    port         = "80"
    request_path = "/"
  }
}

resource "google_compute_backend_service" "tensorboard" {

  name        = "tensorboard-backend-service"
  project     = var.gcp_project
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 120


  backend {
    group = google_compute_instance_group.tensorboard.self_link
  }
  health_checks = [
    google_compute_health_check.tensorboard.self_link
  ]

  //iap {
  //  oauth2_client_id = var.tf_oauth2_id
  //  oauth2_client_secret =  var.tf_oauth2_id
  //
}

resource "google_compute_url_map" "tensorboard" {
  name            = "tensorboard-url-map"
  project         = var.gcp_project
  default_service = google_compute_backend_service.tensorboard.self_link
}

resource "google_compute_target_https_proxy" "tensorboard" {
  name    = "tensorboard-http-proxy"
  project = var.gcp_project
  url_map = google_compute_url_map.tensorboard.self_link
  ssl_certificates = [
    data.google_compute_ssl_certificate.tensorboard-cert.self_link
  ]
}

resource "google_compute_global_forwarding_rule" "tensorboard" {
  name       = "tensorboard-frontend"
  project    = var.gcp_project
  port_range = "443"
  target     = google_compute_target_https_proxy.tensorboard.self_link
  ip_address = data.google_compute_global_address.tensorboard-ip.self_link
}

resource "google_compute_firewall" "tensorboard" {

  name    = "tensorboard-firewall"
  project = var.gcp_project
  network = google_compute_subnetwork.tensorboard_subnet.network
  allow {

    protocol = "tcp"
    ports    = ["80"]
  }
  target_tags = ["tensorboard"]
  source_ranges = concat(
    data.google_compute_lb_ip_ranges.ranges.http_ssl_tcp_internal
  )
}