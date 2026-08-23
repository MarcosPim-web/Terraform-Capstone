# Infraestructura de datos en AWS con Terraform

Este repositorio contiene el trabajo realizado para las preentregas 1, 2, 3, 4 y 5 del curso de Data Engineering.

El proyecto utiliza Terraform para crear una infraestructura modular en AWS. La primera parte se enfoca en la red, los permisos y el almacenamiento remoto del estado. La segunda agrega un flujo básico de ingesta de datos en tiempo real con Amazon Kinesis y Amazon Data Firehose. La tercera incorpora un entorno local de procesamiento distribuido utilizando Kubernetes, Apache Kafka y Apache Spark Structured Streaming. La cuarta incorpora procesamiento stateful en AWS mediante Amazon Kinesis Data Streams y AWS Managed Service for Apache Flink. La quinta extiende este procesamiento hacia una arquitectura Lakehouse utilizando Apache Iceberg, Amazon S3, AWS Glue Data Catalog y Amazon Athena.

## Recursos implementados

### Preentrega 1: infraestructura base

* Backend remoto de Terraform en Amazon S3.
* Tabla de DynamoDB para el bloqueo del estado.
* VPC dedicada para la plataforma de datos.
* Dos subredes privadas en diferentes zonas de disponibilidad.
* Tabla de rutas privada.
* Gateway Endpoint de S3.
* Rol IAM para servicios de procesamiento de datos.
* Política IAM con acceso limitado a un prefijo de S3.
* Rol IAM de auditoría con permisos de solo lectura.

### Preentrega 2: ingesta en tiempo real

* Amazon Kinesis Data Stream para recibir eventos.
* Amazon Data Firehose para entregar los datos en S3.
* Roles y políticas IAM necesarios para conectar los servicios.
* Alarmas de Amazon CloudWatch para monitorear el flujo.
* Script de PowerShell para enviar eventos de prueba.
* Evidencia de los archivos generados en la capa Raw/Bronze.

### Preentrega 3: procesamiento distribuido en tiempo real

* Namespace dedicado `urban-data` en Kubernetes.
* Apache Kafka desplegado mediante Deployment y Service.
* Configuración de Kafka mediante ConfigMap.
* Tópico `urban_sensors` con 3 particiones.
* Script productor en Python para generar eventos JSON de sensores urbanos.
* Apache Spark Structured Streaming desplegado en Kubernetes.
* Configuración de Spark mediante ConfigMap.
* Job de Spark montado automáticamente dentro del contenedor.
* Procesamiento de eventos mediante ventanas de 1 minuto.
* Cálculo del promedio de temperatura y calidad del aire por `sensor_id`.

### Preentrega 4: procesamiento stateful con Apache Flink

* AWS Managed Service for Apache Flink con runtime Apache Flink 1.20.
* Aplicación Java empaquetada mediante Maven.
* Consumo de eventos desde Amazon Kinesis Data Streams.
* Deserialización de eventos JSON de sensores urbanos.
* Procesamiento utilizando Event Time.
* Watermarks con una tolerancia de 10 segundos para eventos fuera de orden.
* Detección de fuentes inactivas mediante idleness de 30 segundos.
* Agrupación de eventos por `sensor_id`.
* Ventanas Tumbling Event Time de 1 minuto.
* Cálculo de cantidad de eventos y promedios de temperatura, humedad y calidad del aire.
* Checkpoints automáticos cada 60 segundos.
* Persistencia del estado mediante checkpoints administrados por Managed Flink.
* Bucket S3 para almacenar el artefacto JAR de la aplicación.
* Logs y monitoreo mediante Amazon CloudWatch.
* Rol y política IAM específicos para la aplicación Flink.
* Script de PowerShell para generar eventos de sensores y enviarlos a Kinesis.

### Preentrega 5: Lakehouse con Apache Iceberg

* Bucket S3 dedicado al warehouse del Lakehouse.
* Versionado y cifrado habilitados en el bucket.
* Base de datos `lakehouse_db` en AWS Glue Data Catalog.
* Tabla Apache Iceberg `sensor_metrics`.
* Integración de AWS Managed Service for Apache Flink con Apache Iceberg.
* AWS Glue utilizado como catálogo de la tabla.
* Amazon S3 utilizado para almacenar datos y metadata de Iceberg.
* Escritura de resultados procesados mediante `IcebergSink`.
* Archivos de datos almacenados en formato Parquet.
* Metadata, manifests y snapshots administrados por Apache Iceberg.
* Particionamiento de la tabla por día utilizando `window_start`.
* Permisos IAM para que Flink pueda operar con S3 y AWS Glue.
* Commits de Iceberg coordinados con los checkpoints de Flink.
* Consulta de la tabla Iceberg desde Amazon Athena.
* Validación end-to-end del flujo Kinesis → Flink → Iceberg → Glue → Athena.

## Estructura del proyecto

