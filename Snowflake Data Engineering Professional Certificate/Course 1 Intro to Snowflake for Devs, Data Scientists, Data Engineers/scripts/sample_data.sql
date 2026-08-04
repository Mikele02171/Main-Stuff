-- Setup script for Tasty Bytes sample data: creates database, schema, table, and loads menu data from S3.
-- Co-authored with CoCo
USE ROLE accountadmin;

USE WAREHOUSE compute_wh;

---> create the Tasty Bytes Database
CREATE DATABASE IF NOT EXISTS tasty_bytes_sample_data;

---> set the database context so subsequent statements resolve correctly
USE DATABASE tasty_bytes_sample_data;

---> create the Raw POS (Point-of-Sale) Schema
CREATE SCHEMA IF NOT EXISTS tasty_bytes_sample_data.raw_pos;

---> set the schema context
USE SCHEMA tasty_bytes_sample_data.raw_pos;

---> create the Raw Menu Table
CREATE OR REPLACE TABLE tasty_bytes_sample_data.raw_pos.menu
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
);

---> create the Stage directly inside the RAW_POS schema to prevent cross-schema resolution errors
CREATE OR REPLACE STAGE tasty_bytes_sample_data.raw_pos.blob_stage
url = 's3://sfquickstarts/tastybytes/'
file_format = (type = csv skip_header = 1); 
-- Note: Added 'skip_header = 1' to avoid loading the CSV column header as a data row.

---> query the Stage to find the Menu CSV file
LIST @tasty_bytes_sample_data.raw_pos.blob_stage/raw_pos/menu/;

---> copy the Menu file into the Menu table
COPY INTO tasty_bytes_sample_data.raw_pos.menu
FROM @tasty_bytes_sample_data.raw_pos.blob_stage/raw_pos/menu/;

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
