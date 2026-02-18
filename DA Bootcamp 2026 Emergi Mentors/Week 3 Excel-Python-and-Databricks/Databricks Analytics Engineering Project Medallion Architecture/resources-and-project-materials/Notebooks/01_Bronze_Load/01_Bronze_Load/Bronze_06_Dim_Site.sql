-- Databricks notebook source
-- MAGIC %md
-- MAGIC %md
-- MAGIC # Bronze Layer: Site Dimension (Master Data)
-- MAGIC
-- MAGIC **Source System:** Site Master / Operations Reference (AMG internal reference)  
-- MAGIC **Frequency:** Infrequent updates (monthly/quarterly), ad-hoc for new sites/projects  
-- MAGIC **Business Purpose:** Standard reference for site-level reporting across safety, production, maintenance, and fleet KPIs
-- MAGIC
-- MAGIC **Issues:**
-- MAGIC - Site names may have inconsistent casing or abbreviations (e.g., "Mt Isa", "Mount Isa")
-- MAGIC - State values may vary (e.g., "QLD", "Queensland")
-- MAGIC - Missing site_id or site_name will cause reporting gaps
-- MAGIC - Regions/zones may be blank or inconsistent if maintained manually
-- MAGIC

-- COMMAND ----------

-- Drop existing table
DROP TABLE IF EXISTS bronze.equipment_dim_raw;

-- Create empty Delta table
CREATE TABLE IF NOT EXISTS bronze.equipment_dim_raw
USING DELTA;

-- Load raw CSV into Delta
COPY INTO bronze.equipment_dim_raw
FROM '/Volumes/workspace/bronze/amg_raw/amg_data/raw/csv/equipment_dim.csv'
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
  COUNT(*) AS total_equipment,
  COUNT(DISTINCT equipment_id) AS unique_equipment,
  COUNT(DISTINCT equipment_type) AS equipment_types,
  COUNT(DISTINCT site_id) AS sites_with_equipment
  FROM bronze.equipment_dim_raw;
