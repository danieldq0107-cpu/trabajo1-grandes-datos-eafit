CREATE EXTERNAL TABLE IF NOT EXISTS trabajo1_bigdata.bts_raw_typed (
    DepDel15 DOUBLE, FlightDate DATE, Year BIGINT, Reporting_Airline STRING,
    Quarter BIGINT, Month BIGINT, DayofMonth BIGINT, DayOfWeek BIGINT,
    Origin STRING, Dest STRING, OriginState STRING, DestState STRING,
    CRSDepTime BIGINT, DepTimeBlk STRING, CRSArrTime BIGINT,
    CRSElapsedTime DOUBLE, Distance DOUBLE,
    Flight_Number_Reporting_Airline BIGINT, Tail_Number STRING,
    Cancelled DOUBLE, CancellationCode STRING, Diverted DOUBLE,
    DepTime DOUBLE, DepDelay DOUBLE, DepDelayMinutes DOUBLE,
    DepartureDelayGroups DOUBLE, TaxiOut DOUBLE, WheelsOff DOUBLE,
    ArrDelay DOUBLE, ArrDel15 DOUBLE, CarrierDelay DOUBLE,
    WeatherDelay DOUBLE, NASDelay DOUBLE, SecurityDelay DOUBLE,
    LateAircraftDelay DOUBLE
)
STORED AS PARQUET
LOCATION 's3://daniel-bigdata-trabajo1-2026/raw/'
TBLPROPERTIES ('parquet.column.index.access'='true');

CREATE TABLE trabajo1_bigdata.bronze_vuelos
WITH (
    format = 'PARQUET',
    external_location = 's3://daniel-bigdata-trabajo1-2026/bronze/'
) AS
SELECT
    CAST(DepDel15 AS VARCHAR) AS DepDel15,
    CAST(FlightDate AS VARCHAR) AS FlightDate,
    CAST(Year AS VARCHAR) AS Year,
    CAST(Reporting_Airline AS VARCHAR) AS Reporting_Airline,
    CAST(Quarter AS VARCHAR) AS Quarter,
    CAST(Month AS VARCHAR) AS Month,
    CAST(DayofMonth AS VARCHAR) AS DayofMonth,
    CAST(DayOfWeek AS VARCHAR) AS DayOfWeek,
    CAST(Origin AS VARCHAR) AS Origin,
    CAST(Dest AS VARCHAR) AS Dest,
    CAST(OriginState AS VARCHAR) AS OriginState,
    CAST(DestState AS VARCHAR) AS DestState,
    CAST(CRSDepTime AS VARCHAR) AS CRSDepTime,
    CAST(DepTimeBlk AS VARCHAR) AS DepTimeBlk,
    CAST(CRSArrTime AS VARCHAR) AS CRSArrTime,
    CAST(CRSElapsedTime AS VARCHAR) AS CRSElapsedTime,
    CAST(Distance AS VARCHAR) AS Distance,
    CAST(Flight_Number_Reporting_Airline AS VARCHAR) AS Flight_Number_Reporting_Airline,
    CAST(Tail_Number AS VARCHAR) AS Tail_Number,
    CAST(Cancelled AS VARCHAR) AS Cancelled,
    CAST(CancellationCode AS VARCHAR) AS CancellationCode,
    CAST(Diverted AS VARCHAR) AS Diverted,
    CAST(DepTime AS VARCHAR) AS DepTime,
    CAST(DepDelay AS VARCHAR) AS DepDelay,
    CAST(DepDelayMinutes AS VARCHAR) AS DepDelayMinutes,
    CAST(DepartureDelayGroups AS VARCHAR) AS DepartureDelayGroups,
    CAST(TaxiOut AS VARCHAR) AS TaxiOut,
    CAST(WheelsOff AS VARCHAR) AS WheelsOff,
    CAST(ArrDelay AS VARCHAR) AS ArrDelay,
    CAST(ArrDel15 AS VARCHAR) AS ArrDel15,
    CAST(CarrierDelay AS VARCHAR) AS CarrierDelay,
    CAST(WeatherDelay AS VARCHAR) AS WeatherDelay,
    CAST(NASDelay AS VARCHAR) AS NASDelay,
    CAST(SecurityDelay AS VARCHAR) AS SecurityDelay,
    CAST(LateAircraftDelay AS VARCHAR) AS LateAircraftDelay
FROM trabajo1_bigdata.bts_raw_typed;

SELECT COUNT(*) AS total_bronce
FROM trabajo1_bigdata.bronze_vuelos;
