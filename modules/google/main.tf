# ------------------------------------------------------------------------------
# INPUT VARIABLES (required)
# ------------------------------------------------------------------------------
variable "project_name" {}

# ------------------------------------------------------------------------------
# INPUT VARIABLES (optional)
# ------------------------------------------------------------------------------

variable "org_id" {
  default = null
}

variable "folder_id" {
  default = null
}

variable "billing_account" {
  default = null
}

variable "region" {
  default = null
}

variable "has_tfstate_bucket" {
  type    = bool
  default = false
}

# ------------------------------------------------------------------------------
# OUTPUTS
# ------------------------------------------------------------------------------

output "project_id" {
  value = google_project.project.project_id
}

output "tfstate_bucket_name" {
  value = var.has_tfstate_bucket ? google_storage_bucket.tfstate_bucket[0].name : null
}

output "tfbackend_config" {
  value = !var.has_tfstate_bucket ? null : <<-EOT
    terraform {
      backend "gcs" {
        bucket = "${google_storage_bucket.tfstate_bucket[0].name}"
       }
    }
  EOT
  description = "Terraform configuration using \"tfstate_bucket\" as remote backend. Write this to a .tf file in the root module using a Terraform \"local_file\" resource, and subsequently run \"terraform init\" to migrate the local state to the remote backend. Don't forget to add the resulting .tf file to source control."
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
  force_destroy = false
}