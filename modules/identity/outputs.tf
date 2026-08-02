output "data_processing_role_arn" {
  description = "ARN del rol de procesamiento de datos"
  value       = aws_iam_role.data_processing.arn
}

output "audit_read_only_role_arn" {
  description = "ARN del rol de auditoría de solo lectura"
  value       = aws_iam_role.audit_read_only.arn
}