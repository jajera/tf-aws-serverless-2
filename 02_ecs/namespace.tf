resource "aws_service_discovery_http_namespace" "private" {
  name        = "serverless-2-private-${local.suffix}"
  description = "ECS cluster namespace."
}
