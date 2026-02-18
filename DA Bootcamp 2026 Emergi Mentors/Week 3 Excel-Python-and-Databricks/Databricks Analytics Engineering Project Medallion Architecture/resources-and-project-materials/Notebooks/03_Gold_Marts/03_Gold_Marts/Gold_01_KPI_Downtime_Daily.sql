-- Databricks notebook source
-- MAGIC %md
-- MAGIC # Gold KPI: Daily Downtime by Site & Equipment Class
-- MAGIC
-- MAGIC **Business Definition:**  
-- MAGIC Downtime Hours = Sum of (close_time - open_time) for all maintenance work orders per day
-- MAGIC
-- MAGIC **Target:** Reduce average downtime from 3.2 hrs/day to 2.7 hrs/day (15% reduction)
-- MAGIC
-- MAGIC **Dashboard Use:**  
-- MAGIC - Executive summary: total downtime hours by site
-- MAGIC - Operations drill-down: downtime by equipment class (trucks vs excavators vs fixed plant)
-- MAGIC - Trend analysis: 7-day moving average
-- MAGIC

-- COMMAND ----------

CREATE OR REPLACE TABLE gold.kpi_downtime_daily AS
SELECT 
  DATE(wo.open_time) as downtime_date,
  wo.site_id,
  s.site_name,
  s.state,
  e.equipment_class,
  e.equipment_type,
  
  -- Downtime metrics
  COUNT(DISTINCT wo.work_order_id) as num_workorders,
  ROUND(SUM(wo.downtime_hours), 2) as total_downtime_hours,
  ROUND(AVG(wo.downtime_hours), 2) as avg_downtime_hours,
  
  -- Availability calculation (assume 24 hrs - downtime)
  ROUND(((24 - COALESCE(SUM(wo.downtime_hours), 0)) / 24.0) * 100, 2) as availability_pct,
  
  -- Cost estimate ($500/hr downtime cost for mobile fleet, $2000/hr for fixed plant)
  ROUND(
    SUM(wo.downtime_hours) * 
    CASE 
      WHEN e.equipment_class = 'Fixed Plant' THEN 2000
      ELSE 500
    END, 
    2
  ) as estimated_downtime_cost_aud,
  
  CURRENT_TIMESTAMP() as kpi_generated_timestamp
  
FROM silver.maintenance_workorders wo
  INNER JOIN silver.dim_equipment e ON wo.equipment_id = e.equipment_id
  INNER JOIN silver.dim_site s ON wo.site_id = s.site_id
  
WHERE wo.downtime_hours IS NOT NULL  -- Only completed work orders
  
GROUP BY 
  DATE(wo.open_time),
  wo.site_id,
  s.site_name,
  s.state,
  e.equipment_class,
  e.equipment_type
;



-- COMMAND ----------

SELECT 
  downtime_date,
  site_name,
  equipment_class,
  total_downtime_hours,
  availability_pct,
  estimated_downtime_cost_aud
FROM gold.kpi_downtime_daily
ORDER BY total_downtime_hours DESC
LIMIT 10;
