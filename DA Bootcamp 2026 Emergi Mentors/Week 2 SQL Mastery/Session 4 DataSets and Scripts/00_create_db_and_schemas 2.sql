/*******************************************************************************
 * SCRIPT: 00_create_db_and_schemas.sql
 * PURPOSE: Create the RetailAnalyticsDB database and set up the Medallion 
 *          architecture (Bronze → Silver → Gold) with quarantine schema.
 * 
 * WHAT IT CREATES:
 *   - Database: RetailAnalyticsDB
 *   - Schemas: bronze, silver, gold, quarantine
 *   - Bronze tables (all columns NVARCHAR for safe landing):
 *       bronze.Customers, bronze.Products, bronze.Orders, bronze.OrderLines,
 *       bronze.Payments, bronze.Returns, bronze.Campaigns
 *
 * HOW TO RUN:
 *   1. Open this script in SQL Server Management Studio (SSMS)
 *   2. Ensure you're connected to your SQL Server instance
 *   3. Execute the entire script (F5)
 *
 * HOW TO VALIDATE:
 *   - Run the validation queries at the bottom of this script
 *   - Verify 4 schemas exist (bronze, silver, gold, quarantine)
 *   - Verify 7 bronze tables exist
 *
 * NOTES:
 *   - This script is idempotent (safe to run multiple times)
 *   - Database will be dropped and recreated if it exists
 *   - All bronze columns are NVARCHAR to accept any CSV data safely
 *******************************************************************************/

-- ============================================================================
-- SECTION 1: CREATE DATABASE
-- ============================================================================
USE master;
GO

-- Drop database if it exists (for clean re-runs)
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'RetailAnalyticsDB')
BEGIN
    PRINT 'Dropping existing RetailAnalyticsDB database...';
    ALTER DATABASE RetailAnalyticsDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE RetailAnalyticsDB;
    PRINT 'Database dropped successfully.';
END
GO

-- Create new database
PRINT 'Creating RetailAnalyticsDB database...';
CREATE DATABASE RetailAnalyticsDB;
GO

PRINT 'Database created successfully.';
PRINT 'Switching to RetailAnalyticsDB context...';
USE RetailAnalyticsDB;
GO

-- ============================================================================
-- SECTION 2: CREATE SCHEMAS (Medallion Architecture)
-- ============================================================================

-- Bronze Schema: Raw landing zone (accepts all data as-is)
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'bronze')
BEGIN
    PRINT 'Creating schema: bronze';
    EXEC('CREATE SCHEMA bronze');
END
GO

-- Silver Schema: Cleaned, typed, deduplicated data
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'silver')
BEGIN
    PRINT 'Creating schema: silver';
    EXEC('CREATE SCHEMA silver');
END
GO

-- Gold Schema: Pre-aggregated marts for analysis
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'gold')
BEGIN
    PRINT 'Creating schema: gold';
    EXEC('CREATE SCHEMA gold');
END
GO

-- Quarantine Schema: Invalid/rejected records for investigation
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'quarantine')
BEGIN
    PRINT 'Creating schema: quarantine';
    EXEC('CREATE SCHEMA quarantine');
END
GO

PRINT 'All schemas created successfully.';
PRINT '';

-- ============================================================================
-- SECTION 3: CREATE BRONZE TABLES
-- ============================================================================
-- NOTE: All columns are NVARCHAR to safely accept any CSV data
--       Type conversion happens later in the Silver layer
-- ============================================================================

PRINT 'Creating Bronze tables...';

-- Bronze: Customers
-- Expected columns from Customers.csv
DROP TABLE IF EXISTS bronze.Customers;
CREATE TABLE bronze.Customers (
    CustomerID NVARCHAR(255),
    CustomerName NVARCHAR(255),
    Email NVARCHAR(255),
    Phone NVARCHAR(255),
    Address NVARCHAR(255),
    City NVARCHAR(255),
    State NVARCHAR(255),
    PostalCode NVARCHAR(255),
    Country NVARCHAR(255),
    Segment NVARCHAR(255),
    RegistrationDate NVARCHAR(255)
);
PRINT '  ✓ bronze.Customers created';

-- Bronze: Products
-- Expected columns from Products.csv
DROP TABLE IF EXISTS bronze.Products;
CREATE TABLE bronze.Products (
    ProductID NVARCHAR(255),
    ProductCode NVARCHAR(255),
    ProductName NVARCHAR(255),
    Category NVARCHAR(255),
    Subcategory NVARCHAR(255),
    UnitPrice NVARCHAR(255),
    UnitCost NVARCHAR(255)
);
PRINT '  ✓ bronze.Products created';

