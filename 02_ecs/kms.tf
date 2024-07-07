resource "aws_kms_key" "private_tier1" {
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "private_tier1" {
  name          = "alias/serverless-2-${local.suffix}"
  target_key_id = aws_kms_key.private_tier1.id
}

resource "aws_kms_key_policy" "private_tier1" {
  key_id = aws_kms_key.private_tier1.id
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
              "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/serverless-2/ecs/private-tier1/logs"
            ]
          }
        }
      }
    ]
    Version = "2012-10-17"
  })
}
