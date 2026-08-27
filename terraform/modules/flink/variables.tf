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

variable "lakehouse_bucket_name" {
  type        = string
  description = "Nombre del bucket S3 utilizado por Apache Iceberg"
}

variable "lakehouse_bucket_arn" {
  type        = string
  description = "ARN del bucket S3 utilizado por Apache Iceberg"
}

variable "glue_database_name" {
  type        = string
  description = "Base de datos de AWS Glue utilizada como catalogo Iceberg"
}

variable "iceberg_warehouse_path" {
  type        = string
  description = "Ruta S3 del warehouse de Apache Iceberg"
}