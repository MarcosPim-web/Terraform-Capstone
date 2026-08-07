variable "environment" {
  description = "Entorno de despliegue"
  type        = string
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "shard_count" {
  description = "Cantidad de shards del Kinesis Data Stream"
  type        = number
  default     = 2
}

variable "raw_bucket_arn" {
  description = "ARN del bucket S3 de la capa Raw/Bronze"
  type        = string
}

variable "raw_bucket_name" {
  description = "Nombre del bucket S3 de la capa Raw/Bronze"
  type        = string
}