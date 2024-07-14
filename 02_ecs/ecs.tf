resource "aws_ecs_cluster" "private" {
  name = "serverless-2-private-${local.suffix}"

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"
      kms_key_id = aws_kms_key.private.id

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name = aws_cloudwatch_log_group.private.name
      }
    }
  }

  service_connect_defaults {
    namespace = aws_service_discovery_http_namespace.private.arn
  }

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