```text
Terraform-Scaffold/
|-- .gitignore
|-- PLAN_OUTPUT.md
|-- README.md
|
|-- bootstrap/
|   |-- .terraform.lock.hcl
|   |-- main.tf
|   |-- outputs.tf
|   |-- provider.tf
|   `-- variables.tf
|
|-- environments/
|   `-- dev/
|       |-- .terraform.lock.hcl
|       |-- backend.tf
|       |-- main.tf
|       |-- outputs.tf
|       |-- provider.tf
|       `-- variables.tf
|
|-- modules/
|   |-- flink/
|   |   |-- main.tf
|   |   |-- outputs.tf
|   |   `-- variables.tf
|   |
|   |-- identity/
|   |   |-- main.tf
|   |   |-- outputs.tf
|   |   `-- variables.tf
|   |
|   |-- kinesis/
|   |   |-- main.tf
|   |   |-- outputs.tf
|   |   `-- variables.tf
|   |
|   |-- lakehouse/
|   |   |-- main.tf
|   |   |-- outputs.tf
|   |   `-- variables.tf
|   |
|   `-- network/
|       |-- main.tf
|       |-- outputs.tf
|       `-- variables.tf
|
|-- flink/
|   |-- pom.xml
|   `-- src/
|       `-- main/
|           `-- java/
|               `-- com/
|                   `-- dataops/
|                       `-- flink/
|                           `-- SensorStreamingJob.java
|
|-- k8s/
|   |-- kafka-configmap.yaml
|   |-- kafka-deployment.yaml
|   |-- kafka-service.yaml
|   |-- namespace.yaml
|   |-- spark-configmap.yaml
|   |-- spark-deployment.yaml
|   `-- spark-job-configmap.yaml
|
|-- producer/
|   `-- producer.py
|
|-- spark/
|   `-- streaming_job.py
|
|-- docs/
|   |-- evidencia-firehose-s3.png
|   |-- evidencia-kafka.png
|   |-- evidencia-kafka-producer.png
|   |-- evidencia-spark-streaming.png
|   |-- evidencia-kinesis-producer.png
|   |-- evidencia-flink-window-results.png
|   |-- evidencia-flink-checkpoints.png
|   |-- evidencia-flink-aws.png
|   |-- evidencia-kinesis-aws.png
|   |-- evidencia-flink-jar-s3.png
|   |-- evidencia-glue-iceberg.png
|   |-- evidencia-s3-iceberg.png
|   `-- evidencia-athena-iceberg.png
|
`-- scripts/
    |-- send_test_events.ps1
    `-- send_sensor_events.ps1
```

Los archivos `terraform.tfvars` se mantienen únicamente de forma local y están excluidos del control de versiones mediante `.gitignore`.

Los artefactos generados por Maven dentro de `flink/target/` también se mantienen fuera del repositorio.

## Organización

### `bootstrap`

Contiene los recursos necesarios para almacenar el estado de Terraform de manera remota:

* Bucket de S3 para el archivo de estado.
* Cifrado del bucket.
* Versionado del estado.
* Tabla de DynamoDB para evitar modificaciones simultáneas.

Esta configuración se ejecuta por separado porque el backend debe existir antes de desplegar el resto de la infraestructura.

### `environments/dev`

Es el punto de entrada del entorno de desarrollo.

Desde esta carpeta se configuran el provider, el backend remoto, las variables del entorno y las llamadas a los módulos de red, identidad, ingesta, procesamiento con Flink y almacenamiento Lakehouse.

### `modules/network`

Crea la infraestructura de red:

* VPC.
* Subredes privadas.
* Tabla de rutas.
* Asociaciones de las subredes.
* Gateway Endpoint para S3.

Las subredes no asignan direcciones IP públicas automáticamente.

### `modules/identity`

Crea los permisos principales del proyecto:

* Rol para servicios de procesamiento.
* Política de acceso limitado al bucket de datos.
* Rol de auditoría de solo lectura.

El acceso de procesamiento se restringe al prefijo configurado dentro del bucket.

### `modules/kinesis`

Crea los recursos de ingesta en tiempo real:

* Kinesis Data Stream.
* Data Firehose.
* Roles y políticas IAM utilizados por Firehose.
* Configuración de entrega hacia Amazon S3.
* Alarmas de CloudWatch.

Los datos entregados por Firehose se almacenan utilizando una estructura de carpetas basada en la fecha de procesamiento.

### `modules/flink`

Contiene la infraestructura necesaria para ejecutar el procesamiento en tiempo real mediante AWS Managed Service for Apache Flink.

El módulo crea:

* Bucket S3 para almacenar el artefacto JAR.
* Objeto S3 correspondiente a la aplicación compilada.
* Rol y política IAM para la ejecución de Flink.
* Grupo y stream de logs de CloudWatch.
* Aplicación de AWS Managed Service for Apache Flink.
* Configuración de checkpoints.
* Configuración de monitoreo.
* Configuración de paralelismo.

A partir de la quinta preentrega, el módulo también configura las propiedades necesarias para que la aplicación conozca la ubicación del warehouse de Apache Iceberg y la base de datos utilizada en AWS Glue.

El rol de ejecución de Flink posee además permisos para leer y escribir objetos dentro del bucket del Lakehouse y consultar, crear o actualizar las tablas necesarias en AWS Glue Data Catalog.

El nombre del objeto JAR almacenado en S3 incluye una parte del hash del archivo. De esta forma, cuando el código cambia, Terraform detecta un nuevo artefacto y actualiza la aplicación.

### `modules/lakehouse`

Contiene la infraestructura utilizada para la capa Lakehouse incorporada en la quinta preentrega.

El módulo crea:

* Bucket S3 dedicado al warehouse de Apache Iceberg.
* Versionado del bucket.
* Cifrado server-side mediante AES256.
* Bloqueo de acceso público.
* Base de datos `lakehouse_db` en AWS Glue Data Catalog.

La ruta del warehouse se construye dentro del bucket utilizando el prefijo:

```text
warehouse/
```

y se entrega como output para que pueda ser utilizada por la aplicación de Apache Flink.

### `k8s`

Contiene los manifiestos de Kubernetes utilizados en la tercera preentrega:

* Namespace `urban-data`.
* ConfigMap de Kafka.
* Deployment de Kafka.
* Service de Kafka.
* ConfigMap de Spark.
* ConfigMap con el job de Spark.
* Deployment de Spark Structured Streaming.

### `producer`

Contiene el script Python encargado de simular datos provenientes de sensores urbanos y enviarlos al tópico `urban_sensors` de Kafka.

### `spark`

