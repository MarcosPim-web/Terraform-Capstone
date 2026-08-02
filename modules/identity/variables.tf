variable "environment" {
  description = "Entorno en el que se desplegarán los roles IAM"
  type        = string
}

variable "bucket_name" {
  description = "Nombre del bucket S3 al que accederá el rol de procesamiento"
  type        = string
}

variable "bucket_prefix" {
  description = "Prefijo específico dentro del bucket S3"
  type        = string
}