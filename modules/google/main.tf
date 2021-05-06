# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  tfbackend_config = !var.has_tfstate_bucket ? null : <<-EOT
    terraform {
      backend "gcs" {
        bucket = "${google_storage_bucket.tfstate_bucket[0].name}"
       }
    }
  EOT
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

resource "google_project" "project" {
  name            = var.project_name
  project_id      = random_id.project_id.dec
  org_id          = var.org_id
  folder_id       = var.folder_id
  billing_account = var.billing_account
}

resource "google_storage_bucket" "tfstate_bucket" {
  count         = var.has_tfstate_bucket ? 1 : 0
  project       = google_project.project.project_id
  name          = random_id.tfstate_bucket_name.dec
  location      = var.region
  versioning {
    enabled = true
  }
  uniform_bucket_level_access = true
  force_destroy = var.force_destroy_tfstate_bucket
}

resource "local_file" "tfbackend_google_file" {
  count           = var.tfbackend_config_filename == null ? 0 : 1
  content         = local.tfbackend_config
  filename        = "${path.root}/${var.tfbackend_config_filename}"
  file_permission = "0640"
}
