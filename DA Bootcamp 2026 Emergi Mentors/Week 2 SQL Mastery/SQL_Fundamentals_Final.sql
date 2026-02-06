/*******************************************************************************
 * SCRIPT: SQL_FUNDAMENTALS_FOR_DATA_ANALYSTS.sql
 * PURPOSE: Complete SQL fundamentals reference for Data Analysts and Junior
 *          Data Engineers. Master these concepts before Session 3 scripts.
 * 
 * TARGET AUDIENCE:
 *   - Data Analysts transitioning to SQL
 *   - Junior Data Engineers learning SQL Server
 *   - Anyone preparing for SQL technical interviews
 *
 * HOW TO USE THIS SCRIPT:
 *   - Read sequentially (builds from basics to advanced)
 *   - Execute examples in SSMS to see results
 *   - Practice modifying examples with your own variations
 *   - Return to this as a reference guide
 *
 * COVERAGE:
 *   ✓ SQL Server Basics (databases, schemas, tables)
 *   ✓ DDL (CREATE, ALTER, DROP)
 *   ✓ DML (INSERT, UPDATE, DELETE)
 *   ✓ DQL (SELECT - the heart of analytics)
 *   ✓ Filtering (WHERE, AND, OR, NOT, IN, BETWEEN, LIKE)
 *   ✓ Sorting (ORDER BY)
 *   ✓ Aggregations (COUNT, SUM, AVG, MIN, MAX)
 *   ✓ Grouping (GROUP BY, HAVING)
 *   ✓ Joins (INNER, LEFT, RIGHT, FULL, CROSS)
 *   ✓ Subqueries (scalar, correlated, derived tables)
 *   ✓ CTEs (Common Table Expressions)
 *   ✓ Window Functions (ROW_NUMBER, RANK, NTILE, running totals)
 *   ✓ Data Types (numeric, text, date/time, conversion)
 *   ✓ NULL handling (IS NULL, ISNULL, COALESCE)
 *   ✓ String functions (CONCAT, SUBSTRING, UPPER, LOWER, TRIM)
 *   ✓ Date functions (DATEADD, DATEDIFF, DATEPART, FORMAT)
 *   ✓ Conditional logic (CASE, IIF)
 *   ✓ Set operations (UNION, INTERSECT, EXCEPT)
 *   ✓ Constraints (PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK)
 *   ✓ Indexes (basics and when to use)
 *   ✓ Transaction control (BEGIN, COMMIT, ROLLBACK)
 *   ✓ Common mistakes and how to avoid them
 *
 * INTERVIEW TOPICS COVERED:
 *   ✓ Find duplicate records
 *   ✓ Find top N records per group
 *   ✓ Calculate running totals
 *   ✓ Compare values to previous/next row
 *   ✓ Handle missing data (NULLs)
 *   ✓ Date calculations (YTD, month-over-month)
 *   ✓ Self-joins
 *   ✓ Pivot/unpivot concepts
 *
 * PREREQUISITES:
 *   - SQL Server installed (Express or Developer edition)
 *   - SQL Server Management Studio (SSMS)
 *   - Basic computer literacy
 *
 * TIME TO COMPLETE:
 *   - 2-3 hours (reading + practicing examples)
 *
 *******************************************************************************/

-- ============================================================================
-- SECTION 0: CLEANUP (Makes script idempotent - safe to run multiple times)
-- ============================================================================
USE master;
GO

-- Drop database if exists
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'SQLFundamentals')
BEGIN
    PRINT 'Dropping existing SQLFundamentals database...';
    ALTER DATABASE SQLFundamentals SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SQLFundamentals;
    PRINT 'Database dropped successfully.';
END
GO

-- ============================================================================
-- SECTION 1: SQL SERVER BASICS - UNDERSTANDING THE HIERARCHY
-- ============================================================================
/*
SQL SERVER HIERARCHY (Top to Bottom):

    Server Instance
        └── Database (e.g., RetailDB)
            └── Schema (e.g., dbo, sales, staging)
                └── Tables, Views, Stored Procedures, Functions
                    └── Columns, Rows, Indexes, Constraints

ANALOGY:
    Server    = City
    Database  = Building
    Schema    = Floor
    Table     = Office
    Row       = Desk
    Column    = Drawer
*/

-- Create a practice database
PRINT 'Creating SQLFundamentals database...';
CREATE DATABASE SQLFundamentals;
GO

USE SQLFundamentals;
GO

-- Create schemas (organizational containers)
CREATE SCHEMA sales;
GO

CREATE SCHEMA hr;
GO

CREATE SCHEMA examples;  -- Add this
GO

/*
WHY USE SCHEMAS:
    - Organization (sales.Orders, hr.Employees)
    - Security (grant permissions per schema)
    - Avoid naming conflicts (sales.Customers, marketing.Customers)
*/

-- ============================================================================
-- SECTION 2: DDL (DATA DEFINITION LANGUAGE) - CREATING STRUCTURE
-- ============================================================================
/*
DDL COMMANDS:
    CREATE - Create new database objects
    ALTER  - Modify existing objects
    DROP   - Delete objects
    TRUNCATE - Remove all data (keep structure)
*/

-- CREATE TABLE: Define structure
CREATE TABLE sales.Customers (
    CustomerID INT PRIMARY KEY,           -- Primary key (unique identifier)
    FirstName NVARCHAR(50) NOT NULL,      -- NOT NULL = required field
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE,           -- UNIQUE = no duplicates allowed
    Phone NVARCHAR(20),
    DateOfBirth DATE,
    CreatedDate DATETIME DEFAULT GETDATE() -- DEFAULT = automatic value
);

CREATE TABLE sales.Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATE NOT NULL,
    TotalAmount DECIMAL(10, 2),
    Status NVARCHAR(20),
    -- Foreign key constraint (referential integrity)
    CONSTRAINT FK_Orders_Customers 
        FOREIGN KEY (CustomerID) 
        REFERENCES sales.Customers(CustomerID)
);

-- ALTER TABLE: Modify existing table
ALTER TABLE sales.Customers 
ADD LoyaltyPoints INT DEFAULT 0;

ALTER TABLE sales.Customers 
ADD CONSTRAINT CK_LoyaltyPoints_Positive 
    CHECK (LoyaltyPoints >= 0);

-- DROP TABLE: Delete table (careful!)
DROP TABLE IF EXISTS sales.TempTable;

-- TRUNCATE: Remove all data, keep structure
TRUNCATE TABLE sales.Orders;

-- ============================================================================
-- SECTION 3: DATA TYPES - CHOOSING THE RIGHT TYPE
-- ============================================================================
/*
NUMERIC TYPES:
    INT              -2 billion to +2 billion (4 bytes)
    BIGINT           Larger range (8 bytes)
    SMALLINT         -32K to +32K (2 bytes)
    TINYINT          0 to 255 (1 byte)
    DECIMAL(p,s)     Exact numeric (e.g., money)
    FLOAT            Approximate (scientific calculations)

TEXT TYPES:
    CHAR(n)          Fixed length (padded with spaces)
    VARCHAR(n)       Variable length (up to 8000 chars)
    NVARCHAR(n)      Unicode variable length (supports all languages)
    TEXT             Large text (deprecated, use VARCHAR(MAX))

DATE/TIME TYPES:
    DATE             Date only (YYYY-MM-DD)
    TIME             Time only (HH:MM:SS)
    DATETIME         Date + Time (precision: 3.33ms)
    DATETIME2        Date + Time (precision: 100ns) - recommended
    DATETIMEOFFSET   Date + Time + Timezone

BOOLEAN:
    BIT              0 or 1 (SQL Server has no true BOOLEAN type)

OTHER:
    UNIQUEIDENTIFIER GUID (globally unique identifier)
    VARBINARY(n)     Binary data (images, files)
    XML              XML documents
    JSON             Stored as NVARCHAR (validated with functions)
*/

