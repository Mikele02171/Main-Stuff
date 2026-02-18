-- Databricks notebook source
-- MAGIC %md
-- MAGIC ### Gold KPI - Executive Summary Daily
-- MAGIC ### This is the "single pane of glass" table for C-suite dashboards.
-- MAGIC

-- COMMAND ----------

CREATE OR REPLACE TABLE gold.kpi_executive_summary_daily AS
SELECT 
  COALESCE(d.downtime_date, f.cycle_date, p.production_date) as report_date,
  COALESCE(d.site_id, f.site_id, p.site_id) as site_id,
  COALESCE(d.site_name, f.site_name, p.site_name) as site_name,
  COALESCE(d.state, f.state, p.state) as state,
  
  -- Production KPIs
  p.actual_ore_tonnes,
  p.plan_tonnes,
  p.variance_pct as production_variance_pct,
  p.production_status,
  
  -- Downtime KPIs
  d.total_downtime_hours,
  d.availability_pct,
  d.estimated_downtime_cost_aud,
  
  -- Fuel efficiency KPIs
  f.fuel_litres_per_tonne,
  f.variance_from_target_pct as fuel_variance_pct,
  
  -- Safety (weekly rollup shown as daily context)
  0 as daily_lti_count,  -- Placeholder; calculate from safety events if needed
  
  -- Overall status
  CASE 
    WHEN p.production_status = 'On Target' 
         AND d.availability_pct >= 85 
         AND f.fuel_litres_per_tonne <= 0.27
    THEN 'Green'
    WHEN p.production_status = 'Below Target' 
         OR d.availability_pct < 75
    THEN 'Red'
    ELSE 'Amber'
  END as overall_status,
  
  CURRENT_TIMESTAMP() as kpi_generated_timestamp
  
FROM gold.kpi_downtime_daily d
  FULL OUTER JOIN gold.kpi_fuel_efficiency_daily f 
    ON d.downtime_date = f.cycle_date AND d.site_id = f.site_id
  FULL OUTER JOIN gold.kpi_production_vs_plan_daily p
    ON d.downtime_date = p.production_date AND d.site_id = p.site_id
;



-- COMMAND ----------

SELECT * 
FROM gold.kpi_executive_summary_daily
ORDER BY report_date DESC, site_name
LIMIT 10;
