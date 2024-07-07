resource "aws_lb" "app1" {
  name                       = "app1-${local.suffix}"
  internal                   = false
  load_balancer_type         = "application"
  drop_invalid_header_fields = true

  security_groups = [
    aws_security_group.app1_lb.id
  ]

  subnets = data.aws_subnets.private.ids
}

resource "aws_lb_target_group" "app1" {
  name        = "app1-${local.suffix}"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.example.id

  health_check {
    matcher = "200,301,302,404"
    path    = "/healthcheck"
  }
}

resource "aws_lb_listener" "app1" {
  load_balancer_arn = aws_lb.app1.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app1.arn
  }
}
