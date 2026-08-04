-- Time travel and cloning examples for frostbyte_tasty_bytes
-- Co-authored with CoCo
SHOW TABLES;
ALTER TABLE FROSTBYTE_TASTY_BYTES.RAW_POS.MENU SET DATA_RETENTION_TIME_IN_DAYS = 90;

SHOW TABLES;
ALTER TABLE FROSTBYTE_TASTY_BYTES.RAW_POS.MENU SET DATA_RETENTION_TIME_IN_DAYS = 1;

CREATE OR REPLACE TABLE frostbyte_tasty_bytes.raw_pos.truck_dev 
CLONE frostbyte_tasty_bytes.raw_pos.truck;

SELECT 
t.truck_id,
t.year,
t.make,
t.model
FROM frostbyte_tasty_bytes.raw_pos.truck_dev t;

-- Correct age calculation 
SELECT 
t.truck_id,
t.year,
t.make,
t.model,
(YEAR(CURRENT_DATE()) - t.year) AS truck_age
FROM frostbyte_tasty_bytes.raw_pos.truck_dev t;

-- Let's record the most recent query_id, back when the data was still correct
SET good_data_query_id = LAST_QUERY_ID();

SELECT $good_data_query_id;

-- Let's record the time, back when the data was still correct 
SET good_data_timestamp = CURRENT_TIMESTAMP;

SELECT $good_data_timestamp;

-- Confirm that worked
SHOW VARIABLES;

-- Intentionally wrong
SELECT 
t.truck_id,
t.year,
t.make,
t.model,
(YEAR(CURRENT_DATE())/t.year) AS truck_age
FROM frostbyte_tasty_bytes.raw_pos.truck_dev t;

-- Now let's mess up our data
UPDATE frostbyte_tasty_bytes.raw_pos.truck_dev t 
SET t.year = (YEAR(CURRENT_DATE())/t.year)

SELECT 
t.truck_id,
t.year,
t.make,
t.model
FROM frostbyte_tasty_bytes.raw_pos.truck_dev t;

SELECT * FROM frostbyte_tasty_bytes.raw_pos.truck_dev
AT(TIMESTAMP => $good_data_timestamp);

SELECT $good_data_timestamp;

-- Example code, without a timestamp inserted

-- SELECT * FROM frostbyte_tasty_bytes.raw_pos.truck_dev
-- AT(TIMESTAMP => '[INSERT TIMESTAMP]'::TIMESTAMP_LTZ);

SELECT * FROM frostbyte_tasty_bytes.raw_pos.truck_dev
AT(TIMESTAMP => $good_data_timestamp);

-- Let's calculate the right offset
SELECT * FROM frostbyte_tasty_bytes.raw_pos.truck_dev AT(OFFSET => -800);
SELECT $good_data_query_id;

SELECT * FROM FROSTBYTE_TASTY_BYTES.RAW_POS.TRUCK_DEV
BEFORE(STATEMENT => $good_data_query_id);

-- Assessment tIME TRAVEL 
SHOW VARIABLES;
SELECT * FROM frostbyte_tasty_bytes.raw_pos.truck_dev
AT(TIMESTAMP => $good_data_timestamp);

SELECT * FROM frostbyte_tasty_bytes.raw_pos.truck_dev
BEFORE(STATEMENT => $good_data_query_id)
WHERE truck_id = 2;

-- DROP truck_dev if not dropped previously 
DROP TABLE FROSTBYTE_TASTY_BYTES.RAW_POS.TRUCK_DEV;

CREATE TRANSIENT TABLE FROSTBYTE_TASTY_BYTES.RAW_POS.TRUCK_TRANSIENT 
CLONE FROSTBYTE_TASTY_BYTES.RAW_POS.TRUCK;

CREATE TEMPORARY TABLE FROSTBYTE_TASTY_BYTES.RAW_POS.TRUCK_TEMPORARY
CLONE FROSTBYTE_TASTY_BYTES.RAW_POS.TRUCK;

SHOW TABLES LIKE 'TRUCK%';
ALTER TABLE FROSTBYTE_TASTY_BYTES.RAW_POS.TRUCK SET DATA_RETENTION_TIME_IN_DAYS = 1;
ALTER TABLE FROSTBYTE_TASTY_BYTES.RAW_POS.TRUCK_TRANSIENT SET DATA_RETENTION_TIME_IN_DAYS = 1;
ALTER TABLE FROSTBYTE_TASTY_BYTES.RAW_POS.TRUCK_TEMPORARY SET DATA_RETENTION_TIME_IN_DAYS = 1;

SHOW TABLES LIKE 'TRUCK%';
ALTER TABLE FROSTBYTE_TASTY_BYTES.RAW_POS.TRUCK_TRANSIENT SET DATA_RETENTION_TIME_IN_DAYS = 0;
ALTER TABLE FROSTBYTE_TASTY_BYTES.RAW_POS.TRUCK_TEMPORARY SET DATA_RETENTION_TIME_IN_DAYS = 0;