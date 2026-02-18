-- Databricks notebook source
CREATE OR REPLACE TABLE silver.production_tonnage AS
SELECT 
  TO_DATE(date) as production_date,
  UPPER(site_id) as site_id,
  
  -- Fix tonnes with commas
  CASE 
    WHEN TRY_CAST(REPLACE(ore_tonnes, ',', '') AS DOUBLE) >= 0 
    THEN CAST(REPLACE(ore_tonnes, ',', '') AS DOUBLE)
    ELSE 0
  END as ore_tonnes,
  
  CASE 
    WHEN TRY_CAST(REPLACE(waste_tonnes, ',', '') AS DOUBLE) >= 0 
    THEN CAST(REPLACE(waste_tonnes, ',', '') AS DOUBLE)
    ELSE 0
  END as waste_tonnes,
  
  CASE 
    WHEN TRY_CAST(REPLACE(plan_tonnes, ',', '') AS DOUBLE) >= 0 
    THEN CAST(REPLACE(plan_tonnes, ',', '') AS DOUBLE)
    ELSE NULL  -- Missing plan
  END as plan_tonnes,
  
  -- Recovery percentage (already clean)
  CAST(recovery_pct AS DOUBLE) as recovery_pct,
  
  CURRENT_TIMESTAMP() as etl_processed_timestamp
  
FROM (
  SELECT 
    *,
    ROW_NUMBER() OVER (PARTITION BY date, site_id ORDER BY date DESC) as row_num
  FROM bronze.production_tonnage_raw
) dedupe
WHERE row_num = 1;



-- COMMAND ----------

SELECT 
  COUNT(*) as total_days,
  SUM(ore_tonnes) as total_ore_tonnes,
  SUM(waste_tonnes) as total_waste_tonnes,
  ROUND(AVG(recovery_pct), 2) as avg_recovery_pct
FROM silver.production_tonnage;


-- COMMAND ----------

select * FROM silver.production_tonnage;