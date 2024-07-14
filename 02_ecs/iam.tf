
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
