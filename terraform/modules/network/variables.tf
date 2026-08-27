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

variable "private_subnet_cidrs" {
  description = "Rangos CIDR utilizados por las subredes privadas"
  type        = list(string)

  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]

  validation {
    condition     = length(var.private_subnet_cidrs) == 3
    error_message = "private_subnet_cidrs debe contener exactamente tres rangos CIDR."
  }
}