-- Example: Choosing appropriate types
CREATE TABLE hr.Employees (
    EmployeeID INT PRIMARY KEY,                    -- INT: IDs
    FirstName NVARCHAR(50),                        -- NVARCHAR: Unicode names
    Salary DECIMAL(10, 2),                         -- DECIMAL: Exact money
    HireDate DATE,                                 -- DATE: No time needed
    LastLogin DATETIME2,                           -- DATETIME2: Precision timestamps
    IsActive BIT DEFAULT 1,                        -- BIT: Yes/No flag
    ProfilePicture VARBINARY(MAX)                  -- VARBINARY: Binary data
);

-- ============================================================================
-- SECTION 4: DML (DATA MANIPULATION LANGUAGE) - WORKING WITH DATA
-- ============================================================================
/*
DML COMMANDS:
    INSERT - Add new rows
    UPDATE - Modify existing rows
    DELETE - Remove rows
    SELECT - Retrieve rows (covered in detail later)
*/

-- INSERT: Add data (method 1 - specify columns)
INSERT INTO sales.Customers (CustomerID, FirstName, LastName, Email, Phone, DateOfBirth )
VALUES (1, 'John', 'Smith', 'john.smith@email.com', '555-0101','1970-01-01');

-- INSERT: Multiple rows at once
INSERT INTO sales.Customers (CustomerID, FirstName, LastName, Email, Phone,DateOfBirth )
VALUES 
    (2, 'Jane', 'Doe', 'jane.doe@email.com', '555-0102','1989-01-28'),
    (3, 'Bob', 'Johnson', 'bob.j@email.com', '555-0103', '1975-01-01'),
    (4, 'Alice', 'Williams', 'alice.w@email.com', '555-0104','1988-01-01');

-- INSERT: From SELECT (copy data from another table)
INSERT INTO sales.Orders (OrderID, CustomerID, OrderDate, TotalAmount, Status)
SELECT 1, 1, '2024-01-15', 150.00, 'Completed'
UNION ALL
SELECT 2, 1, '2024-02-20', 200.00, 'Completed'
UNION ALL
SELECT 3, 2, '2024-01-18', 75.50, 'Pending'
UNION ALL
SELECT 4, 3, '2024-03-10', 320.00, 'Completed'
UNION ALL
SELECT 5, 3, '2024-03-15', 125.00, 'Shipped';

-- UPDATE: Modify existing data
UPDATE sales.Customers
SET LoyaltyPoints = 100
WHERE CustomerID = 1;

-- UPDATE: Multiple columns
UPDATE sales.Orders
SET Status = 'Delivered',
    TotalAmount = TotalAmount * 1.1  -- 10% increase
WHERE OrderID = 2;

-- UPDATE: Using calculations
UPDATE sales.Customers
SET LoyaltyPoints = LoyaltyPoints + 50
WHERE CustomerID IN (1, 2, 3);

-- DELETE: Remove rows (careful - use WHERE!)
DELETE FROM sales.Orders
WHERE Status = 'Cancelled';

-- DELETE: With subquery
DELETE FROM sales.Customers
WHERE CustomerID NOT IN (SELECT DISTINCT CustomerID FROM sales.Orders);

/*
⚠️ CRITICAL WARNING:
    Always use WHERE clause with UPDATE/DELETE!
    
    ❌ UPDATE sales.Customers SET Phone = '000-0000';  -- Updates ALL rows!
    ✅ UPDATE sales.Customers SET Phone = '000-0000' WHERE CustomerID = 1;
*/

-- ============================================================================
-- SECTION 5: SELECT - THE FOUNDATION OF DATA ANALYSIS
-- ============================================================================

/*
SELECT BASIC SYNTAX:
    SELECT column1, column2
    FROM table
    WHERE conditions
    ORDER BY column;
*/

-- SELECT all columns (avoid in production - specify columns)
SELECT * FROM sales.Customers;

-- SELECT specific columns
SELECT CustomerID, FirstName, LastName, Email
FROM sales.Customers;

-- SELECT with column aliases
SELECT 
    CustomerID AS ID,
    FirstName + ' ' + LastName AS FullName,
    Email AS EmailAddress
FROM sales.Customers;

-- SELECT DISTINCT (unique values only)
SELECT DISTINCT Status
FROM sales.Orders;

-- SELECT TOP (limit results)
SELECT TOP 5 *
FROM sales.Orders
ORDER BY TotalAmount DESC;

-- SELECT TOP with PERCENT
SELECT TOP 10 PERCENT *
FROM sales.Orders
ORDER BY OrderDate DESC;

-- ============================================================================
-- SECTION 6: WHERE CLAUSE - FILTERING DATA
-- ============================================================================

-- Basic comparison operators: =, !=, <, >, <=, >=
SELECT * FROM sales.Orders WHERE TotalAmount > 100;
SELECT * FROM sales.Orders WHERE Status = 'Completed';
SELECT * FROM sales.Orders WHERE Status != 'Pending';
SELECT * FROM sales.Orders WHERE Status <> 'Pending';  -- Same as !=

-- Combining conditions: AND, OR, NOT
SELECT * FROM sales.Orders 
WHERE TotalAmount > 100 
  AND Status = 'Completed';

SELECT * FROM sales.Orders 
WHERE Status = 'Completed' 
   OR Status = 'Shipped';

SELECT * FROM sales.Orders 
WHERE NOT (Status = 'Cancelled');

-- IN operator (check against list)
SELECT * FROM sales.Orders 
WHERE Status IN ('Completed', 'Shipped', 'Delivered');

-- NOT IN (exclude list)
SELECT * FROM sales.Customers
WHERE CustomerID NOT IN (1, 2, 3);

-- BETWEEN (inclusive range)
SELECT * FROM sales.Orders
WHERE OrderDate BETWEEN '2024-01-01' AND '2024-03-31';

SELECT * FROM sales.Orders
WHERE TotalAmount BETWEEN 100 AND 500;

-- LIKE (pattern matching)
SELECT * FROM sales.Customers WHERE LastName LIKE 'S%';      -- Starts with S
SELECT * FROM sales.Customers WHERE Email LIKE '%@email.com'; -- Ends with
SELECT * FROM sales.Customers WHERE FirstName LIKE '%oh%';    -- Contains 'oh'
SELECT * FROM sales.Customers WHERE Phone LIKE '555-01__';    -- _ = single char

-- IS NULL / IS NOT NULL (testing for missing values)
SELECT * FROM sales.Customers WHERE Phone IS NULL;
SELECT * FROM sales.Customers WHERE Phone IS NOT NULL;

-- ⚠️ Common mistake: Cannot use = NULL
-- ❌ WHERE Phone = NULL      -- Wrong! Always returns no results
-- ✅ WHERE Phone IS NULL     -- Correct

-- ============================================================================
-- SECTION 7: ORDER BY - SORTING RESULTS
-- ============================================================================

-- ORDER BY single column (ascending by default)
SELECT * FROM sales.Orders
ORDER BY OrderDate;

-- ORDER BY descending
SELECT * FROM sales.Orders
ORDER BY TotalAmount DESC;

