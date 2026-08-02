variable "environment" {
  description = "Entorno en el que se desplegará la red"
  type        = string
}

variable "region" {
  description = "Región de AWS donde se crearán los recursos"
  type        = string
}

variable "vpc_cidr" {
  description = "Rango CIDR de la VPC"
  type        = string
}