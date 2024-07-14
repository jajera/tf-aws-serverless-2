data "aws_kms_key" "private" {
  key_id = "alias/serverless-2-private-${local.suffix}"
}