-- Bronze: Orders
-- Expected columns from Orders.csv
DROP TABLE IF EXISTS bronze.Orders;
CREATE TABLE bronze.Orders (
    OrderID NVARCHAR(255),
    CustomerID NVARCHAR(255),
    OrderDate NVARCHAR(255),
    ShipDate NVARCHAR(255),
    ShipMode NVARCHAR(255),
    Status NVARCHAR(255)
);
PRINT '  ✓ bronze.Orders created';

-- Bronze: OrderLines
-- Expected columns from OrderLines.csv
DROP TABLE IF EXISTS bronze.OrderLines;
CREATE TABLE bronze.OrderLines (
    OrderLineID NVARCHAR(255),
    OrderID NVARCHAR(255),
    ProductID NVARCHAR(255),
    Quantity NVARCHAR(255),
    UnitPrice NVARCHAR(255),
    Discount NVARCHAR(255)
);
PRINT '  ✓ bronze.OrderLines created';

-- Bronze: Payments
-- Expected columns from Payments.csv
DROP TABLE IF EXISTS bronze.Payments;
CREATE TABLE bronze.Payments (
    PaymentID NVARCHAR(255),
    OrderID NVARCHAR(255),
    PaymentDate NVARCHAR(255),
    PaymentMethod NVARCHAR(255),
    Amount NVARCHAR(255)
);
PRINT '  ✓ bronze.Payments created';

-- Bronze: Returns
-- Expected columns from Returns.csv
DROP TABLE IF EXISTS bronze.Returns;
CREATE TABLE bronze.Returns (
    ReturnID NVARCHAR(255),
    OrderID NVARCHAR(255),
    ProductID NVARCHAR(255),
    ReturnDate NVARCHAR(255),
    ReturnReason NVARCHAR(255),
    ReturnQuantity NVARCHAR(255)
);
PRINT '  ✓ bronze.Returns created';

-- Bronze: Campaigns
-- Expected columns from Campaigns.csv
DROP TABLE IF EXISTS bronze.Campaigns;
CREATE TABLE bronze.Campaigns (
    CampaignID NVARCHAR(255),
    CampaignName NVARCHAR(255),
    StartDate NVARCHAR(255),
    EndDate NVARCHAR(255),
    Channel NVARCHAR(255),
    Budget NVARCHAR(255),
    ProductID NVARCHAR(255)
);
PRINT '  ✓ bronze.Campaigns created';

PRINT '';
PRINT 'All Bronze tables created successfully.';
PRINT '';
PRINT '========================================================================';
PRINT 'DATABASE SETUP COMPLETE';
PRINT '========================================================================';
PRINT '';

-- ============================================================================
-- VALIDATION SECTION
-- ============================================================================
PRINT 'VALIDATION CHECKS:';
PRINT '-------------------';
PRINT '';

-- Check schemas exist
PRINT 'Schemas in RetailAnalyticsDB:';
SELECT name AS SchemaName
FROM sys.schemas
WHERE name IN ('bronze', 'silver', 'gold', 'quarantine')
ORDER BY name;
PRINT '';

-- Check bronze tables exist
PRINT 'Bronze tables created:';
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    (SELECT COUNT(*) 
     FROM INFORMATION_SCHEMA.COLUMNS c 
     WHERE c.TABLE_SCHEMA = t.TABLE_SCHEMA 
       AND c.TABLE_NAME = t.TABLE_NAME) AS ColumnCount
FROM INFORMATION_SCHEMA.TABLES t
WHERE TABLE_SCHEMA = 'bronze'
ORDER BY TABLE_NAME;
PRINT '';

-- Verify all bronze tables are empty (no data loaded yet)
PRINT 'Row counts in Bronze tables (should all be 0):';
SELECT 'Customers' AS TableName, COUNT(*) AS [RowCount] FROM bronze.Customers
UNION ALL SELECT 'Products', COUNT(*) FROM bronze.Products
UNION ALL SELECT 'Orders', COUNT(*) FROM bronze.Orders
UNION ALL SELECT 'OrderLines', COUNT(*) FROM bronze.OrderLines
UNION ALL SELECT 'Payments', COUNT(*) FROM bronze.Payments
UNION ALL SELECT 'Returns', COUNT(*) FROM bronze.Returns
UNION ALL SELECT 'Campaigns', COUNT(*) FROM bronze.Campaigns;
PRINT '';

PRINT '========================================================================';
PRINT 'NEXT STEP: Run 01_bronze_load.sql to load CSV data into Bronze tables';
PRINT '========================================================================';
GO