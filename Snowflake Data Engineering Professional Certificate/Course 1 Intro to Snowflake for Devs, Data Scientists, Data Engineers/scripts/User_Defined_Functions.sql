-- SQL and Python UDF examples for frostbyte_tasty_bytes
-- Co-authored with CoCo
-- PART I
SELECT ABS(-14);
SELECT UPPER('upper');
SHOW FUNCTIONS;
SELECT MAX(SALE_PRICE_USD) FROM FROSTBYTE_TASTY_BYTES.RAW_POS.MENU;

USE DATABASE FROSTBYTE_TASTY_BYTES;

CREATE FUNCTION max_menu_price()
RETURNS NUMBER(5,2)
AS
$$
 SELECT MAX(SALE_PRICE_USD) FROM FROSTBYTE_TASTY_BYTES.RAW_POS.MENU
$$;

select max_menu_price();

SHOW FUNCTIONS;
CREATE OR REPLACE FUNCTION max_menu_price_converted(USD_to_new NUMBER)
RETURNS NUMBER(5,2)
AS
$$
 SELECT USD_TO_NEW*MAX(SALE_PRICE_USD) FROM FROSTBYTE_TASTY_BYTES.RAW_POS.MENU
$$;

SELECT max_menu_price_converted(1.35);

-- PART II
CREATE FUNCTION winsorize (val NUMERIC, up_bound NUMERIC, low_bound NUMERIC)
returns NUMERIC
language python
runtime_version = '3.11'
handler = 'winsorize_py'
AS
$$
def winsorize_py(val,up_bound,low_bound):
    if val > up_bound:
        return up_bound
    elif val < low_bound:
        return low_bound
    else:
        return val
$$

SELECT winsorize(12.0,11.0,4.0);



CREATE OR REPLACE FUNCTION max_menu_price()
RETURNS NUMBER(5,2)
AS
$$
 SELECT MAX(SALE_PRICE_USD) FROM FROSTBYTE_TASTY_BYTES.RAW_POS.MENU
$$;

USE DATABASE FROSTBYTE_TASTY_BYTES;

CREATE FUNCTION menu_prices_above(price_floor NUMBER)
RETURNS TABLE (item VARCHAR, price NUMBER)
AS
$$
SELECT MENU_ITEM_NAME, SALE_PRICE_USD
FROM FROSTBYTE_TASTY_BYTES.RAW_POS.MENU
WHERE SALE_PRICE_USD > price_floor
ORDER BY 2 DESC
$$
;

SHOW FUNCTIONS;
SELECT * FROM TABLE(menu_prices_above(15));

-- Removes duplicates 
SELECT DISTINCT * FROM TABLE(menu_prices_above(15))
WHERE ITEM LIKE '%Chicken%';

-- ASSESSMENT 
SHOW FUNCTIONS;
CREATE OR REPLACE FUNCTION min_menu_price()
RETURNS NUMBER(5,2)
AS
$$
 SELECT MIN(SALE_PRICE_USD) FROM FROSTBYTE_TASTY_BYTES.RAW_POS.MENU
$$;

SELECT min_menu_price();
SHOW FUNCTIONS;


USE DATABASE TASTY_BYTES;

CREATE FUNCTION menu_prices_below(price_ceiling NUMBER)
RETURNS TABLE (item VARCHAR, price NUMBER)
AS
$$
SELECT MENU_ITEM_NAME, SALE_PRICE_USD
FROM FROSTBYTE_TASTY_BYTES.RAW_POS.MENU
WHERE SALE_PRICE_USD < price_ceiling
ORDER BY 2 DESC
$$
;

SELECT DISTINCT * FROM TABLE(menu_prices_below(3));
