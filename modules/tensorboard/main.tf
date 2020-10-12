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

resource "google_compute_firewall" "tensorboard" {

  name    = "tensorboard-firewall"
  project = var.gcp_project
  network = google_compute_subnetwork.tensorboard_subnet.network
  allow {

    protocol = "tcp"
    ports    = ["80"]
  }
  target_tags = ["tensorboard"]
  source_ranges = ["0.0.0.0/0"]
}