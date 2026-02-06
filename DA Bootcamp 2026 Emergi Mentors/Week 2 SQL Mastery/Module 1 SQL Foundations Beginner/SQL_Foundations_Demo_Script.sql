/*
================================================================================
SQL FOUNDATIONS - LIVE DEMONSTRATION SCRIPT
================================================================================
Course: SQL Foundations - Understanding the Language
Video: 0 of 15 - Before You Start Coding
Duration: 15-20 minutes live demo
Instructor: Fassahat Ahmad
Purpose: Demonstrate the 5 types of SQL (DDL, DML, DQL, DCL, TCL)
Database: AusRetail (Australian Retail Company)
================================================================================
*/

-- ============================================================================
-- SETUP: Database Creation
-- ============================================================================
-- Note: Run this first to create the demo database
-- Platform: SQL Server / Azure SQL / Compatible RDBMS

USE master;
GO

-- Drop database if exists (for clean demo)
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'AusRetail_Demo')
BEGIN
    ALTER DATABASE AusRetail_Demo SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE AusRetail_Demo;
END
GO

-- Create fresh database
CREATE DATABASE AusRetail_Demo;
GO

USE AusRetail_Demo;
GO

PRINT '✓ Database AusRetail_Demo created successfully!';
PRINT '';
GO

/*
================================================================================
PART 1: DDL - DATA DEFINITION LANGUAGE
================================================================================
Purpose: Define the STRUCTURE of your database
Commands: CREATE, ALTER, DROP, TRUNCATE
Library Analogy: Building the library - installing shelves, creating sections
================================================================================
*/

PRINT '================================================================================';
PRINT 'PART 1: DDL - DATA DEFINITION LANGUAGE';
PRINT '================================================================================';
PRINT 'We are building the structure - like installing bookshelves in a library';
PRINT '';
GO

-- -----------------------------------------------------------------------------
-- DDL Example 1: CREATE TABLE (Building the structure)
-- -----------------------------------------------------------------------------
PRINT '--- DDL Example 1: CREATE TABLE ---';
PRINT 'Creating the Stores table (our first bookshelf!)';
PRINT '';

CREATE TABLE Stores (
    StoreID INT PRIMARY KEY IDENTITY(1,1),
    StoreName NVARCHAR(100) NOT NULL,
    State NVARCHAR(3) NOT NULL,
    City NVARCHAR(50) NOT NULL,
    Manager NVARCHAR(100),
    OpenDate DATE NOT NULL,
    StoreSize INT, -- in square meters
    IsActive BIT DEFAULT 1
);
GO

PRINT '✓ Stores table created!';
PRINT '';
GO

-- Create Employees table
PRINT 'Creating the Employees table';
PRINT '';

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100),
    Phone NVARCHAR(20),
    Department NVARCHAR(50) NOT NULL,
    Position NVARCHAR(50) NOT NULL,
    Salary DECIMAL(10,2) NOT NULL,
    HireDate DATE NOT NULL,
    StoreID INT,
    IsActive BIT DEFAULT 1,
    CONSTRAINT FK_Employees_Stores FOREIGN KEY (StoreID) REFERENCES Stores(StoreID)
);
GO

PRINT '✓ Employees table created!';
PRINT '';
GO

-- Create Products table
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName NVARCHAR(100) NOT NULL,
    Category NVARCHAR(50) NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    CostPrice DECIMAL(10,2) NOT NULL,
    StockQuantity INT DEFAULT 0,
    IsActive BIT DEFAULT 1
);
GO

PRINT '✓ Products table created!';
PRINT '';
GO

-- Create Sales table
CREATE TABLE Sales (
    SaleID INT PRIMARY KEY IDENTITY(1,1),
    SaleDate DATETIME NOT NULL DEFAULT GETDATE(),
    StoreID INT NOT NULL,
    ProductID INT NOT NULL,
    EmployeeID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    TotalAmount AS (Quantity * UnitPrice) PERSISTED,
    CONSTRAINT FK_Sales_Stores FOREIGN KEY (StoreID) REFERENCES Stores(StoreID),
    CONSTRAINT FK_Sales_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    CONSTRAINT FK_Sales_Employees FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);
GO

PRINT '✓ Sales table created!';
PRINT '';
GO

