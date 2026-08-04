-- Harmonized view creation for frostbyte_tasty_bytes
-- Co-authored with CoCo
/* --
harmonized view creation 
--*/

-- order_v view
CREATE OR REPLACE VIEW frostbyte_tasty_bytes.harmonized.orders_v
AS
SELECT
oh.order_id,
oh.truck_id,
oh.order_ts,
od.line_number,
m.truck_brand_name,
m.menu_type,
t.primary_city,
t.region,
t.country,
t.franchise_flag,
t.franchise_id,
f.first_name AS franchisee_first_name,
f.last_name AS franchisee_last_name,
l.location_id,
cl.customer_id,
cl.first_name,
cl.last_name,
cl.e_mail,
cl.phone_number,
cl.children_count,
cl.gender,
cl.marital_status,
od.menu_item_id,
m.menu_item_name,
od.quantity,
od.unit_price,
od.price,
oh.order_amount,
oh.order_tax_amount,
oh.order_discount_amount,
oh.order_total
FROM frostbyte_tasty_bytes.raw_pos.order_detail od
JOIN frostbyte_tasty_bytes.raw_pos.order_header oh
  ON od.order_id = oh.order_id
JOIN frostbyte_tasty_bytes.raw_pos.truck t
  ON oh.truck_id = t.truck_id
JOIN frostbyte_tasty_bytes.raw_pos.menu m
  ON od.menu_item_id = m.menu_item_id
JOIN frostbyte_tasty_bytes.raw_pos.franchise f
  ON t.franchise_id = f.franchise_id
JOIN frostbyte_tasty_bytes.raw_pos.location l
  ON oh.location_id = l.location_id
LEFT JOIN frostbyte_tasty_bytes.raw_customer.customer_loyalty cl
  ON oh.customer_id = cl.customer_id;

SELECT COUNT(*) FROM frostbyte_tasty_bytes.harmonized.orders_v;

CREATE OR REPLACE VIEW frostbyte_tasty_bytes.harmonized.brand_names
AS
SELECT truck_brand_name 
FROM frostbyte_tasty_bytes.raw_pos.menu;

SHOW VIEWS IN frostbyte_tasty_bytes.harmonized;

DROP VIEW frostbyte_tasty_bytes.harmonized.brand_names;
SHOW VIEWS IN frostbyte_tasty_bytes.harmonized;

DESCRIBE VIEW frostbyte_tasty_bytes.harmonized.orders_v;


/* --
Materialized View vs Regular View:
- A regular view is just a stored query; it re-executes the underlying SQL every time you query it.
- A materialized view pre-computes and stores the results, so queries read from cached data.
- Materialized views are faster to query but use storage and have restrictions:
    - Cannot contain joins (single table only)
    - Cannot use UDFs, HAVING, ORDER BY, LIMIT, or nested views
    - Snowflake automatically maintains (refreshes) them when base table data changes
- Use regular views for complex joins; use materialized views for expensive aggregations on a single table.
--*/

CREATE MATERIALIZED VIEW frostbyte_tasty_bytes.harmonized.brand_names_materialized_v2
AS
SELECT DISTINCT truck_brand_name 
FROM frostbyte_tasty_bytes.raw_pos.menu;

-- Query the materized view (reads from precomputed storage, not the base table)
SELECT * FROM frostbyte_tasty_bytes.harmonized.brand_names_materialized_v2;

-- SHOW VIEWS does not include materialized views
SHOW VIEWS IN frostbyte_tasty_bytes.harmonized;

-- Use SHOW MATERIALIZED VIEWS to see them
SHOW MATERIALIZED VIEWS IN frostbyte_tasty_bytes.harmonized;
SHOW DYNAMIC TABLES IN frostbyte_tasty_bytes.harmonized;

-- Reload menu data (the table was emptied by a previous CREATE OR REPLACE)
-- Use FORCE = TRUE because Snowflake skips files it has already loaded
COPY INTO frostbyte_tasty_bytes.raw_pos.menu
FROM @frostbyte_tasty_bytes.public.s3load/raw_pos/menu/
FILE_FORMAT = (FORMAT_NAME = frostbyte_tasty_bytes.public.csv_ff)
FORCE = TRUE;


--> Create secure views
-- Secure views hide the view definition from consumers, useful for data SHARING
-- The query text and logic are not visible even to users with access to the view

CREATE OR REPLACE SECURE VIEW frostbyte_tasty_bytes.analytics.brand_names_secure
AS
SELECT DISTINCT truck_brand_name
FROM frostbyte_tasty_bytes.raw_pos.menu;

---> Query secure views
-- Querying a secure view works exactly like a regular view
SELECT * FROM frostbyte_tasty_bytes.analytics.brand_names_secure;

-- Assessment 
CREATE OR REPLACE VIEW frostbyte_tasty_bytes.harmonized.truck_franchise
AS
SELECT
    t.*,
    f.first_name AS franchisee_first_name,
    f.last_name AS franchisee_last_name
FROM frostbyte_tasty_bytes.raw_pos.truck t
JOIN frostbyte_tasty_bytes.raw_pos.franchise f
    ON t.franchise_id = f.franchise_id;

SELECT * FROM frostbyte_tasty_bytes.harmonized.truck_franchise;

DESCRIBE VIEW frostbyte_tasty_bytes.harmonized.truck_franchise;
DROP VIEW frostbyte_tasty_bytes.harmonized.truck_franchise;

CREATE OR REPLACE DYNAMIC TABLE frostbyte_tasty_bytes.harmonized.truck_franchise_dynamic
TARGET_LAG = '1 hour'
WAREHOUSE = COMPUTE_WH
AS
SELECT
    t.*,
    f.first_name AS franchisee_first_name,
    f.last_name AS franchisee_last_name
FROM frostbyte_tasty_bytes.raw_pos.truck t
JOIN frostbyte_tasty_bytes.raw_pos.franchise f
    ON t.franchise_id = f.franchise_id;


CREATE OR REPLACE DYNAMIC TABLE test_database.test_schema.nissan 
TARGET_LAG = '5 minutes' 
WAREHOUSE = compute_wh 
AS SELECT t.* 
FROM tasty_bytes.raw_pos.truck t 
WHERE t.make = 'Nissan';

SELECT COUNT(*) AS num_rows from test_database.test_schema.nissan;

DROP DYNAMIC TABLE test_database.test_schema.nissan;