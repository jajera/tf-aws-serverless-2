resource "aws_iam_role" "app1_ecs_task" {
  name               = "serverless-2-app1-ecs-task-${local.suffix}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "ecs-tasks.amazonaws.com"
          ]
        }
        Condition = {
          ArnLike = {
            "aws:SourceArn" = "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
          }
          StringEquals = {
            "aws:SourceAccount" = "${data.aws_caller_identity.current.account_id}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "app1_ecs_task" {
  role   = aws_iam_role.app1_ecs_task.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt"
        ]
        Resource = [
          "${data.aws_kms_key.private_tier1.arn}"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "app1_ecs_execution" {
  name = "serverless-2-app1-ecs-execution-${local.suffix}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "app1_ecs_execution" {
  role       = aws_iam_role.app1_ecs_execution.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "app1_ecs_execution" {
  role   = aws_iam_role.app1_ecs_execution.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ],
        Resource = [
          "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${data.aws_secretsmanager_secret.private_tier1.name}"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:ListSecrets"
        ],
        Resource = [
          "*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ],
        Resource = [data.aws_kms_key.private_tier1.arn]
      }
    ]
  })
}

# resource "aws_iam_role" "app1_ecs_execution" {
#   name               = "serverless-2-app1-ecs-execution-${local.suffix}"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = [
#             "ecs-tasks.amazonaws.com"
#           ]
#         }
#       }
#     ]
#   })
# }

# # resource "aws_iam_role_policy" "app1_ecs_execution" {
# #   role   = aws_iam_role.app1_ecs_execution.id
# #   policy = jsonencode({
# #     Version = "2012-10-17"
# #     Statement = [
# #       {
# #         Action = [
# #           "sts:AssumeRole"
# #         ]
# #         Effect = "Allow"
# #         Resource = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# #       },
# #       {
# #         Effect = "Allow"
# #         Action = [
# #           "secretsmanager:GetSecretValue"
# #         ]
# #         Resource = ["${data.aws_secretsmanager_secret.serverless_2.arn}"]
# #       }
# #     ]
# #   })
# # }

# resource "aws_iam_role_policy" "app1_ecs_execution" {
#   role   = aws_iam_role.app1_ecs_execution.id
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "secretsmanager:GetSecretValue"
#         ],
#         Resource = ["${data.aws_secretsmanager_secret.serverless_2.arn}"]
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "app1_ecs_execution" {
#   role       = aws_iam_role.app1_ecs_execution.id
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }

# resource "aws_iam_policy" "secrets_manager_read_policy" {
#   name        = "${var.name}-ecs-fargate-secrets-manager-access"
#   description = "IAM policy for ECS Fargate to access Secrets Manager secrets"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "secretsmanager:GetSecretValue"
#         ]
#         Resource = [local.infra_output["secret_arn"]]
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "attach_secrets_read_policy" {
#   role       = aws_iam_role.ecs_task_execution_role.name
#   policy_arn = aws_iam_policy.secrets_manager_read_policy.arn
# }


# resource "aws_iam_role_policy" "app1_ecs_execution" {
#   role = aws_iam_role.app1_ecs_execution.id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "secretsmanager:GetSecretValue"
#         ],
#         Resource = aws_sqs_queue.example.arn
#       }
#     ]
#   })
# }