-- -----------------------------------------------------------------------------
-- DDL Example 2: ALTER TABLE (Modifying the structure)
-- -----------------------------------------------------------------------------
PRINT '--- DDL Example 2: ALTER TABLE ---';
PRINT 'Boss says: "We need to track employee mobile numbers!"';
PRINT 'This is like adding a new section to our bookshelf';
PRINT '';

ALTER TABLE Employees 
ADD MobilePhone NVARCHAR(20);
GO

PRINT '✓ MobilePhone column added to Employees table!';
PRINT '';
GO

-- Add another column
PRINT 'Adding ManagerID to Employees for organizational hierarchy';
ALTER TABLE Employees
ADD ManagerID INT;
GO

PRINT '✓ ManagerID column added!';
PRINT '';
GO

-- -----------------------------------------------------------------------------
-- DDL Example 3: CREATE INDEX (Performance optimization)
-- -----------------------------------------------------------------------------
PRINT '--- DDL Example 3: CREATE INDEX ---';
PRINT 'Creating indexes for faster searches (like a library catalog system)';
PRINT '';

CREATE INDEX idx_Employees_Department 
ON Employees(Department);
GO

CREATE INDEX idx_Sales_SaleDate 
ON Sales(SaleDate);
GO

CREATE INDEX idx_Stores_State 
ON Stores(State);
GO

PRINT '✓ Indexes created for better query performance!';
PRINT '';
GO

-- -----------------------------------------------------------------------------
-- Summary: What we built with DDL
-- -----------------------------------------------------------------------------
PRINT '--- DDL SUMMARY ---';
PRINT 'We have DEFINED the structure:';
PRINT '  ✓ 4 tables created (Stores, Employees, Products, Sales)';
PRINT '  ✓ Columns added (ALTER TABLE)';
PRINT '  ✓ Indexes created for performance';
PRINT '  ✓ Relationships established (Foreign Keys)';
PRINT '';
PRINT 'The library building is ready - but it has NO BOOKS yet!';
PRINT '';
GO

/*
================================================================================
PART 2: DML - DATA MANIPULATION LANGUAGE
================================================================================
Purpose: Manipulate the ACTUAL DATA inside tables
Commands: INSERT, UPDATE, DELETE
Library Analogy: Adding books, updating book info, removing damaged books
================================================================================
*/

PRINT '================================================================================';
PRINT 'PART 2: DML - DATA MANIPULATION LANGUAGE';
PRINT '================================================================================';
PRINT 'Now we add the actual books to our shelves!';
PRINT '';
GO

-- -----------------------------------------------------------------------------
-- DML Example 1: INSERT (Adding data)
-- -----------------------------------------------------------------------------
PRINT '--- DML Example 1: INSERT ---';
PRINT 'Adding stores across Australia';
PRINT '';

INSERT INTO Stores (StoreName, State, City, Manager, OpenDate, StoreSize, IsActive)
VALUES 
    ('AusRetail Melbourne Central', 'VIC', 'Melbourne', 'Sarah Johnson', '2020-01-15', 850, 1),
    ('AusRetail Sydney CBD', 'NSW', 'Sydney', 'Michael Chen', '2019-06-20', 1200, 1),
    ('AusRetail Brisbane City', 'QLD', 'Brisbane', 'Emma Wilson', '2021-03-10', 950, 1),
    ('AusRetail Perth Plaza', 'WA', 'Perth', 'James Smith', '2020-11-05', 780, 1),
    ('AusRetail Adelaide Square', 'SA', 'Adelaide', 'Olivia Brown', '2022-02-14', 650, 1),
    ('AusRetail Canberra Centre', 'ACT', 'Canberra', 'Liam Davis', '2021-08-22', 550, 1),
    ('AusRetail Hobart Hub', 'TAS', 'Hobart', 'Ava Martinez', '2023-01-30', 450, 1),
    ('AusRetail Darwin Mall', 'NT', 'Darwin', 'Noah Anderson', '2022-09-18', 400, 1);
GO

PRINT '✓ 8 stores inserted across Australia!';
PRINT '';
GO

-- Insert Employees
PRINT 'Adding employees to our stores';
PRINT '';

