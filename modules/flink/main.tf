data "aws_caller_identity" "current" {}

# ------------------------------------------------------------------------------
# 1. BUCKET S3 PARA EL ARTEFACTO DE FLINK
# ------------------------------------------------------------------------------

resource "aws_s3_bucket" "flink_artifacts" {
  bucket        = "${var.project_name}-${var.environment}-flink-artifacts-${data.aws_caller_identity.current.account_id}"
  force_destroy = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-flink-artifacts"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "flink_artifacts" {
  bucket = aws_s3_bucket.flink_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ------------------------------------------------------------------------------
# 2. SUBIDA DEL JAR COMPILADO A S3
# ------------------------------------------------------------------------------

resource "aws_s3_object" "flink_jar" {
  bucket = aws_s3_bucket.flink_artifacts.id
  key    = "flink/realtime-flink-processing-${substr(filemd5(var.jar_path), 0, 8)}.jar"
  source = var.jar_path

  # Hace que Terraform detecte cambios en el JAR.
  # source_hash es preferible para archivos grandes.
  source_hash = filemd5(var.jar_path)

  content_type = "application/java-archive"
}

# ------------------------------------------------------------------------------
# 3. CLOUDWATCH LOGS
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "flink" {
  name              = "/aws/managed-flink/${var.project_name}-${var.environment}"
  retention_in_days = 7

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_log_stream" "flink" {
  name           = "application"
  log_group_name = aws_cloudwatch_log_group.flink.name
}

# ------------------------------------------------------------------------------
# 4. IAM ROLE DE EJECUCIÓN PARA MANAGED FLINK
# ------------------------------------------------------------------------------

resource "aws_iam_role" "flink" {
  name = "${var.project_name}-${var.environment}-flink-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "kinesisanalytics.amazonaws.com"
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

# ------------------------------------------------------------------------------
# 5. IAM POLICY
#    - Leer el JAR desde S3
#    - Leer eventos desde Kinesis
#    - Escribir logs en CloudWatch
# ------------------------------------------------------------------------------

resource "aws_iam_policy" "flink" {
  name        = "${var.project_name}-${var.environment}-flink-policy"
  description = "Permisos minimos para Managed Flink"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ReadFlinkArtifact"
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]

        Resource = aws_s3_object.flink_jar.arn
      },
      {
        Sid    = "ReadKinesisStream"
        Effect = "Allow"

        Action = [
          "kinesis:DescribeStream",
          "kinesis:DescribeStreamSummary",
          "kinesis:GetRecords",
          "kinesis:GetShardIterator",
          "kinesis:ListShards"
        ]

        Resource = var.kinesis_stream_arn
      },
      {
        Sid    = "DescribeCloudWatchLogs"
        Effect = "Allow"

        Action = [
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]

        Resource = "*"
      },
      {
        Sid    = "WriteCloudWatchLogs"
        Effect = "Allow"

        Action = [
          "logs:PutLogEvents"
        ]

        Resource = aws_cloudwatch_log_stream.flink.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "flink" {
  role       = aws_iam_role.flink.name
  policy_arn = aws_iam_policy.flink.arn
}

# ------------------------------------------------------------------------------
# 6. MANAGED SERVICE FOR APACHE FLINK
# ------------------------------------------------------------------------------

resource "aws_kinesisanalyticsv2_application" "flink" {
  name                   = "${var.project_name}-${var.environment}-flink"
  description            = "Procesamiento en tiempo real de sensores urbanos"
  runtime_environment    = "FLINK-1_20"
  service_execution_role = aws_iam_role.flink.arn

  # La dejamos detenida al crearla para evitar consumo accidental.
  # Más adelante la arrancamos cuando hagamos la prueba end-to-end.
  start_application = false

  application_configuration {

    # --------------------------------------------------------------------------
    # Código de la aplicación almacenado en S3
    # --------------------------------------------------------------------------

    application_code_configuration {
      code_content {
        s3_content_location {
          bucket_arn = aws_s3_bucket.flink_artifacts.arn
          file_key   = aws_s3_object.flink_jar.key
        }
      }

      code_content_type = "ZIPFILE"
    }

    # --------------------------------------------------------------------------
    # Propiedades que lee SensorStreamingJob.java
    # --------------------------------------------------------------------------

    environment_properties {
      property_group {
        property_group_id = "InputStream"

        property_map = {
          "stream.arn" = var.kinesis_stream_arn
        }
      }
    }

    # --------------------------------------------------------------------------
    # Configuración de Apache Flink
    # --------------------------------------------------------------------------

    flink_application_configuration {

      checkpoint_configuration {
        configuration_type            = "CUSTOM"
        checkpointing_enabled         = true
        checkpoint_interval           = 60000
        min_pause_between_checkpoints = 5000
      }

      monitoring_configuration {
        configuration_type = "CUSTOM"
        log_level          = "INFO"
        metrics_level      = "APPLICATION"
      }

      parallelism_configuration {
        configuration_type   = "CUSTOM"
        auto_scaling_enabled = false
        parallelism          = 1
        parallelism_per_kpu  = 1
      }
    }
  }

  cloudwatch_logging_options {
    log_stream_arn = aws_cloudwatch_log_stream.flink.arn
  }

  depends_on = [
    aws_iam_role_policy_attachment.flink,
    aws_s3_object.flink_jar
  ]

  tags = {
    Name        = "${var.project_name}-${var.environment}-flink"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
