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
  description = "Nombre del bucket S3 utilizado para almacenar los datos de la capa Raw/Bronze"
  type        = string
}

variable "bucket_prefix" {
  description = "Prefijo del bucket al que puede acceder el rol de procesamiento"
  type        = string
}