Contiene el job de Spark Structured Streaming encargado de consumir los eventos desde Kafka y procesarlos en tiempo real.

### `flink`

Contiene la aplicación Java utilizada por AWS Managed Service for Apache Flink.

El archivo principal es:

```text
flink/src/main/java/com/dataops/flink/SensorStreamingJob.java
```

La aplicación consume eventos desde Kinesis, interpreta los mensajes JSON, utiliza Event Time, genera Watermarks y procesa los datos mediante ventanas de un minuto agrupadas por `sensor_id`.

A partir de la quinta preentrega, los resultados de estas ventanas también se convierten al esquema de la tabla Iceberg y se escriben mediante `IcebergSink`.

El proyecto Java utiliza Maven y su configuración se encuentra en:

```text
flink/pom.xml
```

### `scripts`

Contiene los scripts de PowerShell utilizados para generar eventos de prueba.

El archivo:

```text
scripts/send_test_events.ps1
```

se utilizó inicialmente para las pruebas de ingesta realizadas con Kinesis y Firehose.

En la quinta preentrega fue actualizado para generar eventos JSON con el esquema de sensores esperado por la aplicación Flink:

* `sensor_id`
* `temperature`
* `humidity`
* `air_quality_index`
* `timestamp`

El archivo:

```text
scripts/send_sensor_events.ps1
```

genera eventos JSON de sensores urbanos utilizados para probar el procesamiento mediante AWS Managed Service for Apache Flink.

## Requisitos

Para ejecutar el proyecto se necesita:

* Terraform.
* AWS CLI v2.
* Git.
* Una cuenta de AWS.
* Credenciales configuradas localmente mediante `aws configure`.
* Docker Desktop.
* Minikube.
* kubectl.
* Python.
* Java 17.
* Apache Maven.

Las credenciales de AWS no se almacenan dentro del repositorio.

## Despliegue del backend

Ingresar en la carpeta `bootstrap`:

```powershell
cd bootstrap
```

Inicializar Terraform:

```powershell
terraform init
```

Validar la configuración:

```powershell
terraform validate
```

Revisar los cambios:

```powershell
terraform plan
```

Crear los recursos:

```powershell
terraform apply
```

## Despliegue del entorno de desarrollo

Ingresar en la carpeta del entorno:

```powershell
cd environments\dev
```

Inicializar Terraform y conectar el backend remoto:

```powershell
terraform init
```

Validar la configuración:

```powershell
terraform validate
```

Revisar los cambios:

```powershell
terraform plan
```

Desplegar la infraestructura:

```powershell
terraform apply
```

## Prueba de ingesta

Para comprobar el funcionamiento del flujo se utilizó el script:

```powershell
.\scripts\send_test_events.ps1
```

El script envía 100 eventos de prueba al Kinesis Data Stream.

Los eventos son recibidos por Data Firehose y almacenados en el bucket S3 de la capa Raw/Bronze.

La ruta generada durante la prueba fue:

```text
s3://realtime-data-platform-dev-raw/ingesta/year=2026/month=08/day=06/
```

Los archivos pueden comprobarse mediante AWS CLI:

```powershell
aws s3 ls s3://realtime-data-platform-dev-raw/ingesta/ --recursive
```

Evidencia del resultado:

![Evidencia de archivos generados por Firehose](docs/evidencia-firehose-s3.png)

## Preentrega 3: plataforma de procesamiento distribuido

La tercera etapa agrega una plataforma local de procesamiento distribuido sobre Kubernetes.

El flujo implementado es:

```text
Productor Python
      |
      v
Apache Kafka
urban_sensors
3 particiones
      |
      v
Spark Structured Streaming
      |
      v
Ventana de 1 minuto
      |
      +-- Promedio de temperatura
      `-- Promedio de calidad del aire
              por sensor_id
```

### Arquitectura

```mermaid
flowchart LR
    Producer["Productor Python"]

    subgraph Kubernetes["Kubernetes - urban-data"]
        Kafka["Apache Kafka<br/>urban_sensors<br/>3 particiones"]
        Spark["Apache Spark<br/>Structured Streaming"]
    end

    Result["Window 1 minuto<br/>AVG temperature<br/>AVG air_quality_index"]

    Producer -->|JSON| Kafka
    Kafka --> Spark
    Spark --> Result
