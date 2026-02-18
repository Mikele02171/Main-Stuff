-- Databricks notebook source
-- MAGIC %md
-- MAGIC # Bronze Layer: Equipment Telemetry Raw
-- MAGIC
-- MAGIC **Source System:** SCADA / IoT sensors on trucks, excavators, crushers  
-- MAGIC **Frequency:** Real-time streaming (batch simulated here)  
-- MAGIC **Business Purpose:** Monitor equipment health to predict failures before they happen
-- MAGIC
-- MAGIC **Data Quality Issues Present:**
-- MAGIC - Temperature readings as strings with commas
-- MAGIC - Some null GPS coordinates (underground equipment)
-- MAGIC - Occasional duplicate timestamps (sensor buffering)
-- MAGIC

-- COMMAND ----------

-- Upload the file from your local machine to the Unity Catalog volume
-- Use the Databricks file browser or the following command in a notebook cell:
-- PUT '/local/path/equipment_telemetry.csv' INTO '/Volumes/workspace/bronze/amg_raw/raw/csv/equipment_telemetry.csv' OVERWRITE

-- Then run your SQL code
CREATE TABLE IF NOT EXISTS bronze.equipment_telemetry_raw
USING DELTA;

COPY INTO bronze.equipment_telemetry_raw
FROM '/Volumes/workspace/bronze/amg_raw/amg_data/raw/csv/equipment_telemetry.csv'
FILEFORMAT = CSV
FORMAT_OPTIONS (
  'header' = 'true',
  'inferSchema' = 'true'
)
COPY_OPTIONS (
  'mergeSchema' = 'true'
);

-- COMMAND ----------

SELECT 
  COUNT(*) as total_rows,
  COUNT(DISTINCT equipment_id) as unique_equipment,
  COUNT(DISTINCT site_id) as unique_sites,
  SUM(CASE WHEN temperature IS NULL THEN 1 ELSE 0 END) as null_temps,
  MIN(timestamp) as earliest_reading,
  MAX(timestamp) as latest_reading
FROM bronze.equipment_telemetry_raw;


-- COMMAND ----------

SELECT * FROM bronze.equipment_telemetry_raw LIMIT 10;