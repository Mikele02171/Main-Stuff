-- Databricks notebook source
CREATE OR REPLACE TABLE silver.fleet_cycles AS
SELECT 
  cycle_id,
  truck_id,
  excavator_id,
  UPPER(site_id) as site_id,
  TO_TIMESTAMP(load_time) as load_time,
  TO_TIMESTAMP(dump_time) as dump_time,
  
  -- Parse tonnes (remove commas)
  CASE 
    WHEN TRY_CAST(REPLACE(tonnes, ',', '') AS DOUBLE) BETWEEN 10 AND 500 
    THEN CAST(REPLACE(tonnes, ',', '') AS DOUBLE)
    ELSE NULL
  END as tonnes,
  
  -- Parse distance (remove "km" suffix)
  CASE 
    WHEN TRY_CAST(REGEXP_REPLACE(distance_km, '[^0-9.]', '') AS DOUBLE) BETWEEN 0.1 AND 50 
    THEN CAST(REGEXP_REPLACE(distance_km, '[^0-9.]', '') AS DOUBLE)
    ELSE NULL
  END as distance_km,
  
  -- Fuel litres (must be positive)
  CASE 
    WHEN TRY_CAST(fuel_litres AS DOUBLE) > 0 AND TRY_CAST(fuel_litres AS DOUBLE) < 5000
    THEN CAST(fuel_litres AS DOUBLE)
    ELSE NULL
  END as fuel_litres,
  
  -- Calculate cycle time in minutes
  CASE 
    WHEN dump_time IS NOT NULL 
    THEN ROUND((UNIX_TIMESTAMP(dump_time) - UNIX_TIMESTAMP(load_time)) / 60.0, 1)
    ELSE NULL
  END as cycle_time_minutes,
  
  CURRENT_TIMESTAMP() as etl_processed_timestamp
  
FROM (
  SELECT 
    *,
    ROW_NUMBER() OVER (PARTITION BY cycle_id ORDER BY load_time DESC) as row_num
  FROM bronze.fleet_cycles_raw
) dedupe
WHERE row_num = 1;

-- COMMAND ----------

SELECT 
  COUNT(*) as total_cycles,
  SUM(CASE WHEN dump_time IS NULL THEN 1 ELSE 0 END) as incomplete_cycles,
  ROUND(AVG(tonnes), 2) as avg_tonnes_per_cycle,
  ROUND(AVG(distance_km), 2) as avg_distance_km,
  ROUND(AVG(cycle_time_minutes), 1) as avg_cycle_time_min
FROM silver.fleet_cycles;
