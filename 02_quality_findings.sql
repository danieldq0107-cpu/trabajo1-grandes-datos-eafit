SELECT
    COUNT(*) AS total_filas,
    COUNT_IF(
        FlightDate IS NULL OR Reporting_Airline IS NULL OR Origin IS NULL
        OR Dest IS NULL OR Flight_Number_Reporting_Airline IS NULL
    ) AS campos_clave_faltantes,
    COUNT_IF(
        TRY_CAST(Year AS INTEGER) NOT BETWEEN 2022 AND 2026
        OR TRY_CAST(Month AS INTEGER) NOT BETWEEN 1 AND 12
        OR TRY_CAST(DayofMonth AS INTEGER) NOT BETWEEN 1 AND 31
        OR TRY_CAST(DayOfWeek AS INTEGER) NOT BETWEEN 1 AND 7
    ) AS fechas_invalidas,
    COUNT_IF(
        TRY_CAST(Distance AS DOUBLE) <= 0
        OR TRY_CAST(CRSElapsedTime AS DOUBLE) <= 0
    ) AS valores_fisicos_invalidos,
    COUNT_IF(
        TRY_CAST(Cancelled AS DOUBLE) NOT IN (0,1)
        OR TRY_CAST(Diverted AS DOUBLE) NOT IN (0,1)
    ) AS flags_invalidos,
    COUNT_IF(DepDel15 IS NULL) AS objetivo_depdel15_faltante
FROM trabajo1_bigdata.bronze_vuelos;

SELECT
    COUNT_IF(DepDel15 IS NULL AND TRY_CAST(Cancelled AS DOUBLE) = 1) AS faltante_en_cancelados,
    COUNT_IF(DepDel15 IS NULL AND TRY_CAST(Diverted AS DOUBLE) = 1) AS faltante_en_desviados,
    COUNT_IF(
        DepDel15 IS NULL
        AND COALESCE(TRY_CAST(Cancelled AS DOUBLE), 0) = 0
        AND COALESCE(TRY_CAST(Diverted AS DOUBLE), 0) = 0
    ) AS faltante_en_vuelos_normales
FROM trabajo1_bigdata.bronze_vuelos;

SELECT
    COUNT_IF(TRY_CAST(CRSElapsedTime AS DOUBLE) <= 0) AS duracion_programada_no_positiva,
    COUNT_IF(CRSElapsedTime IS NULL) AS duracion_programada_faltante
FROM trabajo1_bigdata.bronze_vuelos;
