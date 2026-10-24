-- BRONZE
SELECT
    TRY_CAST(Year AS INTEGER) AS anio,
    Reporting_Airline AS aerolinea,
    COUNT(*) AS total_vuelos_evaluables,
    SUM(CASE WHEN TRY_CAST(DepDel15 AS DOUBLE) = 1 THEN 1 ELSE 0 END) AS vuelos_retrasados,
    ROUND(100.0 * SUM(CASE WHEN TRY_CAST(DepDel15 AS DOUBLE) = 1 THEN 1 ELSE 0 END) / COUNT(*), 2)
        AS porcentaje_retrasados
FROM trabajo1_bigdata.bronze_vuelos
WHERE TRY_CAST(DepDel15 AS DOUBLE) IN (0, 1)
GROUP BY TRY_CAST(Year AS INTEGER), Reporting_Airline;

-- SILVER
SELECT
    TRY_CAST(Year AS INTEGER) AS anio,
    Reporting_Airline AS aerolinea,
    COUNT(*) AS total_vuelos_evaluables,
    SUM(CASE WHEN TRY_CAST(DepDel15 AS DOUBLE) = 1 THEN 1 ELSE 0 END) AS vuelos_retrasados,
    ROUND(100.0 * SUM(CASE WHEN TRY_CAST(DepDel15 AS DOUBLE) = 1 THEN 1 ELSE 0 END) / COUNT(*), 2)
        AS porcentaje_retrasados
FROM trabajo1_bigdata.silver_vuelos_validos
WHERE TRY_CAST(DepDel15 AS DOUBLE) IN (0, 1)
GROUP BY TRY_CAST(Year AS INTEGER), Reporting_Airline;

-- GOLD
SELECT *
FROM trabajo1_bigdata.gold_retrasos_aerolinea_anio;

/*
Bronze -> 4.14 MB, 1.035 s
Silver -> 4.25 MB, 1.466 s
Gold   -> 2.23 KB, 0.725 s
*/