INSERT INTO Employees (FirstName, LastName, Email, Phone, Department, Position, Salary, HireDate, StoreID, MobilePhone, IsActive)
VALUES 
    -- Melbourne Store (StoreID = 1)
    ('Sarah', 'Johnson', 'sarah.johnson@ausretail.com.au', '03-9123-4567', 'Management', 'Store Manager', 95000.00, '2020-01-15', 1, '0412-345-678', 1),
    ('David', 'Lee', 'david.lee@ausretail.com.au', '03-9123-4568', 'Sales', 'Sales Associate', 55000.00, '2020-02-01', 1, '0413-456-789', 1),
    ('Emily', 'Taylor', 'emily.taylor@ausretail.com.au', '03-9123-4569', 'IT', 'IT Support', 72000.00, '2020-03-15', 1, '0414-567-890', 1),
    
    -- Sydney Store (StoreID = 2)
    ('Michael', 'Chen', 'michael.chen@ausretail.com.au', '02-8234-5678', 'Management', 'Store Manager', 98000.00, '2019-06-20', 2, '0415-678-901', 1),
    ('Jessica', 'Wang', 'jessica.wang@ausretail.com.au', '02-8234-5679', 'Sales', 'Sales Associate', 58000.00, '2019-07-01', 2, '0416-789-012', 1),
    ('Ryan', 'Murphy', 'ryan.murphy@ausretail.com.au', '02-8234-5680', 'Finance', 'Accountant', 75000.00, '2020-01-10', 2, '0417-890-123', 1),
    
    -- Brisbane Store (StoreID = 3)
    ('Emma', 'Wilson', 'emma.wilson@ausretail.com.au', '07-3345-6789', 'Management', 'Store Manager', 92000.00, '2021-03-10', 3, '0418-901-234', 1),
    ('Liam', 'Roberts', 'liam.roberts@ausretail.com.au', '07-3345-6790', 'Sales', 'Sales Associate', 54000.00, '2021-04-01', 3, '0419-012-345', 1),
    
    -- Perth Store (StoreID = 4)
    ('James', 'Smith', 'james.smith@ausretail.com.au', '08-6456-7890', 'Management', 'Store Manager', 90000.00, '2020-11-05', 4, '0421-123-456', 1),
    ('Sophie', 'Thompson', 'sophie.thompson@ausretail.com.au', '08-6456-7891', 'Marketing', 'Marketing Coordinator', 68000.00, '2021-01-20', 4, '0422-234-567', 1);
GO

PRINT '✓ 10 employees inserted!';
PRINT '';
GO

-- Insert Products
PRINT 'Adding products to our inventory';
PRINT '';

INSERT INTO Products (ProductName, Category, UnitPrice, CostPrice, StockQuantity, IsActive)
VALUES 
    ('iPhone 15 Pro', 'Electronics', 1799.00, 1350.00, 45, 1),
    ('Samsung Galaxy S24', 'Electronics', 1499.00, 1100.00, 38, 1),
    ('Sony WH-1000XM5 Headphones', 'Electronics', 549.00, 380.00, 67, 1),
    ('Apple MacBook Air M3', 'Electronics', 1999.00, 1500.00, 22, 1),
    ('Nike Air Max Sneakers', 'Footwear', 249.00, 150.00, 120, 1),
    ('Adidas Ultraboost', 'Footwear', 299.00, 180.00, 95, 1),
    ('Levi''s 501 Jeans', 'Clothing', 159.00, 90.00, 156, 1),
    ('Ralph Lauren Polo Shirt', 'Clothing', 129.00, 70.00, 203, 1),
    ('Dyson V15 Vacuum', 'Home Appliances', 1149.00, 750.00, 34, 1),
    ('Instant Pot Duo', 'Home Appliances', 179.00, 110.00, 87, 1);
GO

PRINT '✓ 10 products inserted!';
PRINT '';
GO

-- Insert Sales data
PRINT 'Adding recent sales transactions';
PRINT '';

