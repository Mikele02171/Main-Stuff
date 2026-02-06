/*
================================================================================
SQL FOUNDATIONS - STUDENT PRACTICE EXERCISES
================================================================================
Course: SQL Foundations - Understanding the Language
Video: 0 of 15 - Before You Start Coding
Instructor: Fassahat Ahmad
Purpose: Hands-on exercises for students to practice the 5 SQL types
Database: AusRetail_Demo (must run main demo script first!)
================================================================================

INSTRUCTIONS FOR STUDENTS:
1. Run the main demo script (SQL_Foundations_Demo_Script.sql) first
2. Work through these exercises in order
3. Check your answers at the bottom of this file
4. Remember: SELECT is safe - practice freely!
5. Use transactions for UPDATE/DELETE exercises!

================================================================================
*/

USE AusRetail_Demo;
GO

PRINT '================================================================================';
PRINT 'SQL FOUNDATIONS - STUDENT PRACTICE EXERCISES';
PRINT '================================================================================';
PRINT '';
PRINT 'Complete the exercises below. Solutions are at the end of this file.';
PRINT 'Remember the 5 types: DDL, DML, DQL, DCL, TCL';
PRINT '';
GO

/*
================================================================================
SECTION 1: DQL EXERCISES (Data Query Language)
================================================================================
These are 100% SAFE - practice as much as you want!
*/

PRINT '================================================================================';
PRINT 'SECTION 1: DQL EXERCISES';
PRINT '================================================================================';
PRINT 'Remember: SELECT is read-only and completely safe!';
PRINT '';
GO

-- Exercise 1.1: Basic SELECT with WHERE
PRINT '--- Exercise 1.1: Basic SELECT with WHERE ---';
PRINT 'Task: Find all stores in New South Wales (NSW)';
PRINT 'Expected columns: StoreName, City, Manager';
PRINT '';
PRINT '-- YOUR SQL HERE:';
SELECT StoreName,City,Manager
FROM Stores
WHERE State = 'NSW';
GO

-- Exercise 1.2: SELECT with Aggregation
PRINT '--- Exercise 1.2: SELECT with Aggregation ---';
PRINT 'Task: Calculate the average salary by department';
PRINT 'Expected columns: Department, AverageSalary, NumberOfEmployees';
PRINT 'Hint: Use AVG(), COUNT(), and GROUP BY';
PRINT '';
PRINT '-- YOUR SQL HERE:';
SELECT Department, AVG(Salary) as AverageSalary, COUNT(EmployeeID) as NumberOfEmployees
FROM Employees
GROUP BY Department
ORDER BY AverageSalary DESC;
PRINT '';
PRINT '';
GO

-- Exercise 1.3: SELECT with JOIN
PRINT '--- Exercise 1.3: SELECT with JOIN ---';
PRINT 'Task: Show all sales with store name, product name, and employee name';
PRINT 'Expected columns: SaleDate, StoreName, ProductName, EmployeeName, TotalAmount';
PRINT 'Hint: You need to JOIN 4 tables (Sales, Stores, Products, Employees)';
PRINT '';
PRINT '-- YOUR SQL HERE:';
SELECT
sa.SaleDate,
st.StoreName,
p.ProductName,
e.FirstName + ' ' + e.LastName AS EmployeeName,
sa.TotalAmount
FROM Sales sa
INNER JOIN Stores st ON sa.StoreID = st.StoreID
INNER JOIN Products p ON sa.ProductID = p.ProductID
INNER JOIN Employees e ON sa.EmployeeID = e.EmployeeID
ORDER BY sa.SaleDate DESC;
PRINT '';
PRINT '';
GO

