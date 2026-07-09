-- ============================================================================
-- Tip 4: Create nonclustered Index on frequently used Columns in WHERE clause
-- ============================================================================

SELECT * FROM Sales.Orders WHERE OrderStatus = 'Delivered'
CREATE NONCLUSTERED INDEX Idx_Orders_OrderStatus ON Sales.Orders(OrderStatus)


-- ============================================================================
-- Tip 5: Avoid applying functions to columns in WHERE clauses
-- ============================================================================

-- Bad Practice
SELECT * FROM Sales.Orders
WHERE LOWER(OrderStatus) = 'delivered'
-- NOTE: Functions on columns can block index usage

-- Good Practice
SELECT * FROM Sales.Orders
WHERE OrderStatus = 'Delivered'


-- Bad Practice
SELECT *
FROM Sales.Customers
WHERE SUBSTRING(FirstName,1,1) = 'A'

-- Good Practice
SELECT *
FROM Sales.Customers
WHERE FirstName LIKE 'A%'


-- Bad Practice
SELECT * 
FROM Sales.Orders
WHERE YEAR(OrderDate) = 2025

-- Good Practice
SELECT * 
FROM Sales.Orders
WHERE OrderDate BETWEEN '2025-01-01' AND '2025-12-31'

-- ============================================================================
-- Tip 6: Avoid leading wildcards as they prevent index usage
-- ============================================================================

-- Bad Practice
SELECT *
FROM Sales.Customers
WHERE LastName LIKE '%Gold%'

-- Good Practice
SELECT *
FROM Sales.Customers
WHERE LastName LIKE 'Gold%'

-- ============================================================================
-- Tip 7: Use IN instead of Mutiple OR
-- ============================================================================
-- Bad Practice
SELECT *
FROM Sales.Orders
WHERE CustomerID = 1 OR CustomerID = 2 OR CustomerID = 3

-- Good Practice
SELECT *
FROM Sales.Orders
WHERE CustomerID IN (1,2,3)