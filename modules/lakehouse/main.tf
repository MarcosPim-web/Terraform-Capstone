data "aws_caller_identity" "current" {}

# ------------------------------------------------------------------------------
# 1. BUCKET S3 DEL LAKEHOUSE
# ------------------------------------------------------------------------------

resource "aws_s3_bucket" "lakehouse" {
  bucket = "${var.project_name}-${var.environment}-lakehouse-${data.aws_caller_identity.current.account_id}"

  force_destroy = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-lakehouse"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Layer       = "Lakehouse"
  }
}

# ------------------------------------------------------------------------------
# 2. VERSIONADO
#    Recomendado para proteger metadatos y archivos administrados por Iceberg.
# ------------------------------------------------------------------------------

resource "aws_s3_bucket_versioning" "lakehouse" {
  bucket = aws_s3_bucket.lakehouse.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ------------------------------------------------------------------------------
# 3. CIFRADO EN REPOSO
# ------------------------------------------------------------------------------

resource "aws_s3_bucket_server_side_encryption_configuration" "lakehouse" {
  bucket = aws_s3_bucket.lakehouse.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ------------------------------------------------------------------------------
# 4. BLOQUEO DE ACCESO PUBLICO
# ------------------------------------------------------------------------------

resource "aws_s3_bucket_public_access_block" "lakehouse" {
  bucket = aws_s3_bucket.lakehouse.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ------------------------------------------------------------------------------
# 5. AWS GLUE DATA CATALOG
# ------------------------------------------------------------------------------

resource "aws_glue_catalog_database" "lakehouse_db" {
  name = var.glue_database_name

  description = "Catalogo Glue para tablas Apache Iceberg del pipeline DataOps"
}