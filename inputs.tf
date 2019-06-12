variable "s3_bucket_name" {
  type = "string"
}

variable "s3_bucket_acl" {
  type = "string"
}

variable "versioning_enabled" {
  type = "string"
}

variable "kms_key_arn" {
  type    = "string"
  default = ""
}

variable "tags_name" {
  type = "string"
}

variable "tags_env" {
  type = "string"
}

variable "s3_base_dir" {
  type    = "string"
  default = ""
}

variable "static_files" {
  type    = "list"
  default = []
}

variable "static_files_base_dir" {
  type    = "string"
  default = ""
}

variable "dynamic_files" {
  type    = "list"
  default = []
}

variable "dynamic_files_base_dir" {
  type    = "string"
  default = ""
}

variable "folders" {
  type    = "list"
  default = []
}

variable "s3_file_content_dict" {
  type    = "map"
  default = {}
}
