USE SalesDB;

--Step 1: Find the total Sales Per Customer (Standalone CTE)
WITH CTE_Total_Sales AS
(
SELECT
	CustomerID,
	SUM(Sales) AS TotalSales
FROM Sales.Orders
Group By CustomerID
)
-- Step 2: Find the last order date for each customer 
, CTE_Last_Order AS
(
SELECT 
	CustomerID,
	MAX(OrderDate) AS Last_Order
FROM Sales.Orders
GROUP BY CustomerID
)

-- Main Query
SELECT 
c.CustomerID,
c.FirstName,
c.LastName,
cts.TotalSales,
clo.Last_Order
FROM Sales.Customers c
LEFT JOIN CTE_Total_Sales cts
ON cts.CustomerID = c.CustomerID
LEFT JOIN CTE_Last_Order clo
ON clo.CustomerID = c.CustomerID;

--CTS-RULE: You cannot use ORDER BY directly within the CTE.