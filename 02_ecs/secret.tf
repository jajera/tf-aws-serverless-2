resource "random_password" "private" {
  length           = 32
  special          = true
  override_special = "_!#%&*()-<=>?[]^_{|}~"
}

resource "aws_secretsmanager_secret" "private" {
  name                    = "serverless-2-private-${local.suffix}"
  recovery_window_in_days = 0
  kms_key_id              = aws_kms_key.private.id
}

resource "aws_secretsmanager_secret_version" "private" {
  secret_id     = aws_secretsmanager_secret.private.id
  secret_string = random_password.private.result
}
