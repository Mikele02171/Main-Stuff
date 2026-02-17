SET NOCOUNT ON;
SET ANSI_WARNINGS OFF;

PRINT '========================================================================';
PRINT 'GOLD LAYER – ANALYTICS MART BUILD (CORRECTED)';
PRINT '========================================================================';

---------------------------------------------------------
-- DROP GOLD TABLES
---------------------------------------------------------
DROP TABLE IF EXISTS gold.CustomerRFM;
DROP TABLE IF EXISTS gold.MonthlySalesMart;
DROP TABLE IF EXISTS gold.DailySalesMart;
DROP TABLE IF EXISTS gold.ProductPerformanceMart;
DROP TABLE IF EXISTS gold.CustomerMart;

---------------------------------------------------------
-- CREATE GOLD TABLES
---------------------------------------------------------

CREATE TABLE gold.CustomerMart (
    CustomerID NVARCHAR(50),
    CustomerName NVARCHAR(255),
    Email NVARCHAR(255),
    Segment NVARCHAR(100),
    State NVARCHAR(50),
    RegistrationDate DATE,
    TotalOrders INT,
    TotalRevenue DECIMAL(18,2),
    AvgOrderValue DECIMAL(18,2),
    DaysSinceLastOrder INT
);

CREATE TABLE gold.ProductPerformanceMart (
    ProductID NVARCHAR(50),
    ProductName NVARCHAR(255),
    Category NVARCHAR(100),
    Subcategory NVARCHAR(100),
    TotalUnitsSold INT,
    TotalRevenue DECIMAL(18,2),
    AvgSellingPrice DECIMAL(18,2),
    TotalReturns INT,
    ReturnRate DECIMAL(10,2),
    PctOfTotalRevenue DECIMAL(10,2)
);

CREATE TABLE gold.DailySalesMart (
    SalesDate DATE,
    Revenue DECIMAL(18,2),
    TotalOrders INT,
    TotalCustomers INT
);

CREATE TABLE gold.MonthlySalesMart (
    SalesMonth DATE,
    [Year] INT,
    [Month] INT,
    MonthName NVARCHAR(50),
    Revenue DECIMAL(18,2),
    TotalOrders INT,
    AvgOrderValue DECIMAL(18,2)
);

CREATE TABLE gold.CustomerRFM (
    CustomerID NVARCHAR(50),
    CustomerName NVARCHAR(255),
    Email NVARCHAR(255),
    RecencyDays INT,
    Frequency INT,
    MonetaryValue DECIMAL(18,2),
    Segment NVARCHAR(50)
);

---------------------------------------------------------
-- BASE FACT (redeclared where needed)
---------------------------------------------------------

---------------------------------------------------------
-- CUSTOMER MART
---------------------------------------------------------
;WITH SalesFact AS (
    SELECT
        o.OrderID,
        o.CustomerID,
        o.OrderDate,
        ol.ProductID,
        ol.Quantity,
        COALESCE(ol.UnitPrice, p.UnitPrice) AS UnitPrice,
        COALESCE(ol.Discount, 0) AS Discount,
        CAST(
            ol.Quantity
            * COALESCE(ol.UnitPrice, p.UnitPrice)
            * (1 - COALESCE(ol.Discount, 0) / 100.0)
            AS DECIMAL(18,2)
        ) AS LineRevenue
    FROM silver.Orders o
    JOIN silver.OrderLines ol ON o.OrderID = ol.OrderID
    LEFT JOIN silver.Products p ON ol.ProductID = p.ProductID
    WHERE o.OrderDate IS NOT NULL
)
INSERT INTO gold.CustomerMart
SELECT
    c.CustomerID,
    c.CustomerName,
    c.Email,
    c.Segment,
    c.State,
    c.RegistrationDate,
    COUNT(DISTINCT f.OrderID),
    COALESCE(SUM(f.LineRevenue), 0),
    CAST(
        COALESCE(SUM(f.LineRevenue), 0) /
        NULLIF(COUNT(DISTINCT f.OrderID), 0)
        AS DECIMAL(18,2)
    ),
    DATEDIFF(DAY, MAX(f.OrderDate), CAST(GETDATE() AS DATE))
FROM silver.Customers c
LEFT JOIN SalesFact f ON c.CustomerID = f.CustomerID
GROUP BY
    c.CustomerID,
    c.CustomerName,
    c.Email,
    c.Segment,
    c.State,
    c.RegistrationDate;

