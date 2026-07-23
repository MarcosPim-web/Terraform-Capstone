locals {
  resource_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Los recursos de la plataforma de datos se agregarán aquí.
# Ejemplos futuros:
# - AWS Kinesis Data Streams
# - Amazon Managed Service for Apache Flink
# - Amazon S3