```

### Despliegue de Kubernetes

El entorno utiliza Minikube con Docker.

Iniciar el cluster:

```powershell
minikube start --driver=docker
```

Verificar:

```powershell
kubectl get nodes
```

Crear el namespace:

```powershell
kubectl apply -f k8s/namespace.yaml
```

### Despliegue de Kafka

Aplicar los manifiestos:

```powershell
kubectl apply -f k8s/kafka-configmap.yaml
kubectl apply -f k8s/kafka-deployment.yaml
kubectl apply -f k8s/kafka-service.yaml
```

Verificar el estado:

```powershell
kubectl get pods -n urban-data
```

Kafka debe aparecer en estado `Running`.

### Creación del tópico

Obtener el nombre del pod de Kafka:

```powershell
$KAFKA_POD = kubectl get pods -n urban-data -l app=kafka -o jsonpath="{.items[0].metadata.name}"
```

Crear el tópico `urban_sensors` con 3 particiones:

```powershell
kubectl exec -it $KAFKA_POD -n urban-data -- kafka-topics.sh --create --topic urban_sensors --bootstrap-server kafka-service:9092 --partitions 3 --replication-factor 1
```

Verificar:

```powershell
kubectl exec -it $KAFKA_POD -n urban-data -- kafka-topics.sh --describe --topic urban_sensors --bootstrap-server kafka-service:9092
```

La configuración utilizada es:

```text
Topic: urban_sensors
PartitionCount: 3
ReplicationFactor: 1
```

### Productor de eventos

El archivo:

```text
producer/producer.py
```

genera eventos JSON simulados cada 2 segundos con los siguientes campos:

* `sensor_id`
* `temperature`
* `humidity`
* `air_quality_index`
* `timestamp`

Ejemplo:

```json
{
  "sensor_id": "sensor_3",
  "temperature": 25.42,
  "humidity": 61.7,
  "air_quality_index": 84,
  "timestamp": "2026-08-14T13:16:25.123456"
}
```

El productor se ejecuta localmente y utiliza un port-forward para comunicarse con Kafka dentro de Kubernetes.

Mantener una terminal ejecutando:

```powershell
kubectl port-forward service/kafka-service 9094:9094 -n urban-data
```

En otra terminal:

```powershell
python producer/producer.py
```

El productor utiliza un intervalo de 2 segundos entre eventos para evitar una generación excesiva de mensajes durante las pruebas locales y permitir observar el flujo de datos de forma controlada.

Durante las pruebas se verificó correctamente la llegada de los eventos al tópico `urban_sensors`.

Los mensajes pueden comprobarse mediante:

```powershell
kubectl exec -it $KAFKA_POD -n urban-data -- kafka-console-consumer.sh --bootstrap-server kafka-service:9092 --topic urban_sensors --from-beginning --max-messages 10
```

### Despliegue de Spark

Aplicar los manifiestos correspondientes:

```powershell
kubectl apply -f k8s/spark-configmap.yaml
kubectl apply -f k8s/spark-job-configmap.yaml
kubectl apply -f k8s/spark-deployment.yaml
```

Verificar:

```powershell
kubectl get pods -n urban-data
```

Kafka y Spark deben aparecer en estado `Running`.

El Deployment de Spark monta automáticamente `streaming_job.py` desde el ConfigMap `spark-job-script` y ejecuta el job mediante `spark-submit`.

### Procesamiento en tiempo real

El archivo:

```text
spark/streaming_job.py
```

consume los eventos desde Kafka utilizando Spark Structured Streaming.

El job:

* Interpreta los mensajes JSON.
* Utiliza el campo `timestamp` como tiempo del evento.
* Aplica un watermark de 1 minuto.
* Utiliza ventanas de tiempo de 1 minuto.
* Agrupa los eventos por `sensor_id`.
* Calcula el promedio de `temperature`.
* Calcula el promedio de `air_quality_index`.

Los resultados pueden consultarse mediante:

```powershell
kubectl logs deployment/spark-streaming -n urban-data --tail=120
```

Durante la prueba se obtuvo una salida como:

```text
+------------------------------------------+---------+------------------+---------------------+
|window                                    |sensor_id|avg_temperature   |avg_air_quality_index|
+------------------------------------------+---------+------------------+---------------------+
|{2026-08-14 13:16:00, 2026-08-14 13:17:00}|sensor_2 |24.98107431807679 |85.28392279241794    |
|{2026-08-14 13:16:00, 2026-08-14 13:17:00}|sensor_1 |24.991138767890465|84.62329580811223    |
|{2026-08-14 13:16:00, 2026-08-14 13:17:00}|sensor_4 |25.03353926461307 |85.36511214363563    |
|{2026-08-14 13:16:00, 2026-08-14 13:17:00}|sensor_5 |24.992562948615664|84.68531388857241    |
|{2026-08-14 13:16:00, 2026-08-14 13:17:00}|sensor_3 |25.03867602127421 |85.04498132850514    |
+------------------------------------------+---------+------------------+---------------------+
```

Esto confirma la comunicación exitosa entre Kafka y Spark y el procesamiento de los eventos en tiempo real.

### Evidencias de la Preentrega 3

#### Kafka: tópico, particiones y comunicación

La siguiente evidencia muestra el tópico `urban_sensors` configurado con 3 particiones y una prueba de envío y recepción de un evento mediante Kafka.

![Evidencia de Kafka](docs/evidencia-kafka.png)

#### Productor Python

El productor genera eventos simulados de sensores urbanos con los campos `sensor_id`, `temperature`, `humidity`, `air_quality_index` y `timestamp`, y los envía hacia Kafka mediante el listener expuesto localmente.

![Evidencia del productor Python](docs/evidencia-kafka-producer.png)

#### Spark Structured Streaming

Spark consume los eventos provenientes de Kafka y procesa el flujo utilizando ventanas de 1 minuto, calculando el promedio de temperatura y del índice de calidad del aire para cada sensor.

![Evidencia de Spark Structured Streaming](docs/evidencia-spark-streaming.png)

## Preentrega 4: procesamiento en tiempo real con Apache Flink

La cuarta etapa del proyecto incorpora procesamiento stateful en AWS utilizando Amazon Kinesis Data Streams y AWS Managed Service for Apache Flink.

El flujo implementado es:

```text
Productor PowerShell
        |
        v
Amazon Kinesis Data Streams
        |
        v
AWS Managed Service
for Apache Flink 1.20
        |
        v
Deserialización JSON
        |
        v
Event Time + Watermarks
        |
        v
keyBy(sensor_id)
        |
        v
Tumbling Window de 1 minuto
        |
        +-- Cantidad de eventos
        +-- Promedio de temperatura
        +-- Promedio de humedad
        `-- Promedio de calidad del aire
        |
        v
Amazon CloudWatch Logs
```

### Arquitectura

