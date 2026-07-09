SELECT
*
FROM(
SELECT
*,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
FROM bronze.crm_cust_info)t WHERE flag_last = 1 -- Show no duplicates for customer id 


SELECT
*
FROM(
SELECT
*,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
FROM bronze.crm_cust_info WHERE cst_id IS NOT NULL)t 
WHERE flag_last = 1 -- Show no duplicates for customer id 


-- Check for unwanted Spaces
-- Expectation: No Results
SELECT cst_firstname 
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);




-- ===============================================
-- Inserting after cleaning Customer Data
-- ================================================
INSERT INTO silver.crm_cust_info (
cst_id,
cst_key,
cst_firstname,
cst_lastname,
cst_marital_status,
cst_gndr,
cst_create_date
)
SELECT
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_firstname,
TRIM(cst_lastname) AS cst_lastname,
CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female' 
     -- Apply UPPER() just in case mixed-case values 
     -- appear later in your column. Then apply TRIM() just in case spaces appear later in your column.
	 WHEN UPPER(TRIM(cst_gndr))  = 'M' THEN 'Male' 
	 ELSE 'n/a' 
END cst_gndr, -- Normalize gender va;ues to readable format
CASE WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married' 
     -- Apply UPPER() just in case mixed-case values 
     -- appear later in your column. Then apply TRIM() just in case spaces appear later in your column.
	 WHEN UPPER(TRIM(cst_marital_status))  = 'S' THEN 'Single' 
	 ELSE 'n/a'
END cst_marital_status, -- Normalize martial status values to readable format 
cst_create_date
FROM(
	SELECT
	*,
	ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
FROM bronze.crm_cust_info)t 
WHERE flag_last = 1 -- Select the most recent record per customer
