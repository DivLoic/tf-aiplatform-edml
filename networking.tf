resource "google_compute_network" "ai_platform" {
  name                    = "ai-platform"
  project                 = var.gcp_project
  auto_create_subnetworks = false
}

resource "google_compute_firewall" "main-ssh-access" {
  name    = "ssh-access"
  project = var.gcp_project
  network = google_compute_network.ai_platform.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = [
    //"mlflow"
    //"jupyter"
    //"tensorboard"
  ]
}