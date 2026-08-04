-- Cloning examples and storage metrics for frostbyte_tasty_bytes
-- Co-authored with CoCo
CREATE OR REPLACE TABLE frostbyte_tasty_bytes.raw_pos.truck_clone
CLONE frostbyte_tasty_bytes.raw_pos.truck;

SELECT * FROM FROSTBYTE_TASTY_BYTES.INFORMATION_SCHEMA.TABLE_STORAGE_METRICS
WHERE TABLE_NAME = 'TRUCK_CLONE' OR TABLE_NAME = 'TRUCK';

SELECT * FROM FROSTBYTE_TASTY_BYTES.INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME = 'TRUCK_CLONE' OR TABLE_NAME = 'TRUCK';

INSERT INTO frostbyte_tasty_bytes.raw_pos.truck_clone
SELECT * FROM frostbyte_tasty_bytes.raw_pos.truck;

SELECT * FROM FROSTBYTE_TASTY_BYTES.INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = 'TRUCK_CLONE' OR TABLE_NAME = 'TRUCK';

CREATE OR REPLACE SCHEMA frostbyte_tasty_bytes.raw_pos_clone
CLONE frostbyte_tasty_bytes.raw_pos;

CREATE OR REPLACE DATABASE frostbyte_tasty_bytes_clone
CLONE frostbyte_tasty_bytes;

CREATE OR REPLACE TABLE frostbyte_tasty_bytes.raw_pos.truck_clone_time_travel
CLONE frostbyte_tasty_bytes.raw_pos.truck AT(OFFSET => -60*10);

SELECT * FROM frostbyte_tasty_bytes.raw_pos.truck_clone_time_travel;

-- ASSESSMENT 
CREATE DATABASE tasty_bytes_clone
CLONE tasty_bytes;

CREATE TABLE truck_clone
CLONE tasty_bytes.raw_pos.truck;

SELECT TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME, ACTIVE_BYTES 
FROM TASTY_BYTES_CLONE.INFORMATION_SCHEMA.TABLE_STORAGE_METRICS
WHERE (TABLE_NAME = 'TRUCK' AND TABLE_CATALOG = 'TASTY_BYTES' AND TABLE_SCHEMA = 'RAW_POS')
   OR (TABLE_NAME = 'TRUCK_CLONE' AND TABLE_CATALOG = 'TASTY_BYTES_CLONE' AND TABLE_SCHEMA = 'PUBLIC');