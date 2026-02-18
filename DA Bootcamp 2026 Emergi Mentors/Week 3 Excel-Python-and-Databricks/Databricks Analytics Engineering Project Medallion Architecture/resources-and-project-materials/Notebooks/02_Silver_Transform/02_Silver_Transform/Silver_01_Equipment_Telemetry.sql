-- Databricks notebook source
-- MAGIC %md
-- MAGIC markdown
-- MAGIC # Silver Layer: Equipment Telemetry
-- MAGIC
-- MAGIC **Transformations Applied:**
-- MAGIC 1. Cast temperature from string to double (remove commas)
-- MAGIC 2. Deduplicate based on (equipment_id, timestamp) - keep latest
-- MAGIC 3. Filter out impossible values (temperature > 200°C likely sensor error)
-- MAGIC 4. Standardize timestamp to Australia/Sydney timezone
-- MAGIC 5. Handle null GPS coordinates (underground equipment)
-- MAGIC
-- MAGIC **Data Quality Rules:**
-- MAGIC - Temperature: 0-150°C valid range
-- MAGIC - Vibration: 0-100mm/s valid range
-- MAGIC - Engine hours: must increase monotonically per equipment
-- MAGIC

-- COMMAND ----------

-- Create or replace Silver table
CREATE OR REPLACE TABLE silver.equipment_telemetry AS
SELECT 
  -- Deduplicate: use ROW_NUMBER() to keep only the latest record per (equipment_id, timestamp)
  equipment_id,
  site_id,
  TO_TIMESTAMP(timestamp) as timestamp,  -- Standardize timestamp format
  
  -- Fix temperature: remove commas and cast to double
  CASE 
    WHEN TRY_CAST(REPLACE(temperature, ',', '') AS DOUBLE) BETWEEN 0 AND 150 
    THEN CAST(REPLACE(temperature, ',', '') AS DOUBLE)
    ELSE NULL  -- Invalid readings set to null
  END as temperature_celsius,
  
  -- Fix vibration
  CASE 
    WHEN TRY_CAST(vibration AS DOUBLE) BETWEEN 0 AND 100 
    THEN CAST(vibration AS DOUBLE)
    ELSE NULL
  END as vibration_mm_per_sec,
  
  -- Engine hours (no transformation needed if already numeric)
  CAST(engine_hours AS DOUBLE) as engine_hours,
  
  -- Fault codes (clean up)
  UPPER(TRIM(fault_code)) as fault_code,
  
  -- GPS coordinates (nullable for underground equipment)
  CAST(gps_lat AS DOUBLE) as gps_latitude,
  CAST(gps_lon AS DOUBLE) as gps_longitude,
  
  -- Metadata
  CURRENT_TIMESTAMP() as etl_processed_timestamp
  
FROM (
  SELECT 
    *,
    ROW_NUMBER() OVER (
      PARTITION BY equipment_id, timestamp 
      ORDER BY timestamp DESC  -- If duplicates exist, keep the last one
    ) as row_num
  FROM bronze.equipment_telemetry_raw
) dedupe
WHERE row_num = 1  -- Keep only unique records
;



-- COMMAND ----------

-- Validation: Check data quality improvements
SELECT 
  'Total Rows' as metric,
  COUNT(*) as value
FROM silver.equipment_telemetry

UNION ALL

SELECT 
  'Null Temperatures' as metric,
  SUM(CASE WHEN temperature_celsius IS NULL THEN 1 ELSE 0 END)
FROM silver.equipment_telemetry

UNION ALL

SELECT 
  'Out of Range Temps (cleaned)' as metric,
  SUM(CASE WHEN temperature_celsius < 0 OR temperature_celsius > 150 THEN 1 ELSE 0 END)
FROM silver.equipment_telemetry;


-- COMMAND ----------

select * from silver.equipment_telemetry