INSERT INTO Sales (SaleDate, StoreID, ProductID, EmployeeID, Quantity, UnitPrice)
VALUES 
    -- Recent sales from different stores
    ('2024-12-15 10:30:00', 1, 1, 2, 2, 1799.00),  -- Melbourne: 2 iPhones
    ('2024-12-15 11:45:00', 1, 3, 2, 1, 549.00),   -- Melbourne: 1 Headphones
    ('2024-12-15 14:20:00', 2, 2, 5, 1, 1499.00),  -- Sydney: 1 Samsung
    ('2024-12-16 09:15:00', 2, 5, 5, 3, 249.00),   -- Sydney: 3 Nike Sneakers
    ('2024-12-16 10:30:00', 1, 7, 2, 2, 159.00),   -- Melbourne: 2 Jeans
    ('2024-12-16 13:45:00', 3, 4, 8, 1, 1999.00),  -- Brisbane: 1 MacBook
    ('2024-12-17 11:20:00', 4, 9, 10, 1, 1149.00), -- Perth: 1 Dyson
    ('2024-12-17 15:30:00', 2, 6, 5, 2, 299.00),   -- Sydney: 2 Adidas
    ('2024-12-18 10:00:00', 1, 8, 2, 4, 129.00),   -- Melbourne: 4 Polo Shirts
    ('2024-12-18 12:30:00', 3, 10, 8, 3, 179.00),  -- Brisbane: 3 Instant Pots
    ('2024-12-19 09:45:00', 2, 1, 5, 1, 1799.00),  -- Sydney: 1 iPhone
    ('2024-12-19 14:15:00', 1, 2, 2, 1, 1499.00),  -- Melbourne: 1 Samsung
    ('2024-12-20 11:00:00', 4, 3, 10, 2, 549.00),  -- Perth: 2 Headphones
    ('2024-12-20 16:20:00', 3, 5, 8, 1, 249.00),   -- Brisbane: 1 Nike Sneakers
    ('2024-12-21 10:30:00', 2, 7, 5, 3, 159.00);   -- Sydney: 3 Jeans
GO

PRINT '✓ 15 sales transactions inserted!';
PRINT '';
GO

-- -----------------------------------------------------------------------------
-- DML Example 2: UPDATE (Modifying existing data)
-- -----------------------------------------------------------------------------
PRINT '--- DML Example 2: UPDATE ---';
PRINT 'Scenario: Employee Sarah Johnson got a well-deserved raise!';
PRINT '';
PRINT 'BEFORE demonstrating the SAFE way to UPDATE...';
PRINT '';

-- DEMONSTRATION: The WRONG way (commented out to prevent disaster!)
PRINT '⚠️  DANGEROUS UPDATE (DO NOT RUN):';
PRINT '    UPDATE Employees SET Salary = 100000;';
PRINT '    ^ This would set EVERYONE to $100K!';
PRINT '';

-- DEMONSTRATION: The RIGHT way - Always SELECT first!
PRINT '✓ SAFE UPDATE - Step 1: Preview with SELECT';
SELECT EmployeeID, FirstName, LastName, Salary 
FROM Employees 
WHERE EmployeeID = 1;
GO

PRINT '';
PRINT '✓ SAFE UPDATE - Step 2: UPDATE with WHERE clause';
UPDATE Employees 
SET Salary = 100000.00 
WHERE EmployeeID = 1;
GO

PRINT '';
PRINT '✓ SAFE UPDATE - Step 3: Verify the change';
SELECT EmployeeID, FirstName, LastName, Salary 
FROM Employees 
WHERE EmployeeID = 1;
GO

PRINT '';
PRINT '✓ Sarah Johnson now earns $100,000!';
PRINT '';
GO

-- Another UPDATE example
PRINT 'Another UPDATE: Updating product stock after sales';
UPDATE Products 
SET StockQuantity = StockQuantity - 2 
WHERE ProductID = 1;
GO

PRINT '✓ iPhone stock reduced by 2 units';
PRINT '';
GO

-- -----------------------------------------------------------------------------
-- DML Example 3: DELETE (Removing data)
-- -----------------------------------------------------------------------------
PRINT '--- DML Example 3: DELETE ---';
PRINT 'Scenario: Removing a test employee record';
PRINT '';

-- First, insert a test record to delete
INSERT INTO Employees (FirstName, LastName, Email, Department, Position, Salary, HireDate, StoreID, IsActive)
VALUES ('Test', 'Employee', 'test@ausretail.com.au', 'Admin', 'Temporary', 50000.00, GETDATE(), 1, 0);
GO

PRINT '✓ Test employee inserted';
PRINT '';

-- Safe DELETE: Preview first
PRINT '✓ SAFE DELETE - Step 1: Preview what will be deleted';
SELECT * FROM Employees WHERE FirstName = 'Test' AND LastName = 'Employee';
GO

PRINT '';
PRINT '✓ SAFE DELETE - Step 2: DELETE with WHERE clause';
DELETE FROM Employees 
WHERE FirstName = 'Test' AND LastName = 'Employee';
GO

