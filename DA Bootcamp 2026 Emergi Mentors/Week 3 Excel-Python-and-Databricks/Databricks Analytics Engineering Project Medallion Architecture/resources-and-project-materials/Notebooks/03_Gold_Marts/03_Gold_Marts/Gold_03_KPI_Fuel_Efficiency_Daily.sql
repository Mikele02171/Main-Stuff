-- Databricks notebook source
-- MAGIC %md
-- MAGIC ### Gold KPI - Daily Fuel Efficiency by Site

-- COMMAND ----------

CREATE OR REPLACE TABLE gold.kpi_fuel_efficiency_daily AS
SELECT 
  DATE(fc.load_time) as cycle_date,
  fc.site_id,
  s.site_name,
  s.state,
  
  -- Fuel efficiency metrics
  COUNT(*) as num_cycles,
  ROUND(SUM(fc.tonnes), 2) as total_tonnes_hauled,
  ROUND(SUM(fc.fuel_litres), 2) as total_fuel_litres,
  
  -- Key KPI: Fuel litres per tonne (lower is better)
  ROUND(SUM(fc.fuel_litres) / NULLIF(SUM(fc.tonnes), 0), 4) as fuel_litres_per_tonne,
  
  -- Additional context
  ROUND(AVG(fc.distance_km), 2) as avg_distance_km,
  ROUND(AVG(fc.cycle_time_minutes), 1) as avg_cycle_time_minutes,
  
  -- Benchmark against site target (example: 0.25 L/tonne target)
  ROUND(
    ((SUM(fc.fuel_litres) / NULLIF(SUM(fc.tonnes), 0)) - 0.25) / 0.25 * 100, 
    2
  ) as variance_from_target_pct,
  
  CURRENT_TIMESTAMP() as kpi_generated_timestamp
  
FROM silver.fleet_cycles fc
  INNER JOIN silver.dim_site s ON fc.site_id = s.site_id
  
WHERE fc.tonnes > 0 AND fc.fuel_litres > 0  -- Valid cycles only
  
GROUP BY 
  DATE(fc.load_time),
  fc.site_id,
  s.site_name,
  s.state


-- COMMAND ----------

SELECT 
  cycle_date,
  site_name,
  fuel_litres_per_tonne,
  total_tonnes_hauled,
  variance_from_target_pct
FROM gold.kpi_fuel_efficiency_daily
ORDER BY fuel_litres_per_tonne DESC
LIMIT 10;
