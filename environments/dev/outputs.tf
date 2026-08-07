output "vpc_id" {
  description = "ID de la VPC del entorno dev"
  value       = module.network.vpc_id
}

output "private_subnet_ids" {
  description = "IDs de las subredes privadas"
  value       = module.network.private_subnet_ids
}

output "data_processing_role_arn" {
  description = "ARN del rol de procesamiento de datos"
  value       = module.identity.data_processing_role_arn
}

output "audit_read_only_role_arn" {
  description = "ARN del rol de auditoría de solo lectura"
  value       = module.identity.audit_read_only_role_arn
}

output "raw_bucket_name" {
  description = "Nombre del bucket S3 de la capa Raw/Bronze"
  value       = aws_s3_bucket.raw.bucket
}

output "kinesis_stream_name" {
  description = "Nombre del Kinesis Data Stream"
  value       = module.kinesis.kinesis_stream_name
}

output "kinesis_stream_arn" {
  description = "ARN del Kinesis Data Stream"
  value       = module.kinesis.kinesis_stream_arn
}

output "firehose_delivery_stream_name" {
  description = "Nombre del Firehose Delivery Stream"
  value       = module.kinesis.firehose_delivery_stream_name
}

output "firehose_role_arn" {
  description = "ARN del rol utilizado por Firehose"
  value       = module.kinesis.firehose_role_arn
}