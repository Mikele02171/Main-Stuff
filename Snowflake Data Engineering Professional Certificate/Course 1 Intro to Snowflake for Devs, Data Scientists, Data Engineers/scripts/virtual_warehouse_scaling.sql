-- Demonstrates vertical and horizontal warehouse scaling with suspend/resume operations.
-- Co-authored with CoCo
-- Scaling Vertically 
ALTER WAREHOUSE warehouse_dash SET warehouse_size = MEDIUM;
USE WAREHOUSE warehouse_dash;
SELECT
    menu_item_name,
    ROUND((sale_price_usd-cost_of_goods_usd),2) as profit_usd
FROM tasty_bytes_sample_data.raw_pos.menu
ORDER BY 2 DESC;

ALTER WAREHOUSE warehouse_dash SET warehouse_size = XSMALL;
DROP WAREHOUSE warehouse_vino;
SHOW WAREHOUSES;
CREATE WAREHOUSE warehouse_vino MAX_CLUSTER_COUNT = 3;
SHOW WAREHOUSES;
ALTER WAREHOUSE warehouse_dash SET AUTO_SUSPEND = 180 AUTO_RESUME = FALSE;
SHOW WAREHOUSES;

-- Want to suspend warehouse
-- Note: This errors if the warehouse is already suspended. That is expected and safe to ignore.
--ALTER WAREHOUSE IF EXISTS warehouse_dash SUSPEND;

-- Virtual Warehouses Hands-on Assignment 
CREATE WAREHOUSE warehouse_one;
SHOW WAREHOUSES;

CREATE WAREHOUSE warehouse_two;
USE WAREHOUSE warehouse_two;
SHOW WAREHOUSES

DROP WAREHOUSE warehouse_two;

ALTER WAREHOUSE warehouse_one SET warehouse_size = SMALL;
SHOW WAREHOUSES;

-- This is to set the warehouse one in 2 minutues 
ALTER WAREHOUSE warehouse_one SET AUTO_SUSPEND = 120;
SHOW WAREHOUSES;