-- Exercise 1.4: Business Analysis Query
PRINT '--- Exercise 1.4: Business Analysis Query ---';
PRINT 'Task: Find which store has generated the most revenue';
PRINT 'Expected columns: StoreName, State, TotalRevenue, NumberOfSales';
PRINT 'Hint: Use SUM(), COUNT(), GROUP BY, and ORDER BY';
PRINT '';
PRINT '-- YOUR SQL HERE:';
SELECT 
TOP (1) st.StoreName,
st.[State], 
SUM(sa.TotalAmount) as TotalRevenue,
COUNT(sa.SaleID) as NumberOfSales
FROM Sales sa
INNER JOIN Stores st ON sa.StoreID = st.StoreID
GROUP BY st.StoreName,st.[State]
ORDER BY TotalRevenue DESC;
PRINT '';
PRINT '';
GO

-- Exercise 1.5: Advanced Query
PRINT '--- Exercise 1.5: Advanced Query ---';
PRINT 'Task: Find products that have sold more than 3 units total';
PRINT 'Expected columns: ProductName, Category, TotalUnitsSold, TotalRevenue';
PRINT 'Hint: Use JOIN, SUM(), GROUP BY, and HAVING';
PRINT '';
PRINT '-- YOUR SQL HERE:';
SELECT 
p.ProductName,
p.Category,
SUM(sa.Quantity) AS TotalUnitsSold,
SUM(sa.TotalAmount) AS TotalRevenue
FROM Sales sa
INNER JOIN Products p ON p.ProductID = sa.ProductID
GROUP BY p.ProductName, p.Category
HAVING SUM(sa.Quantity) > 3;
PRINT '';
PRINT '';
GO

/*
================================================================================
SECTION 2: DML EXERCISES (Data Manipulation Language)
================================================================================
⚠️  WARNING: These change data! Always use transactions!
*/

PRINT '================================================================================';
PRINT 'SECTION 2: DML EXERCISES';
PRINT '================================================================================';
PRINT '⚠️  WARNING: Always use BEGIN TRANSACTION before UPDATE/DELETE!';
PRINT '';
GO

-- Exercise 2.1: INSERT new data
PRINT '--- Exercise 2.1: INSERT new data ---';
PRINT 'Task: Add a new product to the Products table';
PRINT 'Product Details:';
PRINT '  - ProductName: "Apple AirPods Pro"';
PRINT '  - Category: "Electronics"';
PRINT '  - UnitPrice: 399.00';
PRINT '  - CostPrice: 280.00';
PRINT '  - StockQuantity: 50';
PRINT '  - IsActive: 1';
PRINT '';
PRINT '-- YOUR SQL HERE:';
PRINT '';
PRINT '';
GO


INSERT INTO Products (ProductName, Category, UnitPrice, CostPrice, StockQuantity, IsActive)
VALUES 
    ('Apple AirPods Pro', 'Electronics', 399.00, 280.00, 50,1);
GO

PRINT '✓ Inserted new product into Products!';
PRINT '';
GO


-- Exercise 2.2: UPDATE with WHERE
PRINT '--- Exercise 2.2: UPDATE with WHERE ---';
PRINT 'Task: Increase the stock quantity of all Footwear products by 10';
PRINT 'Steps:';
PRINT '  1. BEGIN TRANSACTION';
PRINT '  2. SELECT to preview (WHERE Category = ''Footwear'')';
PRINT '  3. UPDATE StockQuantity = StockQuantity + 10';
PRINT '  4. SELECT again to verify';
PRINT '  5. COMMIT or ROLLBACK';
PRINT '';
PRINT '-- YOUR SQL HERE:';
PRINT '';
PRINT '';
GO

PRINT '✓ SAFE UPDATE - Step 1: Preview with SELECT';
SELECT * -- For my learning 
FROM Products
WHERE Category = 'Footwear';
GO

PRINT '';
PRINT '✓ SAFE UPDATE - Step 2: UPDATE with WHERE clause';
UPDATE Products
SET StockQuantity = StockQuantity + 10
WHERE Category = 'Footwear';
GO

PRINT '';
PRINT '✓ SAFE UPDATE - Step 3: Verify the change';
SELECT * -- For my learning 
FROM Products
WHERE Category = 'Footwear';
GO



