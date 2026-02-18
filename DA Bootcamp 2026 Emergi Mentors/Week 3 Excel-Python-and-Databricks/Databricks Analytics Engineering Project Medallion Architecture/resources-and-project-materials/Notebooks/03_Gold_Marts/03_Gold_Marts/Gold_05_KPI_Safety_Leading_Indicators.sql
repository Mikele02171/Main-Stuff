-- Databricks notebook source
-- MAGIC %md
-- MAGIC ### Gold KPI - Safety Leading Indicators

-- COMMAND ----------

CREATE OR REPLACE TABLE gold.kpi_safety_leading_indicators AS
WITH weekly_metrics AS (
  SELECT 
    DATE_TRUNC('week', se.event_timestamp) as week_start_date,
    se.site_id,
    s.site_name,
    s.state,
    
    -- Event counts
    COUNT(*) as total_events,
    SUM(CASE WHEN se.is_near_miss THEN 1 ELSE 0 END) as near_miss_count,
    SUM(CASE WHEN se.is_lti THEN 1 ELSE 0 END) as lti_count,
    SUM(CASE WHEN se.event_type = 'Hazard Reported' THEN 1 ELSE 0 END) as hazards_reported,
    SUM(CASE WHEN se.event_type = 'Safety Inspection' THEN 1 ELSE 0 END) as inspections_completed,
    
    -- Severity breakdown
    SUM(CASE WHEN se.severity = 'HIGH' THEN 1 ELSE 0 END) as high_severity_events,
    SUM(CASE WHEN se.severity = 'MEDIUM' THEN 1 ELSE 0 END) as medium_severity_events,
    SUM(CASE WHEN se.severity = 'LOW' THEN 1 ELSE 0 END) as low_severity_events
    
  FROM silver.safety_events se
    INNER JOIN silver.dim_site s ON se.site_id = s.site_id
  GROUP BY 
    DATE_TRUNC('week', se.event_timestamp),
    se.site_id,
    s.site_name,
    s.state
)

SELECT 
  week_start_date,
  site_id,
  site_name,
  state,
  
  -- Leading indicators (proactive safety measures)
  near_miss_count,
  hazards_reported,
  inspections_completed,
  
  -- Near miss ratio (target: 10+ near misses per 1 LTI)
  ROUND(near_miss_count / NULLIF(lti_count, 0), 2) as near_miss_to_lti_ratio,
  
  -- Lagging indicator (actual injuries)
  lti_count,
  
  -- Severity distribution
  high_severity_events,
  medium_severity_events,
  low_severity_events,
  total_events,
  
  -- Safety trend indicator
  CASE 
    WHEN lti_count = 0 AND near_miss_count >= 5 THEN 'Good - Proactive Reporting'
    WHEN lti_count = 0 AND near_miss_count < 5 THEN 'Caution - Low Reporting'
    WHEN lti_count > 0 THEN 'Action Required'
    ELSE 'Monitor'
  END as safety_trend,
  
  CURRENT_TIMESTAMP() as kpi_generated_timestamp
  
FROM weekly_metrics
ORDER BY week_start_date DESC, site_name;


-- COMMAND ----------

SELECT 
  week_start_date,
  site_name,
  near_miss_count,
  lti_count,
  near_miss_to_lti_ratio,
  safety_trend
FROM gold.kpi_safety_leading_indicators
ORDER BY week_start_date DESC
LIMIT 20;