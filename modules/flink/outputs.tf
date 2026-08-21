output "application_name" {
  description = "Nombre de la aplicacion Managed Service for Apache Flink"
  value       = aws_kinesisanalyticsv2_application.flink.name
}

output "application_arn" {
  description = "ARN de la aplicacion Managed Service for Apache Flink"
  value       = aws_kinesisanalyticsv2_application.flink.arn
}

output "artifact_bucket_name" {
  description = "Bucket S3 que almacena el JAR de Flink"
  value       = aws_s3_bucket.flink_artifacts.bucket
}

output "cloudwatch_log_group_name" {
  description = "Log Group de CloudWatch utilizado por Flink"
  value       = aws_cloudwatch_log_group.flink.name
}

output "flink_execution_role_arn" {
  description = "ARN del rol IAM utilizado por Managed Flink"
  value       = aws_iam_role.flink.arn
}