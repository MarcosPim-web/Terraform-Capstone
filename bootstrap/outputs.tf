output "state_bucket_name" {
  description = "Nombre del bucket S3 que almacena el estado remoto"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "lock_table_name" {
  description = "Nombre de la tabla DynamoDB para el state locking"
  value       = aws_dynamodb_table.terraform_lock.name
}