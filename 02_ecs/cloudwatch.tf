resource "aws_cloudwatch_log_group" "private" {
  name              = "/ecs-${local.suffix}/ecs/cluster/private"
  retention_in_days = 1
  kms_key_id        = aws_kms_key.private.arn

  lifecycle {
    prevent_destroy = false
  }
}