-- Exercise 2.3: DELETE with WHERE
PRINT '--- Exercise 2.3: DELETE with WHERE ---';
PRINT 'Task: First INSERT a test employee, then DELETE them';
PRINT 'Test Employee Details:';
PRINT '  - FirstName: "Practice"';
PRINT '  - LastName: "Student"';
PRINT '  - Email: "practice.student@ausretail.com.au"';
PRINT '  - Department: "Training"';
PRINT '  - Position: "Intern"';
PRINT '  - Salary: 45000.00';
PRINT '  - HireDate: Today''s date';
PRINT '  - StoreID: 1';
PRINT '';
PRINT 'Steps:';
PRINT '  1. INSERT the test employee';
PRINT '  2. SELECT to confirm insertion';
PRINT '  3. BEGIN TRANSACTION';
PRINT '  4. DELETE the test employee';
PRINT '  5. SELECT to verify deletion';
PRINT '  6. COMMIT';
PRINT '';
PRINT '-- YOUR SQL HERE:';

PRINT '✓ UPDATE - Step 1: Insert a new employee';
INSERT INTO Employees (FirstName, LastName, Email, Department, Position, Salary,HireDate,StoreID)
VALUES 
    ('Practice','Student','practice.student@ausretail.com.au','Training','Intern',45000.00,GETDATE(),1);
GO

PRINT '✓ Inserted new Employee into Employees!';
PRINT '';
GO

PRINT '✓ UPDATE - Step 2: SELECT to confirm insertion';
SELECT EmployeeID, FirstName, LastName, Salary 
FROM Employees 
WHERE EmployeeID = 12;
GO

PRINT '✓ UPDATE - Step 3: BEGIN TRANSACTION';
UPDATE Employees 
SET Salary = 100000.00 
WHERE EmployeeID = 12;
GO

PRINT '✓ SEE THE UPDATE';
SELECT EmployeeID, FirstName, LastName, Salary 
FROM Employees 
WHERE EmployeeID = 12;
GO

PRINT '✓ UPDATE - Step 4: DELETE the test employee';
BEGIN TRANSACTION;

DELETE FROM Employees 
WHERE FirstName = 'Practice' AND LastName = 'Student';
GO

PRINT '';
PRINT '✓ Test employee deleted successfully';
PRINT '';
GO

PRINT '✓ UPDATE - Step 5: SELECT to confirm deletion';
DELETE FROM Employees 
SELECT EmployeeID, FirstName, LastName, Salary 
FROM Employees 
WHERE EmployeeID = 12;
GO

PRINT '';
PRINT '✓ Test employee deleted successfully';
PRINT '';
GO

PRINT '✓ UPDATE - Step 6: COMMIT';
COMMIT;
GO
PRINT '';
GO

/*
================================================================================
SECTION 3: DDL EXERCISES (Data Definition Language)
================================================================================
These change the database structure!
*/

PRINT '================================================================================';
PRINT 'SECTION 3: DDL EXERCISES';
PRINT '================================================================================';
PRINT 'These commands modify the database structure';
PRINT '';
GO

-- Exercise 3.1: CREATE TABLE
PRINT '--- Exercise 3.1: CREATE TABLE ---';
PRINT 'Task: Create a new table called "Customers"';
PRINT 'Columns:';
PRINT '  - CustomerID (INT, Primary Key, Auto-increment)';
PRINT '  - FirstName (NVARCHAR(50), NOT NULL)';
PRINT '  - LastName (NVARCHAR(50), NOT NULL)';
PRINT '  - Email (NVARCHAR(100))';
PRINT '  - Phone (NVARCHAR(20))';
PRINT '  - City (NVARCHAR(50))';
PRINT '  - State (NVARCHAR(3))';
PRINT '  - JoinDate (DATE, NOT NULL, DEFAULT today)';
PRINT '  - IsActive (BIT, DEFAULT 1)';
PRINT '';
PRINT '-- YOUR SQL HERE:';
PRINT '';
PRINT '';
GO

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100),
    Phone NVARCHAR(20),
    City NVARCHAR(50),
    State NVARCHAR(3),
    JoinDate DATE NOT NULL DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1
);
GO

