resource "aws_kms_key" "private" {
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "private" {
  name          = "alias/serverless-2-private-${local.suffix}"
  target_key_id = aws_kms_key.private.id
}

resource "aws_kms_key_policy" "private" {
  key_id = aws_kms_key.private.id
  policy = jsonencode({
    Statement = [
      {
        Action = "kms:*"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Resource = "*"
      },
      {
        Effect : "Allow",
        Principal : {
          Service : "logs.${data.aws_region.current.name}.amazonaws.com"
        },
        Action : [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ],
        Resource : "*",
        Condition : {
          ArnEquals : {
            "kms:EncryptionContext:aws:logs:arn" : [
              "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/ecs-${local.suffix}/ecs/cluster/private",
              "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/ecs-${local.suffix}/ecs/service/app1"
            ]
          }
        }
      }
    ]
    Version = "2012-10-17"
  })
}
