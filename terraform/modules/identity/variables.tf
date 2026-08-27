variable "environment" {
  description = "Entorno en el que se desplegarán los roles IAM"
  type        = string
}

variable "bucket_name" {
  description = "Nombre del bucket S3 utilizado por el rol de procesamiento"
  type        = string
}

variable "bucket_prefix" {
  description = "Prefijo del bucket al que puede acceder el rol de procesamiento"
  type        = string
}