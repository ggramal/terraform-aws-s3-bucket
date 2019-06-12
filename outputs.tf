output "s3_bucket_arn" {
  value = "${local.s3_bucket_arn}"
}

output "s3_dynamic_objects" {
  value = "${replace(join(" ", var.dynamic_files),"/(^| )//"," ")}" //join file list and remove preceding "/"
}

output "s3_static_objects" {
  value = "${replace(join(" ", var.static_files),"/(^| )//"," ")}" //join file list and remove preceding "/"
}

output "s3_folder_objects" {
  value = "${replace(join(" ", var.folders),"/(^| )//"," ")}"
}

output "s3_content_objects" {
  value = "${join(" ",local.s3_files)}"
}

output "s3_base_dir" {
  value = "${replace(var.s3_base_dir,"//$/","")}"
}

output "s3_bucket_name" {
  value = "${var.s3_bucket_name}"
}
