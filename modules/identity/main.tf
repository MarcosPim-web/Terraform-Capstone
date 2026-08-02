resource "aws_iam_role" "data_processing" {
  name = "${var.environment}-data-processing-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = [
            "lambda.amazonaws.com",
            "kinesisanalytics.amazonaws.com"
          ]
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_policy" "data_processing_s3" {
  name        = "${var.environment}-data-processing-s3-policy"
  description = "Permite acceso limitado al prefijo configurado en S3"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = "arn:aws:s3:::${var.bucket_name}"

        Condition = {
          StringLike = {
            "s3:prefix" = [
              "${var.bucket_prefix}*"
            ]
          }
        }
      },
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]

        Resource = "arn:aws:s3:::${var.bucket_name}/${var.bucket_prefix}*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "data_processing_s3" {
  role       = aws_iam_role.data_processing.name
  policy_arn = aws_iam_policy.data_processing_s3.arn
}

resource "aws_iam_role" "audit_read_only" {
  name = "${var.environment}-audit-read-only-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_policy" "audit_read_only" {
  name        = "${var.environment}-audit-read-only-policy"
  description = "Permite consultar recursos para tareas de auditoría"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeRouteTables",
          "ec2:DescribeVpcEndpoints",
          "s3:GetBucketLocation",
          "s3:GetBucketPolicy",
          "s3:ListBucket",
          "iam:GetRole",
          "iam:ListAttachedRolePolicies"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "audit_read_only" {
  role       = aws_iam_role.audit_read_only.name
  policy_arn = aws_iam_policy.audit_read_only.arn
}