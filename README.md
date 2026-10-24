# Evidencias sugeridas para el video

- S3 con `raw/`, `bronze/`, `silver/` y `gold/`.
- Athena con las tablas del catálogo.
- Conteo Bronze = 32,386,436.
- Silver válidos = 32,386,404.
- Silver rechazados = 32.
- Conciliación Bronze = válidos + rechazados.
- Tabla Gold.
- Métricas Athena:
  - Bronze: 4.14 MB / 1.035 s
  - Silver: 4.25 MB / 1.466 s
  - Gold: 2.23 KB / 0.725 s
- SQS `trabajo1-flight-events`.
- Lambda y trigger SQS.
- Regla IoT `trabajo1_flight_to_sqs`.
- DynamoDB con 10,000 eventos.
- CloudWatch con 20 descartes.
- Latencia promedio y máxima.
- CloudFormation mostrando la pila base automática de AWS Academy Learner Lab.