-- ORDER BY multiple columns
SELECT * FROM sales.Orders
ORDER BY Status ASC, TotalAmount DESC;

-- ORDER BY column position (avoid in production - use names)
SELECT CustomerID, FirstName, LastName FROM sales.Customers
ORDER BY 2, 3;  -- Orders by FirstName, then LastName

-- ORDER BY with calculation
SELECT 
    OrderID, 
    TotalAmount,
    TotalAmount * 0.9 AS DiscountedAmount
FROM sales.Orders
ORDER BY TotalAmount * 0.9 DESC;

-- ============================================================================
-- SECTION 8: AGGREGATE FUNCTIONS - SUMMARIZING DATA
-- ============================================================================

/*
COMMON AGGREGATE FUNCTIONS:
    COUNT(*)      - Count all rows
    COUNT(column) - Count non-NULL values
    SUM(column)   - Total of numeric values
    AVG(column)   - Average of numeric values
    MIN(column)   - Minimum value
    MAX(column)   - Maximum value
*/

-- COUNT: Total rows
SELECT COUNT(*) AS TotalOrders FROM sales.Orders;

-- COUNT: Non-NULL values
SELECT COUNT(Phone) AS CustomersWithPhone FROM sales.Customers;

-- COUNT DISTINCT: Unique values
SELECT COUNT(DISTINCT CustomerID) AS UniqueCustomers FROM sales.Orders;

-- SUM: Total
SELECT SUM(TotalAmount) AS TotalRevenue FROM sales.Orders;

-- AVG: Average
SELECT AVG(TotalAmount) AS AverageOrderValue FROM sales.Orders;

-- MIN and MAX
SELECT 
    MIN(TotalAmount) AS SmallestOrder,
    MAX(TotalAmount) AS LargestOrder,
    MAX(OrderDate) AS MostRecentOrder
FROM sales.Orders;

-- Multiple aggregates in one query
SELECT 
    COUNT(*) AS TotalOrders,
    COUNT(DISTINCT CustomerID) AS UniqueCustomers,
    SUM(TotalAmount) AS TotalRevenue,
    AVG(TotalAmount) AS AvgOrderValue,
    MIN(TotalAmount) AS MinOrder,
    MAX(TotalAmount) AS MaxOrder
FROM sales.Orders;

-- ============================================================================
-- SECTION 9: GROUP BY - AGGREGATING BY CATEGORY
-- ============================================================================

/*
GROUP BY RULE:
    Every column in SELECT must be either:
    1. In the GROUP BY clause, OR
    2. Inside an aggregate function (COUNT, SUM, AVG, etc.)
*/

-- Group by single column
SELECT 
    Status,
    COUNT(*) AS OrderCount,
    SUM(TotalAmount) AS TotalRevenue
FROM sales.Orders
GROUP BY Status;

-- Group by multiple columns
SELECT 
    CustomerID,
    Status,
    COUNT(*) AS OrderCount,
    AVG(TotalAmount) AS AvgOrderValue
FROM sales.Orders
GROUP BY CustomerID, Status
ORDER BY CustomerID, Status;

-- Group by with calculated columns
SELECT 
    YEAR(OrderDate) AS OrderYear,
    MONTH(OrderDate) AS OrderMonth,
    COUNT(*) AS OrderCount,
    SUM(TotalAmount) AS Revenue
FROM sales.Orders
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY OrderYear, OrderMonth;

-- ❌ Common mistake: Column not in GROUP BY
/*
SELECT 
    CustomerID, 
    FirstName,          -- ❌ Error! Not in GROUP BY or aggregate
    COUNT(*) 
FROM sales.Orders 
GROUP BY CustomerID;
*/

-- ============================================================================
-- SECTION 10: HAVING - FILTERING AGGREGATED RESULTS
-- ============================================================================

/*
WHERE vs HAVING:
    WHERE  - Filters rows BEFORE grouping/aggregation
    HAVING - Filters groups AFTER aggregation
*/

-- HAVING: Filter aggregated results
SELECT 
    CustomerID,
    COUNT(*) AS OrderCount,
    SUM(TotalAmount) AS TotalSpent
FROM sales.Orders
GROUP BY CustomerID
HAVING COUNT(*) >= 2;  -- Only customers with 2+ orders

-- WHERE + HAVING together
SELECT 
    CustomerID,
    COUNT(*) AS OrderCount,
    AVG(TotalAmount) AS AvgOrderValue
FROM sales.Orders
WHERE OrderDate >= '2024-01-01'     -- Filter rows BEFORE grouping
GROUP BY CustomerID
HAVING COUNT(*) >= 2                -- Filter groups AFTER aggregation
ORDER BY AvgOrderValue DESC;

-- HAVING with multiple conditions
SELECT 
    Status,
    COUNT(*) AS OrderCount,
    SUM(TotalAmount) AS TotalRevenue
FROM sales.Orders
GROUP BY Status
HAVING COUNT(*) >= 2 
   AND SUM(TotalAmount) > 200;

-- ============================================================================
-- SECTION 11: JOINS - COMBINING TABLES
-- ============================================================================

/*
JOIN TYPES:
    INNER JOIN - Only matching rows from both tables
    LEFT JOIN  - All from left table + matches from right
    RIGHT JOIN - All from right table + matches from left
    FULL JOIN  - All rows from both tables
    CROSS JOIN - Cartesian product (every combination)
*/

-- Setup: Add more data for join examples
INSERT INTO sales.Customers (CustomerID, FirstName, LastName, Email)
VALUES (5, 'Charlie', 'Brown', 'charlie@email.com');

-- INNER JOIN: Only customers with orders
SELECT 
    c.CustomerID,
    c.FirstName,
    c.LastName,
    o.OrderID,
    o.OrderDate,
    o.TotalAmount
FROM sales.Customers c
INNER JOIN sales.Orders o ON c.CustomerID = o.CustomerID
ORDER BY c.CustomerID, o.OrderDate;

/*
Result: Only customers 1, 2, 3 (who have orders)
        Customer 4 and 5 excluded (no orders)
*/

-- LEFT JOIN: All customers, even without orders
SELECT 
    c.CustomerID,
    c.FirstName,
    c.LastName,
    COUNT(o.OrderID) AS OrderCount,
    ISNULL(SUM(o.TotalAmount), 0) AS TotalSpent
FROM sales.Customers c
LEFT JOIN sales.Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName
ORDER BY c.CustomerID;

/*
Result: All 5 customers included
        Customers 4 and 5 show 0 orders, 0 spent
*/

-- RIGHT JOIN: All orders, even if customer deleted
-- (Less common - usually rewrite as LEFT JOIN)
SELECT 
    o.OrderID,
    o.OrderDate,
    c.FirstName,
    c.LastName
FROM sales.Orders o
RIGHT JOIN sales.Customers c ON o.CustomerID = c.CustomerID;

-- FULL OUTER JOIN: Everything from both tables
SELECT 
    c.CustomerID,
    c.FirstName,
    o.OrderID,
    o.TotalAmount
FROM sales.Customers c
FULL OUTER JOIN sales.Orders o ON c.CustomerID = o.CustomerID;

-- CROSS JOIN: Every combination (use carefully!)
-- Example: All customers × all order statuses
DROP TABLE IF EXISTS #Statuses;  -- Add this line
CREATE TABLE #Statuses (Status NVARCHAR(20));
INSERT INTO #Statuses VALUES ('Pending'), ('Completed'), ('Shipped');

SELECT 
    c.CustomerID,
    c.FirstName,
    s.Status
