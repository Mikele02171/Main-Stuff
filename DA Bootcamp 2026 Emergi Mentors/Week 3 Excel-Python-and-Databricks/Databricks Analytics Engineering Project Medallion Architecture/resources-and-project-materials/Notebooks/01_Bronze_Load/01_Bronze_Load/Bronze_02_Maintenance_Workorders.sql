-- Databricks notebook source
-- MAGIC %md
-- MAGIC # Bronze Layer: Maintenance Work Orders
-- MAGIC
-- MAGIC **Source System:** SAP EAM (Enterprise Asset Management)  
-- MAGIC **Frequency:** Hourly batch export  
-- MAGIC **Business Purpose:** Track maintenance history, costs, and failure patterns
-- MAGIC
-- MAGIC **Known Issues:**
-- MAGIC - Parts costs stored as strings with AUD symbol and commas
-- MAGIC - Mixed case in failure_type field
-- MAGIC - Some work orders still open (close_time = null)
-- MAGIC

-- COMMAND ----------

DROP TABLE IF EXISTS bronze.maintenance_workorders_raw;

CREATE TABLE IF NOT EXISTS bronze.maintenance_workorders_raw
USING DELTA;

COPY INTO bronze.maintenance_workorders_raw
FROM '/Volumes/workspace/bronze/amg_raw/amg_data/raw/csv/maintenance_workorders.csv'
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
  COUNT(*) as total_workorders,
  SUM(CASE WHEN close_time IS NULL THEN 1 ELSE 0 END) as open_workorders,
  COUNT(DISTINCT equipment_id) as equipment_serviced,
  MIN(open_time) as earliest_wo,
  MAX(open_time) as latest_wo
FROM bronze.maintenance_workorders_raw;


-- COMMAND ----------

SELECT 
  COUNT(*) as total_workorders,
  SUM(CASE WHEN close_time IS NULL THEN 1 ELSE 0 END) as open_workorders,
  COUNT(DISTINCT equipment_id) as equipment_serviced,
  MIN(open_time) as earliest_wo,
  MAX(open_time) as latest_wo
FROM bronze.maintenance_workorders_raw;


-- COMMAND ----------

SELECT 
  *
FROM bronze.maintenance_workorders_raw;