resource "aws_s3_bucket" "s3-bucket" {
  count  = "${var.kms_key_arn == "" ? 1 : 0}"
  bucket = "${var.s3_bucket_name}"
  acl    = "${var.s3_bucket_acl}"

  versioning {
    enabled = "${var.versioning_enabled}"
  }

  tags {
    Name        = "${var.tags_name}"
    Environment = "${var.tags_env}"
  }
}

resource "aws_s3_bucket" "s3-bucket-encrypted" {
  count  = "${var.kms_key_arn == "" ? 0 : 1}"
  bucket = "${var.s3_bucket_name}"
  acl    = "${var.s3_bucket_acl}"

  versioning {
    enabled = "${var.versioning_enabled}"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${var.kms_key_arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags {
    Name        = "${var.tags_name}"
    Environment = "${var.tags_env}"
  }
}

locals {
  s3_files      = ["${keys(var.s3_file_content_dict)}"]
  s3_content    = ["${values(var.s3_file_content_dict)}"]
  s3_bucket     = "${var.kms_key_arn == "" ? join(" ",aws_s3_bucket.s3-bucket.*.bucket) : join(" ",aws_s3_bucket.s3-bucket-encrypted.*.bucket)}"
  s3_bucket_arn = "${var.kms_key_arn == "" ? join(" ",aws_s3_bucket.s3-bucket.*.arn) : join(" ",aws_s3_bucket.s3-bucket-encrypted.*.arn)}"
}

resource "aws_s3_bucket_object" "s3-bucket-folder-objects" {
  count  = "${length(var.folders)}"
  bucket = "${local.s3_bucket}"
  key    = "${element(var.folders, count.index)}/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "s3-bucket-static-objects" {
  count                  = "${length(var.static_files)}"
  bucket                 = "${local.s3_bucket}"
  key                    = "${var.s3_base_dir}/${element(var.static_files, count.index)}"
  source                 = "${var.static_files_base_dir}/${element(var.static_files, count.index)}"
  server_side_encryption = "aws:kms"
}

resource "aws_s3_bucket_object" "s3-bucket-dynamic-objects" {
  count  = "${length(var.dynamic_files)}"
  bucket = "${local.s3_bucket}"
  key    = "${var.s3_base_dir}/${element(var.dynamic_files, count.index)}"
  source = "${var.dynamic_files_base_dir}/${element(var.dynamic_files, count.index)}"
  etag   = "${md5(file("${var.dynamic_files_base_dir}/${element(var.dynamic_files, count.index)}"))}"
}

resource "aws_s3_bucket_object" "s3-bucket-content-objects" {
  count   = "${length(local.s3_files)}"
  bucket  = "${local.s3_bucket}"
  key     = "${var.s3_base_dir}/${element(local.s3_files, count.index)}"
  content = "${element(local.s3_content, count.index)}"
}