FROM sales.Customers c
CROSS JOIN #Statuses s
ORDER BY c.CustomerID, s.Status;

-- Multiple JOINs
CREATE TABLE sales.OrderItems (
    OrderItemID INT PRIMARY KEY,
    OrderID INT,
    ProductName NVARCHAR(100),
    Quantity INT,
    Price DECIMAL(10, 2)
);

INSERT INTO sales.OrderItems VALUES
(1, 1, 'Laptop', 1, 1200.00),
(2, 1, 'Mouse', 2, 25.00),
(3, 2, 'Monitor', 1, 350.00);

SELECT 
    c.FirstName,
    c.LastName,
    o.OrderID,
    o.OrderDate,
    oi.ProductName,
    oi.Quantity,
    oi.Price
FROM sales.Customers c
INNER JOIN sales.Orders o ON c.CustomerID = o.CustomerID
INNER JOIN sales.OrderItems oi ON o.OrderID = oi.OrderID
ORDER BY c.CustomerID, o.OrderID, oi.OrderItemID;

-- Self-JOIN: Compare rows within same table
-- Example: Find customers in same city
ALTER TABLE sales.Customers ADD City NVARCHAR(50);
UPDATE sales.Customers SET City = 'New York' WHERE CustomerID IN (1, 2);
UPDATE sales.Customers SET City = 'Boston' WHERE CustomerID IN (3, 4);

SELECT 
    c1.FirstName + ' ' + c1.LastName AS Customer1,
    c2.FirstName + ' ' + c2.LastName AS Customer2,
    c1.City
FROM sales.Customers c1
INNER JOIN sales.Customers c2 ON c1.City = c2.City AND c1.CustomerID < c2.CustomerID;

-- ============================================================================
-- SECTION 12: SUBQUERIES - QUERIES WITHIN QUERIES
-- ============================================================================

/*
SUBQUERY TYPES:
    1. Scalar subquery - Returns single value
    2. Multi-row subquery - Returns multiple rows (use with IN, EXISTS)
    3. Correlated subquery - References outer query
    4. Derived table - Subquery in FROM clause
*/

-- Scalar subquery: Returns single value
SELECT 
    OrderID,
    TotalAmount,
    (SELECT AVG(TotalAmount) FROM sales.Orders) AS OverallAvg,
    TotalAmount - (SELECT AVG(TotalAmount) FROM sales.Orders) AS DiffFromAvg
FROM sales.Orders;

-- Subquery with IN: Filter based on subquery results
SELECT * FROM sales.Customers
WHERE CustomerID IN (
    SELECT CustomerID 
    FROM sales.Orders 
    WHERE TotalAmount > 200
);

-- Subquery with EXISTS: Check for existence (efficient)
SELECT * FROM sales.Customers c
WHERE EXISTS (
    SELECT 1 
    FROM sales.Orders o 
    WHERE o.CustomerID = c.CustomerID 
      AND o.TotalAmount > 200
);

-- Subquery with NOT EXISTS: Find customers with no orders
SELECT * FROM sales.Customers c
WHERE NOT EXISTS (
    SELECT 1 
    FROM sales.Orders o 
    WHERE o.CustomerID = c.CustomerID
);

-- Correlated subquery: References outer query (runs for each row)
SELECT 
    o1.OrderID,
    o1.CustomerID,
    o1.TotalAmount,
    (SELECT AVG(o2.TotalAmount) 
     FROM sales.Orders o2 
     WHERE o2.CustomerID = o1.CustomerID) AS CustomerAvg
FROM sales.Orders o1;

-- Derived table: Subquery in FROM clause
SELECT 
    AvgByCustomer.CustomerID,
    AvgByCustomer.AvgAmount,
    c.FirstName,
    c.LastName
FROM (
    SELECT 
        CustomerID, 
        AVG(TotalAmount) AS AvgAmount
    FROM sales.Orders
    GROUP BY CustomerID
) AS AvgByCustomer
INNER JOIN sales.Customers c ON AvgByCustomer.CustomerID = c.CustomerID
WHERE AvgByCustomer.AvgAmount > 150;

-- ============================================================================
-- SECTION 13: CTEs (COMMON TABLE EXPRESSIONS) - READABLE SUBQUERIES
-- ============================================================================

/*
CTE BENEFITS:
    - More readable than nested subqueries
    - Can be referenced multiple times
    - Supports recursive queries
    - Better for complex logic
*/

-- Basic CTE
WITH CustomerOrderStats AS (
    SELECT 
        CustomerID,
        COUNT(*) AS OrderCount,
        SUM(TotalAmount) AS TotalSpent,
        AVG(TotalAmount) AS AvgOrderValue
    FROM sales.Orders
    GROUP BY CustomerID
)
SELECT 
    c.FirstName,
    c.LastName,
    cos.OrderCount,
    cos.TotalSpent,
    cos.AvgOrderValue
FROM CustomerOrderStats cos
INNER JOIN sales.Customers c ON cos.CustomerID = c.CustomerID
WHERE cos.OrderCount >= 2
ORDER BY cos.TotalSpent DESC;

-- Multiple CTEs
WITH OrderSummary AS (
    SELECT 
        CustomerID,
        COUNT(*) AS OrderCount,
        SUM(TotalAmount) AS TotalSpent
    FROM sales.Orders
    GROUP BY CustomerID
),
HighValueCustomers AS (
    SELECT CustomerID
    FROM OrderSummary
    WHERE TotalSpent > 200
)
SELECT 
    c.FirstName,
    c.LastName,
    os.OrderCount,
    os.TotalSpent
FROM HighValueCustomers hvc
INNER JOIN sales.Customers c ON hvc.CustomerID = c.CustomerID
INNER JOIN OrderSummary os ON hvc.CustomerID = os.CustomerID;

-- Recursive CTE: Generate number series
WITH Numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM Numbers
    WHERE n < 10
)
SELECT n FROM Numbers;

-- Recursive CTE: Organizational hierarchy
CREATE TABLE hr.Employees2 (
    EmployeeID INT PRIMARY KEY,
    EmployeeName NVARCHAR(50),
    ManagerID INT
);

INSERT INTO hr.Employees2 VALUES
(1, 'CEO', NULL),
(2, 'VP Sales', 1),
(3, 'VP Engineering', 1),
(4, 'Sales Manager', 2),
(5, 'Engineer', 3);

WITH EmployeeHierarchy AS (
    -- Anchor: Top level (CEO)
    SELECT 
        EmployeeID, 
        EmployeeName, 
        ManagerID,
        0 AS Level
    FROM hr.Employees2
    WHERE ManagerID IS NULL
    
    UNION ALL
    
    -- Recursive: Each level down
    SELECT 
        e.EmployeeID,
        e.EmployeeName,
        e.ManagerID,
        eh.Level + 1
    FROM hr.Employees2 e
    INNER JOIN EmployeeHierarchy eh ON e.ManagerID = eh.EmployeeID
)
SELECT 
    REPLICATE('  ', Level) + EmployeeName AS OrgChart,
    Level
FROM EmployeeHierarchy
ORDER BY Level, EmployeeID;

-- ============================================================================
-- SECTION 14: WINDOW FUNCTIONS - ADVANCED ANALYTICS
-- ============================================================================

/*
WINDOW FUNCTION SYNTAX:
    function() OVER (
        [PARTITION BY column]  -- Group rows
        ORDER BY column        -- Sort within group
        [ROWS/RANGE ...]       -- Define window frame
    )

CATEGORIES:
    1. Ranking: ROW_NUMBER, RANK, DENSE_RANK, NTILE
    2. Offset: LAG, LEAD, FIRST_VALUE, LAST_VALUE
    3. Aggregate: SUM, AVG, COUNT OVER (...)
*/

