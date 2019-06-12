variable "s3_bucket" {
  type = object({
    name               = string
    bucket_acl         = string
    versioning_enabled = string
    kms_key_arn        = string
    tags               = map(string)
    prevent_destroy    = bool
  })
}

variable "static_files" {
  type = object({
    local_base_dir = string
    files          = list(string)
  })
  default = null
}

variable "dynamic_files" {
  type = object({
    local_base_dir = string
    files          = list(string)
  })
  default = null
}

variable "content_files" {
  type = object({
    file_names-content = map(string)
  })
  default = null
}

variable "s3_base_dir" {
  type    = "string"
  default = ""
}

variable "folders" {
  type    = "list"
  default = []
}

