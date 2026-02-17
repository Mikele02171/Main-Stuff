SET NOCOUNT ON;

PRINT '========================================================================';
PRINT 'SILVER LAYER – FULL RESET AND LOAD';
PRINT '========================================================================';

---------------------------------------------------------
-- 1. DROP SILVER TABLES
---------------------------------------------------------
DROP TABLE IF EXISTS silver.Campaigns;
DROP TABLE IF EXISTS silver.Customers;
DROP TABLE IF EXISTS silver.OrderLines;
DROP TABLE IF EXISTS silver.Orders;
DROP TABLE IF EXISTS silver.Payments;
DROP TABLE IF EXISTS silver.Products;
DROP TABLE IF EXISTS silver.Returns;

PRINT 'Silver tables dropped';

---------------------------------------------------------
-- 2. RECREATE SILVER TABLES (CORRECT SCHEMA)
---------------------------------------------------------

-- Customers
CREATE TABLE silver.Customers (
    CustomerID        NVARCHAR(50) NOT NULL,
    CustomerName      NVARCHAR(255),
    Email             NVARCHAR(255),
    Phone             NVARCHAR(50),
    Address           NVARCHAR(255),
    City              NVARCHAR(100),
    State             NVARCHAR(50),
    PostalCode        NVARCHAR(20),
    Country           NVARCHAR(100),
    Segment           NVARCHAR(100),
    RegistrationDate  DATE
);

-- Products
CREATE TABLE silver.Products (
    ProductID     NVARCHAR(50) NOT NULL,
    ProductCode   NVARCHAR(50),
    ProductName   NVARCHAR(255),
    Category      NVARCHAR(100),
    Subcategory   NVARCHAR(100),
    UnitPrice     DECIMAL(10,2),
    UnitCost      DECIMAL(10,2)
);

-- Orders
CREATE TABLE silver.Orders (
    OrderID     NVARCHAR(50) NOT NULL,
    CustomerID  NVARCHAR(50),
    OrderDate   DATE,
    ShipDate    DATE,
    ShipMode    NVARCHAR(50),
    Status      NVARCHAR(50)
);

-- OrderLines
CREATE TABLE silver.OrderLines (
    OrderLineID NVARCHAR(50) NOT NULL,
    OrderID     NVARCHAR(50),
    ProductID   NVARCHAR(50),
    Quantity    INT,
    UnitPrice   DECIMAL(10,2),
    Discount    DECIMAL(10,2)
);

-- Payments
CREATE TABLE silver.Payments (
    PaymentID     NVARCHAR(50) NOT NULL,
    OrderID       NVARCHAR(50),
    PaymentDate   DATE,
    PaymentMethod NVARCHAR(50),
    Amount        DECIMAL(10,2)
);

-- Returns
CREATE TABLE silver.Returns (
    ReturnID       NVARCHAR(50) NOT NULL,
    OrderID        NVARCHAR(50),
    ProductID      NVARCHAR(50),
    ReturnDate     DATE,
    ReturnReason   NVARCHAR(255),
    ReturnQuantity INT
);

-- Campaigns
CREATE TABLE silver.Campaigns (
    CampaignID   NVARCHAR(50) NOT NULL,
    CampaignName NVARCHAR(255),
    StartDate    DATE,
    EndDate      DATE,
    Channel      NVARCHAR(100),
    Budget       DECIMAL(12,2),
    ProductID    NVARCHAR(50)
);

PRINT 'Silver tables created';

---------------------------------------------------------
-- 3. LOAD SILVER TABLES
---------------------------------------------------------

-- Customers
INSERT INTO silver.Customers
SELECT
    LTRIM(RTRIM(CustomerID)),
    LTRIM(RTRIM(CustomerName)),
    LOWER(LTRIM(RTRIM(Email))),
    LTRIM(RTRIM(Phone)),
    LTRIM(RTRIM(Address)),
    LTRIM(RTRIM(City)),
    UPPER(LTRIM(RTRIM(State))),
    LTRIM(RTRIM(PostalCode)),
    LTRIM(RTRIM(Country)),
    LTRIM(RTRIM(Segment)),
    TRY_CONVERT(DATE, RegistrationDate)
