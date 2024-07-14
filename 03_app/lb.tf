data "aws_lb_target_group" "app1" {
  name = "serverless-2-app1-${local.suffix}"
}