-- Exercise 3.2: ALTER TABLE
PRINT '--- Exercise 3.2: ALTER TABLE ---';
PRINT 'Task: Add a new column to the Employees table';
PRINT 'Column Details:';
PRINT '  - Column Name: EmergencyContact';
PRINT '  - Data Type: NVARCHAR(100)';
PRINT '';
PRINT '-- YOUR SQL HERE:';
PRINT '';
PRINT '';
GO


ALTER TABLE Employees 
ADD EmergencyContact NVARCHAR(100);
GO
PRINT '✓ EmergencyContact column added to Employees table!';
PRINT '';
GO

-- Exercise 3.3: CREATE INDEX
PRINT '--- Exercise 3.3: CREATE INDEX ---';
PRINT 'Task: Create an index on the Products table for the Category column';
PRINT 'Index Name: idx_Products_Category';
PRINT 'Hint: This will speed up queries that filter by Category';
PRINT '';
PRINT '-- YOUR SQL HERE:';
PRINT '';
PRINT '';
GO

CREATE INDEX idx_Products_Category 
ON Products(Category);
GO

/*
================================================================================
SECTION 4: TCL EXERCISES (Transaction Control Language)
================================================================================
Practice the safety net!
*/

PRINT '================================================================================';
PRINT 'SECTION 4: TCL EXERCISES';
PRINT '================================================================================';
PRINT 'Master the art of safe data manipulation!';
PRINT '';
GO

-- Exercise 4.1: ROLLBACK Practice
PRINT '--- Exercise 4.1: ROLLBACK Practice ---';
PRINT 'Task: Practice using ROLLBACK to undo changes';
PRINT 'Steps:';
PRINT '  1. BEGIN TRANSACTION';
PRINT '  2. UPDATE all products to increase UnitPrice by 50%';
PRINT '  3. SELECT to see the changes';
PRINT '  4. ROLLBACK to undo (prices too high!)';
PRINT '  5. SELECT again to verify prices are back to normal';
PRINT '';
PRINT '-- YOUR SQL HERE:';

-- Step 1: Check current salaries
PRINT 'Step 1: Current products before transaction';
SELECT *
FROM Products
WHERE ProductID <= 5
ORDER BY ProductID;
GO

PRINT '';
GO

-- Step 2: Start transaction and update
PRINT 'Step 2: BEGIN TRANSACTION and apply increase UnitPrice by 50%';
BEGIN TRANSACTION;

UPDATE Products
SET UnitPrice = UnitPrice * 1.50;

PRINT '';
GO

-- Step 3: Check what changed
PRINT 'Step 3: Checking salaries after 50% raise';
SELECT *
FROM Products
WHERE ProductID <= 5
ORDER BY ProductID;
GO


--SPECIAL NOTE: STEP 4 ROLLBACK; THIS IS IN CASE YOU MADE A MISTAKE YOU CAN UNDO WHEN RUNNING THE TRANSACTION;

-- Step 5: Check what changed
PRINT 'Step 5: again to verify prices are back to normal';
SELECT *
FROM Products
WHERE ProductID <= 5
ORDER BY ProductID;
GO


-- Exercise 4.2: COMMIT Practice
PRINT '--- Exercise 4.2: COMMIT Practice ---';
PRINT 'Task: Give all Management employees a 3% raise';
PRINT 'Steps:';
PRINT '  1. BEGIN TRANSACTION';
PRINT '  2. SELECT to preview (WHERE Position = ''Store Manager'')';
PRINT '  3. UPDATE Salary = Salary * 1.03';
PRINT '  4. SELECT to verify changes';
PRINT '  5. COMMIT to save permanently';
PRINT '';
PRINT '-- YOUR SQL HERE:';
-- Before Proceeding: Check current salaries
PRINT 'Step 1: Current salaries for manager employees before transaction';
SELECT FirstName,LastName,Position,Salary
FROM Employees
WHERE Position = 'Store Manager'
PRINT '';
GO

