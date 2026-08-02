locals {
  resource_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket" "data_lake_raw" {
  bucket        = "${local.resource_prefix}-raw"
  force_destroy = true

  tags = local.common_tags
}

# Los recursos de la plataforma de datos se agregarán aquí.
# Ejemplos futuros:
# - AWS Kinesis Data Streams
# - Amazon Managed Service for Apache Flink
# - Amazon S3