PRINT '';
PRINT '✓ Test employee deleted successfully';
PRINT '';
GO

-- -----------------------------------------------------------------------------
-- Summary: What we did with DML
-- -----------------------------------------------------------------------------
PRINT '--- DML SUMMARY ---';
PRINT 'We have MANIPULATED the data:';
PRINT '  ✓ Inserted stores, employees, products, sales (INSERT)';
PRINT '  ✓ Updated Sarah Johnson''s salary (UPDATE)';
PRINT '  ✓ Deleted test employee (DELETE)';
PRINT '';
PRINT 'Our library now has books on the shelves!';
PRINT '';
GO

/*
================================================================================
PART 3: DQL - DATA QUERY LANGUAGE
================================================================================
Purpose: QUERY (ask questions about) the data
Command: SELECT (100% safe, read-only)
Library Analogy: Searching the catalog, checking availability
This is 90% of a data analyst's job!
================================================================================
*/

PRINT '================================================================================';
PRINT 'PART 3: DQL - DATA QUERY LANGUAGE';
PRINT '================================================================================';
PRINT 'Now we SEARCH for information - like using a library catalog';
PRINT 'Remember: SELECT is 100% SAFE - it NEVER changes data!';
PRINT '';
GO

-- -----------------------------------------------------------------------------
-- DQL Example 1: Basic SELECT
-- -----------------------------------------------------------------------------
PRINT '--- DQL Example 1: Basic SELECT ---';
PRINT 'Question: Show me all stores in Victoria';
PRINT '';

SELECT 
    StoreID,
    StoreName,
    State,
    City,
    Manager,
    OpenDate
FROM Stores
WHERE State = 'VIC';
GO

PRINT '';
GO

-- Selects all columns and rows from the stores dataset
SELECT * from Stores;

-- -----------------------------------------------------------------------------
-- DQL Example 2: SELECT with Aggregation
-- -----------------------------------------------------------------------------
PRINT '--- DQL Example 2: SELECT with Aggregation ---';
PRINT 'Question: What is the total sales revenue per store?';
PRINT '';

SELECT 
    s.StoreName,
    s.State,
    COUNT(sa.SaleID) AS TotalTransactions,
    SUM(sa.TotalAmount) AS TotalRevenue,
    AVG(sa.TotalAmount) AS AverageTransaction
FROM Stores s
LEFT JOIN Sales sa ON s.StoreID = sa.StoreID
GROUP BY s.StoreName, s.State
ORDER BY TotalRevenue DESC;
GO

PRINT '';
GO

-- -----------------------------------------------------------------------------
-- DQL Example 3: SELECT with JOIN
-- -----------------------------------------------------------------------------
PRINT '--- DQL Example 3: SELECT with JOIN ---';
PRINT 'Question: Show me each sale with store, product, and employee details';
PRINT '';

SELECT TOP 5
    sa.SaleID,
    sa.SaleDate,
    st.StoreName,
    st.State,
    p.ProductName,
    p.Category,
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    sa.Quantity,
    sa.UnitPrice,
    sa.TotalAmount
FROM Sales sa
INNER JOIN Stores st ON sa.StoreID = st.StoreID
INNER JOIN Products p ON sa.ProductID = p.ProductID
INNER JOIN Employees e ON sa.EmployeeID = e.EmployeeID
ORDER BY sa.SaleDate DESC;
GO

PRINT '';
GO

-- -----------------------------------------------------------------------------
-- DQL Example 4: Complex Business Question
-- -----------------------------------------------------------------------------
PRINT '--- DQL Example 4: Complex Business Question ---';
PRINT 'Question: Which product categories generate the most revenue?';
PRINT '';

SELECT 
    p.Category,
    COUNT(DISTINCT sa.SaleID) AS NumberOfSales,
    SUM(sa.Quantity) AS TotalUnitsSold,
    SUM(sa.TotalAmount) AS TotalRevenue,
    AVG(sa.TotalAmount) AS AverageTransactionValue
FROM Sales sa
INNER JOIN Products p ON sa.ProductID = p.ProductID
GROUP BY p.Category
ORDER BY TotalRevenue DESC;
GO

PRINT '';
GO

