resource "aws_s3_bucket" "s3-bucket" {
  count  = var.s3_bucket.kms_key_arn == "" ? 1 : 0
  bucket = var.s3_bucket.name
  acl    = var.s3_bucket.bucket_acl

  versioning {
    enabled = var.s3_bucket.versioning_enabled
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.s3_bucket.kms_key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }


  tags = var.s3_bucket.tags
}

resource "aws_s3_bucket" "s3-bucket-encrypted" {
  count  = var.s3_bucket.kms_key_arn == "" ? 0 : 1
  bucket = var.s3_bucket.name
  acl    = var.s3_bucket.bucket_acl

  versioning {
    enabled = var.s3_bucket.versioning_enabled
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.s3_bucket.kms_key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = var.s3_bucket.tags
}

locals {
  s3_files      = var.content_files != null ? keys(var.content_files.file_names-content) : []
  s3_content    = var.content_files != null ? values(var.content_files.file_names-content) : []
  s3_bucket     = var.s3_bucket.kms_key_arn == "" ? aws_s3_bucket.s3-bucket[0].bucket : aws_s3_bucket.s3-bucket-encrypted[0].bucket
  s3_bucket_arn = var.s3_bucket.kms_key_arn == "" ? aws_s3_bucket.s3-bucket[0].arn : aws_s3_bucket.s3-bucket-encrypted[0].arn
}

resource "aws_s3_bucket_object" "s3-bucket-folder-objects" {
  count  = length(var.folders)
  bucket = local.s3_bucket
  key    = "${var.folders[count.index]}/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "s3-bucket-static-objects" {
  count                  = var.static_files != null ? length(var.static_files.files) : 0
  bucket                 = local.s3_bucket
  key                    = "${var.s3_base_dir}/${var.static_files.files[count.index]}"
  source                 = "${var.static_files.local_base_dir}/${var.static_files.files[count.index]}"
  server_side_encryption = "aws:kms"
}

resource "aws_s3_bucket_object" "s3-bucket-dynamic-objects" {
  count  = var.dynamic_files != null ? length(var.dynamic_files.files) : 0
  bucket = local.s3_bucket
  key    = "${var.s3_base_dir}/${var.dynamic_files.files[count.index]}"
  source = "${var.dynamic_files.local_base_dir}/${var.dynamic_files.files[count.index]}"
  etag   = md5(file("${var.dynamic_files.local_base_dir}/${var.dynamic_files.files[count.index]}"))
}

resource "aws_s3_bucket_object" "s3-bucket-content-objects" {
  count   = var.content_files != null ? length(local.s3_files) : 0
  bucket  = local.s3_bucket
  key     = "${var.s3_base_dir}/${local.s3_files[count.index]}"
  content = local.s3_content[count.index]
}
