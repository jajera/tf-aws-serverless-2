# resource "aws_ecs_task_definition" "heartbeat" {
#   family        = "heartbeat"
#   network_mode  = "bridge"
#   task_role_arn = aws_iam_role.heartbeat_ecs_task.arn

#   container_definitions = jsonencode([{
#     name   = "heartbeat"
#     image  = "public.ecr.aws/amazonlinux/amazonlinux:2023"
#     cpu    = 256
#     memory = 1024

#     environment = [
#       {
#         name  = "AWS_REGION",
#         value = "ap-southeast-2"
#       },
#       {
#         name  = "DB_CONN_TIMEOUT",
#         value = "5"
#       },
#       {
#         name  = "DB_HOST",
#         value = "db.rds.amazonaws.com"
#       },
#       {
#         name  = "DB_MAX_IDLE_CONNS",
#         value = "1"
#       },
#       {
#         name  = "DB_MAX_OPEN_CONNS",
#         value = "2"
#       },
#       {
#         name  = "DB_NAME",
#         value = "mydb"
#       },
#       {
#         name  = "DB_PASSWD",
#         value = "test"
#       },
#       {
#         name  = "DB_SSLMODE",
#         value = "disable"
#       },
#       {
#         name  = "DB_USER",
#         value = "user_w"
#       },
#       {
#         name  = "SQS_QUEUE_URL",
#         value = "sqs_url"
#       }
#     ]

#     essential = true

#     logConfiguration = {
#       logDriver = "awslogs"
#       options = {
#         "awslogs-create-group" = "True"
#         "awslogs-group"        = "/serverless/ecs/service/heartbeat"
#         "awslogs-region"       = data.aws_region.current.name
#       }
#     }

#     portMappings = [
#       {
#         containerPort = 8080
#         hostPort      = 0
#         protocol      = "tcp"
#       }
#     ]
#   }])
# }

# resource "aws_ecs_service" "heartbeat" {
#   name                               = "heartbeat"
#   task_definition                    = aws_ecs_task_definition.heartbeat.arn
#   cluster                            = data.aws_ecs_cluster.private_tier1.id
#   desired_count                      = 1
#   deployment_maximum_percent         = 200
#   deployment_minimum_healthy_percent = 100
#   enable_ecs_managed_tags            = true
#   enable_execute_command             = false

#   deployment_circuit_breaker {
#     enable   = false
#     rollback = false
#   }

#   deployment_controller {
#     type = "ECS"
#   }

#   health_check_grace_period_seconds = 0

#   ordered_placement_strategy {
#     type  = "spread"
#     field = "attribute:ecs.availability-zone"
#   }

#   ordered_placement_strategy {
#     type  = "spread"
#     field = "instanceId"
#   }

#   propagate_tags      = "TASK_DEFINITION"
#   scheduling_strategy = "REPLICA"

#   lifecycle {
#     ignore_changes = [
#       capacity_provider_strategy,
#       desired_count
#     ]
#   }

#   depends_on = [
#     aws_cloudwatch_log_group.heartbeat
#   ]
# }
