-- Check for Nulls or Duplicates in Primary Key
-- Expectation: No Result
USE DataWarehouse;
SELECT 
cst_id,
COUNT(*) as record_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for unwanted spaces
-- Expectation: No Results
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

-- Data Standardization and Consistency
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;

-- Check the Silver Table for Customers
SELECT * FROM silver.crm_cust_info;

