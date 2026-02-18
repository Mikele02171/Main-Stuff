-- Databricks notebook source
-- MAGIC %md
-- MAGIC # Bronze Layer: Safety Events & Near Misses
-- MAGIC
-- MAGIC **Source System:** Safety Management System (iAuditor / SafetyCulture)  
-- MAGIC **Frequency:** Real-time (critical events), daily batch (routine)  
-- MAGIC **Business Purpose:** Lead indicators for safety performance, prevent Lost Time Injuries (LTI)
-- MAGIC
-- MAGIC **Issues:**
-- MAGIC - Event types have inconsistent casing
-- MAGIC - Severity stored as text ("high", "High", "HIGH")
-- MAGIC - Contributing factors in JSON nested structure
-- MAGIC

-- COMMAND ----------

DROP TABLE IF EXISTS bronze.safety_events_raw;

CREATE TABLE IF NOT EXISTS bronze.safety_events_raw
USING DELTA;

COPY INTO bronze.safety_events_raw
FROM '/Volumes/workspace/bronze/amg_raw/amg_data/raw/csv/safety_events.csv'
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
  COUNT(*) as total_events,
  COUNT(DISTINCT event_type) as unique_event_types,
  SUM(CASE WHEN is_lti = 'true' THEN 1 ELSE 0 END) as lost_time_injuries,
  SUM(CASE WHEN near_miss_flag = 'true' THEN 1 ELSE 0 END) as near_misses,
  COUNT(DISTINCT site_id) as sites_with_events
FROM bronze.safety_events_raw;


-- COMMAND ----------

SELECT *
FROM bronze.safety_events_raw;