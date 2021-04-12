# ------------------------------------------------------------------------------
# INPUT VARIABLES (required)
# ------------------------------------------------------------------------------

variable "project_name" {}

variable "org_id" {}

variable "billing_account" {}

# ------------------------------------------------------------------------------
# INPUT VARIABLES (optional)
# ------------------------------------------------------------------------------

variable "default_region" {
  default = null
}

variable "default_zone" {
  default = null
}


# ------------------------------------------------------------------------------
# OUTPUTS
# ------------------------------------------------------------------------------

output "project_id" {
  value = google_project.project.project_id
}

output "tfstate_bucket_name" {
  value = google_storage_bucket.tfstate_bucket.name
}


# ------------------------------------------------------------------------------
# RESOURCES
# ------------------------------------------------------------------------------

resource "random_id" "project_id" {
  byte_length = 2
  prefix      = "${var.project_name}-"
}

resource "random_id" "tfstate_bucket_name" {
  byte_length = 2
  prefix      = "${var.project_name}-tfstate-"
}


provider "google" {
  project = random_id.project_id.dec
  region = var.default_region
  zone = var.default_zone
}

resource "google_project" "project" {
  name            = var.project_name
  project_id      = random_id.project_id.dec
  org_id          = var.org_id
  billing_account = var.billing_account
}

resource "google_storage_bucket" "tfstate_bucket" {
  project       = google_project.project.project_id
  name          = random_id.tfstate_bucket_name.dec
  location      = var.default_region
  versioning {
    enabled = true
  }
  uniform_bucket_level_access = true
  force_destroy = false
}