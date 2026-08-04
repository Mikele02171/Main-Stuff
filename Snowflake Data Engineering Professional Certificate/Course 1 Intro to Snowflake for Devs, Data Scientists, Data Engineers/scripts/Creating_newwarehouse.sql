-- Create a new Standard Small virtual warehouse named warehouse_giberto.
-- Co-authored with CoCo

CREATE OR REPLACE WAREHOUSE warehouse_giberto
    WAREHOUSE_SIZE = 'SMALL'
    WAREHOUSE_TYPE = 'STANDARD'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE;


--> Back to the exercise
-- What menu items does the Freezing Point brand sell?

SELECT
    menu_item_name
FROM tasty_bytes_sample_data.raw_pos.menu
WHERE truck_brand_name = 'Freezing Point';


-- What is the profit on Mango Sticky Rice?
SELECT 
    menu_item_name,
    ROUND((sale_price_usd - cost_of_goods_usd),2) AS profit_usd
FROM tasty_bytes_sample_data.raw_pos.menu
WHERE 1=1
AND truck_brand_name = 'Freezing Point'
AND menu_item_name = 'Mango Sticky Rice';

-- Creating a new warehouse
CREATE WAREHOUSE warehouse_dash;

-- Shows all warehouses in Snowflake 
SHOW WAREHOUSES;

-- Use Warehouse 
USE WAREHOUSE warehouse_giberto;