---------------------------------------------------------
-- DAILY SALES MART
---------------------------------------------------------
;WITH SalesFact AS (
    SELECT
        o.OrderID,
        o.CustomerID,
        o.OrderDate,
        CAST(
            ol.Quantity
            * COALESCE(ol.UnitPrice, p.UnitPrice)
            * (1 - COALESCE(ol.Discount, 0) / 100.0)
            AS DECIMAL(18,2)
        ) AS LineRevenue
    FROM silver.Orders o
    JOIN silver.OrderLines ol ON o.OrderID = ol.OrderID
    LEFT JOIN silver.Products p ON ol.ProductID = p.ProductID
    WHERE o.OrderDate IS NOT NULL
)
INSERT INTO gold.DailySalesMart
SELECT
    OrderDate,
    SUM(LineRevenue),
    COUNT(DISTINCT OrderID),
    COUNT(DISTINCT CustomerID)
FROM SalesFact
GROUP BY OrderDate;

---------------------------------------------------------
-- MONTHLY SALES MART
---------------------------------------------------------
INSERT INTO gold.MonthlySalesMart
SELECT
    DATEFROMPARTS(YEAR(SalesDate), MONTH(SalesDate), 1),
    YEAR(SalesDate),
    MONTH(SalesDate),
    DATENAME(MONTH, SalesDate),
    SUM(Revenue),
    SUM(TotalOrders),
    CAST(SUM(Revenue) / NULLIF(SUM(TotalOrders), 0) AS DECIMAL(18,2))
FROM gold.DailySalesMart
GROUP BY
    YEAR(SalesDate),
    MONTH(SalesDate),
    DATENAME(MONTH, SalesDate);

---------------------------------------------------------
-- PRODUCT PERFORMANCE MART
---------------------------------------------------------
;WITH SalesFact AS (
    SELECT
        ol.ProductID,
        ol.Quantity,
        CAST(
            ol.Quantity
            * COALESCE(ol.UnitPrice, p.UnitPrice)
            * (1 - COALESCE(ol.Discount, 0) / 100.0)
            AS DECIMAL(18,2)
        ) AS LineRevenue
    FROM silver.OrderLines ol
    LEFT JOIN silver.Products p ON ol.ProductID = p.ProductID
),
ProductAgg AS (
    SELECT
        ProductID,
        SUM(Quantity) AS UnitsSold,
        SUM(LineRevenue) AS Revenue
    FROM SalesFact
    GROUP BY ProductID
),
TotalRevenue AS (
    SELECT SUM(Revenue) AS GrandRevenue FROM ProductAgg
),
ReturnAgg AS (
    SELECT
        ProductID,
        SUM(ReturnQuantity) AS ReturnedUnits
    FROM silver.Returns
    GROUP BY ProductID
)
INSERT INTO gold.ProductPerformanceMart
SELECT
    p.ProductID,
    p.ProductName,
    p.Category,
    p.Subcategory,
    COALESCE(a.UnitsSold, 0),
    COALESCE(a.Revenue, 0),
    CAST(
        COALESCE(a.Revenue, 0) /
        NULLIF(a.UnitsSold, 0)
        AS DECIMAL(18,2)
    ),
    COALESCE(r.ReturnedUnits, 0),
    CAST(
        COALESCE(r.ReturnedUnits, 0) * 100.0 /
        NULLIF(a.UnitsSold, 0)
        AS DECIMAL(10,2)
    ),
    CAST(
        COALESCE(a.Revenue, 0) * 100.0 /
        NULLIF(t.GrandRevenue, 0)
        AS DECIMAL(10,2)
    )
FROM silver.Products p
LEFT JOIN ProductAgg a ON p.ProductID = a.ProductID
LEFT JOIN ReturnAgg r ON p.ProductID = r.ProductID
CROSS JOIN TotalRevenue t;

---------------------------------------------------------
-- CUSTOMER RFM
---------------------------------------------------------
INSERT INTO gold.CustomerRFM
SELECT
    CustomerID,
    CustomerName,
    Email,
    DaysSinceLastOrder,
    TotalOrders,
    TotalRevenue,
    CASE
        WHEN TotalOrders = 0 THEN 'No Purchases'
        WHEN DaysSinceLastOrder <= 60 AND TotalOrders >= 10 THEN 'Champions'
        WHEN DaysSinceLastOrder <= 90 AND TotalOrders >= 5 THEN 'Loyal Customers'
        WHEN DaysSinceLastOrder <= 60 THEN 'Recent Customers'
        WHEN DaysSinceLastOrder <= 120 THEN 'Potential Loyalists'
        WHEN DaysSinceLastOrder <= 180 THEN 'At Risk'
        ELSE 'Churned'
    END
FROM gold.CustomerMart;

SET ANSI_WARNINGS ON;

PRINT '========================================================================';
PRINT 'GOLD LAYER COMPLETE – CORRECT & DQL READY';
PRINT '========================================================================';