```mermaid
flowchart LR
    Producer["Productor PowerShell<br/>Sensores urbanos"]
    Kinesis["Amazon Kinesis<br/>Data Stream"]
    Flink["AWS Managed Service<br/>for Apache Flink 1.20"]
    Window["Event Time<br/>Watermark 10 segundos<br/>Window 1 minuto"]
    Result["Conteo de eventos<br/>AVG temperatura<br/>AVG humedad<br/>AVG AQI"]
    CloudWatch["Amazon CloudWatch"]
    Checkpoint["Checkpoints<br/>cada 60 segundos"]
    State["Estado persistente<br/>administrado por Flink"]

    Producer -->|JSON| Kinesis
    Kinesis --> Flink
    Flink --> Window
    Window --> Result
    Result --> CloudWatch
    Flink --> Checkpoint
    Checkpoint --> State
```

### Infraestructura de Flink

La infraestructura necesaria para Managed Flink está declarada mediante Terraform dentro de:

```text
modules/flink/
```

El módulo crea la aplicación de procesamiento, el bucket utilizado para almacenar el artefacto JAR, el rol y la política IAM necesarios y la integración con CloudWatch Logs.

La aplicación utiliza:

```text
Runtime: FLINK-1_20
Parallelism: 1
Parallelism per KPU: 1
Auto Scaling: deshabilitado
```

El Data Stream de Kinesis utilizado como fuente se configura mediante una propiedad de ejecución denominada:

```text
InputStream
```

que contiene el ARN del stream.

### Aplicación Flink

La aplicación está implementada en Java:

```text
flink/src/main/java/com/dataops/flink/SensorStreamingJob.java
```

El job obtiene el ARN del Kinesis Data Stream desde las propiedades configuradas en AWS Managed Service for Apache Flink.

Los eventos utilizados contienen:

* `sensor_id`
* `temperature`
* `humidity`
* `air_quality_index`
* `timestamp`

Ejemplo:

```json
{
  "sensor_id": "sensor_3",
  "temperature": 25.42,
  "humidity": 61.70,
  "air_quality_index": 84,
  "timestamp": "2026-08-21T19:10:35.0000000Z"
}
```

### Event Time y Watermarks

El campo `timestamp` de cada mensaje se utiliza como tiempo del evento.

La aplicación utiliza un Watermark con una tolerancia máxima de 10 segundos para eventos que puedan llegar fuera de orden.

La estrategia utilizada es equivalente a:

```text
WatermarkStrategy.forBoundedOutOfOrderness(Duration.ofSeconds(10))
```

También se configura una detección de inactividad de 30 segundos para evitar que una fuente temporalmente inactiva impida el avance global del Watermark.

### Ventanas y procesamiento stateful

Después de deserializar los eventos, el flujo se agrupa utilizando:

```text
keyBy(sensor_id)
```

Posteriormente se aplican ventanas Tumbling Event Time de 1 minuto.

Dentro de cada ventana se calcula:

* Cantidad de eventos.
* Temperatura promedio.
* Humedad promedio.
* Índice promedio de calidad del aire.

El operador de ventanas mantiene estado administrado por Apache Flink durante el procesamiento.

Los resultados se registran utilizando el logger de la aplicación y pueden consultarse posteriormente mediante CloudWatch.

Durante las pruebas se obtuvo, por ejemplo:

```text
WINDOW_RESULT sensor=sensor_1 |
window_start=2026-08-21T19:10:00Z |
window_end=2026-08-21T19:11:00Z |
events=6 |
avg_temperature=23.37 |
avg_humidity=56.41 |
avg_aqi=126.83
```

También se observaron resultados correspondientes a múltiples sensores y varias ventanas consecutivas de un minuto.

### Checkpoints y tolerancia a fallos

La aplicación utiliza checkpoints automáticos para permitir la recuperación del estado ante fallos.

La configuración declarada mediante Terraform es:

```text
Checkpoint interval: 60000 ms
Minimum pause between checkpoints: 5000 ms
Checkpointing: enabled
```

Durante las pruebas se verificó la creación continua de checkpoints.

Entre los checkpoints observados se encontraron:

```text
Completed checkpoint 52
Completed checkpoint 53
Completed checkpoint 54
Completed checkpoint 55
Completed checkpoint 56
Completed checkpoint 57
Completed checkpoint 58
```

Los logs de Managed Flink también mostraron la escritura de metadata asociada a los checkpoints mediante el sistema de archivos S3 utilizado por el servicio.

### Compilación de la aplicación

La aplicación Java utiliza Maven.

Desde la raíz del repositorio puede compilarse mediante:

```powershell
mvn -f .\flink\pom.xml clean package
```

La compilación genera el artefacto:

```text
flink/target/realtime-flink-processing-1.0.0.jar
```

La carpeta:

```text
flink/target/
```

está excluida del control de versiones.

Durante el despliegue, Terraform toma este JAR local y lo almacena dentro del bucket de artefactos de Flink.

El nombre del objeto almacenado en S3 incluye una parte del hash del archivo.

Por ejemplo:

```text
flink/realtime-flink-processing-78e105f2.jar
```

Esto permite que Terraform detecte cambios en el código de la aplicación y actualice el artefacto utilizado por Managed Flink.

### Despliegue mediante Terraform

Desde:

```powershell
cd environments\dev
```

se puede ejecutar:

```powershell
terraform init
terraform validate
terraform plan
terraform apply
```

La aplicación Managed Flink se crea inicialmente detenida.

Para consultar su estado:

```powershell
aws kinesisanalyticsv2 describe-application --application-name realtime-data-platform-dev-flink --query "ApplicationDetail.ApplicationStatus" --output text --region us-east-1
```

Una aplicación desplegada pero detenida aparece como:

```text
READY
```

Para iniciarla:

```powershell
aws kinesisanalyticsv2 start-application --application-name realtime-data-platform-dev-flink --region us-east-1
```

Durante la ejecución, el estado esperado es:

```text
RUNNING
```

### Generación de eventos de prueba

El archivo:

```text
scripts/send_sensor_events.ps1
```

