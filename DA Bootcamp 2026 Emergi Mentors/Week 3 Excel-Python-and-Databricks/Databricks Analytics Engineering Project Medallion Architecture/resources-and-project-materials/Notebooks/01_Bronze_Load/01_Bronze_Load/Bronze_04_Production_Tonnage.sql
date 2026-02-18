-- Databricks notebook source
-- MAGIC %md
-- MAGIC # Bronze Layer: Daily Production Tonnage
-- MAGIC
-- MAGIC **Source System:** Mine Production Reporting System  
-- MAGIC **Frequency:** Daily (end of shift)  
-- MAGIC **Business Purpose:** Track against production plan, calculate ore recovery rates
-- MAGIC
-- MAGIC **Issues:**
-- MAGIC - Tonnes stored with commas (e.g., "1,234.50")
-- MAGIC - Some negative waste tonnes (data entry errors)
-- MAGIC - Plan tonnes sometimes zero (incomplete planning data)
-- MAGIC

-- COMMAND ----------

DROP TABLE IF EXISTS bronze.production_tonnage_raw;

CREATE TABLE IF NOT EXISTS bronze.production_tonnage_raw
USING DELTA;

COPY INTO bronze.production_tonnage_raw
FROM '/Volumes/workspace/bronze/amg_raw/amg_data/raw/csv/production_tonnage.csv'
FILEFORMAT = CSV
FORMAT_OPTIONS (
  'header' = 'true',
  'inferSchema' = 'true'
)
COPY_OPTIONS (
  'mergeSchema' = 'true'
);

-- COMMAND ----------

select * from bronze.production_tonnage_raw

-- COMMAND ----------

SELECT 
  COUNT(*) as total_days,
  COUNT(DISTINCT site_id) as sites_reporting,
  MIN(date) as earliest_date,
  MAX(date) as latest_date
FROM bronze.production_tonnage_raw;
