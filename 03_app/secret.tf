data "aws_secretsmanager_secret" "private" {
  name = "serverless-2-private-${local.suffix}"
}
