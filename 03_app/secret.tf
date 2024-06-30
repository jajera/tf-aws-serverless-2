data "aws_secretsmanager_secret" "private_tier1" {
  name = "ecs_secret"
}
