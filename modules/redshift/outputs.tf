output "namespace_name" {
  description = "Nombre del namespace de Redshift Serverless"
  value       = aws_redshiftserverless_namespace.main.namespace_name
}

output "workgroup_name" {
  description = "Nombre del workgroup de Redshift Serverless"
  value       = aws_redshiftserverless_workgroup.main.workgroup_name
}

output "workgroup_arn" {
  description = "ARN del workgroup de Redshift Serverless"
  value       = aws_redshiftserverless_workgroup.main.arn
}

output "redshift_role_arn" {
  description = "ARN del rol IAM utilizado por Redshift"
  value       = aws_iam_role.redshift.arn
}

output "kinesis_vpc_endpoint_id" {
  description = "ID del Interface VPC Endpoint de Kinesis"
  value       = aws_vpc_endpoint.kinesis.id
}