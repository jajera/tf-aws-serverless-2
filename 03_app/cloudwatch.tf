resource "aws_cloudwatch_log_group" "app1" {
  name              = "/ecs-${local.suffix}/ecs/service/app1"
  retention_in_days = 1
  kms_key_id        = data.aws_kms_key.private.arn

  lifecycle {
    prevent_destroy = false
  }
}
