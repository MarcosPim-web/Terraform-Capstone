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