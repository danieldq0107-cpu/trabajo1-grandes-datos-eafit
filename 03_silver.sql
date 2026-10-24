CREATE TABLE trabajo1_bigdata.silver_vuelos_validos
WITH (
    table_type = 'ICEBERG',
    is_external = false,
    format = 'PARQUET',
    location = 's3://daniel-bigdata-trabajo1-2026/silver/validos/'
) AS
SELECT *
FROM trabajo1_bigdata.bronze_vuelos
WHERE
    FlightDate IS NOT NULL
    AND Reporting_Airline IS NOT NULL
    AND Origin IS NOT NULL
    AND Dest IS NOT NULL
    AND Flight_Number_Reporting_Airline IS NOT NULL
    AND CRSElapsedTime IS NOT NULL
    AND TRY_CAST(CRSElapsedTime AS DOUBLE) > 0;

CREATE TABLE trabajo1_bigdata.silver_vuelos_rechazados
WITH (
    table_type = 'ICEBERG',
    is_external = false,
    format = 'PARQUET',
    location = 's3://daniel-bigdata-trabajo1-2026/silver/rechazados/'
) AS
SELECT
    *,
    CASE
        WHEN FlightDate IS NULL
          OR Reporting_Airline IS NULL
          OR Origin IS NULL
          OR Dest IS NULL
          OR Flight_Number_Reporting_Airline IS NULL
            THEN 'Campos clave obligatorios faltantes'
        WHEN CRSElapsedTime IS NULL
            THEN 'CRSElapsedTime faltante'
        WHEN TRY_CAST(CRSElapsedTime AS DOUBLE) <= 0
            THEN 'CRSElapsedTime no positivo'
    END AS motivo_rechazo
FROM trabajo1_bigdata.bronze_vuelos
WHERE
    FlightDate IS NULL
    OR Reporting_Airline IS NULL
    OR Origin IS NULL
    OR Dest IS NULL
    OR Flight_Number_Reporting_Airline IS NULL
    OR CRSElapsedTime IS NULL
    OR TRY_CAST(CRSElapsedTime AS DOUBLE) <= 0;

SELECT motivo_rechazo, COUNT(*) AS cantidad
FROM trabajo1_bigdata.silver_vuelos_rechazados
GROUP BY motivo_rechazo
ORDER BY cantidad DESC;

SELECT
    (SELECT COUNT(*) FROM trabajo1_bigdata.bronze_vuelos) AS total_bronce,
    (SELECT COUNT(*) FROM trabajo1_bigdata.silver_vuelos_validos) AS total_validos,
    (SELECT COUNT(*) FROM trabajo1_bigdata.silver_vuelos_rechazados) AS total_rechazados,
    (SELECT COUNT(*) FROM trabajo1_bigdata.silver_vuelos_validos)
      + (SELECT COUNT(*) FROM trabajo1_bigdata.silver_vuelos_rechazados)
      AS validos_mas_rechazados;
