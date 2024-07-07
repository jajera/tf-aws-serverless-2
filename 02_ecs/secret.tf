resource "random_password" "private_tier1" {
  length           = 32
  special          = true
  override_special = "_!#%&*()-<=>?[]^_{|}~"
}

resource "aws_secretsmanager_secret" "private_tier1" {
  name                    = "ecs_secret"
  recovery_window_in_days = 0
  kms_key_id              = aws_kms_key.private_tier1.id
}

resource "aws_secretsmanager_secret_version" "private_tier1" {
  secret_id     = aws_secretsmanager_secret.private_tier1.id
  secret_string = random_password.private_tier1.result
}
