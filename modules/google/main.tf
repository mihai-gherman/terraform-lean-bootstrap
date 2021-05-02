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

variable "force_destroy_tfstate_bucket" {
  type        = bool
  default     = false
  description = "Allow destruction of state bucket containing tfstate data"
}

variable "tfbackend_config_filename" {
  default     = null
  description = "Name of `.tf` file to be generated with remote backend configuration. The specified filename/path is relative to the current Terraform root module. After creation run `terraform init` to migrate local state to the remote backend. Don't forget to add the resulting `.tf` file to source control. Setting this variable to null destroys the `.tf` file, after which `terraform init` can be used to migrate remote state back to local state."
}

# ------------------------------------------------------------------------------
# OUTPUTS
# ------------------------------------------------------------------------------

output "project_id" {
  value = google_project.project.project_id
}

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
