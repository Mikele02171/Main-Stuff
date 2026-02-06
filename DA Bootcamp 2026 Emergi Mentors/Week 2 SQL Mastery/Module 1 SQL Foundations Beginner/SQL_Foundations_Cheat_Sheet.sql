/*
================================================================================
SQL FOUNDATIONS - QUICK REFERENCE CHEAT SHEET
================================================================================
Course: SQL Foundations - Understanding the Language
Instructor: Fassahat Ahmad
Purpose: One-page reference for the 5 types of SQL commands
Print this and keep it next to your computer while learning!
================================================================================
*/

/*
┌──────────────────────────────────────────────────────────────────────────┐
│                    THE 5 TYPES OF SQL COMMANDS                           │
└──────────────────────────────────────────────────────────────────────────┘

1️⃣  DDL - Data Definition Language (Structure)
   └─ Define and modify database STRUCTURE
   
2️⃣  DML - Data Manipulation Language (Content)
   └─ Add, modify, or remove DATA
   
3️⃣  DQL - Data Query Language (Reading)
   └─ Read and analyze data (90% of analyst work!)
   
4️⃣  TCL - Transaction Control Language (Safety)
   └─ Manage transactions (your UNDO button)
   
5️⃣  DCL - Data Control Language (Security)
   └─ Control who can access what

┌──────────────────────────────────────────────────────────────────────────┐
│                     1. DDL - STRUCTURE COMMANDS                          │
└──────────────────────────────────────────────────────────────────────────┘

CREATE TABLE - Build new table
┌─────────────────────────────────────────────────────────────────────┐
│ CREATE TABLE Employees (                                            │
│     EmployeeID INT PRIMARY KEY IDENTITY(1,1),                       │
│     FirstName NVARCHAR(50) NOT NULL,                                │
│     LastName NVARCHAR(50) NOT NULL,                                 │
│     Email NVARCHAR(100),                                            │
│     Salary DECIMAL(10,2),                                           │
│     HireDate DATE DEFAULT GETDATE()                                 │
│ );                                                                  │
└─────────────────────────────────────────────────────────────────────┘

ALTER TABLE - Modify existing table
┌─────────────────────────────────────────────────────────────────────┐
│ -- Add column                                                       │
│ ALTER TABLE Employees ADD Phone NVARCHAR(20);                       │
│                                                                     │
│ -- Modify column                                                    │
│ ALTER TABLE Employees ALTER COLUMN Email NVARCHAR(150);             │
│                                                                     │
│ -- Drop column                                                      │
│ ALTER TABLE Employees DROP COLUMN Phone;                            │
└─────────────────────────────────────────────────────────────────────┘

DROP TABLE - Delete table permanently
┌─────────────────────────────────────────────────────────────────────┐
│ DROP TABLE OldTempData;  -- ⚠️ PERMANENT! Can't undo!              │
└─────────────────────────────────────────────────────────────────────┘

TRUNCATE TABLE - Remove all data, keep structure
┌─────────────────────────────────────────────────────────────────────┐
│ TRUNCATE TABLE StagingData;  -- Empties table, keeps structure     │
└─────────────────────────────────────────────────────────────────────┘

CREATE INDEX - Speed up queries
┌─────────────────────────────────────────────────────────────────────┐
│ CREATE INDEX idx_Employees_Department                               │
│ ON Employees(Department);                                           │
└─────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────┐
│                     2. DML - DATA COMMANDS                               │
└──────────────────────────────────────────────────────────────────────────┘

INSERT - Add new rows
┌─────────────────────────────────────────────────────────────────────┐
│ -- Single row                                                       │
│ INSERT INTO Employees (FirstName, LastName, Email, Salary)          │
│ VALUES ('John', 'Smith', 'john@email.com', 75000);                  │
│                                                                     │
│ -- Multiple rows                                                    │
│ INSERT INTO Employees (FirstName, LastName, Salary)                 │
│ VALUES                                                              │
│     ('Jane', 'Doe', 80000),                                         │
│     ('Bob', 'Wilson', 72000),                                       │
│     ('Alice', 'Johnson', 85000);                                    │
└─────────────────────────────────────────────────────────────────────┘

UPDATE - Modify existing rows
┌─────────────────────────────────────────────────────────────────────┐
│ ⚠️ ALWAYS use WHERE clause! ⚠️                                       │
│                                                                     │
│ -- Safe way                                                         │
│ UPDATE Employees                                                    │
│ SET Salary = 90000                                                  │
│ WHERE EmployeeID = 5;                                               │
│                                                                     │
│ -- Multiple columns                                                 │
│ UPDATE Employees                                                    │
│ SET Salary = Salary * 1.05,                                         │
│     LastModified = GETDATE()                                        │
│ WHERE Department = 'IT';                                            │
└─────────────────────────────────────────────────────────────────────┘

DELETE - Remove rows
┌─────────────────────────────────────────────────────────────────────┐
│ ⚠️ ALWAYS use WHERE clause! ⚠️                                       │
│                                                                     │
│ DELETE FROM Employees                                               │
│ WHERE EmployeeID = 999;                                             │
│                                                                     │
│ -- Delete with condition                                            │
│ DELETE FROM Employees                                               │
│ WHERE IsActive = 0 AND HireDate < '2020-01-01';                     │
└─────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────┐
│                     3. DQL - QUERY COMMANDS                              │
└──────────────────────────────────────────────────────────────────────────┘

SELECT - Read data (100% SAFE!)
┌─────────────────────────────────────────────────────────────────────┐
│ -- Basic SELECT                                                     │
│ SELECT * FROM Employees;                                            │
│                                                                     │
│ -- Specific columns                                                 │
│ SELECT FirstName, LastName, Salary FROM Employees;                  │
│                                                                     │
│ -- With WHERE filter                                                │
│ SELECT * FROM Employees WHERE Department = 'IT';                    │
│                                                                     │
│ -- With ORDER BY                                                    │
│ SELECT * FROM Employees ORDER BY Salary DESC;                       │
│                                                                     │
│ -- Top N results                                                    │
│ SELECT TOP 10 * FROM Employees ORDER BY Salary DESC;                │
└─────────────────────────────────────────────────────────────────────┘

Aggregations - Summarize data
┌─────────────────────────────────────────────────────────────────────┐
│ SELECT                                                              │
│     Department,                                                     │
│     COUNT(*) AS EmployeeCount,                                      │
│     AVG(Salary) AS AvgSalary,                                       │
│     SUM(Salary) AS TotalSalary,                                     │
│     MIN(Salary) AS MinSalary,                                       │
│     MAX(Salary) AS MaxSalary                                        │
│ FROM Employees                                                      │
│ GROUP BY Department                                                 │
│ HAVING COUNT(*) > 5                                                 │
│ ORDER BY AvgSalary DESC;                                            │
└─────────────────────────────────────────────────────────────────────┘

JOINs - Combine tables
┌─────────────────────────────────────────────────────────────────────┐
│ -- INNER JOIN (matching rows only)                                  │
│ SELECT e.FirstName, e.LastName, d.DepartmentName                    │
│ FROM Employees e                                                    │
│ INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID;        │
│                                                                     │
│ -- LEFT JOIN (all from left, matching from right)                   │
│ SELECT e.FirstName, s.SaleAmount                                    │
│ FROM Employees e                                                    │
│ LEFT JOIN Sales s ON e.EmployeeID = s.EmployeeID;                   │
│                                                                     │
│ -- Multiple JOINs                                                   │
│ SELECT e.FirstName, d.DepartmentName, s.SaleAmount                  │
│ FROM Employees e                                                    │
│ INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID         │
│ LEFT JOIN Sales s ON e.EmployeeID = s.EmployeeID;                   │
└─────────────────────────────────────────────────────────────────────┘

Subqueries - Query within query
┌─────────────────────────────────────────────────────────────────────┐
│ -- Employees earning above average                                  │
│ SELECT FirstName, LastName, Salary                                  │
│ FROM Employees                                                      │
│ WHERE Salary > (SELECT AVG(Salary) FROM Employees);                 │
│                                                                     │
│ -- Using IN                                                         │
│ SELECT * FROM Employees                                             │
│ WHERE DepartmentID IN (                                             │
│     SELECT DepartmentID FROM Departments                            │
│     WHERE Location = 'Sydney'                                       │
│ );                                                                  │
└─────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────┐
│                     4. TCL - TRANSACTION COMMANDS                        │
└──────────────────────────────────────────────────────────────────────────┘

The Professional Workflow
┌─────────────────────────────────────────────────────────────────────┐
│ -- Step 1: Preview what will change                                 │
│ SELECT * FROM Employees WHERE EmployeeID = 5;                       │
│                                                                     │
│ -- Step 2: Start transaction                                        │
│ BEGIN TRANSACTION;                                                  │
│                                                                     │
│ -- Step 3: Make changes                                             │
│ UPDATE Employees SET Salary = 95000 WHERE EmployeeID = 5;           │
│                                                                     │
│ -- Step 4: Verify changes                                           │
│ SELECT * FROM Employees WHERE EmployeeID = 5;                       │
│                                                                     │
│ -- Step 5a: If correct - save permanently                           │
│ COMMIT;                                                             │
│                                                                     │
│ -- Step 5b: If wrong - undo everything                              │
│ ROLLBACK;                                                           │
└─────────────────────────────────────────────────────────────────────┘

Multiple Changes in One Transaction
┌─────────────────────────────────────────────────────────────────────┐
│ BEGIN TRANSACTION;                                                  │
│                                                                     │
│ UPDATE Employees SET Salary = Salary * 1.05 WHERE Dept = 'IT';      │
│ UPDATE Employees SET Bonus = 5000 WHERE Dept = 'IT';                │
│ INSERT INTO AuditLog VALUES ('Salary update', GETDATE());           │
│                                                                     │
│ -- All succeed together or all fail together                        │
│ COMMIT;  -- or ROLLBACK;                                            │
└─────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────┐
│                     5. DCL - SECURITY COMMANDS                           │
└──────────────────────────────────────────────────────────────────────────┘

GRANT - Give permissions
┌─────────────────────────────────────────────────────────────────────┐
│ -- Grant SELECT (read) permission                                   │
│ GRANT SELECT ON Employees TO Marketing_Team;                        │
│                                                                     │
│ -- Grant INSERT and UPDATE permissions                              │
│ GRANT INSERT, UPDATE ON Products TO Product_Team;                   │
│                                                                     │
│ -- Grant all permissions                                            │
│ GRANT ALL ON Sales TO Admin_Team;                                   │
└─────────────────────────────────────────────────────────────────────┘

REVOKE - Remove permissions
┌─────────────────────────────────────────────────────────────────────┐
│ -- Remove DELETE permission                                         │
│ REVOKE DELETE ON Products FROM Junior_Analysts;                     │
│                                                                     │
│ -- Remove all permissions                                           │
│ REVOKE ALL ON Employees FROM Contractor_Group;                      │
└─────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────┐
│                    COMMON MISTAKES TO AVOID                              │
└──────────────────────────────────────────────────────────────────────────┘

❌ WRONG: UPDATE without WHERE
┌─────────────────────────────────────────────────────────────────────┐
│ UPDATE Employees SET Salary = 100000;                               │
│ -- Sets EVERYONE to $100K! Disaster!                                │
└─────────────────────────────────────────────────────────────────────┘

✅ RIGHT: Always include WHERE
┌─────────────────────────────────────────────────────────────────────┐
│ UPDATE Employees SET Salary = 100000 WHERE EmployeeID = 5;          │
└─────────────────────────────────────────────────────────────────────┘

❌ WRONG: No transaction for risky updates
┌─────────────────────────────────────────────────────────────────────┐
│ UPDATE Products SET Price = Price * 1.5;                            │
│ -- Oops! Too expensive! Can't undo!                                 │
└─────────────────────────────────────────────────────────────────────┘

✅ RIGHT: Use transactions
┌─────────────────────────────────────────────────────────────────────┐
│ BEGIN TRANSACTION;                                                  │
│ UPDATE Products SET Price = Price * 1.5;                            │
│ -- Check results...                                                 │
│ ROLLBACK;  -- Undo if needed                                        │
└─────────────────────────────────────────────────────────────────────┘

❌ WRONG: Confusing DDL and DML
┌─────────────────────────────────────────────────────────────────────┐
│ ALTER TABLE Customers ADD phone_123 NVARCHAR(20);                   │
│ -- This adds a COLUMN to the table structure!                       │
│ -- Not what you want if you just need to update one customer's phone│
└─────────────────────────────────────────────────────────────────────┘

✅ RIGHT: Use UPDATE to change data
┌─────────────────────────────────────────────────────────────────────┐
│ UPDATE Customers SET Phone = '0412345678' WHERE CustomerID = 123;   │
│ -- This updates DATA in an existing column                          │
└─────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────┐
│                    HELPFUL SQL FUNCTIONS                                 │
└──────────────────────────────────────────────────────────────────────────┘

String Functions
┌─────────────────────────────────────────────────────────────────────┐
│ UPPER('hello') → 'HELLO'                                            │
│ LOWER('HELLO') → 'hello'                                            │
│ LEN('hello') → 5                                                    │
│ LEFT('hello', 2) → 'he'                                             │
│ RIGHT('hello', 2) → 'lo'                                            │
│ SUBSTRING('hello', 2, 3) → 'ell'                                    │
│ CONCAT('hello', ' ', 'world') → 'hello world'                       │
│ TRIM('  hello  ') → 'hello'                                         │
│ REPLACE('hello', 'l', 'r') → 'herro'                                │
└─────────────────────────────────────────────────────────────────────┘

Date Functions
┌─────────────────────────────────────────────────────────────────────┐
│ GETDATE() → Current date and time                                   │
│ DATEADD(day, 7, GETDATE()) → 7 days from now                        │
│ DATEDIFF(day, '2024-01-01', GETDATE()) → Days between dates         │
│ YEAR(GETDATE()) → Current year                                      │
│ MONTH(GETDATE()) → Current month                                    │
│ DAY(GETDATE()) → Current day                                        │
│ FORMAT(GETDATE(), 'yyyy-MM-dd') → '2024-12-21'                      │
└─────────────────────────────────────────────────────────────────────┘

Aggregate Functions
┌─────────────────────────────────────────────────────────────────────┐
│ COUNT(*) → Count all rows                                           │
│ COUNT(column) → Count non-null values                               │
│ SUM(column) → Sum of values                                         │
│ AVG(column) → Average                                               │
│ MIN(column) → Minimum value                                         │
│ MAX(column) → Maximum value                                         │
└─────────────────────────────────────────────────────────────────────┘

Conditional Logic
┌─────────────────────────────────────────────────────────────────────┐
│ CASE                                                                │
│     WHEN Salary < 50000 THEN 'Low'                                  │
│     WHEN Salary < 80000 THEN 'Medium'                               │
│     ELSE 'High'                                                     │
│ END                                                                 │
│                                                                     │
│ ISNULL(column, 'default_value')                                     │
│ COALESCE(col1, col2, col3, 'default')  -- First non-null value      │
└─────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────┐
│                    DATA ANALYST QUICK TIPS                               │
└──────────────────────────────────────────────────────────────────────────┘

1. 90% of your work is DQL (SELECT queries)
   → Master WHERE, JOIN, GROUP BY first

2. SELECT is 100% safe
   → Practice queries freely without fear

3. Always use transactions for UPDATE/DELETE
   → BEGIN TRANSACTION → test → COMMIT or ROLLBACK

4. Test before running on production
   → Write SELECT to preview, then UPDATE

5. Never trust UPDATE/DELETE without WHERE
   → Preview with SELECT first

6. Comment your code
   → Future you will thank present you

7. Use meaningful aliases
   → e for Employees, sa for Sales, etc.

8. Format for readability
   → Indent, line breaks, uppercase keywords

9. Start simple, add complexity gradually
   → Get basic query working, then add features

10. Save successful queries
    → Build your personal library of solutions

┌──────────────────────────────────────────────────────────────────────────┐
│                    NEXT STEPS                                            │
└──────────────────────────────────────────────────────────────────────────┘

✅ Completed: SQL Foundations - Understanding the Language
✅ You know: The 5 types of SQL (DDL, DML, DQL, DCL, TCL)
✅ You understand: Structure vs Data vs Queries vs Transactions

🚀 Ready for: Video 1 - The SQL Analyst's First Day
   → Answer real business questions with SELECT
   → Use WHERE, JOIN, GROUP BY in production scenarios
   → Deliver $50K+ business value on Day 1

📚 Keep this cheat sheet handy while practicing!

*/