-- Steps 1,2 and 3: Start transaction and update Salaries for Store Managers Only
PRINT 'Step 2: UPDATE Salary = Salary * 1.03';
BEGIN TRANSACTION;
UPDATE Employees
SET Salary = Salary * 1.03
WHERE Position = 'Store Manager';

PRINT '';
GO

-- Step 4: Check what changed
PRINT 'Step 3: Checking salaries after 3% raise for store managers';
SELECT FirstName,LastName,Position,Salary
FROM Employees
WHERE Position = 'Store Manager'
PRINT '';
GO

--MAKING SURE, the rest don't get a 3% increase in salary
SELECT FirstName,LastName,Position,Salary
FROM Employees;
PRINT '';
GO


--Step 5 COMMIT
PRINT 'Commit these changes';
COMMIT;
GO

--ROLLBACK; Again in case of mistake

PRINT '';
PRINT '';
GO

/*
================================================================================
SECTION 5: MIXED CHALLENGE EXERCISES
================================================================================
Combine multiple SQL types to solve real business problems!
*/

PRINT '================================================================================';
PRINT 'SECTION 5: MIXED CHALLENGE EXERCISES';
PRINT '================================================================================';
PRINT 'Real-world scenarios combining multiple SQL types';
PRINT '';
GO

-- Challenge 1: New Store Setup
PRINT '--- Challenge 1: New Store Setup ---';
PRINT 'Scenario: AusRetail is opening a new store in Gold Coast, Queensland';
PRINT 'Tasks:';
PRINT '  1. INSERT new store:';
PRINT '     - StoreName: "AusRetail Gold Coast"';
PRINT '     - State: "QLD"';
PRINT '     - City: "Gold Coast"';
PRINT '     - Manager: "Your Name"';
PRINT '     - OpenDate: Today';
PRINT '     - StoreSize: 720';
PRINT '     - IsActive: 1';
PRINT '  2. INSERT yourself as the new store manager:';
PRINT '     - Use your actual name';
PRINT '     - Department: "Management"';
PRINT '     - Position: "Store Manager"';
PRINT '     - Salary: 88000.00';
PRINT '     - HireDate: Today';
PRINT '     - StoreID: (use the new store you just created)';
PRINT '  3. SELECT to verify both records were created';
PRINT '';
PRINT '-- YOUR SQL HERE:';


INSERT INTO Stores (StoreName, State, City, Manager, OpenDate, StoreSize,IsActive)
VALUES 
    -- My New Store
    ('AusRetail Gold Coast','QLD', 'Gold Coast', 'Michael Le', GETDATE(), 720,1); 
GO

PRINT 'Opened my New Store';

INSERT INTO Employees (FirstName, LastName, Department, Position, Salary, HireDate, StoreID)
VALUES 
    -- New Employee
    ('Michael','Le','Management','Store Manager',88000.00,GETDATE(),9); 
GO
PRINT 'Hired new Manager';

--Check the new enquiries 
SELECT * FROM Stores WHERE Manager = 'Michael Le';
SELECT * FROM Employees WHERE FirstName = 'Michael' and LastName = 'Le';


