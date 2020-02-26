variable "gcp_project" {}

variable "gcp_region" {
  default = "europe-west2"
}

/*
variable "gcp_availability_zones" {
  type    = "list"
  default = ["europe-west2-b"]
}*/

variable "github_project" {}

variable "github_user" {}

variable "github_token" {}

variable "github_branch" {
  default = ""
}

variable "service_account_id" {}