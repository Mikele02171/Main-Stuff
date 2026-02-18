-- Databricks notebook source
-- MAGIC %md
-- MAGIC # Bronze Layer: Fleet Cycles (Operational Usage)
-- MAGIC
-- MAGIC **Source System:** Fleet Management System / Telematics Aggregation  
-- MAGIC **Frequency:** Daily batch (end-of-shift aggregation)  
-- MAGIC **Business Purpose:** Capture equipment usage cycles to analyse utilisation, fatigue, productivity, and maintenance drivers
-- MAGIC
-- MAGIC **Grain:** One record per equipment per operational cycle (shift / haul / duty cycle)
-- MAGIC
-- MAGIC **Issues:**
-- MAGIC - Cycle durations may be zero or unusually high due to sensor glitches
-- MAGIC - Cycle status values may be inconsistent (e.g., "Complete", "COMPLETED")
-- MAGIC - Equipment IDs may exist that are missing in equipment master
-- MAGIC - Timestamp fields may be stored as strings
-- MAGIC
-- MAGIC

-- COMMAND ----------

-- Drop existing table
DROP TABLE IF EXISTS bronze.fleet_cycles_raw;

-- Create empty Delta table
CREATE TABLE IF NOT EXISTS bronze.fleet_cycles_raw
USING DELTA;

-- Load raw CSV into Delta
COPY INTO bronze.fleet_cycles_raw
FROM '/Volumes/workspace/bronze/amg_raw/amg_data/raw/csv/fleet_cycles.csv'
FILEFORMAT = CSV
FORMAT_OPTIONS (
  'header' = 'true',
  'inferSchema' = 'true'
)
COPY_OPTIONS (
  'mergeSchema' = 'true'
);

-- COMMAND ----------

SELECT *
FROM bronze.fleet_cycles_raw;
