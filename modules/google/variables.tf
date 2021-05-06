# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "project_name" {}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES
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
  description = "Allow destruction of non-empty bucket containing tfstate data"
  type        = bool
  default     = false
}

variable "tfbackend_config_filename" {
  description = "Create backend `.tf` file by specifying name/path (relative to root module)"
  default     = null
}