-- Challenge 2: Sales Analysis Report
PRINT '--- Challenge 2: Sales Analysis Report ---';
PRINT 'Scenario: Your manager needs a comprehensive sales report';
PRINT 'Task: Create a query that shows:';
PRINT '  - Each store''s name and state';
PRINT '  - Total revenue';
PRINT '  - Number of transactions';
PRINT '  - Average transaction value';
PRINT '  - Best selling product (product with highest revenue)';
PRINT '  - Sort by total revenue (highest first)';
PRINT 'Hint: This is complex! You may need subqueries or CTEs'; --Unsure google it
PRINT '';
PRINT '-- YOUR SQL HERE:';
SELECT st.StoreName, st.state, SUM(sa.TotalAmount) AS TotalRevenue, COUNT(sa.SaleID) as TotalTransactions, 
AVG(sa.TotalAmount) AS AverageTransaction 
FROM Stores st
LEFT JOIN Sales sa ON st.StoreID = sa.StoreID 
GROUP BY st.StoreName, st.State
ORDER BY TotalRevenue DESC;



PRINT '';
GO

-- Challenge 3: Data Cleanup
PRINT '--- Challenge 3: Data Cleanup ---';
PRINT 'Scenario: Clean up inactive records safely';
PRINT 'Tasks:';
PRINT '  1. Find all employees marked as inactive (IsActive = 0)';
PRINT '  2. Using a transaction, DELETE these inactive employees';
PRINT '  3. Verify the deletion';
PRINT '  4. Decide whether to COMMIT or ROLLBACK';
PRINT 'Remember: Use the professional workflow!';
PRINT '';
PRINT '-- YOUR SQL HERE:';

-- Since there is no entries of employees that has isActive = 0, otherwise follow the steps, similarly in SECTION 4
SELECT EmployeeID,FirstName,LastName,IsActive
FROM employees WHERE isActive = 0;



PRINT '';
PRINT '';
GO

/*
================================================================================
BONUS CHALLENGE: Build Your Own Analytics
================================================================================
*/

PRINT '================================================================================';
PRINT 'BONUS CHALLENGE: Build Your Own Analytics';
PRINT '================================================================================';
PRINT '';
GO

PRINT 'Task: Answer this business question:';
PRINT '"Which employees have generated more than $5,000 in sales,';
PRINT ' and what is their sales performance ranking?"';
PRINT '';
PRINT 'Your query should show:';
PRINT '  - Employee name';
PRINT '  - Store name';
PRINT '  - Total sales revenue';
PRINT '  - Number of sales transactions';
PRINT '  - Performance ranking (1 = best, 2 = second, etc.)';
PRINT 'Hint: Use window functions like ROW_NUMBER() or RANK()'; --Again, when in doubt use Google
PRINT '';
PRINT '-- YOUR SQL HERE:';
--My Attempt
SELECT e.FirstName,
e.LastName,
st.StoreName,
SUM(sa.TotalAmount) AS TotalSalesRevenue,
COUNT(sa.SaleID) AS NumberOfSales,
ROW_NUMBER() OVER (ORDER BY SUM(sa.TotalAmount) DESC) row_number
FROM employees e 
INNER JOIN Sales sa ON e.EmployeeID = sa.EmployeeID
INNER JOIN Stores st ON e.StoreID = st.StoreID
GROUP BY e.FirstName,e.LastName,st.StoreName
HAVING SUM(sa.TotalAmount) > 5000;

PRINT '';
PRINT '';
GO

/*
================================================================================
SOLUTIONS SECTION
================================================================================
Scroll down to see solutions after attempting the exercises!
(Leave some space so students don't accidentally see answers)
*/

PRINT '';
PRINT '';
PRINT '';
PRINT '';
PRINT '';
PRINT '';
PRINT '';
PRINT '';
PRINT '';
PRINT '';
GO

PRINT '================================================================================';
PRINT 'SOLUTIONS';
PRINT '================================================================================';
PRINT 'Only look at these AFTER attempting the exercises yourself!';
PRINT '';
GO

-- Solution 1.1
PRINT '--- Solution 1.1: Basic SELECT with WHERE ---';
SELECT 
    StoreName, 
    City, 
    Manager
FROM Stores
WHERE State = 'NSW';
GO

PRINT '';
GO

