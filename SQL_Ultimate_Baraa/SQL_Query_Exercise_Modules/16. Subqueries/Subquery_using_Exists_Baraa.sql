-- Show the details of orders made by customers in Germany
USE SalesDB;

-- Main Query
SELECT
*
FROM Sales.Orders o
WHERE EXISTS (SELECT
	1 -- Value does not matter
	FROM Sales.Customers c
	WHERE Country = 'Germany'
	AND o.CustomerID = c.CustomerID);


-- Show the details of orders made by customers not in Germany
-- Main Query
SELECT
*
FROM Sales.Orders o
WHERE NOT EXISTS (SELECT
	1 -- Value does not matter
	FROM Sales.Customers c
	WHERE Country = 'Germany'
	AND o.CustomerID = c.CustomerID);