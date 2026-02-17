/*******************************************************************************
 * SCRIPT: 01_bronze_load.sql
 * PURPOSE: Load clean CSV data into Bronze layer tables using BULK INSERT.
 *
 * ASSUMPTIONS:
 *   - SQL Server is running locally
 *   - CSV files exist in the specified folder
 *   - Files were generated using the Python dataset generator
 *
 * DATA FOLDER:
 *   C:\Users\sunda\Desktop\Session 3 Content Data Analytics Bootcamp\
 *
 * FILES EXPECTED:
 *   Customers.csv
 *   Products.csv
 *   Orders.csv
 *   OrderLines.csv
 *   Payments.csv
 *   Returns.csv
 *   Campaigns.csv
 *
 * HOW TO RUN:
 *   1. Ensure CSV files exist in the folder above
 *   2. Open this script in SSMS
 *   3. Execute entire script (F5)
 *
 * HOW TO VALIDATE:
 *   - Row counts printed at the bottom
 *******************************************************************************/

USE RetailAnalyticsDB;
GO

PRINT 'Starting Bronze data load...';
PRINT '';

-- ============================================================================
-- CUSTOMERS
-- ============================================================================
PRINT 'Loading bronze.Customers...';

BULK INSERT bronze.Customers
FROM 'C:\Users\sunda\Desktop\Session 3 Content Data Analytics Bootcamp\Customers.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

PRINT '✓ Customers loaded';
PRINT '';

-- ============================================================================
-- PRODUCTS
-- ============================================================================
PRINT 'Loading bronze.Products...';

BULK INSERT bronze.Products
FROM 'C:\Users\sunda\Desktop\Session 3 Content Data Analytics Bootcamp\Products.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

PRINT '✓ Products loaded';
PRINT '';

-- ============================================================================
-- ORDERS
-- ============================================================================
PRINT 'Loading bronze.Orders...';

BULK INSERT bronze.Orders
FROM 'C:\Users\sunda\Desktop\Session 3 Content Data Analytics Bootcamp\Orders.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

PRINT '✓ Orders loaded';
PRINT '';

-- ============================================================================
-- ORDER LINES
-- ============================================================================
PRINT 'Loading bronze.OrderLines...';

BULK INSERT bronze.OrderLines
FROM 'C:\Users\sunda\Desktop\Session 3 Content Data Analytics Bootcamp\OrderLines.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

PRINT '✓ OrderLines loaded';
PRINT '';

-- ============================================================================
-- PAYMENTS
-- ============================================================================
PRINT 'Loading bronze.Payments...';

BULK INSERT bronze.Payments
FROM 'C:\Users\sunda\Desktop\Session 3 Content Data Analytics Bootcamp\Payments.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

PRINT '✓ Payments loaded';
PRINT '';

-- ============================================================================
-- RETURNS
-- ============================================================================
PRINT 'Loading bronze.Returns...';

BULK INSERT bronze.Returns
FROM 'C:\Users\sunda\Desktop\Session 3 Content Data Analytics Bootcamp\Returns.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

PRINT '✓ Returns loaded';
PRINT '';

-- ============================================================================
-- CAMPAIGNS
-- ============================================================================
PRINT 'Loading bronze.Campaigns...';

BULK INSERT bronze.Campaigns
FROM 'C:\Users\sunda\Desktop\Session 3 Content Data Analytics Bootcamp\Campaigns.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

PRINT '✓ Campaigns loaded';
PRINT '';

-- ============================================================================
-- VALIDATION SECTION
-- ============================================================================
PRINT '==============================================================';
PRINT 'VALIDATION: ROW COUNTS IN BRONZE TABLES';
PRINT '==============================================================';

SELECT 'Customers'   AS TableName, COUNT(*) AS [RowCount] FROM bronze.Customers
UNION ALL
SELECT 'Products',    COUNT(*) FROM bronze.Products
UNION ALL
SELECT 'Orders',      COUNT(*) FROM bronze.Orders
UNION ALL
SELECT 'OrderLines',  COUNT(*) FROM bronze.OrderLines
UNION ALL
SELECT 'Payments',    COUNT(*) FROM bronze.Payments
UNION ALL
SELECT 'Returns',     COUNT(*) FROM bronze.Returns
UNION ALL
SELECT 'Campaigns',   COUNT(*) FROM bronze.Campaigns;

PRINT '';
PRINT '==============================================================';
PRINT 'BRONZE LOAD COMPLETE';
PRINT 'NEXT STEP: Run 02_silver_transform.sql';
PRINT '==============================================================';
GO