genera eventos JSON simulando sensores urbanos y los envía directamente al Kinesis Data Stream.

Para realizar una prueba prolongada se utilizó:

```powershell
.\scripts\send_sensor_events.ps1 -RecordCount 180 -DelayMilliseconds 500
```

Durante la prueba se generaron datos correspondientes a cinco sensores diferentes y se enviaron correctamente 180 eventos.

### Consulta de resultados en CloudWatch

Los resultados de las ventanas pueden consultarse utilizando:

```powershell
aws logs filter-log-events --log-group-name "/aws/managed-flink/realtime-data-platform-dev" --filter-pattern "WINDOW_RESULT" --region us-east-1 --query "events[].message" --output text --no-cli-pager
```

Los mensajes muestran el sensor procesado, la ventana temporal, la cantidad de eventos y los valores promedio obtenidos.

Los checkpoints también pueden consultarse mediante los logs de CloudWatch.

### Evidencias de la Preentrega 4

#### Productor hacia Kinesis

El productor PowerShell genera eventos JSON de sensores urbanos y los envía directamente hacia Amazon Kinesis Data Streams.

Durante la prueba se enviaron correctamente 180 eventos.

![Evidencia del productor hacia Kinesis](docs/evidencia-kinesis-producer.png)

#### Procesamiento de ventanas con Flink

Los logs de CloudWatch muestran los resultados generados por Flink para múltiples sensores y ventanas consecutivas de un minuto.

Cada resultado incluye la cantidad de eventos procesados y los promedios de temperatura, humedad y calidad del aire.

![Evidencia de ventanas de Flink](docs/evidencia-flink-window-results.png)

#### Checkpoints de Flink

Durante la ejecución se verificó que los checkpoints se completaran periódicamente.

La evidencia muestra múltiples checkpoints finalizados correctamente junto con su tamaño y duración.

![Evidencia de checkpoints de Flink](docs/evidencia-flink-checkpoints.png)

#### Aplicación AWS Managed Service for Apache Flink

La aplicación `realtime-data-platform-dev-flink` fue desplegada correctamente utilizando Apache Flink 1.20.

![Evidencia de Managed Flink](docs/evidencia-flink-aws.png)

#### Amazon Kinesis Data Stream

El stream `realtime-data-platform-dev-stream` fue desplegado correctamente en modo provisionado utilizando dos shards.

![Evidencia de Kinesis Data Streams](docs/evidencia-kinesis-aws.png)

#### Artefacto JAR en Amazon S3

El artefacto compilado de la aplicación fue almacenado correctamente en el bucket S3 destinado a Managed Flink.

![Evidencia del JAR de Flink en S3](docs/evidencia-flink-jar-s3.png)

## Preentrega 5: Lakehouse con Apache Iceberg

La quinta etapa del proyecto extiende el procesamiento en tiempo real desarrollado con Apache Flink incorporando una capa Lakehouse basada en Apache Iceberg.

Los resultados agregados de las ventanas dejan de utilizarse únicamente como salida de monitoreo y también se persisten como una tabla Iceberg almacenada en Amazon S3 y registrada dentro de AWS Glue Data Catalog.

El flujo implementado es:

```text
Amazon Kinesis Data Streams
        |
        v
AWS Managed Service
for Apache Flink 1.20
        |
        v
Event Time + Watermarks
        |
        v
Tumbling Window de 1 minuto
        |
        v
Agregaciones por sensor_id
        |
        v
Apache Iceberg Sink
        |
        +--------------------------+
        |                          |
        v                          v
Amazon S3                  AWS Glue Data Catalog
Parquet + Metadata         lakehouse_db
                           sensor_metrics
        |                          |
        +------------+-------------+
                     |
                     v
                Amazon Athena
```

### Arquitectura

```mermaid
flowchart LR
    Kinesis["Amazon Kinesis<br/>Data Streams"]
    Flink["AWS Managed Service<br/>for Apache Flink 1.20"]
    Window["Event Time + Watermarks<br/>Window 1 minuto"]
    Iceberg["Apache Iceberg<br/>IcebergSink"]
    S3["Amazon S3<br/>Parquet + Metadata"]
    Glue["AWS Glue Data Catalog<br/>lakehouse_db"]
    Athena["Amazon Athena"]

    Kinesis --> Flink
    Flink --> Window
    Window --> Iceberg
    Iceberg --> S3
    Iceberg --> Glue
    S3 --> Athena
    Glue --> Athena
```

### Infraestructura del Lakehouse

La infraestructura de esta etapa está declarada mediante Terraform dentro de:

```text
modules/lakehouse/
```

El módulo crea un bucket S3 dedicado al almacenamiento del warehouse de Apache Iceberg.

El bucket posee:

```text
Versioning: Enabled
Server-side encryption: AES256
Public access: Blocked
```

También se crea mediante Terraform la base de datos:

```text
lakehouse_db
```

dentro de AWS Glue Data Catalog.

El warehouse utilizado por Apache Iceberg se encuentra dentro de:

```text
s3://realtime-data-platform-dev-lakehouse-<account-id>/warehouse/
```

La ubicación se expone mediante outputs de Terraform y se entrega al módulo de Flink como propiedad de ejecución.

### Integración entre Flink e Iceberg

La aplicación:

```text
flink/src/main/java/com/dataops/flink/SensorStreamingJob.java
```

fue extendida para persistir los resultados calculados por las ventanas utilizando Apache Iceberg.

La configuración utiliza:

```text
Catalog: GlueCatalog
FileIO: S3FileIO
Database: lakehouse_db
Table: sensor_metrics
```

Las propiedades necesarias para la integración son configuradas dentro de Managed Flink mediante el grupo:

```text
IcebergCatalog
```

que contiene:

```text
warehouse.path
database.name
```

