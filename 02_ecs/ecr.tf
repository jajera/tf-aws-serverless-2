resource "aws_ecr_repository" "app1" {
  name         = "serverless-2-app1-${local.suffix}"

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.private.arn
  }

  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "IMMUTABLE"
}
