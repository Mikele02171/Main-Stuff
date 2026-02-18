-- Databricks notebook source
CREATE OR REPLACE TABLE silver.safety_events AS
SELECT 
  event_id,
  UPPER(site_id) as site_id,
  TO_TIMESTAMP(date_time) as event_timestamp,
  
  -- Standardize event type
  INITCAP(TRIM(event_type)) as event_type,
  
  -- Standardize severity to uppercase
  CASE 
    WHEN UPPER(TRIM(severity)) IN ('HIGH', 'MEDIUM', 'LOW') THEN UPPER(TRIM(severity))
    ELSE 'UNKNOWN'
  END as severity,
  
  -- Numeric severity for ranking (1=low, 2=medium, 3=high)
  CASE 
    WHEN UPPER(TRIM(severity)) = 'HIGH' THEN 3
    WHEN UPPER(TRIM(severity)) = 'MEDIUM' THEN 2
    WHEN UPPER(TRIM(severity)) = 'LOW' THEN 1
    ELSE 0
  END as severity_score,
  
  -- Boolean flags (convert string to boolean)
  CASE WHEN LOWER(is_lti) IN ('true', '1', 'yes') THEN TRUE ELSE FALSE END as is_lti,
  CASE WHEN LOWER(near_miss_flag) IN ('true', '1', 'yes') THEN TRUE ELSE FALSE END as is_near_miss,
  
  -- Contributing factor (keep as-is, could parse JSON if needed)
  contributing_factor,
  
  CURRENT_TIMESTAMP() as etl_processed_timestamp
  
FROM (
  SELECT 
    *,
    ROW_NUMBER() OVER (PARTITION BY event_id ORDER BY date_time DESC) as row_num
  FROM bronze.safety_events_raw
) dedupe
WHERE row_num = 1;

-- COMMAND ----------

SELECT 
  COUNT(*) as total_events,
  SUM(CASE WHEN is_lti THEN 1 ELSE 0 END) as total_lti,
  SUM(CASE WHEN is_near_miss THEN 1 ELSE 0 END) as total_near_misses,
  COUNT(DISTINCT event_type) as unique_event_types
FROM silver.safety_events;

-- COMMAND ----------

SELECT * from silver.safety_events