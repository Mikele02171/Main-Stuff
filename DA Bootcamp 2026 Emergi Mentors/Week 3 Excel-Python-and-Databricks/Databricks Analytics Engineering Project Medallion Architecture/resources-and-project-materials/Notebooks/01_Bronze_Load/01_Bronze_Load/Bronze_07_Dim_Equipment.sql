-- Databricks notebook source
-- MAGIC %md
-- MAGIC %md
-- MAGIC # Bronze Layer: Equipment Dimension (Master Data)
-- MAGIC
-- MAGIC **Source System:** Asset Register / Maintenance Master (CMMS extract)  
-- MAGIC **Frequency:** Daily batch (master refresh), ad-hoc updates for new assets  
-- MAGIC **Business Purpose:** Single source of truth for equipment attributes used across maintenance, telemetry, production, and safety analytics
-- MAGIC
-- MAGIC **Issues:**
-- MAGIC - Equipment types may have inconsistent naming/casing (e.g., "Truck", "truck", "TRUCK")
-- MAGIC - Status fields can be inconsistent (e.g., "Active", "ACTIVE", "In Service")
-- MAGIC - Missing or duplicate equipment_id values can break joins downstream
-- MAGIC - Manufacturer/model fields may contain free-text variations
-- MAGIC

-- COMMAND ----------

-- Drop existing table
DROP TABLE IF EXISTS bronze.site_dim_raw;

-- Create empty Delta table
CREATE TABLE IF NOT EXISTS bronze.site_dim_raw
USING DELTA;

-- Load raw CSV into Delta
COPY INTO bronze.site_dim_raw
FROM '/Volumes/workspace/bronze/amg_raw/amg_data/raw/csv/site_dim.csv'
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
  COUNT(*) AS total_sites,
  COUNT(DISTINCT site_id) AS unique_sites,
  COUNT(DISTINCT state) AS states_covered,
  SUM(CASE WHEN site_name IS NULL THEN 1 ELSE 0 END) AS missing_site_names
FROM bronze.site_dim_raw;


-- COMMAND ----------

SELECT *
FROM bronze.site_dim_raw;