-- Solution 1.2
PRINT '--- Solution 1.2: SELECT with Aggregation ---';
SELECT 
    Department,
    AVG(Salary) AS AverageSalary,
    COUNT(*) AS NumberOfEmployees
FROM Employees
GROUP BY Department
ORDER BY AverageSalary DESC;
GO

PRINT '';
GO

-- Solution 1.3
PRINT '--- Solution 1.3: SELECT with JOIN ---';
SELECT 
    sa.SaleDate,
    st.StoreName,
    p.ProductName,
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    sa.TotalAmount
FROM Sales sa
INNER JOIN Stores st ON sa.StoreID = st.StoreID
INNER JOIN Products p ON sa.ProductID = p.ProductID
INNER JOIN Employees e ON sa.EmployeeID = e.EmployeeID
ORDER BY sa.SaleDate DESC;
GO

PRINT '';
GO

-- Solution 1.4
PRINT '--- Solution 1.4: Business Analysis Query ---';
SELECT 
    st.StoreName,
    st.State,
    SUM(sa.TotalAmount) AS TotalRevenue,
    COUNT(sa.SaleID) AS NumberOfSales
FROM Stores st
LEFT JOIN Sales sa ON st.StoreID = sa.StoreID
GROUP BY st.StoreName, st.State
ORDER BY TotalRevenue DESC;
GO

PRINT '';
GO

-- Solution 1.5
PRINT '--- Solution 1.5: Advanced Query ---';
SELECT 
    p.ProductName,
    p.Category,
    SUM(sa.Quantity) AS TotalUnitsSold,
    SUM(sa.TotalAmount) AS TotalRevenue
FROM Products p
INNER JOIN Sales sa ON p.ProductID = sa.ProductID
GROUP BY p.ProductName, p.Category
HAVING SUM(sa.Quantity) > 3
ORDER BY TotalRevenue DESC;
GO

PRINT '';
GO

-- Solution 2.1
PRINT '--- Solution 2.1: INSERT new data ---';
INSERT INTO Products (ProductName, Category, UnitPrice, CostPrice, StockQuantity, IsActive)
VALUES ('Apple AirPods Pro', 'Electronics', 399.00, 280.00, 50, 1);

SELECT * FROM Products WHERE ProductName = 'Apple AirPods Pro';
GO

PRINT '';
GO

-- Solution 2.2
PRINT '--- Solution 2.2: UPDATE with WHERE ---';
-- Step 1: Preview
SELECT ProductID, ProductName, Category, StockQuantity 
FROM Products 
WHERE Category = 'Footwear';

-- Step 2: Transaction
BEGIN TRANSACTION;

UPDATE Products 
SET StockQuantity = StockQuantity + 10 
WHERE Category = 'Footwear';

-- Step 3: Verify
SELECT ProductID, ProductName, Category, StockQuantity 
FROM Products 
WHERE Category = 'Footwear';

-- Step 4: Commit
COMMIT;
GO

PRINT '';
GO

-- Solution 2.3
PRINT '--- Solution 2.3: DELETE with WHERE ---';
-- Step 1: Insert
INSERT INTO Employees (FirstName, LastName, Email, Department, Position, Salary, HireDate, StoreID)
VALUES ('Practice', 'Student', 'practice.student@ausretail.com.au', 'Training', 'Intern', 45000.00, GETDATE(), 1);

-- Step 2: Verify insertion
SELECT * FROM Employees WHERE FirstName = 'Practice' AND LastName = 'Student';

-- Step 3-6: Safe deletion
BEGIN TRANSACTION;

DELETE FROM Employees 
WHERE FirstName = 'Practice' AND LastName = 'Student';

SELECT * FROM Employees WHERE FirstName = 'Practice' AND LastName = 'Student';

COMMIT;
GO

PRINT '';
GO

-- Solution 3.1
PRINT '--- Solution 3.1: CREATE TABLE ---';
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100),
    Phone NVARCHAR(20),
    City NVARCHAR(50),
    State NVARCHAR(3),
    JoinDate DATE NOT NULL DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1
);
GO

