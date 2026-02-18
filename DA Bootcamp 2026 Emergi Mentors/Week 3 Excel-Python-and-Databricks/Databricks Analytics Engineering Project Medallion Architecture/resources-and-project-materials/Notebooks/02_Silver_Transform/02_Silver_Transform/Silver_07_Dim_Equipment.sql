-- Databricks notebook source
CREATE OR REPLACE TABLE silver.dim_equipment AS
SELECT 
  equipment_id,
  INITCAP(equipment_type) as equipment_type,
  INITCAP(equipment_class) as equipment_class,
  manufacturer,
  model,
  UPPER(site_id) as site_id,
  commissioning_date,
  capacity_tonnes,
  CURRENT_TIMESTAMP() as etl_processed_timestamp
FROM bronze.equipment_dim_raw;

SELECT * FROM silver.dim_equipment;
