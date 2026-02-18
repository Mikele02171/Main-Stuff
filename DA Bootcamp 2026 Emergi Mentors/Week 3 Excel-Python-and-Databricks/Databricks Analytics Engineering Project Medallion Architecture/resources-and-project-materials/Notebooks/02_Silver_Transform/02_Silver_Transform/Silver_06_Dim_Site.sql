-- Databricks notebook source
CREATE OR REPLACE TABLE silver.dim_site AS
SELECT 
  site_id,
  INITCAP(site_name) as site_name,
  UPPER(state) as state,  -- Standardize to uppercase (WA, QLD, NSW)
  INITCAP(type) as site_type,
  lat,
  lon,
  CURRENT_TIMESTAMP() as etl_processed_timestamp
FROM bronze.site_dim_raw;


-- COMMAND ----------

select * from silver.dim_site