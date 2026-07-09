USE SalesDB;
-- If the table exists we want to drop the current table and update or modify any changes for our CTAS
IF OBJECT_ID('Sales.MonthlyOrders','U') IS NOT NULL
	DROP TABLE Sales.MonthlyOrders;
GO

-- Creating a CTAS for Sales.MonthlyOrders make sure to USE SalesDB and follow the correct Schema [Sales] follow by .[New Table Name]
SELECT 
	DATENAME(month,OrderDate) OrderMonth,
	COUNT(OrderID) TotalOrders
INTO Sales.MonthlyOrders
FROM Sales.Orders
GROUP BY DATENAME(month,OrderDate)


-- Run this line only to see the new updated table Sales.MonthlyOrders
-- SELECT * FROM Sales.MonthlyOrders;

