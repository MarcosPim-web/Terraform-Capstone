data "aws_region" "current" {}

resource "aws_kinesis_stream" "main" {
  name             = "${var.project_name}-${var.environment}-stream"
  shard_count      = var.shard_count
  retention_period = 24

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }

  encryption_type = "KMS"
  kms_key_id      = "alias/aws/kinesis"

  tags = {
    Name        = "${var.project_name}-${var.environment}-stream"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role" "firehose" {
  name = "${var.project_name}-${var.environment}-firehose-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "firehose.amazonaws.com"
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

resource "aws_iam_policy" "firehose" {
  name        = "${var.project_name}-${var.environment}-firehose-policy"
  description = "Permisos para que Firehose lea de Kinesis, escriba en S3 y publique logs"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "kinesis:DescribeStream",
          "kinesis:DescribeStreamSummary",
          "kinesis:GetRecords",
          "kinesis:GetShardIterator",
          "kinesis:ListShards"
        ]

        Resource = aws_kinesis_stream.main.arn
      },
      {
        Effect = "Allow"

        Action = [
          "kms:Decrypt"
        ]

        Resource = "*"

        Condition = {
          StringEquals = {
            "kms:ViaService" = "kinesis.${data.aws_region.current.region}.amazonaws.com"
          }
        }
      },
      {
        Effect = "Allow"

        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ]

        Resource = [
          var.raw_bucket_arn,
          "${var.raw_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"

        Action = [
          "logs:PutLogEvents"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "firehose" {
  role       = aws_iam_role.firehose.name
  policy_arn = aws_iam_policy.firehose.arn
}

resource "aws_cloudwatch_log_group" "firehose" {
  name              = "/aws/kinesisfirehose/${var.project_name}-${var.environment}"
  retention_in_days = 7

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_log_stream" "firehose" {
  name           = "s3-delivery"
  log_group_name = aws_cloudwatch_log_group.firehose.name
}

resource "aws_kinesis_firehose_delivery_stream" "main" {
  name        = "${var.project_name}-${var.environment}-firehose"
  destination = "extended_s3"

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.main.arn
    role_arn           = aws_iam_role.firehose.arn
  }

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose.arn
    bucket_arn = var.raw_bucket_arn

    prefix              = "ingesta/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
    error_output_prefix = "errors/!{firehose:error-output-type}/"

    buffering_size     = 5
    buffering_interval = 60
    compression_format = "UNCOMPRESSED"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.firehose.name
      log_stream_name = aws_cloudwatch_log_stream.firehose.name
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.firehose
  ]

  tags = {
    Name        = "${var.project_name}-${var.environment}-firehose"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_metric_alarm" "write_throughput_exceeded" {
  alarm_name          = "${var.project_name}-${var.environment}-kinesis-write-throughput-exceeded"
  alarm_description   = "Detecta si los productores superan la capacidad de escritura del stream"
  namespace           = "AWS/Kinesis"
  metric_name         = "WriteProvisionedThroughputExceeded"
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 1
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    StreamName = aws_kinesis_stream.main.name
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_metric_alarm" "read_throughput_exceeded" {
  alarm_name          = "${var.project_name}-${var.environment}-kinesis-read-throughput-exceeded"
  alarm_description   = "Detecta si los consumidores superan la capacidad de lectura del stream"
  namespace           = "AWS/Kinesis"
  metric_name         = "ReadProvisionedThroughputExceeded"
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 1
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    StreamName = aws_kinesis_stream.main.name
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}