provider "google" {
  version      = "2.20"
  project      = var.gcp_project
  region       = var.gcp_region
  access_token = data.google_service_account_access_token.default.access_token
}

terraform {
  backend "gcs" {
    bucket = "edml"
    prefix = "/metadata/aiplatform"
  }
}

module "tensorboard" {
  source      = "./modules/tensorboard"
  gcp_project = var.gcp_project
  gcp_region  = var.gcp_region
  network     = google_compute_network.ai_platform.id
}

module "mlflow" {
  source      = "./modules/mlflow"
  gcp_project = var.gcp_project
  gcp_region  = "europe-west2"
  network     = google_compute_network.ai_platform.id
}

module "jupyter" {
  source        = "./modules/jupyter"
  gcp_project   = var.gcp_project
  gcp_region    = "europe-west1"
  gcp_zone      = "europe-west1-b"
  network       = google_compute_network.ai_platform.id
  notebook_name = "edml"
  machine_type  = "n1-standard-8"
  disk_size     = "500"
  github_user   = var.github_user
  github_token  = var.github_token
  git_branch    = var.github_branch
}