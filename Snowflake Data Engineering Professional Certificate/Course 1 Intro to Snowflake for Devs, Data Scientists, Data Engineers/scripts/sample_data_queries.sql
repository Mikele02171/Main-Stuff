-- Queries against Tasty Bytes sample menu data.
-- Co-authored with CoCo

-- Running our first section of queries in Snowflake
-- How many rows are in the table?
SELECT COUNT(*) AS row_count FROM tasty_bytes_sample_data.raw_pos.menu;

-- What do the top 10 rows look like?
SELECT TOP 10 * FROM tasty_bytes_sample_data.raw_pos.menu;

-- How many food truck brands are we talking about?
SELECT 
    TRUCK_BRAND_NAME,
    MENU_TYPE,
    COUNT(*)
FROM tasty_bytes_sample_data.raw_pos.menu
GROUP BY 1,2
ORDER BY 3 DESC;

--Practice Assignment
--Worksheets Hands-on Assignment
--  How many items are there with an item_category of 'Snack' and an item_subcategory of 'Warm Option'?
SELECT COUNT(*),
ITEM_CATEGORY,
ITEM_SUBCATEGORY
FROM tasty_bytes_sample_data.raw_pos.menu
WHERE ITEM_CATEGORY = 'Snack' AND ITEM_SUBCATEGORY = 'Warm Option'
GROUP BY 2,3;

--What are the max sales prices for each of the three item subcategories (hot option, warm option, cold option)? 
--List from highest price to lowest
SELECT TOP 3
    ITEM_SUBCATEGORY,
    MAX(SALE_PRICE_USD) AS max_price
FROM tasty_bytes_sample_data.raw_pos.menu
WHERE ITEM_SUBCATEGORY IN ('Hot Option', 'Warm Option', 'Cold Option')
GROUP BY ITEM_SUBCATEGORY
ORDER BY max_price DESC;
