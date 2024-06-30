resource "aws_cloudwatch_log_group" "private_tier1" {
  name              = "/serverless-2/ecs/private-tier1/logs"
  retention_in_days = 1
  kms_key_id        = aws_kms_key.private_tier1.arn

  lifecycle {
    prevent_destroy = false
  }
}

# resource "aws_cloudwatch_log_group" "cwagent" {
#   name              = "/serverless-2/ecs/service/cwagent"
#   retention_in_days = 1

#   lifecycle {
#     prevent_destroy = false
#   }
# }
