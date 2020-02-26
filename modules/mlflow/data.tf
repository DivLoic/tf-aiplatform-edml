data "google_compute_lb_ip_ranges" "ranges" {}

data "google_compute_ssl_certificate" "mlflow-cert" {
  name    = "mlflow-cert"
  project = var.gcp_project
}

data "google_compute_global_address" "mlflow-ip" {
  name    = "mlflow-ip"
  project = var.gcp_project
}

data "template_file" "mlflow_startup" {
  template = file("${path.module}/utils/mlflow-startup.sh")
}