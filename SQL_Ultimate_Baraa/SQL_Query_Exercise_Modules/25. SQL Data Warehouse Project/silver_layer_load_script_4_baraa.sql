-- === FOR THE SILVER ERP CUST AZ12 === 
IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE silver.erp_cust_az12;
GO

CREATE TABLE silver.erp_cust_az12 (
    cid             NVARCHAR(50),
    bdate           DATE,
    gen             NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

INSERT INTO silver.erp_cust_az12
(
cid,
bdate,
gen
)
SELECT
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
     ELSE cid
END cid,
CASE WHEN bdate > GETDATE() THEN NULL
     ELSE bdate
END bdate, -- Set future birthdates to NULL
CASE WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
     WHEN UPPER(TRIM(gen)) IN ('M','Male') THEN 'Male'
     ELSE 'n/a'
END gen -- Normalize gender values and handle unknown cases
FROM bronze.erp_cust_az12

-- Identify Out-Of-Range Dates

SELECT
DISTINCT bdate 
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()  
-- Check for very old customers or birthdays in the future

-- Date Standardization and Consistency
SELECT
DISTINCT gen 
FROM bronze.erp_cust_az12



-- After transforming
-- Identify Out-Of-Range Dates

SELECT
DISTINCT bdate 
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()  
-- Check for very old customers or birthdays in the future

-- Date Standardization and Consistency
SELECT
DISTINCT gen 
FROM silver.erp_cust_az12

-- See the Silver Table for ERP Customers AZ12
SELECT * FROM silver.erp_cust_az12


-- === FOR THE SILVER ERP LOC A101 === 
IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE silver.erp_loc_a101;
GO

CREATE TABLE silver.erp_loc_a101 (
    cid             NVARCHAR(50),
    cntry           NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

INSERT INTO silver.erp_loc_a101(
cid,
cntry
)
select 
REPLACE(cid,'-','') cid,
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
ELSE TRIM(cntry) 
END AS cntry -- Normalize and Handle missing or blank country codes.
FROM bronze.erp_loc_a101;

-- Data Standardization and Consistency
SELECT DISTINCT cntry
FROM bronze.erp_loc_a101
ORDER BY cntry;

-- After transformation
-- Data Standardization and Consistency
SELECT DISTINCT cntry
FROM silver.erp_loc_a101
ORDER BY cntry;

-- See the Silver Table for ERP Locations A101
SELECT * FROM silver.erp_loc_a101;


-- === FOR THE SILVER ERP PX CAT G1V@ === 
IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE silver.erp_px_cat_g1v2;
GO

CREATE TABLE silver.erp_px_cat_g1v2 (
    id              NVARCHAR(50),
    cat             NVARCHAR(50),
    subcat          NVARCHAR(50),
    maintenance     NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

INSERT silver.erp_px_cat_g1v2(
id,
cat,
subcat,
maintenance
)
SELECT 
id,
cat,
subcat,
maintenance
FROM bronze.erp_px_cat_g1v2

-- Check for unwanted spaces
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)

-- Data Standardization and Consistency
SELECT DISTINCT
subcat
FROM bronze.erp_px_cat_g1v2


SELECT DISTINCT
maintenance
FROM bronze.erp_px_cat_g1v2


-- After transformation
-- Check for unwanted spaces
SELECT * FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)

-- Data Standardization and Consistency
SELECT DISTINCT
subcat
FROM silver.erp_px_cat_g1v2


SELECT DISTINCT
maintenance
FROM silver.erp_px_cat_g1v2

-- See the Silver Table for ERP PX CAT G1V2
SELECT * FROM silver.erp_px_cat_g1v2;