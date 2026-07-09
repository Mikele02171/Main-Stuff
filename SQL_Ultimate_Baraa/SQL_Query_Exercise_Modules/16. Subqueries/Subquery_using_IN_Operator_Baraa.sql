-- Show the details of orders made by customers in Germany 
-- Main Query
USE SalesDB;
SELECT
*
FROM Sales.Orders
WHERE CustomerID IN 
	-- Sub Query
	(SELECT CustomerID
	FROM Sales.Customers
	WHERE Country = 'Germany');

-- Show the details of orders made by customers not in Germany 
-- Method 1: Use != in the WHERE Clause in the Sub Query
SELECT
*
FROM Sales.Orders
WHERE CustomerID IN 
	-- Sub Query
	(SELECT CustomerID
	FROM Sales.Customers
	WHERE Country != 'Germany');


	-- Method 2: Use NOT IN
SELECT
*
FROM Sales.Orders
WHERE CustomerID NOT IN 
	-- Sub Query
	(SELECT CustomerID
	FROM Sales.Customers
	WHERE Country = 'Germany');