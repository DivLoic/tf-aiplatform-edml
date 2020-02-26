data "google_compute_lb_ip_ranges" "ranges" {}

data "google_compute_ssl_certificate" "tensorboard-cert" {
  name    = "tensorboard-cert"
  project = var.gcp_project
}

data "google_compute_global_address" "tensorboard-ip" {
  name    = "tensorboard-ip"
  project = var.gcp_project
}

data "template_file" "tensorboard_startup" {
  template = file("${path.module}/utils/tensorboard-startup.sh")
}