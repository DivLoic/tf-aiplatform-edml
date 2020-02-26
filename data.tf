data "google_service_account" "tf_account" {
  project    = var.gcp_project
  account_id = "jarvis"
}

data "google_service_account_access_token" "default" {
  provider = "google.impersonated"
  target_service_account = data.google_service_account.tf_account.email
  scopes = [
    "userinfo-email",
    "cloud-platform"
  ]
  lifetime = "300s"
}