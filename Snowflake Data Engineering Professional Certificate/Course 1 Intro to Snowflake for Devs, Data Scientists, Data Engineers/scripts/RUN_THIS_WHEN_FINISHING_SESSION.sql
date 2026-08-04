USE ROLE ACCOUNTADMIN;

-- 1. Create a monitor that shuts down operations at 100% of your credit limit
CREATE OR REPLACE RESOURCE MONITOR account_budget_shield
  WITH CREDIT_QUOTA = 1000            -- Set your monthly credit limit here
       FREQUENCY = MONTHLY            -- Resets automatically every month
       START_TIMESTAMP = IMMEDIATELY  -- Activates right now
  TRIGGERS 
    ON 80 PERCENT DO NOTIFY           -- Alerts administrators
    ON 90 PERCENT DO SUSPEND          -- Stops new queries; lets active ones finish
    ON 100 PERCENT DO SUSPEND_IMMEDIATE; -- Kills all running queries immediately

-- 2. Apply this strict shield to your entire Snowflake account
ALTER ACCOUNT SET RESOURCE_MONITOR = account_budget_shield;
