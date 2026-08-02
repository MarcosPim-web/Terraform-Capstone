variable "region" {
  description = "Región de AWS donde se crearán los recursos"
  type        = string
}

variable "project_name" {
  description = "Nombre del proyecto de plataforma de datos"
  type        = string
}

variable "environment" {
  description = "Entorno en el que se desplegará la infraestructura"
  type        = string
}

variable "vpc_cidr" {
  description = "Rango CIDR de la VPC"
  type        = string
}

variable "bucket_name" {
  description = "Nombre del bucket S3 al que accederá el rol de procesamiento"
  type        = string
}

variable "bucket_prefix" {
  description = "Prefijo permitido dentro del bucket S3"
  type        = string
}