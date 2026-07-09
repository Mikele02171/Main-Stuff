-- Find the running total of sales for each month
USE SalesDB;

WITH CTE_Monthly_Summary AS (
	SELECT 
	DATETRUNC(month,OrderDate) OrderMonth,
	SUM(Sales) TotalSales,
	COUNT(OrderID) TotalOrders,
	SUM(Quantity) TotalQuantities 
	FROM Sales.Orders
	GROUP BY DATETRUNC(month,OrderDate)
) 
SELECT
OrderMonth,
TotalSales,
SUM(TotalSales) OVER (ORDER BY OrderMonth) AS RunningTotal
FROM CTE_Monthly_Summary