# Terraform Scaffold para Plataforma de Datos

Este repositorio contiene la estructura inicial de un proyecto de Terraform para desplegar una plataforma de datos en AWS.

El proyecto está preparado para crecer progresivamente e incorporar servicios como Amazon Kinesis, Amazon Managed Service for Apache Flink y Amazon S3.

## Requisitos

Para utilizar este proyecto se necesita:

* Terraform 1.1.0 o superior.
* Git.
* Una cuenta de AWS para futuros despliegues.
* Credenciales de AWS configuradas de forma segura.

Las credenciales de AWS no deben almacenarse dentro de los archivos del repositorio.

## Estructura del proyecto

```text
Terraform-Scaffold/
├── .gitignore
├── .terraform.lock.hcl
├── main.tf
├── outputs.tf
├── provider.tf
├── README.md
├── terraform.tfvars
└── variables.tf
```

### Descripción de los archivos

* `provider.tf`: define la versión mínima de Terraform y configura el provider de AWS.
* `variables.tf`: declara las variables utilizadas por el proyecto, incluyendo sus tipos y descripciones.
* `terraform.tfvars`: contiene los valores concretos asignados a las variables.
* `main.tf`: contiene la configuración principal y será utilizado para agregar los recursos de AWS.
* `outputs.tf`: define los valores que Terraform mostrará como resultado.
* `.terraform.lock.hcl`: registra las versiones seleccionadas de los providers.
* `.gitignore`: evita subir archivos temporales, archivos de estado y otros artefactos locales de Terraform.

## Inicialización del proyecto

Después de clonar el repositorio, se debe ingresar en su carpeta:

```powershell
cd "Terraform-Scaffold"
```

Luego se inicializa Terraform:

```powershell
terraform init
```

Este comando descarga los providers necesarios y prepara el directorio de trabajo.

Para comprobar el formato de los archivos:

```powershell
terraform fmt
```

Para validar que la configuración sea correcta:

```powershell
terraform validate
```

Antes de realizar un despliegue, se puede revisar el plan de ejecución:

```powershell
terraform plan
```

Los comandos `terraform apply` y `terraform destroy` se utilizarán cuando el proyecto contenga recursos reales de AWS y las credenciales estén correctamente configuradas.

## Variables

El proyecto utiliza las siguientes variables:

| Variable       | Descripción                                 | Ejemplo                  |
| -------------- | ------------------------------------------- | ------------------------ |
| `region`       | Región de AWS donde se crearán los recursos | `us-east-1`              |
| `project_name` | Nombre de la plataforma de datos            | `realtime-data-platform` |
| `environment`  | Entorno de ejecución                        | `dev`                    |

Los valores se encuentran definidos en `terraform.tfvars`.

Este archivo contiene solamente valores no sensibles. No deben almacenarse contraseñas, claves privadas ni credenciales de AWS.

## Convención de nombres

Los recursos futuros de AWS seguirán esta convención:

```text
<project_name>-<environment>-<resource>
```

Por ejemplo:

```text
realtime-data-platform-dev-stream
realtime-data-platform-dev-bucket
realtime-data-platform-dev-flink
```

Esta convención permite identificar fácilmente:

* El proyecto al que pertenece el recurso.
* El entorno donde está desplegado.
* La función del recurso.

Los recursos también podrán utilizar etiquetas comunes:

* `Project`: nombre del proyecto.
* `Environment`: entorno correspondiente.
* `ManagedBy`: herramienta encargada de administrar el recurso.

## Decisión de diseño

La configuración se separó en varios archivos en lugar de colocar todo dentro de un único `main.tf`.

Aunque Terraform procesa conjuntamente todos los archivos `.tf` del directorio, separarlos mejora la organización y el mantenimiento del proyecto.

Cada archivo tiene una responsabilidad específica:

* Los providers y las versiones se encuentran en `provider.tf`.
* Las entradas configurables se encuentran en `variables.tf`.
* Los recursos y valores locales se encuentran en `main.tf`.
* Los resultados se encuentran en `outputs.tf`.
* Los valores propios del entorno se encuentran en `terraform.tfvars`.

Esta estructura permite que otras personas comprendan el proyecto con mayor facilidad y prepara el repositorio para crecer hacia una plataforma de datos con Kinesis, Flink y otros servicios de AWS.

## Gestión del estado

Terraform utiliza archivos de estado para registrar la infraestructura que administra.

Los archivos `.tfstate` y la carpeta `.terraform/` están excluidos mediante `.gitignore`, ya que pueden contener información sensible y no deben versionarse directamente en el repositorio.