-- ROW_NUMBER: Sequential numbering
SELECT 
    CustomerID,
    OrderID,
    OrderDate,
    TotalAmount,
    ROW_NUMBER() OVER (ORDER BY OrderDate) AS RowNum
FROM sales.Orders;

-- ROW_NUMBER with PARTITION BY: Restart numbering per group
SELECT 
    CustomerID,
    OrderID,
    OrderDate,
    TotalAmount,
    ROW_NUMBER() OVER (
        PARTITION BY CustomerID 
        ORDER BY OrderDate
    ) AS OrderSequence
FROM sales.Orders
ORDER BY CustomerID, OrderDate;

-- RANK: With gaps for ties
SELECT 
    OrderID,
    TotalAmount,
    RANK() OVER (ORDER BY TotalAmount DESC) AS Rank
FROM sales.Orders;

-- DENSE_RANK: Without gaps
SELECT 
    OrderID,
    TotalAmount,
    DENSE_RANK() OVER (ORDER BY TotalAmount DESC) AS DenseRank
FROM sales.Orders;

-- NTILE: Divide into buckets (quartiles, quintiles)
SELECT 
    OrderID,
    TotalAmount,
    NTILE(4) OVER (ORDER BY TotalAmount) AS Quartile,
    NTILE(5) OVER (ORDER BY TotalAmount) AS Quintile
FROM sales.Orders;

-- LAG: Previous row value
SELECT 
    OrderID,
    OrderDate,
    TotalAmount,
    LAG(TotalAmount) OVER (ORDER BY OrderDate) AS PreviousOrderAmount,
    TotalAmount - LAG(TotalAmount) OVER (ORDER BY OrderDate) AS Difference
FROM sales.Orders;

-- LEAD: Next row value
SELECT 
    OrderID,
    OrderDate,
    TotalAmount,
    LEAD(TotalAmount) OVER (ORDER BY OrderDate) AS NextOrderAmount
FROM sales.Orders;

-- FIRST_VALUE / LAST_VALUE: First/Last in window
SELECT 
    OrderID,
    OrderDate,
    TotalAmount,
    FIRST_VALUE(TotalAmount) OVER (
        PARTITION BY YEAR(OrderDate) 
        ORDER BY OrderDate
    ) AS FirstOrderOfYear,
    LAST_VALUE(TotalAmount) OVER (
        PARTITION BY YEAR(OrderDate) 
        ORDER BY OrderDate
        ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
    ) AS LastOrderOfYear
FROM sales.Orders;

-- Running total (cumulative sum)
SELECT 
    OrderID,
    OrderDate,
    TotalAmount,
    SUM(TotalAmount) OVER (
        ORDER BY OrderDate
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS RunningTotal
FROM sales.Orders;

-- Moving average (7-day)
SELECT 
    OrderDate,
    TotalAmount,
    AVG(TotalAmount) OVER (
        ORDER BY OrderDate
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS MovingAvg7Day
FROM sales.Orders;

-- ============================================================================
-- SECTION 15: STRING FUNCTIONS
-- ============================================================================

-- CONCAT: Combine strings
SELECT CONCAT(FirstName, ' ', LastName) AS FullName FROM sales.Customers;

-- String operator: + (same as CONCAT but NULL-sensitive)
SELECT FirstName + ' ' + LastName AS FullName FROM sales.Customers;

-- UPPER / LOWER: Change case
SELECT 
    Email,
    UPPER(Email) AS Uppercase,
    LOWER(Email) AS Lowercase
FROM sales.Customers;

-- SUBSTRING: Extract portion of string
SELECT 
    Email,
    SUBSTRING(Email, 1, CHARINDEX('@', Email) - 1) AS Username,
    SUBSTRING(Email, CHARINDEX('@', Email) + 1, LEN(Email)) AS Domain
FROM sales.Customers;

-- LEFT / RIGHT: Extract from start/end
SELECT 
    Phone,
    LEFT(Phone, 3) AS AreaCode,
    RIGHT(Phone, 4) AS LastFourDigits
FROM sales.Customers
WHERE Phone IS NOT NULL;

-- LEN: String length
SELECT FirstName, LEN(FirstName) AS NameLength FROM sales.Customers;

-- TRIM / LTRIM / RTRIM: Remove whitespace
SELECT 
    TRIM('  Hello World  ') AS Trimmed,
    LTRIM('  Hello World  ') AS LeftTrimmed,
    RTRIM('  Hello World  ') AS RightTrimmed;

-- REPLACE: Replace substring
SELECT 
    Email,
    REPLACE(Email, '@email.com', '@company.com') AS NewEmail
FROM sales.Customers;

-- CHARINDEX: Find position of substring
SELECT 
    Email,
    CHARINDEX('@', Email) AS AtSignPosition
FROM sales.Customers;

-- STUFF: Insert/replace substring
SELECT STUFF('Hello World', 7, 5, 'SQL') AS Result;  -- 'Hello SQL'

-- REVERSE: Reverse string
SELECT REVERSE('Hello') AS Reversed;  -- 'olleH'

-- ============================================================================
-- SECTION 16: DATE FUNCTIONS
-- ============================================================================

-- Current date/time
SELECT 
    GETDATE() AS CurrentDateTime,        -- 2024-03-15 14:30:00
    GETUTCDATE() AS CurrentUTCDateTime,  -- UTC time
    SYSDATETIME() AS HighPrecisionDateTime;  -- More precise

-- Extract parts of date
SELECT 
    OrderDate,
    YEAR(OrderDate) AS Year,
    MONTH(OrderDate) AS Month,
    DAY(OrderDate) AS Day,
    DATEPART(QUARTER, OrderDate) AS Quarter,
    DATEPART(WEEK, OrderDate) AS WeekOfYear,
    DATEPART(WEEKDAY, OrderDate) AS DayOfWeek
FROM sales.Orders;

-- Date name functions
SELECT 
    OrderDate,
    DATENAME(MONTH, OrderDate) AS MonthName,
    DATENAME(WEEKDAY, OrderDate) AS DayName
FROM sales.Orders;

-- DATEADD: Add interval to date
SELECT 
    OrderDate,
    DATEADD(DAY, 7, OrderDate) AS Plus7Days,
    DATEADD(MONTH, 1, OrderDate) AS Plus1Month,
    DATEADD(YEAR, -1, OrderDate) AS Minus1Year
FROM sales.Orders;

-- DATEDIFF: Difference between dates
SELECT 
    OrderDate,
    DATEDIFF(DAY, OrderDate, GETDATE()) AS DaysSinceOrder,
    DATEDIFF(MONTH, OrderDate, GETDATE()) AS MonthsSinceOrder,
    DATEDIFF(YEAR, OrderDate, GETDATE()) AS YearsSinceOrder
FROM sales.Orders;

-- EOMONTH: End of month
SELECT 
    OrderDate,
    EOMONTH(OrderDate) AS EndOfMonth,
    EOMONTH(OrderDate, -1) AS EndOfPreviousMonth
FROM sales.Orders;

-- DATEFROMPARTS: Construct date from parts
SELECT DATEFROMPARTS(2024, 3, 15) AS ConstructedDate;

-- FORMAT: Custom date formatting
SELECT 
    OrderDate,
    FORMAT(OrderDate, 'yyyy-MM-dd') AS ISO8601,
    FORMAT(OrderDate, 'MM/dd/yyyy') AS USFormat,
    FORMAT(OrderDate, 'MMMM dd, yyyy') AS LongFormat,
    FORMAT(OrderDate, 'ddd, MMM dd') AS ShortFormat
FROM sales.Orders;

-- Date calculations: Age
UPDATE sales.Customers SET DateOfBirth = '1990-05-15' WHERE CustomerID = 1;

SELECT 
    FirstName,
    DateOfBirth,
    DATEDIFF(YEAR, DateOfBirth, GETDATE()) AS Age,
    DATEDIFF(YEAR, DateOfBirth, GETDATE()) - 
        CASE 
            WHEN MONTH(DateOfBirth) > MONTH(GETDATE()) OR 
                 (MONTH(DateOfBirth) = MONTH(GETDATE()) AND DAY(DateOfBirth) > DAY(GETDATE()))
            THEN 1 
            ELSE 0 
        END AS ExactAge
FROM sales.Customers
WHERE DateOfBirth IS NOT NULL;

-- ============================================================================
-- SECTION 17: CONDITIONAL LOGIC (CASE, IIF)
-- ============================================================================

-- CASE: Multi-way conditional
SELECT 
    OrderID,
    TotalAmount,
    CASE 
        WHEN TotalAmount < 100 THEN 'Small'
        WHEN TotalAmount < 300 THEN 'Medium'
        ELSE 'Large'
    END AS OrderSize
FROM sales.Orders;

-- CASE with aggregation
SELECT 
    Status,
    COUNT(*) AS TotalOrders,
    SUM(CASE WHEN TotalAmount < 100 THEN 1 ELSE 0 END) AS SmallOrders,
    SUM(CASE WHEN TotalAmount >= 100 AND TotalAmount < 300 THEN 1 ELSE 0 END) AS MediumOrders,
    SUM(CASE WHEN TotalAmount >= 300 THEN 1 ELSE 0 END) AS LargeOrders
FROM sales.Orders
GROUP BY Status;

-- IIF: Simple if-else (SQL Server 2012+)
SELECT 
    OrderID,
    TotalAmount,
    IIF(TotalAmount > 200, 'High Value', 'Standard') AS Category
FROM sales.Orders;

-- Nested CASE
SELECT 
    CustomerID,
    LoyaltyPoints,
    CASE 
        WHEN LoyaltyPoints >= 1000 THEN 'Platinum'
        WHEN LoyaltyPoints >= 500 THEN 'Gold'
        WHEN LoyaltyPoints >= 100 THEN 'Silver'
        ELSE 'Bronze'
    END AS LoyaltyTier,
    CASE 
        WHEN LoyaltyPoints >= 1000 THEN 0.20
        WHEN LoyaltyPoints >= 500 THEN 0.15
        WHEN LoyaltyPoints >= 100 THEN 0.10
        ELSE 0.05
    END AS DiscountRate
FROM sales.Customers;

-- ============================================================================
-- SECTION 18: NULL HANDLING
-- ============================================================================

/*
NULL = Unknown/Missing value
NULL is NOT equal to anything, not even NULL
NULL + 5 = NULL
NULL = NULL returns UNKNOWN (not TRUE)
*/

-- IS NULL / IS NOT NULL
SELECT * FROM sales.Customers WHERE Phone IS NULL;
SELECT * FROM sales.Customers WHERE Phone IS NOT NULL;

-- ISNULL: Replace NULL with value (SQL Server specific)
SELECT 
    FirstName,
    Phone,
    ISNULL(Phone, 'No phone provided') AS PhoneDisplay
FROM sales.Customers;

-- COALESCE: Return first non-NULL (SQL standard, supports multiple values)
SELECT 
    FirstName,
    COALESCE(Phone, Email, 'No contact info') AS ContactMethod
FROM sales.Customers;

-- NULLIF: Return NULL if two values are equal
SELECT 
    OrderID,
    TotalAmount,
    NULLIF(TotalAmount, 0) AS NonZeroAmount  -- Returns NULL for 0 amounts
FROM sales.Orders;

-- NULL in calculations
SELECT 
    OrderID,
    TotalAmount,
    TotalAmount * 0.1 AS Tax,
    TotalAmount + (TotalAmount * 0.1) AS Total,
    NULL + TotalAmount AS NullCalc  -- Result is always NULL!
FROM sales.Orders;

-- NULL in aggregations (ignored)
DROP TABLE IF EXISTS #TestNulls;  -- Add this line
CREATE TABLE #TestNulls (Value INT);
INSERT INTO #TestNulls VALUES (10), (20), (NULL), (30);

SELECT 
    COUNT(*) AS AllRows,           -- 4
    COUNT(Value) AS NonNullRows,   -- 3
    SUM(Value) AS Total,           -- 60
    AVG(Value) AS Average          -- 20 (60/3, not 60/4)
FROM #TestNulls;

-- ============================================================================
-- SECTION 19: SET OPERATIONS (UNION, INTERSECT, EXCEPT)
-- ============================================================================

-- UNION: Combine results, remove duplicates
SELECT FirstName FROM sales.Customers WHERE CustomerID <= 2
UNION
SELECT FirstName FROM sales.Customers WHERE CustomerID >= 2;

-- UNION ALL: Combine results, keep duplicates (faster)
SELECT FirstName FROM sales.Customers WHERE CustomerID <= 2
UNION ALL
SELECT FirstName FROM sales.Customers WHERE CustomerID >= 2;

-- INTERSECT: Only rows in both results
SELECT CustomerID FROM sales.Customers
INTERSECT
SELECT CustomerID FROM sales.Orders;  -- Customers who have orders

-- EXCEPT: Rows in first but not in second
SELECT CustomerID FROM sales.Customers
EXCEPT
SELECT CustomerID FROM sales.Orders;  -- Customers with no orders

/*
SET OPERATION RULES:
    - Same number of columns
    - Compatible data types
    - Column names from first query
    - ORDER BY only at the end
*/

-- ============================================================================
-- SECTION 20: DATA TYPE CONVERSION
-- ============================================================================

-- CAST: SQL standard conversion
SELECT 
    CAST('12345' AS INT) AS StringToInt,
    CAST(12345 AS NVARCHAR(10)) AS IntToString,
    CAST('2024-03-15' AS DATE) AS StringToDate,
    CAST(123.456 AS DECIMAL(10, 2)) AS Rounded;

-- CONVERT: SQL Server specific (more options)
SELECT 
    CONVERT(INT, '12345') AS StringToInt,
    CONVERT(NVARCHAR(10), 12345) AS IntToString,
    CONVERT(DATE, '2024-03-15') AS StringToDate,
    CONVERT(VARCHAR(10), GETDATE(), 101) AS DateFormatted;  -- MM/DD/YYYY

-- TRY_CAST / TRY_CONVERT: Safe conversion (returns NULL on failure)
SELECT 
    TRY_CAST('12345' AS INT) AS ValidConversion,       -- 12345
    TRY_CAST('abc' AS INT) AS InvalidConversion,       -- NULL (no error)
    TRY_CONVERT(DATE, '2024-03-15') AS ValidDate,      -- 2024-03-15
    TRY_CONVERT(DATE, '2024-13-45') AS InvalidDate;    -- NULL (no error)

/*
⚠️ PRODUCTION RULE:
    Always use TRY_CAST or TRY_CONVERT when converting user input
    or potentially dirty data. Prevents script crashes.
*/

-- PARSE: Convert string to date/number using culture
SELECT PARSE('03/15/2024' AS DATE USING 'en-US') AS USDate;

-- Common date format codes for CONVERT
SELECT 
    CONVERT(VARCHAR(30), GETDATE(), 101) AS [MM/DD/YYYY],
    CONVERT(VARCHAR(30), GETDATE(), 103) AS [DD/MM/YYYY],
    CONVERT(VARCHAR(30), GETDATE(), 112) AS [YYYYMMDD],
    CONVERT(VARCHAR(30), GETDATE(), 120) AS [YYYY-MM-DD HH:MI:SS];

-- ============================================================================
-- SECTION 21: CONSTRAINTS - DATA INTEGRITY
-- ============================================================================

/*
CONSTRAINT TYPES:
    PRIMARY KEY  - Unique identifier, not NULL
    FOREIGN KEY  - References another table's primary key
    UNIQUE       - No duplicate values allowed
    CHECK        - Custom validation rule
    DEFAULT      - Automatic value if not provided
    NOT NULL     - Value required
*/

-- PRIMARY KEY
CREATE TABLE examples.Products (
    ProductID INT PRIMARY KEY,
    ProductName NVARCHAR(100)
);

-- FOREIGN KEY
CREATE TABLE examples.Orders (
    OrderID INT PRIMARY KEY,
    ProductID INT,
    CONSTRAINT FK_Orders_Products 
        FOREIGN KEY (ProductID) REFERENCES examples.Products(ProductID)
);

-- UNIQUE constraint
ALTER TABLE sales.Customers 
ADD CONSTRAINT UQ_Customers_Email UNIQUE (Email);

-- CHECK constraint
ALTER TABLE sales.Customers
ADD CONSTRAINT CK_Customers_LoyaltyPoints_Positive 
    CHECK (LoyaltyPoints >= 0);

CREATE TABLE examples.Employees (
    EmployeeID INT PRIMARY KEY,
    Salary DECIMAL(10, 2),
    HireDate DATE,
    CONSTRAINT CK_Salary_Positive CHECK (Salary > 0),
    CONSTRAINT CK_HireDate_NotFuture CHECK (HireDate <= GETDATE())
);

-- DEFAULT constraint
ALTER TABLE sales.Customers
ADD RegisteredDate DATE DEFAULT GETDATE();

-- NOT NULL (already defined, this is for ALTER example)
-- ALTER TABLE sales.Customers
-- ALTER COLUMN Email NVARCHAR(100) NOT NULL;

-- ============================================================================
-- SECTION 22: INDEXES - PERFORMANCE BASICS
-- ============================================================================

/*
INDEX TYPES:
    CLUSTERED     - Determines physical row order (one per table)
    NON-CLUSTERED - Separate structure pointing to data (many allowed)

PRIMARY KEY automatically creates clustered index
*/

-- Create non-clustered index
CREATE NONCLUSTERED INDEX IX_Orders_CustomerID 
ON sales.Orders(CustomerID);

CREATE NONCLUSTERED INDEX IX_Orders_OrderDate 
ON sales.Orders(OrderDate);

-- Composite index (multiple columns)
CREATE NONCLUSTERED INDEX IX_Orders_Customer_Date 
ON sales.Orders(CustomerID, OrderDate);

-- Drop index
DROP INDEX IF EXISTS IX_Orders_OrderDate ON sales.Orders;

-- View indexes on table
SELECT 
    i.name AS IndexName,
    i.type_desc AS IndexType,
    COL_NAME(ic.object_id, ic.column_id) AS ColumnName
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE i.object_id = OBJECT_ID('sales.Orders')
ORDER BY i.name, ic.index_column_id;

/*
WHEN TO CREATE INDEXES:
    ✅ Foreign key columns
    ✅ Columns in WHERE clauses
    ✅ Columns in ORDER BY
    ✅ Columns in GROUP BY
    ❌ Small tables (< 1000 rows)
    ❌ Columns rarely queried
    ❌ Columns with low cardinality (few unique values)

COST:
    + Faster SELECT queries
    - Slower INSERT/UPDATE/DELETE
    - Takes disk space
*/

-- ============================================================================
-- SECTION 23: TRANSACTIONS - DATA CONSISTENCY
-- ============================================================================

/*
TRANSACTION PROPERTIES (ACID):
    Atomicity   - All or nothing
    Consistency - Database remains valid
    Isolation   - Concurrent transactions don't interfere
    Durability  - Committed changes persist
*/

-- Basic transaction
BEGIN TRANSACTION;

    UPDATE sales.Customers 
    SET LoyaltyPoints = LoyaltyPoints + 100 
    WHERE CustomerID = 1;
    
    INSERT INTO sales.Orders (OrderID, CustomerID, OrderDate, TotalAmount, Status)
    VALUES (100, 1, GETDATE(), 250.00, 'Completed');

COMMIT TRANSACTION;  -- Save changes

-- Transaction with rollback on error
BEGIN TRANSACTION;

    BEGIN TRY
        UPDATE sales.Customers 
        SET LoyaltyPoints = LoyaltyPoints - 500 
        WHERE CustomerID = 1;
        
        -- This will fail if customer has insufficient points
        IF (SELECT LoyaltyPoints FROM sales.Customers WHERE CustomerID = 1) < 0
            THROW 50000, 'Insufficient loyalty points', 1;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Transaction rolled back: ' + ERROR_MESSAGE();
    END CATCH;

-- Check transaction state
SELECT @@TRANCOUNT AS OpenTransactions;

-- ============================================================================
-- SECTION 24: COMMON INTERVIEW QUESTIONS (WITH SOLUTIONS)
-- ============================================================================

-- Q1: Find duplicate email addresses
SELECT Email, COUNT(*) AS DuplicateCount
FROM sales.Customers
GROUP BY Email
HAVING COUNT(*) > 1;

-- Q2: Find duplicate records (all columns)
WITH DuplicateCTE AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY Email ORDER BY CustomerID) AS RowNum
    FROM sales.Customers
)
SELECT * FROM DuplicateCTE WHERE RowNum > 1;

-- Q3: Delete duplicate records (keep first occurrence)
WITH DuplicateCTE AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY Email ORDER BY CustomerID) AS RowNum
    FROM sales.Customers
)
DELETE FROM DuplicateCTE WHERE RowNum > 1;

-- Q4: Find Nth highest salary
DROP TABLE IF EXISTS #Salaries;  -- Add this line
CREATE TABLE #Salaries (EmployeeID INT, Salary DECIMAL(10, 2));
INSERT INTO #Salaries VALUES (1, 50000), (2, 60000), (3, 70000), (4, 80000), (5, 90000);

-- Method 1: Using OFFSET/FETCH
DECLARE @N INT = 3;
SELECT Salary 
FROM #Salaries 
ORDER BY Salary DESC
OFFSET @N - 1 ROWS
FETCH NEXT 1 ROW ONLY;

-- Method 2: Using DENSE_RANK
WITH RankedSalaries AS (
    SELECT Salary, DENSE_RANK() OVER (ORDER BY Salary DESC) AS Rank
    FROM #Salaries
)
SELECT Salary FROM RankedSalaries WHERE Rank = 3;

-- Q5: Find customers with consecutive orders
WITH OrderSequence AS (
    SELECT 
        CustomerID,
        OrderDate,
        LAG(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS PrevOrderDate,
        DATEDIFF(DAY, LAG(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate), OrderDate) AS DaysBetween
    FROM sales.Orders
)
SELECT DISTINCT CustomerID
FROM OrderSequence
WHERE DaysBetween <= 7;  -- Orders within 7 days

-- Q6: Running total by customer
SELECT 
    CustomerID,
    OrderID,
    OrderDate,
    TotalAmount,
    SUM(TotalAmount) OVER (
        PARTITION BY CustomerID 
        ORDER BY OrderDate
        ROWS UNBOUNDED PRECEDING
    ) AS RunningTotal
FROM sales.Orders
ORDER BY CustomerID, OrderDate;

-- Q7: Top N records per group
WITH RankedOrders AS (
    SELECT 
        CustomerID,
        OrderID,
        TotalAmount,
        ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY TotalAmount DESC) AS Rank
    FROM sales.Orders
)
SELECT CustomerID, OrderID, TotalAmount
FROM RankedOrders
WHERE Rank <= 2;  -- Top 2 orders per customer

-- Q8: Find gaps in sequential numbers
WITH AllNumbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM AllNumbers WHERE n < 100
),
ExistingOrders AS (
    SELECT DISTINCT OrderID FROM sales.Orders
)
SELECT an.n AS MissingOrderID
FROM AllNumbers an
LEFT JOIN ExistingOrders eo ON an.n = eo.OrderID
WHERE eo.OrderID IS NULL
OPTION (MAXRECURSION 100);

-- Q9: Month-over-month growth
WITH MonthlySales AS (
    SELECT 
        YEAR(OrderDate) AS Year,
        MONTH(OrderDate) AS Month,
        SUM(TotalAmount) AS Revenue
    FROM sales.Orders
    GROUP BY YEAR(OrderDate), MONTH(OrderDate)
)
SELECT 
    Year,
    Month,
    Revenue,
    LAG(Revenue) OVER (ORDER BY Year, Month) AS PrevMonthRevenue,
    Revenue - LAG(Revenue) OVER (ORDER BY Year, Month) AS MoMGrowth,
    CAST((Revenue - LAG(Revenue) OVER (ORDER BY Year, Month)) * 100.0 / 
         NULLIF(LAG(Revenue) OVER (ORDER BY Year, Month), 0) AS DECIMAL(10, 2)) AS MoMGrowthPct
FROM MonthlySales;

-- Q10: Pivot table (dynamic columns)
SELECT 
    CustomerID,
    SUM(CASE WHEN Status = 'Pending' THEN TotalAmount ELSE 0 END) AS Pending,
    SUM(CASE WHEN Status = 'Completed' THEN TotalAmount ELSE 0 END) AS Completed,
    SUM(CASE WHEN Status = 'Shipped' THEN TotalAmount ELSE 0 END) AS Shipped
FROM sales.Orders
GROUP BY CustomerID;

-- ============================================================================
-- SECTION 25: COMMON MISTAKES TO AVOID
-- ============================================================================

/*
MISTAKE #1: Forgetting WHERE in UPDATE/DELETE
    ❌ UPDATE sales.Customers SET Phone = '000-0000';  -- Updates ALL!
    ✅ UPDATE sales.Customers SET Phone = '000-0000' WHERE CustomerID = 1;

MISTAKE #2: Using = NULL instead of IS NULL
    ❌ WHERE Phone = NULL    -- Always returns 0 rows
    ✅ WHERE Phone IS NULL

MISTAKE #3: Not handling NULL in calculations
    ❌ SELECT TotalAmount + Tax FROM Orders;  -- NULL tax makes result NULL
    ✅ SELECT TotalAmount + ISNULL(Tax, 0) FROM Orders;

MISTAKE #4: Forgetting GROUP BY columns
    ❌ SELECT CustomerID, FirstName, COUNT(*) FROM Orders GROUP BY CustomerID;
    ✅ SELECT CustomerID, FirstName, COUNT(*) FROM Orders GROUP BY CustomerID, FirstName;

MISTAKE #5: Using CONVERT instead of TRY_CONVERT
    ❌ SELECT CONVERT(INT, 'abc') FROM ...;  -- Crashes on bad data
    ✅ SELECT TRY_CONVERT(INT, 'abc') FROM ...; -- Returns NULL safely

MISTAKE #6: Not using ORDER BY with TOP
    ❌ SELECT TOP 10 * FROM Orders;  -- Arbitrary 10 rows
    ✅ SELECT TOP 10 * FROM Orders ORDER BY TotalAmount DESC;

MISTAKE #7: String concatenation with NULL
    ❌ SELECT FirstName + ' ' + LastName;  -- NULL if either is NULL
    ✅ SELECT CONCAT(FirstName, ' ', LastName);  -- Handles NULLs

MISTAKE #8: Comparing strings case-sensitively (depends on collation)
    Check: SELECT SERVERPROPERTY('Collation');
    Default SQL Server collation is usually case-insensitive

MISTAKE #9: Not aliasing derived tables
    ❌ SELECT * FROM (SELECT CustomerID FROM Orders);  -- Error
    ✅ SELECT * FROM (SELECT CustomerID FROM Orders) AS Derived;

MISTAKE #10: Cartesian joins (missing join condition)
    ❌ SELECT * FROM Customers, Orders;  -- Every combination!
    ✅ SELECT * FROM Customers c INNER JOIN Orders o ON c.CustomerID = o.CustomerID;
*/

-- ============================================================================
-- FINAL TIPS FOR DATA ANALYSTS
-- ============================================================================

/*
PRODUCTIVITY TIPS:
    1. Use CTEs for complex queries (easier to debug)
    2. Comment your code (future you will thank you)
    3. Test with small datasets first (TOP 100)
    4. Use meaningful aliases (c for Customers, o for Orders)
    5. Format your SQL (indentation matters for readability)
    6. Save frequently used queries as snippets
    7. Learn keyboard shortcuts in SSMS (F5 = Execute, Ctrl+R = Toggle results)

PERFORMANCE TIPS:
    1. SELECT only needed columns (avoid SELECT *)
    2. Use WHERE to filter early (before joins when possible)
    3. Index foreign keys
    4. Use EXISTS instead of IN for subqueries (usually faster)
    5. Avoid functions on indexed columns in WHERE (breaks index usage)
    6. Use UNION ALL instead of UNION (if duplicates OK)

INTERVIEW PREPARATION:
    Practice these topics:
    ✓ JOINs (especially LEFT JOIN)
    ✓ GROUP BY with HAVING
    ✓ Window functions (ROW_NUMBER, RANK, NTILE)
    ✓ Subqueries and CTEs
    ✓ Finding duplicates
    ✓ Top N per group
    ✓ Running totals
    ✓ Date calculations
    ✓ NULL handling
    ✓ CASE statements

NEXT STEPS:
    1. Practice Session 3 scripts with this knowledge
    2. Try modifying examples with your own data
    3. Solve LeetCode SQL problems (easy to medium)
    4. Read query execution plans (CTRL+M in SSMS)
    5. Learn about indexes and performance tuning
    6. Study data warehousing concepts (star schema, fact/dimension)

=============================================================================
CONGRATULATIONS!
=============================================================================

You now have a solid foundation in SQL fundamentals. These concepts are:
✓ Essential for data analyst roles
✓ Tested in technical interviews
✓ Used daily in production environments
✓ Transferable across database platforms (with minor syntax changes)

Practice makes perfect. Write queries daily. Challenge yourself with 
increasingly complex scenarios. Most importantly, understand WHY each 
query works, not just HOW to write it.

Ready for Session 3? Let's build that Medallion architecture! 🚀

=============================================================================
*/

PRINT 'Script completed successfully!';
PRINT 'Database: SQLFundamentals ready for practice.';
GO