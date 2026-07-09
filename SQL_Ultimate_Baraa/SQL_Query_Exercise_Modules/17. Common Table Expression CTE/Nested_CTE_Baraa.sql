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
-- Step 2: Find the last order date for each customer (Standalone CTE)
, CTE_Last_Order AS
(
SELECT 
	CustomerID,
	MAX(OrderDate) AS Last_Order
FROM Sales.Orders
GROUP BY CustomerID
)
-- Step 3: Rank Customers based on Total Sales Per Customer (Nested CTE)
, CTE_Customer_Rank AS
(
SELECT
CustomerID,
TotalSales,
RANK() OVER (ORDER BY TotalSales DESC) AS Customer_Rank
FROM CTE_Total_Sales
)
-- Step 4: Segment customers based on their total sales (Nested CTE)
, CTE_Customer_Segments AS
(
SELECT
CustomerID,
CASE WHEN TotalSales > 100 THEN 'HIGH'
	WHEN TotalSales > 80 THEN 'Medium'
	ELSE 'Low'
END Customer_Segments
FROM CTE_Total_Sales
)

-- Main Query
SELECT 
c.CustomerID,
c.FirstName,
c.LastName,
cts.TotalSales,
clo.Last_Order,
ccr.Customer_Rank,
ccs.Customer_Segments
FROM Sales.Customers c
LEFT JOIN CTE_Total_Sales cts
ON cts.CustomerID = c.CustomerID
LEFT JOIN CTE_Last_Order clo
ON clo.CustomerID = c.CustomerID
LEFT JOIN CTE_Customer_Rank ccr
ON ccr.CustomerID = c.CustomerID
LEFT JOIN CTE_Customer_Segments ccs
ON ccs.CustomerID = c.CustomerID;

--CTS-RULE: You cannot use ORDER BY directly within the CTE.