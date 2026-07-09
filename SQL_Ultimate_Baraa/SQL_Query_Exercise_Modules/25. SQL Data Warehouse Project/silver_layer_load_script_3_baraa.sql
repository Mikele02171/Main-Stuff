INSERT INTO silver.crm_sales_details
(
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_price,
sls_quantity,
sls_sales
)
SELECT 
sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
	 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
END AS sls_order_dt,
CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
	 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
END AS sls_ship_dt,
CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
	 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
END AS sls_due_dt,
CASE WHEN sls_price IS NULL OR sls_price <= 0
     THEN sls_sales / NULLIF(sls_quantity,0)
	 ELSE sls_price
END AS sls_price, -- Derive price if original value is invalid.
CASE WHEN sls_quantity IS NULL or sls_quantity < 0
     THEN 0
	 ELSE sls_quantity
END AS sls_quantity,
CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
     THEN sls_quantity * ABS(sls_price)
	 ELSE sls_sales -- Recalculate sales if original value is missing or incorrect
END AS sls_sales
FROM bronze.crm_sales_details;

--NOTE: Order Date must always be earlier than the Shipping Date or Due Date

-- Check for Invalid Dates
SELECT
NULLIF(sls_order_dt,0) sls_order_dt
-- In this scenario, the length of the date must be 8.
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 -- Negative numbers or zeros can't be cast to a date. 
OR LEN(sls_order_dt) != 8 
OR sls_order_dt > 20500101
OR sls_order_dt < 19000101
-- Check for outliers by validating the boundaries
-- of the date range.


-- Check for Invalid Date Orders
SELECT
*
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- Check Data Consistency: Between Sales, Quantity, and Price
-- >> Sales = Quantity * Price
-- >> Values must not be NULL, zero, or negative.

SELECT DISTINCT 
sls_sales,
sls_quantity,
sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <=0 
ORDER BY sls_sales,sls_quantity, sls_price

--1 Solution: Data Issues will be fixed direct in source system
--2 Solution: Data Issues has to be fixed in the data warehouse

-- RULES: If Sales is negative, zero, or null, derive it using
-- Quantity and Price
-- If Price is zero or null, calculate it using Sales and Quantity.
-- If Price is negative, convert it to a positive value

-- After Updating 
-- Check for the Invalid Date Orders
SELECT
*
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt


-- Check Data Consistency: Between Sales, Quantity, and Price
-- >> Sales = Quantity * Price
-- >> Values must not be NULL, zero, or negative.

SELECT DISTINCT 
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <=0 
ORDER BY sls_sales,sls_quantity, sls_price

-- See the Silver Table for Sales Details
SELECT * FROM silver.crm_sales_details