AWS Glue actúa como catálogo central de la tabla mientras que Amazon S3 almacena físicamente los datos y la metadata administrada por Iceberg.

### Dependencias de Apache Iceberg

El proyecto Maven fue extendido para incorporar las dependencias necesarias para utilizar Apache Iceberg con Flink 1.20 y AWS.

Entre las dependencias utilizadas se encuentran:

```text
iceberg-flink-runtime-1.20
iceberg-aws-bundle
hadoop-client-api
hadoop-client-runtime
```

La aplicación continúa empaquetándose como un JAR mediante Maven para posteriormente ser subida al bucket de artefactos utilizado por Managed Flink.

### Tabla `sensor_metrics`

La aplicación crea la tabla:

```text
lakehouse_db.sensor_metrics
```

si todavía no existe en AWS Glue.

El esquema utilizado contiene siete columnas:

```text
sensor_id
window_start
window_end
event_count
avg_temperature
avg_humidity
avg_aqi
```

Cada registro representa el resultado agregado de un sensor para una ventana de Event Time de un minuto.

Los datos almacenados contienen:

* Identificador del sensor.
* Inicio de la ventana.
* Fin de la ventana.
* Cantidad de eventos procesados.
* Temperatura promedio.
* Humedad promedio.
* Índice promedio de calidad del aire.

### Estrategia de particionamiento

La tabla Iceberg utiliza una transformación de particionamiento basada en:

```text
day(window_start)
```

Durante las pruebas, los archivos de datos fueron almacenados en rutas como:

```text
data/window_start_day=2026-08-23/
```

Se utilizó `window_start` porque los datos generados son métricas temporales y las consultas analíticas normalmente se realizan sobre períodos de tiempo.

El particionamiento por día permite que Apache Iceberg aplique partition pruning al consultar rangos temporales.

De esta forma, una consulta filtrada por una fecha o un rango de fechas puede evitar leer archivos correspondientes a días que no forman parte de la consulta, reduciendo la cantidad de datos escaneados.

No se utilizó `sensor_id` como estrategia principal de particionamiento para evitar generar una cantidad excesiva de particiones a medida que aumente el número de sensores.

### Escritura mediante IcebergSink

Después del procesamiento de las ventanas, los resultados son convertidos a filas compatibles con el esquema de Apache Iceberg.

La aplicación utiliza:

```text
IcebergSink
```

para escribir los resultados en la tabla `sensor_metrics`.

Los datos se almacenan físicamente en Amazon S3 en formato Parquet.

Durante la prueba end-to-end se generaron múltiples archivos:

```text
*.parquet
```

dentro de la partición correspondiente al día de procesamiento.

### Checkpoints y commits de Iceberg

La escritura hacia Apache Iceberg está integrada con el mecanismo de checkpoints de Flink.

La aplicación mantiene la configuración utilizada en la preentrega anterior:

```text
Checkpoint interval: 60000 ms
Minimum pause between checkpoints: 5000 ms
Checkpointing: enabled
```

Durante la ejecución se verificaron checkpoints completados correctamente junto con actividad de los componentes:

```text
IcebergWriteAggregator
IcebergCommitter
```

Los commits permiten que los nuevos archivos escritos sean incorporados de forma consistente a la metadata de la tabla Iceberg.

### Metadata de Apache Iceberg

Apache Iceberg mantiene la metadata de la tabla dentro del mismo warehouse en Amazon S3.

La ruta utilizada es:

```text
warehouse/lakehouse_db.db/sensor_metrics/metadata/
```

Durante las pruebas se verificaron múltiples versiones de archivos:

```text
00000-....metadata.json
00001-....metadata.json
00002-....metadata.json
00003-....metadata.json
00004-....metadata.json
00005-....metadata.json
```

También se generaron archivos:

```text
*-m0.avro
snap-*.avro
```

correspondientes a manifests y snapshots utilizados por Apache Iceberg.

La existencia de diferentes versiones de `metadata.json` muestra la evolución de la tabla a medida que se realizan nuevos commits.

### Control de concurrencia

No se agregó una tabla DynamoDB adicional para bloquear los commits de Apache Iceberg.

AWS Glue e Iceberg utilizan optimistic locking para controlar las actualizaciones concurrentes de la metadata de la tabla.

Esto permite detectar si la versión de metadata cambió antes de completar una actualización y evita sobrescribir silenciosamente cambios realizados por otro proceso.

La tabla DynamoDB creada durante la primera preentrega continúa siendo utilizada únicamente para el bloqueo del estado remoto de Terraform.

### Permisos IAM

El rol de ejecución de AWS Managed Service for Apache Flink fue extendido para permitir la interacción con la capa Lakehouse.

Los permisos sobre Amazon S3 permiten:

* Listar el bucket del Lakehouse.
* Leer objetos.
* Escribir objetos.
* Eliminar objetos cuando sea necesario.
* Administrar operaciones multipart.

Los permisos de AWS Glue permiten:

* Consultar bases de datos.
* Consultar tablas.
* Crear tablas.
* Actualizar tablas.

Estos permisos permiten que la aplicación utilice `GlueCatalog` y escriba los resultados mediante Apache Iceberg.

### Generación de eventos de prueba

Para verificar el flujo de la quinta preentrega se utilizó:

```powershell
.\scripts\send_test_events.ps1
```

El script genera eventos JSON compatibles con el esquema esperado por `SensorStreamingJob.java`.

Ejemplo:

```json
{
  "sensor_id": "sensor-01",
  "temperature": 24.37,
  "humidity": 61.82,
  "air_quality_index": 74,
  "timestamp": "2026-08-23T14:50:00.0000000Z"
}
```

Los eventos son enviados al stream:

```text
realtime-data-platform-dev-stream
```

