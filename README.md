# Trabajo 1 - Almacenamiento y Procesamiento de Grandes Datos

**Curso:** Almacenamiento y Procesamiento de Grandes Datos  
**Universidad:** EAFIT  
**Arquitectura:** Medallion + procesamiento de eventos en AWS

## Objetivo

Implementar dos componentes en AWS:

1. Una arquitectura Medallion sobre datos de vuelos de Estados Unidos usando S3, Athena e Iceberg.
2. Un flujo de eventos con AWS IoT Core -> SQS -> Lambda -> DynamoDB, incluyendo validación, conciliación y medición de latencia.

## Dataset

Se utilizó el dataset del proyecto integrador de predicción de retrasos en vuelos comerciales de Estados Unidos.

- Archivo: `bts_2022_2026_combined.parquet`
- Periodo: 2022-2026
- Filas: **32,386,436**
- Tamaño aproximado: **565.2 MB**
- Columnas: **35**
- Formato original: **Parquet**

Ubicación del archivo:

`s3://daniel-bigdata-trabajo1-2026/raw/`

# Parte A - Arquitectura Medallion

## Bronze

El archivo Parquet original se registró en Athena mediante una tabla auxiliar con los tipos físicos del archivo. Después se creó `bronze_vuelos`, almacenada en S3, convirtiendo las 35 columnas a `VARCHAR`.

- Bronze: **32,386,436 filas**

SQL: `sql/01_bronze.sql`.

## Hallazgos de calidad

| Hallazgo | Cantidad |
|---|---:|
| Campos clave faltantes | 1 |
| `CRSElapsedTime` faltante | 10 |
| `CRSElapsedTime <= 0` | 21 |
| Fechas fuera de rango | 0 |
| Flags `Cancelled/Diverted` inválidos | 0 |
| Duplicados según llave lógica | 0 |

También se detectaron **553,405 valores faltantes en `DepDel15`**, pero todos pertenecían a vuelos cancelados, por lo que no se trataron automáticamente como defectos de calidad.

SQL: `sql/02_quality_findings.sql`.

## Silver

Reglas de calidad:

1. Los campos clave `FlightDate`, `Reporting_Airline`, `Origin`, `Dest` y `Flight_Number_Reporting_Airline` deben existir.
2. `CRSElapsedTime` debe existir.
3. `CRSElapsedTime` debe ser mayor que cero.

Tablas Iceberg:

- `silver_vuelos_validos`
- `silver_vuelos_rechazados`

Resultados:

| Resultado | Filas |
|---|---:|
| Válidos | **32,386,404** |
| Rechazados | **32** |

Motivos:

| Motivo | Filas |
|---|---:|
| `CRSElapsedTime no positivo` | 21 |
| `CRSElapsedTime faltante` | 10 |
| Campos clave obligatorios faltantes | 1 |

Conciliación:

**32,386,436 = 32,386,404 + 32**

SQL: `sql/03_silver.sql`.

## Gold

Pregunta de negocio:

> ¿Qué proporción de vuelos presenta retraso de salida de 15 minutos o más, por aerolínea y año?

Tabla Iceberg:

`gold_retrasos_aerolinea_anio`

Ejemplo 2026:

| Aerolínea | Vuelos evaluables | Retrasados | % retrasados |
|---|---:|---:|---:|
| NK | 43,737 | 15,390 | 35.19% |
| WN | 918,535 | 282,296 | 30.73% |
| B6 | 158,706 | 45,105 | 28.42% |
| F9 | 144,221 | 40,307 | 27.95% |
| OH | 153,477 | 42,633 | 27.78% |

SQL: `sql/04_gold.sql`.

## Comparación Bronze vs Silver vs Gold

| Capa | Datos analizados | Tiempo de ejecución |
|---|---:|---:|
| Bronze | **4.14 MB** | **1.035 s** |
| Silver | **4.25 MB** | **1.466 s** |
| Gold | **2.23 KB** | **0.725 s** |

Interpretación:

- Silver mejora principalmente la calidad y confiabilidad, no necesariamente el tiempo de consulta, porque conserva casi todo el detalle.
- Gold reduce drásticamente los datos escaneados porque la información ya está agregada por año y aerolínea.

SQL: `sql/05_performance_comparison.sql`.

# Parte B - Procesamiento de eventos

## Arquitectura

`AWS IoT Core -> Amazon SQS -> AWS Lambda -> Amazon DynamoDB`

Recursos:

- IoT topic: `trabajo1/flights`
- IoT Rule: `trabajo1_flight_to_sqs`
- SQS: `trabajo1-flight-events`
- Lambda: `trabajo1-process-flight-event`
- DynamoDB: `trabajo1-flight-events-db`
- Partition key: `event_id`

`event_id` identifica de forma única cada evento y evita crear múltiples registros para el mismo identificador si un mensaje se vuelve a procesar.

## Lambda

La función:

1. Recibe lotes desde SQS.
2. Parsea cada mensaje JSON.
3. Valida `event_id`, `sent_at_ms`, `flight_number`, `origin` y `dest`.
4. Descarta mensajes inválidos y registra el motivo.
5. Calcula `processed_at_ms` y `latency_ms`.
6. Almacena eventos válidos en DynamoDB.

Código: `lambda/lambda_function.py`.

## Publicación de eventos

Se publicaron eventos mediante la API de AWS IoT Core desde CloudShell.

- **10,020 intentados**
- **10,020 aceptados por la API**
- **0 fallos de publicación**
- **10,000 válidos**
- **20 inválidos intencionales**
  - 10 sin `origin`
  - 10 sin `sent_at_ms`

Script: `publisher/publish_events.py`.

## Conciliación

- Publicados: **10,020**
- Guardados en DynamoDB: **10,000**
- Descartados por Lambda: **20**

**10,020 = 10,000 + 20**

Motivos obtenidos de CloudWatch Logs:

| Motivo | Cantidad |
|---|---:|
| Missing fields: origin | 10 |
| Missing fields: sent_at_ms | 10 |

## Latencia

La latencia se calculó como:

`processed_at_ms - sent_at_ms`

sobre los 10,000 eventos almacenados.

- Eventos medidos: **10,000**
- Latencia promedio: **1,596.64 ms**
- Latencia máxima: **4,911 ms**

## Infraestructura

Los recursos del trabajo fueron creados manualmente desde la consola de AWS.

No se utilizó Terraform, Serverless Framework ni CloudFormation para crear los recursos del trabajo.

El entorno AWS Academy Learner Lab posee una pila de CloudFormation creada automáticamente por la plataforma. Esa pila corresponde a la infraestructura base del laboratorio y no fue utilizada para desplegar los recursos de esta solución.
