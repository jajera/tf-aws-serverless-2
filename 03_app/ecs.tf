data "aws_ecs_cluster" "private" {
  cluster_name = "serverless-2-private-${local.suffix}"
}

resource "aws_ecs_task_definition" "app1" {
  family                   = "app1-${local.suffix}"
  execution_role_arn       = aws_iam_role.app1_ecs_execution.arn
  task_role_arn            = aws_iam_role.app1_ecs_task.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "3072"

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name                   = "app1-${local.suffix}"
      image                  = "${data.aws_ecr_repository.app1.repository_url}:app1-latest"
      memory                 = 512
      essential              = true
      readonlyRootFilesystem = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.app1.name}"
          awslogs-region        = "${data.aws_region.current.name}"
          awslogs-stream-prefix = "ecs"
        }
      }
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8080/soh>> /proc/1/fd/1 2>&1 || exit 1"]
        interval    = 30
        retries     = 3
        timeout     = 5
        startPeriod = 10
      }
      environments = [
        {
          name  = "AWS_REGION",
          value = "${data.aws_region.current.name}"
        }
      ]
      secrets = [
        {
          name      = data.aws_secretsmanager_secret.private.name
          valueFrom = data.aws_secretsmanager_secret.private.arn
        }
      ]
    }
  ])

  depends_on = [
    aws_cloudwatch_log_group.app1
  ]  
}

resource "aws_ecs_service" "app1" {
  name                 = "app1-${local.suffix}"
  cluster              = data.aws_ecs_cluster.private.id
  task_definition      = aws_ecs_task_definition.app1.arn
  desired_count        = 3
  force_new_deployment = true

  load_balancer {
    target_group_arn = data.aws_lb_target_group.app1.arn
    container_name   = "app1-${local.suffix}"
    container_port   = "8080"
  }

  launch_type = "FARGATE"

  network_configuration {
    security_groups  = data.aws_security_groups.app1_lb.ids
    subnets          = data.aws_subnets.private.ids
    assign_public_ip = false
  }
}