utilizando el identificador del sensor como partition key.

### Verificación de archivos en Amazon S3

Los archivos generados por Apache Iceberg pueden verificarse mediante AWS CLI:

```powershell
aws s3 ls s3://realtime-data-platform-dev-lakehouse-<account-id>/warehouse/ --recursive
```

Durante la prueba se observaron archivos de datos en rutas como:

```text
warehouse/lakehouse_db.db/sensor_metrics/data/window_start_day=2026-08-23/
```

junto con las diferentes versiones de metadata, manifests y snapshots.

Esto confirma que los resultados procesados por Apache Flink fueron persistidos correctamente dentro del Lakehouse.

### Registro en AWS Glue Data Catalog

La tabla fue registrada correctamente en AWS Glue Data Catalog con la siguiente configuración:

```text
Database: lakehouse_db
Table: sensor_metrics
Table format: Apache Iceberg
```

Glue reconoce también el esquema de siete columnas generado por la aplicación.

La ubicación de la tabla apunta al warehouse almacenado en Amazon S3.

### Consulta mediante Amazon Athena

La tabla Iceberg fue consultada desde Amazon Athena utilizando AWS Glue Data Catalog.

La consulta utilizada durante la prueba fue:

```sql
SELECT *
FROM lakehouse_db.sensor_metrics
ORDER BY window_start DESC
LIMIT 20;
```

Athena devolvió correctamente registros correspondientes a diferentes sensores y ventanas de un minuto.

Los resultados incluyen:

```text
sensor_id
window_start
window_end
event_count
avg_temperature
avg_humidity
avg_aqi
```

Esto permite comprobar que los datos transformados por Apache Flink pueden ser consultados directamente desde la capa Lakehouse.

### Validación end-to-end

Durante la prueba final se verificó el flujo completo:

```text
Amazon Kinesis Data Streams
        |
        v
AWS Managed Service for Apache Flink
        |
        v
Event Time + Watermarks
        |
        v
Ventanas de 1 minuto
        |
        v
Agregaciones por sensor
        |
        v
Apache Iceberg
        |
        +--> Amazon S3
        |    Parquet
        |    metadata.json
        |    manifests
        |    snapshots
        |
        +--> AWS Glue Data Catalog
                 |
                 v
             Amazon Athena
```

La prueba confirmó:

* Recepción de eventos desde Kinesis.
* Procesamiento mediante Apache Flink.
* Procesamiento mediante Event Time y Watermarks.
* Generación de ventanas de un minuto.
* Cálculo de las métricas agregadas.
* Escritura de archivos Parquet.
* Generación de metadata de Apache Iceberg.
* Creación de manifests y snapshots.
* Registro de la tabla dentro de AWS Glue.
* Consulta exitosa de la tabla mediante Amazon Athena.

### Evidencias de la Preentrega 5

#### Tabla Apache Iceberg en AWS Glue

AWS Glue Data Catalog muestra la tabla `sensor_metrics` dentro de la base de datos `lakehouse_db`.

La tabla aparece identificada con formato Apache Iceberg y Glue reconoce correctamente las siete columnas utilizadas por el pipeline.

![Evidencia de Apache Iceberg en AWS Glue](docs/evidencia-glue-iceberg.png)

#### Archivos Iceberg almacenados en Amazon S3

La evidencia muestra los archivos Parquet generados por el pipeline junto con las diferentes versiones de `metadata.json`, manifests y snapshots de Apache Iceberg.

También puede observarse la partición generada mediante `window_start_day`.

![Evidencia de Apache Iceberg en Amazon S3](docs/evidencia-s3-iceberg.png)

#### Consulta de la tabla mediante Amazon Athena

Amazon Athena permite consultar directamente `lakehouse_db.sensor_metrics` y devuelve los resultados de las ventanas procesadas por Apache Flink.

![Evidencia de consulta mediante Amazon Athena](docs/evidencia-athena-iceberg.png)

### Limpieza de recursos

Una vez finalizadas las pruebas, la aplicación puede detenerse mediante:

```powershell
aws kinesisanalyticsv2 stop-application --application-name realtime-data-platform-dev-flink --region us-east-1
```

Para evitar costos innecesarios, los recursos administrados por el entorno de desarrollo pueden eliminarse desde:

```text
environments/dev
```

mediante:

```powershell
terraform destroy
```

El backend remoto ubicado en `bootstrap` se mantiene separado del entorno de desarrollo y no forma parte de este proceso de destrucción.

El bucket del Lakehouse utiliza `force_destroy` dentro del entorno de desarrollo, por lo que al ejecutar `terraform destroy` también se eliminan los archivos Parquet, la metadata, los manifests y los snapshots de Apache Iceberg generados durante las pruebas.

## Validación del código

Desde la raíz del repositorio se puede aplicar formato a todos los archivos:

```powershell
terraform fmt -recursive
```

Luego, desde cada configuración de Terraform, se puede ejecutar:

```powershell
terraform validate
terraform plan
```

El archivo `PLAN_OUTPUT.md` contiene el resultado de uno de los planes realizados durante el desarrollo.

La aplicación Java puede compilarse y validarse mediante Maven utilizando:

```powershell
mvn -f .\flink\pom.xml clean package
```

## Seguridad y control de versiones

El archivo `.gitignore` evita subir al repositorio:

* Carpetas `.terraform`.
* Entornos virtuales `.venv`.
* Archivos `terraform.tfstate`.
* Archivos `terraform.tfvars`.
* Copias de respaldo del estado.
* Archivos temporales.
* Credenciales y secretos.
* Configuración local de VS Code.
* Artefactos de compilación de Maven dentro de `flink/target/`.

Los archivos `.terraform.lock.hcl` sí se incluyen para mantener versiones consistentes de los providers.