-- ==================================
-- Tip 1: Select Only What You Need
-- ==================================

-- Bad Practice
USE SalesDB;
SELECT * FROM Sales.Customers

-- Good Practice
SELECT CustomerID,FirstName,LastName FROM Sales.Customers


-- ============================================
-- Tip 2: Avoid unnecessary DISTINCT & ORDER BY 
-- ============================================

-- Bad Practice
SELECT DISTINCT
	FirstName
FROM Sales.Customers
ORDER BY FirstName

-- Good Practice
SELECT FirstName
FROM Sales.Customers

-- ============================================
-- Tip 3: For Exploration Purpose, Limit Rows! 
-- ============================================

SELECT OrderID, Sales 
FROM Sales.Orders

SELECT TOP 10 OrderID,Sales
FROM Sales.Orders