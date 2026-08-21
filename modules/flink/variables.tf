variable "project_name" {
  description = "Nombre base del proyecto"
  type        = string
}

variable "environment" {
  description = "Ambiente de despliegue"
  type        = string
}

variable "region" {
  description = "Region de AWS"
  type        = string
}

variable "kinesis_stream_arn" {
  description = "ARN del Kinesis Data Stream consumido por Flink"
  type        = string
}

variable "jar_path" {
  description = "Ruta local al JAR compilado de la aplicacion Flink"
  type        = string
}