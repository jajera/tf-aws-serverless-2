data "aws_ecr_repository" "app1" {
  name = "serverless-2-app1-${local.suffix}"
}
