resource "aws_lb" "app1" {
  name                       = "serverless-2-app1-${local.suffix}"
  internal                   = false
  load_balancer_type         = "application"
  drop_invalid_header_fields = true

  security_groups = [
    aws_security_group.app1_lb.id
  ]

  subnets = data.aws_subnets.public.ids
}

resource "aws_lb_target_group" "app1" {
  name        = "serverless-2-app1-${local.suffix}"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.example.id

  health_check {
    path = "/soh"
  }
}

resource "aws_lb_listener" "app1" {
  load_balancer_arn = aws_lb.app1.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app1.arn
  }
}
