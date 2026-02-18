-- Databricks notebook source
-- MAGIC %md
-- MAGIC # Business Context:
-- MAGIC •	MTBF (Mean Time Between Failures): Average operating hours between breakdowns
-- MAGIC •	MTTR (Mean Time To Repair): Average hours to fix equipment
-- MAGIC •	Target: MTBF > 200 hrs, MTTR < 4 hrs
-- MAGIC

-- COMMAND ----------

CREATE OR REPLACE TABLE gold.kpi_mtbf_mttr AS
WITH failure_intervals AS (
  SELECT 
    wo.equipment_id,
    e.equipment_class,
    e.equipment_type,
    wo.open_time,
    wo.close_time,
    wo.downtime_hours,
    
    -- Calculate hours since last failure (using LAG function)
    (UNIX_TIMESTAMP(wo.open_time) - UNIX_TIMESTAMP(LAG(wo.close_time) OVER (PARTITION BY wo.equipment_id ORDER BY wo.open_time))) / 3600.0 
    as hours_since_last_failure
    
  FROM silver.maintenance_workorders wo
    INNER JOIN silver.dim_equipment e ON wo.equipment_id = e.equipment_id
  WHERE wo.close_time IS NOT NULL  -- Only completed work orders
)

SELECT 
  equipment_class,
  equipment_type,
  
  -- MTBF: Mean Time Between Failures
  ROUND(AVG(hours_since_last_failure), 2) as mtbf_hours,
  
  -- MTTR: Mean Time To Repair
  ROUND(AVG(downtime_hours), 2) as mttr_hours,
  
  -- Supporting metrics
  COUNT(*) as num_failures,
  ROUND(MIN(hours_since_last_failure), 2) as min_time_between_failures,
  ROUND(MAX(hours_since_last_failure), 2) as max_time_between_failures,
  
  -- Reliability score (higher is better)
  ROUND(AVG(hours_since_last_failure) / AVG(downtime_hours), 2) as reliability_ratio,
  
  CURRENT_TIMESTAMP() as kpi_generated_timestamp
  
FROM failure_intervals
WHERE hours_since_last_failure IS NOT NULL  -- Exclude first failure (no prior)
  
GROUP BY equipment_class, equipment_type
ORDER BY mtbf_hours DESC;


-- COMMAND ----------

SELECT * FROM gold.kpi_mtbf_mttr;