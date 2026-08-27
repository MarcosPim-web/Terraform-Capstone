variable "region" {
  description = "Región de AWS para los recursos del backend"
  type        = string
}

variable "state_bucket_name" {
  description = "Nombre del bucket S3 para almacenar el estado remoto"
  type        = string
}

variable "lock_table_name" {
  description = "Nombre de la tabla DynamoDB para el state locking"
  type        = string
}