-- -----------------------------------------------------------------------------
-- DQL Example 5: Employee Performance Report
-- -----------------------------------------------------------------------------
PRINT '--- DQL Example 5: Employee Performance Report ---';
PRINT 'Question: Who are our top-performing sales staff?';
PRINT '';

SELECT 
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    e.Position,
    st.StoreName,
    COUNT(sa.SaleID) AS NumberOfSales,
    SUM(sa.TotalAmount) AS TotalSalesRevenue,
    AVG(sa.TotalAmount) AS AverageSaleValue
FROM Employees e
INNER JOIN Sales sa ON e.EmployeeID = sa.EmployeeID
INNER JOIN Stores st ON e.StoreID = st.StoreID
WHERE e.Position LIKE '%Sales%'
GROUP BY e.FirstName, e.LastName, e.Position, st.StoreName
ORDER BY TotalSalesRevenue DESC;
GO

PRINT '';
GO

-- -----------------------------------------------------------------------------
-- Summary: What we did with DQL
-- -----------------------------------------------------------------------------
PRINT '--- DQL SUMMARY ---';
PRINT 'We QUERIED the data to answer business questions:';
PRINT '  ✓ Found stores in specific states (WHERE)';
PRINT '  ✓ Calculated revenue by store (SUM, GROUP BY)';
PRINT '  ✓ Combined multiple tables (JOIN)';
PRINT '  ✓ Identified top categories and employees (ORDER BY)';
PRINT '';
PRINT 'ALL of these were 100% SAFE - no data was changed!';
PRINT 'This is what data analysts do 90% of the time!';
PRINT '';
GO

/*
================================================================================
PART 4: TCL - TRANSACTION CONTROL LANGUAGE
================================================================================
Purpose: Control TRANSACTIONS (groups of changes)
Commands: BEGIN TRANSACTION, COMMIT, ROLLBACK, SAVEPOINT
Library Analogy: Try rearranging books - keep it or put them back
This is your UNDO button!
================================================================================
*/

PRINT '================================================================================';
PRINT 'PART 4: TCL - TRANSACTION CONTROL LANGUAGE';
PRINT '================================================================================';
PRINT 'This is your safety net - the UNDO button for databases!';
PRINT '';
GO

-- -----------------------------------------------------------------------------
-- TCL Example 1: ROLLBACK (The Undo Button)
-- -----------------------------------------------------------------------------
PRINT '--- TCL Example 1: ROLLBACK (The Undo Button) ---';
PRINT 'Scenario: We want to give everyone a 10% raise, but test it first';
PRINT '';

-- Step 1: Check current salaries
PRINT 'Step 1: Current salaries before transaction';
SELECT EmployeeID, FirstName, LastName, Salary 
FROM Employees 
WHERE EmployeeID <= 5
ORDER BY EmployeeID;
GO

PRINT '';
GO

-- Step 2: Start transaction and update
PRINT 'Step 2: BEGIN TRANSACTION and apply 10% raise';
BEGIN TRANSACTION;

UPDATE Employees 
SET Salary = Salary * 1.10;

-- Step 3: Check what changed
PRINT 'Step 3: Checking salaries after 10% raise';
SELECT EmployeeID, FirstName, LastName, Salary 
FROM Employees 
WHERE EmployeeID <= 5
ORDER BY EmployeeID;
GO

PRINT '';
PRINT 'Step 4: Hmm... that''s too expensive! Let''s ROLLBACK';
ROLLBACK;

PRINT '';
PRINT 'Step 5: After ROLLBACK - salaries are back to original!';
SELECT EmployeeID, FirstName, LastName, Salary 
FROM Employees 
WHERE EmployeeID <= 5
ORDER BY EmployeeID;
GO

PRINT '';
PRINT '✓ ROLLBACK saved us from an expensive mistake!';
PRINT '';
GO

-- -----------------------------------------------------------------------------
-- TCL Example 2: COMMIT (Making Changes Permanent)
-- -----------------------------------------------------------------------------
PRINT '--- TCL Example 2: COMMIT (Making Changes Permanent) ---';
PRINT 'Scenario: Give a 5% raise to IT department only';
PRINT '';

-- Step 1: Start transaction
PRINT 'Step 1: BEGIN TRANSACTION';
BEGIN TRANSACTION;

-- Step 2: Update IT salaries
UPDATE Employees 
SET Salary = Salary * 1.05 
WHERE Department = 'IT';

