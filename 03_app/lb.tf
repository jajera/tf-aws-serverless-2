data "aws_lb_target_group" "app1" {
  name = "app1-${local.suffix}"
}
