-- Databricks notebook source
-- MAGIC %md
-- MAGIC ### Gold KPI - Production vs Plan Daily

-- COMMAND ----------

CREATE OR REPLACE TABLE gold.kpi_production_vs_plan_daily AS
SELECT 
  pt.production_date,
  pt.site_id,
  s.site_name,
  s.state,
  
  -- Production metrics
  ROUND(pt.ore_tonnes, 2) as actual_ore_tonnes,
  ROUND(pt.waste_tonnes, 2) as actual_waste_tonnes,
  ROUND(pt.ore_tonnes + pt.waste_tonnes, 2) as total_tonnes_moved,
  ROUND(pt.plan_tonnes, 2) as plan_tonnes,
  
  -- Variance analysis
  ROUND(pt.ore_tonnes - pt.plan_tonnes, 2) as variance_tonnes,
  ROUND(((pt.ore_tonnes - pt.plan_tonnes) / NULLIF(pt.plan_tonnes, 0)) * 100, 2) as variance_pct,
  
  -- Recovery rate
  ROUND(pt.recovery_pct, 2) as recovery_pct,
  
  -- Status flag
  CASE 
    WHEN pt.ore_tonnes >= pt.plan_tonnes THEN 'On Target'
    WHEN pt.ore_tonnes >= pt.plan_tonnes * 0.95 THEN 'Within Tolerance'
    ELSE 'Below Target'
  END as production_status,
  
  CURRENT_TIMESTAMP() as kpi_generated_timestamp
  
FROM silver.production_tonnage pt
  INNER JOIN silver.dim_site s ON pt.site_id = s.site_id
  
WHERE pt.plan_tonnes > 0  -- Only days with valid plan
;


-- COMMAND ----------

SELECT 
  production_date,
  site_name,
  actual_ore_tonnes,
  plan_tonnes,
  variance_pct,
  production_status
FROM gold.kpi_production_vs_plan_daily
ORDER BY production_date DESC
LIMIT 20;