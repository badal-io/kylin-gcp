terraform {
  backend "gcs" {
    bucket  = "<OPS_BUCKET_NAME>"
    prefix  = "terraform/state/kylin"
  }
}

provider "google" {
  # project     = "" // provided by ${GOOGLE_PROJECT}
  region      = "${var.default_region}"
}

variable "default_region" {
  default = "us-central1"
  description = "default region for regional/zonal resource deployments"
}

variable "default_zone" {
  default = "us-central1-a"
  description = "default zone for zonal resource deployments"
}
