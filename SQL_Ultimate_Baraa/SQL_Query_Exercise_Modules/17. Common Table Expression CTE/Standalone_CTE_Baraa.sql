USE SalesDB;

--Step 1: Find the total Sales Per Customer
WITH CTE_Total_Sales AS
(
SELECT
	CustomerID,
	SUM(Sales) AS TotalSales
FROM Sales.Orders
Group By CustomerID
)

-- Main Query
SELECT 
c.CustomerID,
c.FirstName,
c.LastName,
cts.TotalSales
FROM Sales.Customers c
LEFT JOIN CTE_Total_Sales cts
ON cts.CustomerID = c.CustomerID;

--CTS-RULE: You cannot use ORDER BY directly within the CTE.