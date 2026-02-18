-- Databricks notebook source
-- MAGIC %md
-- MAGIC # Silver Layer: Maintenance Work Orders
-- MAGIC
-- MAGIC **Transformations:**
-- MAGIC 1. Parse parts_cost_aud: remove "$", "," and cast to decimal
-- MAGIC 2. Calculate downtime_hours from open_time to close_time
-- MAGIC 3. Standardize failure_type to sentence case
-- MAGIC 4. Handle null close_time (still open work orders)
-- MAGIC 5. Deduplicate on work_order_id
-- MAGIC
-- MAGIC **Business Rules:**
-- MAGIC - Parts cost: 0-500,000 AUD valid range (above that likely data entry error)
-- MAGIC - Labor hours: 0.5-200 hours valid range
-- MAGIC - Downtime: calculated only if close_time exists
-- MAGIC

-- COMMAND ----------

CREATE OR REPLACE TABLE silver.maintenance_workorders AS
SELECT 
  work_order_id,
  equipment_id,
  UPPER(site_id) as site_id,  -- Standardize to uppercase
  TO_TIMESTAMP(open_time) as open_time,
  TO_TIMESTAMP(close_time) as close_time,
  
  -- Fix parts cost: remove currency symbols and commas
  CASE 
    WHEN TRY_CAST(REGEXP_REPLACE(parts_cost_aud, '[^0-9.]', '') AS DECIMAL(10,2)) BETWEEN 0 AND 500000
    THEN CAST(REGEXP_REPLACE(parts_cost_aud, '[^0-9.]', '') AS DECIMAL(10,2))
    ELSE NULL
  END as parts_cost_aud,
  
  -- Labor hours (simple cast)
  CASE 
    WHEN TRY_CAST(labor_hours AS DOUBLE) BETWEEN 0.5 AND 200 
    THEN CAST(labor_hours AS DOUBLE)
    ELSE NULL
  END as labor_hours,
  
  -- Standardize failure type
  INITCAP(TRIM(failure_type)) as failure_type,
  
  -- Priority (uppercase)
  UPPER(TRIM(priority)) as priority,
  
  -- Calculate downtime hours (only if closed)
  CASE 
    WHEN close_time IS NOT NULL 
    THEN ROUND((UNIX_TIMESTAMP(close_time) - UNIX_TIMESTAMP(open_time)) / 3600.0, 2)
    ELSE NULL
  END as downtime_hours,
  
  -- Flag for still open
  CASE WHEN close_time IS NULL THEN TRUE ELSE FALSE END as is_open,
  
  CURRENT_TIMESTAMP() as etl_processed_timestamp
  
FROM (
  SELECT 
    *,
    ROW_NUMBER() OVER (PARTITION BY work_order_id ORDER BY open_time DESC) as row_num
  FROM bronze.maintenance_workorders_raw
) dedupe
WHERE row_num = 1;


-- COMMAND ----------

SELECT 
  COUNT(*) as total_workorders,
  SUM(CASE WHEN is_open THEN 1 ELSE 0 END) as open_workorders,
  ROUND(AVG(downtime_hours), 2) as avg_downtime_hours,
  ROUND(AVG(parts_cost_aud), 2) as avg_parts_cost_aud
FROM silver.maintenance_workorders;