-- Step 3: Verify changes
PRINT 'Step 2: Verify the changes look correct';
SELECT FirstName, LastName, Department, Salary 
FROM Employees 
WHERE Department = 'IT';
GO

PRINT '';
PRINT 'Step 3: Changes look good! COMMIT to make them permanent';
COMMIT;

PRINT '';
PRINT '✓ IT department now has 5% raise - permanently saved!';
PRINT '';
GO

-- -----------------------------------------------------------------------------
-- TCL Example 3: The Professional Workflow
-- -----------------------------------------------------------------------------
PRINT '--- TCL Example 3: The Professional Workflow ---';
PRINT 'Scenario: Update product prices - the SAFE way';
PRINT '';

PRINT 'Step 1: BEGIN TRANSACTION';
BEGIN TRANSACTION;

PRINT 'Step 2: Preview what will change (SELECT)';
SELECT ProductID, ProductName, UnitPrice, 
       UnitPrice * 1.15 AS NewPrice
FROM Products
WHERE Category = 'Electronics';
GO

PRINT '';
PRINT 'Step 3: Apply the UPDATE';
UPDATE Products 
SET UnitPrice = UnitPrice * 1.15 
WHERE Category = 'Electronics';

PRINT '';
PRINT 'Step 4: Verify the changes (SELECT again)';
SELECT ProductID, ProductName, Category, UnitPrice
FROM Products
WHERE Category = 'Electronics';
GO

PRINT '';
PRINT 'Step 5: If correct, COMMIT. If wrong, ROLLBACK';
PRINT 'Let''s COMMIT this one:';
COMMIT;

PRINT '';
PRINT '✓ Electronics prices increased by 15% - permanently saved!';
PRINT '';
GO

-- -----------------------------------------------------------------------------
-- Summary: What we learned about TCL
-- -----------------------------------------------------------------------------
PRINT '--- TCL SUMMARY ---';
PRINT 'We used TRANSACTIONS for safety:';
PRINT '  ✓ BEGIN TRANSACTION - Start a group of changes';
PRINT '  ✓ ROLLBACK - Undo changes (saved us from 10% raise mistake!)';
PRINT '  ✓ COMMIT - Make changes permanent (IT raise, price updates)';
PRINT '';
PRINT 'Professional Workflow:';
PRINT '  1. BEGIN TRANSACTION';
PRINT '  2. SELECT to preview';
PRINT '  3. UPDATE/DELETE';
PRINT '  4. SELECT to verify';
PRINT '  5. COMMIT if correct, ROLLBACK if wrong';
PRINT '';
PRINT '⚠️  ALWAYS use transactions for UPDATE/DELETE!';
PRINT '';
GO

/*
================================================================================
PART 5: DCL - DATA CONTROL LANGUAGE
================================================================================
Purpose: Control WHO can access WHAT
Commands: GRANT, REVOKE
Library Analogy: Issue library cards, set borrowing permissions
Note: Requires database administrator privileges
================================================================================
*/

PRINT '================================================================================';
PRINT 'PART 5: DCL - DATA CONTROL LANGUAGE';
PRINT '================================================================================';
PRINT 'Controlling who can access what - like issuing library cards';
PRINT '';
GO

-- -----------------------------------------------------------------------------
-- DCL Examples (Demonstration Only - May require admin rights)
-- -----------------------------------------------------------------------------
PRINT '--- DCL Examples (Conceptual Demonstration) ---';
PRINT '';
PRINT 'As a data analyst, you probably won''t write these commands daily.';
PRINT 'Your DBA (Database Administrator) handles this.';
PRINT 'But you should understand the concepts!';
PRINT '';

-- Example 1: GRANT permissions
PRINT 'Example 1: GRANT permissions to a role';
PRINT '';
PRINT 'Imagine we have a "Marketing_Team" role:';
PRINT '  GRANT SELECT ON Sales TO Marketing_Team;';
PRINT '  → Marketing can READ sales data';
PRINT '';
PRINT '  GRANT INSERT, UPDATE ON Products TO Product_Team;';
PRINT '  → Product team can ADD and EDIT products';
PRINT '';

-- Example 2: REVOKE permissions
PRINT 'Example 2: REVOKE permissions';
PRINT '';
PRINT '  REVOKE DELETE ON Products FROM Junior_Analysts;';
PRINT '  → Junior analysts cannot DELETE products';
PRINT '';

