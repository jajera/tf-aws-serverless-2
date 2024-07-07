
resource "aws_iam_role" "imagebuilder" {
  name = "serverless-2-imagebuilder-${local.suffix}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "imagebuilder" {
  role = aws_iam_role.imagebuilder.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:DescribeRepositories",
        ],
        Resource = "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/*",
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ],
        Resource = [
          "${aws_ecr_repository.app1.arn}",
          "${aws_ecr_repository.app1.arn}/*",
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
        ],
        Resource = "*",
      },
      {
        Effect   = "Allow",
        Action   = [
          "s3:ListAllMyBuckets",
          "s3:ListBucket"
        ],
        Resource = "arn:aws:s3:::*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = "${aws_s3_bucket.app1.arn}/*",
      }
    ],
  })
}

resource "aws_iam_instance_profile" "imagebuilder" {
  name = "serverless-2-imagebuilder-${local.suffix}"
  role = aws_iam_role.imagebuilder.name
}

# resource "aws_iam_role" "ecs_assume" {
#   name = "ecs-assume-${local.suffix}"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "ec2.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole",
#       "Sid": "EC2AssumeRole"
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_policy" "ecs_assume" {
#   name        = "ecs-assume-${local.suffix}"
#   description = "Policy for ECS and ECR"

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": [
#         "ecs:DescribeContainerInstances",
#         "ecs:DeregisterContainerInstance",
#         "ecs:ListClusters",
#         "ecs:ListContainerInstances",
#         "ecs:ListServices",
#         "ecs:ListTagsForResource",
#         "ecs:Poll",
#         "ecs:RegisterContainerInstance",
#         "ecs:StartTelemetrySession",
#         "ecs:Submit*",
#         "ecs:UpdateContainerInstancesState"
#       ],
#       "Resource": "arn:aws:ecs:*"
#     },
#     {
#       "Effect": "Allow",
#       "Action": [
#         "ecr:BatchCheckLayerAvailability",
#         "ecr:BatchGetImage",
#         "ecs:DiscoverPollEndpoint",
#         "ecr:GetAuthorizationToken",
#         "ecr:GetDownloadUrlForLayer",
#         "logs:CreateLogGroup",
#         "logs:CreateLogStream",
#         "logs:DescribeLogStreams",
#         "logs:PutLogEvents"
#       ],
#       "Resource": "*"
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_role_policy_attachment" "ecs_assume" {
#   policy_arn = aws_iam_policy.ecs_assume.arn
#   role       = aws_iam_role.ecs_assume.name
# }

# resource "aws_iam_instance_profile" "ecs_assume" {
#   name = "ecs-assume-${local.suffix}"
#   role = aws_iam_role.ecs_assume.name
# }

# data "aws_iam_policy_document" "ecs_task_assume" {
#   version = "2012-10-17"
#   statement {
#     effect = "Allow"
#     principals {
#       type        = "Service"
#       identifiers = ["ecs-tasks.amazonaws.com"]
#     }
#     actions = [
#       "sts:AssumeRole"
#     ]
#   }
# }

# resource "aws_iam_role" "cwagent_task" {
#   name               = "CWAgentECSTaskRole"
#   assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
# }

# resource "aws_iam_role_policy_attachment" "cwagent_task_attachment" {
#   policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
#   role       = aws_iam_role.cwagent_task.name
# }

# resource "aws_iam_role" "cwagent_execution" {
#   name               = "CWAgentECSExecutionRole"
#   assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
# }

# resource "aws_iam_role_policy_attachment" "cwagent_ssm_read_policy" {
#   role       = aws_iam_role.cwagent_execution.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
# }

# resource "aws_iam_role_policy_attachment" "cwagent_cw_server_policy" {
#   role       = aws_iam_role.cwagent_execution.name
#   policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
# }

# resource "aws_iam_role_policy_attachment" "cwagent_ecs_task_exec_policy" {
#   role       = aws_iam_role.cwagent_execution.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }
