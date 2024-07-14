resource "aws_s3_bucket" "app1" {
  bucket        = "serverless-2-${local.suffix}"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "app1" {
  bucket = aws_s3_bucket.app1.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

locals {
  source_code = "${path.module}/external"
  files = [
    for file in fileset(local.source_code, "**/*") :
    {
      path = "${local.source_code}/${file}",
      dest = file
    }
  ]
}

resource "aws_s3_object" "app1" {
  for_each = { for file in local.files : file.path => file }
  bucket   = aws_s3_bucket.app1.id
  key      = each.value.dest
  source   = each.value.path
  etag     = filemd5(each.value.path)
}