-- -----------------------------------------------------------------------------
-- Summary: What we learned about DCL
-- -----------------------------------------------------------------------------
PRINT '--- DCL SUMMARY ---';
PRINT 'DCL controls access and permissions:';
PRINT '  ✓ GRANT - Give permissions to users/roles';
PRINT '  ✓ REVOKE - Take away permissions';
PRINT '';
PRINT 'As an analyst, you work WITHIN your granted permissions.';
PRINT 'DBAs manage who can do what.';
PRINT '';
GO

/*
================================================================================
FINAL SUMMARY: THE 5 TYPES OF SQL
================================================================================
*/

PRINT '================================================================================';
PRINT 'FINAL SUMMARY: THE 5 TYPES OF SQL';
PRINT '================================================================================';
PRINT '';
PRINT '1️⃣  DDL (Data Definition Language) - Define STRUCTURE';
PRINT '    Commands: CREATE, ALTER, DROP, TRUNCATE';
PRINT '    Library: Building shelves, creating sections';
PRINT '    When: Setting up databases, adding columns';
PRINT '';
PRINT '2️⃣  DML (Data Manipulation Language) - Manipulate DATA';
PRINT '    Commands: INSERT, UPDATE, DELETE';
PRINT '    Library: Adding books, updating info, removing damaged books';
PRINT '    When: Loading data, correcting errors, cleaning data';
PRINT '    ⚠️  WARNING: Always use with transactions!';
PRINT '';
PRINT '3️⃣  DQL (Data Query Language) - Query DATA';
PRINT '    Command: SELECT (100% SAFE!)';
PRINT '    Library: Searching catalog, checking availability';
PRINT '    When: EVERY DAY as a data analyst!';
PRINT '    ✓ This is 90% of your job!';
PRINT '';
PRINT '4️⃣  TCL (Transaction Control Language) - Control TRANSACTIONS';
PRINT '    Commands: BEGIN TRANSACTION, COMMIT, ROLLBACK';
PRINT '    Library: Try rearranging - keep it or put back';
PRINT '    When: ALWAYS with UPDATE/DELETE!';
PRINT '    ✓ Your undo button!';
PRINT '';
PRINT '5️⃣  DCL (Data Control Language) - Control ACCESS';
PRINT '    Commands: GRANT, REVOKE';
PRINT '    Library: Issue cards, set permissions';
PRINT '    When: DBAs manage this, analysts use permissions';
PRINT '';
PRINT '================================================================================';
PRINT 'KEY TAKEAWAYS FOR DATA ANALYSTS';
PRINT '================================================================================';
PRINT '';
PRINT '✓ 90% of your work = DQL (SELECT queries)';
PRINT '✓ SELECT is 100% safe - query all day with zero risk!';
PRINT '✓ ALWAYS use transactions before UPDATE/DELETE';
PRINT '✓ Test with SELECT before running UPDATE/DELETE';
PRINT '✓ Never UPDATE/DELETE without WHERE clause!';
PRINT '';
PRINT '================================================================================';
PRINT 'YOU ARE NOW READY FOR VIDEO 1!';
PRINT '================================================================================';
PRINT '';
PRINT 'Next: Video 1 - The SQL Analyst''s First Day';
PRINT 'You''ll answer real business questions using SELECT queries';
PRINT 'Foundation complete - let''s solve business problems!';
PRINT '';
GO

-- ============================================================================
-- BONUS: Quick Reference Queries
-- ============================================================================
PRINT '================================================================================';
PRINT 'BONUS: QUICK REFERENCE QUERIES';
PRINT '================================================================================';
PRINT 'Save these for practice after the session!';
PRINT '';
GO

-- View all tables created
PRINT '--- View all tables in the database ---';
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO

PRINT '';
GO

-- View row counts
PRINT '--- Row counts for each table ---';
SELECT 'Stores' AS TableName, COUNT(*) AS RowCount FROM Stores
UNION ALL
SELECT 'Employees', COUNT(*) FROM Employees
UNION ALL
SELECT 'Products', COUNT(*) FROM Products
UNION ALL
SELECT 'Sales', COUNT(*) FROM Sales;
GO

PRINT '';
PRINT '✓ Demo script completed successfully!';
PRINT '✓ Database ready for student practice';
PRINT '';
PRINT 'Happy teaching, Fassahat! 🎓';
GO
