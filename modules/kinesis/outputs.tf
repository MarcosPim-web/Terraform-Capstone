output "kinesis_stream_name" {
  description = "Nombre del Kinesis Data Stream"
  value       = aws_kinesis_stream.main.name
}

output "kinesis_stream_arn" {
  description = "ARN del Kinesis Data Stream"
  value       = aws_kinesis_stream.main.arn
}

output "firehose_delivery_stream_name" {
  description = "Nombre del Firehose Delivery Stream"
  value       = aws_kinesis_firehose_delivery_stream.main.name
}

output "firehose_role_arn" {
  description = "ARN del rol IAM utilizado por Firehose"
  value       = aws_iam_role.firehose.arn
}