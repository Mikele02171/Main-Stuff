USE SalesDB;
SELECT
	o.Sales,
	c.Country
FROM Sales.Orders o
LEFT JOIN Sales.Customers c 
ON o.CustomerID = c.CustomerID
OPTION (HASH JOIN)


SELECT
	o.Sales,
	c.Country
FROM Sales.Orders o
LEFT JOIN Sales.Customers c WITH (FORCESEEK)
ON o.CustomerID = c.CustomerID


SELECT 
	o.Sales,
	c.Country 
FROM Sales.Orders o 
LEFT JOIN Sales.Customers c WITH 
(INDEX([PK_customers]))
--(INDEX([PK_Customers_A4AE64B87FC20A48]))
ON o.CustomerID = c.CustomerID

