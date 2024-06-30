data "aws_kms_key" "private_tier1" {
  key_id = "alias/serverless-2-${local.suffix}"
}
