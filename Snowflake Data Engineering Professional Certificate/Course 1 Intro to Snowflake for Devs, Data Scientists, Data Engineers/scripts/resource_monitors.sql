-- Resource monitor creation, assignment, and management examples
-- Co-authored with CoCo
CREATE RESOURCE MONITOR tasty_test_rm
WITH 
CREDIT_QUOTA = 20 -- 20 Credits
FREQUENCY = daily -- reset the monitor monthly 
START_TIMESTAMP = immediately -- begin tracking immediately 
TRIGGERS
ON 80 PERCENT DO NOTIFY -- notify accountadmins at 80%
ON 100 PERCENT DO SUSPEND --Suspend warehouse at 100 percent, let queries finish
ON 110 PERCENT DO SUSPEND_IMMEDIATE; --suspend warehouse and cancel queries at 110 percent 

SHOW RESOURCE MONITORS;
ALTER WAREHOUSE tasty_de_wh SET RESOURCE_MONITOR = tasty_test_rm;

SHOW RESOURCE MONITORS;
ALTER RESOURCE MONITOR tasty_test_rm
SET CREDIT_QUOTA=30;

SHOW RESOURCE MONITORS;
DROP RESOURCE MONITOR tasty_test_rm;
SHOW RESOURCE MONITORS;

-- Assessment 
CREATE RESOURCE MONITOR tasty_test_rm
WITH 
CREDIT_QUOTA = 15 -- 20 Credits
FREQUENCY = daily -- reset the monitor monthly 
START_TIMESTAMP = immediately -- begin tracking immediately 
TRIGGERS
ON 90 PERCENT DO NOTIFY; -- notify accountadmins at 80%
SHOW RESOURCE MONITORS;


CREATE WAREHOUSE tasty_test_wh;
ALTER WAREHOUSE tasty_test_wh SET RESOURCE_MONITOR = tasty_test_rm;
SHOW RESOURCE MONITORS;

ALTER RESOURCE MONITOR tasty_test_rm
SET CREDIT_QUOTA=20;

DROP RESOURCE MONITOR tasty_test_rm;

