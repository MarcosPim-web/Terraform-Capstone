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