-- Semi-structured data queries and VARIANT manipulation for frostbyte_tasty_bytes menu
-- Co-authored with CoCo
SELECT MENU_ITEM_NAME,
MENU_ITEM_HEALTH_METRICS_OBJ
FROM FROSTBYTE_TASTY_BYTES.RAW_POS.MENU;

DESCRIBE TABLE FROSTBYTE_TASTY_BYTES.RAW_POS.MENU;

/*
CREATE TABLE frostbyte_tasty_bytes.raw_pos.menu
(
menu_id NUMBER(19,0),
menu_type_id NUMBER(38,0),
menu_type VARCHAR(16777216),
truck_brand_name VARCHAR(16777216),
menu_item_id NUMBER(38,0),
menu_item_name VARCHAR(16777216),
item_category VARCHAR(16777216),
item_subcategory VARCHAR(16777216),
cost_of_goods_usd NUMBER(38,4),
sale_price_usd NUMBER(38,4),
menu_item_health_metrics_obj VARIANT
)

*/

CREATE TABLE FROSTBYTE_TASTY_BYTES.RAW_POS.TEST_MENU (cost_of_goods_variant)
AS SELECT cost_of_goods_usd::VARIANT 
FROM FROSTBYTE_TASTY_BYTES.RAW_POS.MENU;

DESCRIBE TABLE FROSTBYTE_TASTY_BYTES.RAW_POS.TEST_MENU;
SELECT TYPEOF(cost_of_goods_variant) FROM frostbyte_tasty_bytes.raw_pos.test_menu;

SELECT cost_of_goods_variant, cost_of_goods_variant*2.0 FROM frostbyte_tasty_bytes.raw_pos.test_menu;

DROP TABLE frostbyte_tasty_bytes.raw_pos.test_menu;

SELECT MENU_ITEM_HEALTH_METRICS_OBJ:menu_item_health_metrics FROM frostbyte_tasty_bytes.raw_pos.menu;

SELECT TYPEOF(MENU_ITEM_HEALTH_METRICS_OBJ) FROM frostbyte_tasty_bytes.raw_pos.menu;

SELECT MENU_ITEM_HEALTH_METRICS_OBJ, MENU_ITEM_HEALTH_METRICS_OBJ['menu_item_id'] FROM frostbyte_tasty_bytes.raw_pos.menu;


-- SEMI-STRUCTURED DATA MANIPULATION 
-- Dot Notation

SELECT MENU_ITEM_HEALTH_METRICS_OBJ:menu_item_health_analytics
FROM FROSTBYTE_TASTY_BYTES.RAW_POS.MENU;

SELECT MENU_ITEM_HEALTH_METRICS_OBJ['menu_item_health_metrics']
FROM FROSTBYTE_TASTY_BYTES.RAW_POS.MENU;

-- Variant (with object type)
CREATE TABLE FROSTBYTE_TASTY_BYTES.RAW_POS.TEST_MENU1 (ingredients)
AS SELECT MENU_ITEM_HEALTH_METRICS_OBJ
FROM FROSTBYTE_TASTY_BYTES.RAW_POS.MENU;

SELECT * FROM FROSTBYTE_TASTY_BYTES.RAW_POS.TEST_MENU1;

DESCRIBE TABLE FROSTBYTE_TASTY_BYTES.RAW_POS.TEST_MENU1;
SELECT TYPEOF(ingredients) FROM FROSTBYTE_TASTY_BYTES.RAW_POS.TEST_MENU1;

-- Variant (with array type)
CREATE TABLE FROSTBYTE_TASTY_BYTES.RAW_POS.TEST_MENU2 (ingredients)
AS SELECT MENU_ITEM_HEALTH_METRICS_OBJ['menu_item_health_metrics']
FROM FROSTBYTE_TASTY_BYTES.RAW_POS.MENU;

SELECT * FROM FROSTBYTE_TASTY_BYTES.RAW_POS.TEST_MENU2;
SELECT TYPEOF(ingredients) FROM FROSTBYTE_TASTY_BYTES.RAW_POS.TEST_MENU2;

-- Variant (with object type)
CREATE TABLE FROSTBYTE_TASTY_BYTES.RAW_POS.TEST_MENU3 (ingredients)
AS SELECT MENU_ITEM_HEALTH_METRICS_OBJ['menu_item_health_metrics'][0]
FROM FROSTBYTE_TASTY_BYTES.RAW_POS.MENU;

