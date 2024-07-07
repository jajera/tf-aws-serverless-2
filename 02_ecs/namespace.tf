resource "aws_service_discovery_http_namespace" "private_tier1" {
  name        = "private-tier1"
  description = "ECS cluster namespace."
}