PRINT '';
GO

-- Solution 3.2
PRINT '--- Solution 3.2: ALTER TABLE ---';
ALTER TABLE Employees 
ADD EmergencyContact NVARCHAR(100);
GO

PRINT '';
GO

-- Solution 3.3
PRINT '--- Solution 3.3: CREATE INDEX ---';
CREATE INDEX idx_Products_Category 
ON Products(Category);
GO

PRINT '';
GO

-- Solution 4.1
PRINT '--- Solution 4.1: ROLLBACK Practice ---';
-- Before transaction
SELECT ProductID, ProductName, UnitPrice FROM Products;

BEGIN TRANSACTION;

UPDATE Products 
SET UnitPrice = UnitPrice * 1.50;

-- Check changes
SELECT ProductID, ProductName, UnitPrice FROM Products;

-- Undo!
ROLLBACK;

-- Verify rollback
SELECT ProductID, ProductName, UnitPrice FROM Products;
GO

PRINT '';
GO

-- Solution 4.2
PRINT '--- Solution 4.2: COMMIT Practice ---';
BEGIN TRANSACTION;

-- Preview
SELECT EmployeeID, FirstName, LastName, Position, Salary 
FROM Employees 
WHERE Position = 'Store Manager';

-- Update
UPDATE Employees 
SET Salary = Salary * 1.03 
WHERE Position = 'Store Manager';

-- Verify
SELECT EmployeeID, FirstName, LastName, Position, Salary 
FROM Employees 
WHERE Position = 'Store Manager';

-- Make permanent
COMMIT;
GO

PRINT '';
GO

-- Solution Challenge 2
PRINT '--- Solution Challenge 2: Sales Analysis Report ---';
SELECT 
    st.StoreName,
    st.State,
    ISNULL(SUM(sa.TotalAmount), 0) AS TotalRevenue,
    COUNT(sa.SaleID) AS NumberOfTransactions,
    ISNULL(AVG(sa.TotalAmount), 0) AS AverageTransactionValue
FROM Stores st
LEFT JOIN Sales sa ON st.StoreID = sa.StoreID
GROUP BY st.StoreName, st.State
ORDER BY TotalRevenue DESC;
GO

PRINT '';
GO

-- Bonus Challenge Solution
PRINT '--- Bonus Challenge Solution ---';
SELECT 
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    st.StoreName,
    SUM(sa.TotalAmount) AS TotalSalesRevenue,
    COUNT(sa.SaleID) AS NumberOfSales,
    ROW_NUMBER() OVER (ORDER BY SUM(sa.TotalAmount) DESC) AS PerformanceRank
FROM Employees e
INNER JOIN Sales sa ON e.EmployeeID = sa.EmployeeID
INNER JOIN Stores st ON e.StoreID = st.StoreID
GROUP BY e.FirstName, e.LastName, st.StoreName
HAVING SUM(sa.TotalAmount) > 5000
ORDER BY TotalSalesRevenue DESC;
GO

PRINT '';
PRINT '================================================================================';
PRINT 'CONGRATULATIONS!';
PRINT '================================================================================';
PRINT 'You have completed the SQL Foundations practice exercises!';
PRINT '';
PRINT 'Key takeaways:';
PRINT '  ✓ You understand the 5 types of SQL (DDL, DML, DQL, DCL, TCL)';
PRINT '  ✓ You can write safe SELECT queries (DQL)';
PRINT '  ✓ You know how to use transactions for data changes (TCL)';
PRINT '  ✓ You can create and modify database structures (DDL)';
PRINT '  ✓ You can manipulate data safely (DML)';
PRINT '';
PRINT 'Next steps:';
PRINT '  → Practice more complex queries';
PRINT '  → Build your own projects';
PRINT '  → Apply these skills to real business problems';
PRINT '';
PRINT 'Keep learning! 🚀';
PRINT '';
GO