SELECT * FROM FROSTBYTE_TASTY_BYTES.RAW_POS.TEST_MENU3;

DESCRIBE TABLE FROSTBYTE_TASTY_BYTES.RAW_POS.TEST_MENU3;
SELECT TYPEOF(ingredients) FROM FROSTBYTE_TASTY_BYTES.RAW_POS.TEST_MENU3;

-- Variant (with array type)
CREATE TABLE FROSTBYTE_TASTY_BYTES.RAW_POS.TEST_MENU4 (ingredients)
AS SELECT MENU_ITEM_HEALTH_METRICS_OBJ['menu_item_health_metrics'][0]['ingredients']
FROM FROSTBYTE_TASTY_BYTES.RAW_POS.MENU;

SELECT * FROM FROSTBYTE_TASTY_BYTES.RAW_POS.TEST_MENU4;
SELECT TYPEOF(ingredients) FROM FROSTBYTE_TASTY_BYTES.RAW_POS.TEST_MENU4;

-- Variant (with varchar type) -- Now we've gotten to the first ingredient 

CREATE TABLE FROSTBYTE_TASTY_BYTES.RAW_POS.TEST_MENU5 (ingredients)
AS SELECT MENU_ITEM_HEALTH_METRICS_OBJ['menu_item_health_metrics'][0]['ingredients'][0]
FROM FROSTBYTE_TASTY_BYTES.RAW_POS.MENU;

SELECT * FROM FROSTBYTE_TASTY_BYTES.RAW_POS.TEST_MENU5;
SELECT TYPEOF(ingredients) FROM FROSTBYTE_TASTY_BYTES.RAW_POS.TEST_MENU5;

-- All at once
SELECT MENU_ITEM_HEALTH_METRICS_OBJ['menu_item_health_metrics'][0]['ingredients'][0] as first_ingredient
FROM FROSTBYTE_TASTY_BYTES.RAW_POS.MENU;


SELECT *
FROM FROSTBYTE_TASTY_BYTES.RAW_POS.MENU M,
LATERAL FLATTEN (input => m.menu_item_health_metrics_obj:menu_item_health_metrics);

SELECT m.menu_item_name,
value:"ingredients"[0] AS ingredients
FROM FROSTBYTE_TASTY_BYTES.RAW_POS.MENU M,
LATERAL FLATTEN (input => m.menu_item_health_metrics_obj:menu_item_health_metrics);

-- Creating our View Using our Semi-Structured Flattening SQL
CREATE OR REPLACE VIEW frostbyte_tasty_bytes.analytics.menu_v
AS
SELECT 
m.menu_item_health_metrics_obj:menu_item_id::integer AS menu_item_id,
value:"is_healthy_flag"::VARCHAR(1) AS is_healthy_flag,
value:"is_gluten_free_flag"::VARCHAR(1) AS is_gluten_free_flag,
value:"is_dairy_free_flag"::VARCHAR(1) AS is_dairy_free_flag,
value:"is_nut_free_flag"::VARCHAR(1) AS is_nut_free_flag
FROM frostbyte_tasty_bytes.raw_pos.menu m,
LATERAL FLATTEN (input => m.menu_item_health_metrics_obj:menu_item_health_metrics);

-- Providing Metrics to Executives
SELECT 
COUNT(DISTINCT menu_item_id) AS total_menu_items,
SUM(case when is_healthy_flag = 'Y' THEN 1 ELSE 0 END) AS healthy_item_count,
SUM(case when is_gluten_free_flag = 'Y' THEN 1 ELSE 0 END) AS gluten_free_item_count,
SUM(case when is_dairy_free_flag = 'Y' THEN 1 ELSE 0 END) AS dairy_free_item_count,
SUM(case when is_nut_free_flag = 'Y' THEN 1 ELSE 0 END) AS nut_free_item_count
FROM frostbyte_tasty_bytes.analytics.menu_v;


-- Assessment 
DESCRIBE TABLE tasty_bytes.raw_pos.menu;
SELECT TYPEOF(MENU_ITEM_HEALTH_METRICS_OBJ) FROM tasty_bytes.raw_pos.menu;

SELECT MENU_ITEM_HEALTH_METRICS_OBJ
FROM tasty_bytes.raw_pos.menu
WHERE MENU_ITEM_NAME = 'Mango Sticky Rice';
