-- ==============================================================================
-- Tip 8: Use Explicit Join (ANSI Join) Instead of Implicit Join (non-ANSI Join)
-- ==============================================================================

-- Bad Practice
SELECT o.OrderID, c.FirstName
FROM Sales.Customers c, Sales.Orders o
WHERE c.CustomerID = o.CustomerID

-- Good Practice
SELECT o.OrderID, c.FirstName
FROM Sales.Customers c
INNER JOIN Sales.Orders o
ON c.CustomerID = o.CustomerID

-- ==============================================================================
-- Tip 9: Make sure to Index the columns used in the ON clause
-- ==============================================================================

SELECT c.FirstName, o.OrderID
FROM Sales.Orders o
INNER JOIN Sales.Customers c
ON c.CustomerID = o.CustomerID

CREATE NONCLUSTERED INDEX IX_Orders_CustomerID ON Sales.Orders(CustomerID)

-- ==============================================================================
-- Tip 10: filter Before Joining (Big Tables)
-- ==============================================================================

-- Filter After Join (WHERE) (For small and medium size tables)
SELECT c.FirstName, o.OrderID
FROM Sales.Orders o
INNER JOIN Sales.Customers c
ON c.CustomerID = o.CustomerID
WHERE o.OrderStatus = 'Delivered'

-- Filter During Join (ON) ()
SELECT c.FirstName, o.OrderID
FROM Sales.Customers c
INNER JOIN Sales.Orders o
ON c.CustomerID = o.CustomerID
AND o.OrderStatus = 'Delivered'

-- Filter During Join (SUBQUERY) (For LARGE Tables)
SELECT c.FirstName, o.OrderID
FROM Sales.Customers c
INNER JOIN (SELECT OrderID, CustomerID FROm Sales.Orders WHERE OrderStatus = 'Delivered') o
ON c.CustomerID = o.CustomerID

--TIP: Try to isolate the preperation step in a CTE or subquery

-- ==============================================================================
-- Tip 11: Aggregate Before Joining (Big Tables)
-- ==============================================================================

-- Best Practice for Small-Medium Tables
-- Grouping and Joining 
SELECT c.CustomerID, c.FirstName, COUNT(o.OrderID) AS OrderCount
FROM Sales.Customers c
INNER JOIN Sales.Orders o
ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName

-- Best Practice for Big Tables
-- Pre-aggregated Subquery 
SELECT c.CustomerID, c.FirstName,o.OrderCount
FROM Sales.Customers c
INNER JOIN (
SELECT CustomerID, COUNT(OrderID) AS OrderCount
FROM Sales.Orders GROUP BY CustomerID)o
ON c.CustomerID = o.CustomerID

-- NOTE: Correlated Queries are inefficient because SQL execute Aggregations for every row.
-- Correlated Subquery
SELECT 
c.CustomerID,
c.FirstName,
(SELECT COUNT(o.OrderID) FROM Sales.Orders o WHERE o.CustomerID = c.CustomerID) AS OrderCount
FROM Sales.Customers c

-- ==============================================================================
-- Tip 12: Use Union Instead of OR in Joins
-- ==============================================================================

-- Bad Practice
SELECT o.OrderID, c.FirstName
FROM Sales.Customers c
INNER JOIN Sales.Orders o
ON c.CustomerID = o.CustomerID
OR c.CustomerID = o.SalesPersonID


-- Good Practice
SELECT o.OrderID, c.FirstName
FROM Sales.Customers c
INNER JOIN Sales.Orders o
ON c.CustomerID = o.CustomerID
UNION
SELECT o.OrderID, c.FirstName
FROM Sales.Customers c
INNER JOIN Sales.Orders o
ON c.CustomerID = o.SalesPersonID

-- ==============================================================================
-- Tip 13: Check for Nested Loops and Use SQL HINTS
-- ==============================================================================

-- Bad Practice
SELECT o.OrderID, c.FirstName
FROM Sales.Customers c
INNER JOIN Sales.Orders o
ON c.CustomerID = o.CustomerID

-- Good Practice for Having Big Table & Small Table
SELECT o.OrderID, c.FirstName
FROM Sales.Customers c
INNER JOIN Sales.Orders o
ON c.CustomerID = o.CustomerID
OPTION (HASH JOIN)


-- ==============================================================================
-- Tip 14: Use UNION ALL instead of using UNION | duplicates are acceptable 
-- ==============================================================================

-- Bad Practice
SELECT CustomerID FROM Sales.Orders
UNION 
SELECT CustomerID FROM Sales.OrdersArchive

-- Best Practice
SELECT CustomerID FROM Sales.Orders
UNION ALL
SELECT CustomerID FROM Sales.OrdersArchive


-- ========================================================================================
-- Tip 15: Use UNION ALL + Distinct instead of using UNION | duplicates are not acceptable
-- ========================================================================================

-- Bad Practice
SELECT CustomerID FROM Sales.Orders
UNION 
SELECT CustomerID FROM Sales.OrdersArchive

-- Best Practice
SELECT DISTINCT CustomerID
FROM (
SELECT CustomerID FROM Sales.Orders
UNION ALL 
SELECT CustomerID FROM Sales.OrdersArchive)
AS CombinedData
