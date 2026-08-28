# Validación End-to-End

## Fecha
27 de agosto de 2026

## Arquitectura validada

La prueba E2E validó los dos caminos que consumen el mismo stream de Amazon Kinesis:

- Hot path: Producer -> Kinesis -> Redshift Serverless
- Historical path: Producer -> Kinesis -> Flink -> Apache Iceberg -> S3 / Glue

## Resultados

### Infraestructura
- Terraform apply: 48 recursos creados, 0 modificados, 0 destruidos.
- Kinesis: ACTIVE.
- Redshift Serverless: AVAILABLE.
- Flink: RUNNING durante la prueba.

### Camino hot
Se enviaron 100 eventos correspondientes a 5 sensores.

Redshift obtuvo:
- Eventos: 100
- Sensores: 5

### Camino histórico
Flink procesó los mismos eventos mediante Event Time, Watermarks y ventanas de un minuto.

Iceberg produjo:
- Ventanas: 15
- Eventos agregados: 100
- Sensores: 5

Se verificaron archivos Parquet, metadata, manifests y snapshots Iceberg en S3, y la tabla `lakehouse_db.sensor_metrics` en AWS Glue.

### Consistencia
Comparación Redshift vs Iceberg:

- Ventanas comparadas: 15
- Eventos Redshift: 100
- Eventos Iceberg: 100
- Diferencias de conteo: 0
- Diferencias en promedios: únicamente precisión de punto flotante.

### Observabilidad
- Kinesis IteratorAgeMilliseconds: 0
- Flink failed checkpoints: 0
- Duración observada de checkpoints: aproximadamente 190-363 ms

## Conclusión

La arquitectura actual fue validada satisfactoriamente de extremo a extremo.

Ambos caminos procesaron consistentemente el lote original de 100 eventos y produjeron resultados equivalentes.

## Limpieza

Después de la prueba:

- Flink fue detenido correctamente.
- Terraform destroy eliminó los 48 recursos.
- El repositorio quedó limpio antes de documentar los resultados.
