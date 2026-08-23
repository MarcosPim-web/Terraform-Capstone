output "bucket_name" {
  value       = aws_s3_bucket.lakehouse.bucket
  description = "Nombre del bucket S3 utilizado como Lakehouse"
}

output "bucket_arn" {
  value       = aws_s3_bucket.lakehouse.arn
  description = "ARN del bucket S3 utilizado como Lakehouse"
}

output "glue_database_name" {
  value       = aws_glue_catalog_database.lakehouse_db.name
  description = "Nombre de la base de datos creada en AWS Glue"
}

output "warehouse_path" {
  value       = "s3://${aws_s3_bucket.lakehouse.bucket}/warehouse/"
  description = "Ruta S3 utilizada como warehouse de Apache Iceberg"
}