FROM bronze.Customers;

PRINT 'silver.Customers (' + CAST(@@ROWCOUNT AS VARCHAR(20)) + ')';

-- Products
INSERT INTO silver.Products
SELECT
    LTRIM(RTRIM(ProductID)),
    LTRIM(RTRIM(ProductCode)),
    LTRIM(RTRIM(ProductName)),
    LTRIM(RTRIM(Category)),
    LTRIM(RTRIM(Subcategory)),
    TRY_CONVERT(DECIMAL(10,2), UnitPrice),
    TRY_CONVERT(DECIMAL(10,2), UnitCost)
FROM bronze.Products;

PRINT 'silver.Products (' + CAST(@@ROWCOUNT AS VARCHAR(20)) + ')';

-- Orders
INSERT INTO silver.Orders
SELECT
    LTRIM(RTRIM(OrderID)),
    LTRIM(RTRIM(CustomerID)),
    TRY_CONVERT(DATE, OrderDate),
    TRY_CONVERT(DATE, ShipDate),
    LTRIM(RTRIM(ShipMode)),
    LTRIM(RTRIM(Status))
FROM bronze.Orders;

PRINT 'silver.Orders (' + CAST(@@ROWCOUNT AS VARCHAR(20)) + ')';

-- OrderLines
INSERT INTO silver.OrderLines
SELECT
    LTRIM(RTRIM(OrderLineID)),
    LTRIM(RTRIM(OrderID)),
    LTRIM(RTRIM(ProductID)),
    TRY_CONVERT(INT, Quantity),
    TRY_CONVERT(DECIMAL(10,2), UnitPrice),
    TRY_CONVERT(DECIMAL(10,2), Discount)
FROM bronze.OrderLines;

PRINT 'silver.OrderLines (' + CAST(@@ROWCOUNT AS VARCHAR(20)) + ')';

-- Payments
INSERT INTO silver.Payments
SELECT
    LTRIM(RTRIM(PaymentID)),
    LTRIM(RTRIM(OrderID)),
    TRY_CONVERT(DATE, PaymentDate),
    LTRIM(RTRIM(PaymentMethod)),
    TRY_CONVERT(DECIMAL(10,2), Amount)
FROM bronze.Payments;

PRINT 'silver.Payments (' + CAST(@@ROWCOUNT AS VARCHAR(20)) + ')';

-- Returns
INSERT INTO silver.Returns
SELECT
    LTRIM(RTRIM(ReturnID)),
    LTRIM(RTRIM(OrderID)),
    LTRIM(RTRIM(ProductID)),
    TRY_CONVERT(DATE, ReturnDate),
    LTRIM(RTRIM(ReturnReason)),
    TRY_CONVERT(INT, ReturnQuantity)
FROM bronze.Returns;

PRINT 'silver.Returns (' + CAST(@@ROWCOUNT AS VARCHAR(20)) + ')';

-- Campaigns
INSERT INTO silver.Campaigns
SELECT
    LTRIM(RTRIM(CampaignID)),
    LTRIM(RTRIM(CampaignName)),
    TRY_CONVERT(DATE, StartDate),
    TRY_CONVERT(DATE, EndDate),
    LTRIM(RTRIM(Channel)),
    TRY_CONVERT(DECIMAL(12,2), Budget),
    LTRIM(RTRIM(ProductID))
FROM bronze.Campaigns;

PRINT 'silver.Campaigns (' + CAST(@@ROWCOUNT AS VARCHAR(20)) + ')';

PRINT '========================================================================';
PRINT 'SILVER LAYER COMPLETE – SUCCESS';
PRINT '========================================================================';
