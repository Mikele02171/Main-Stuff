	
-- Make sure your using SalesDB Database before executing the view
IF OBJECT_ID('Sales.V_Monthly_Summary','V') IS NOT NULL
	DROP VIEW Sales.V_Monthly_Summary;
GO

CREATE VIEW Sales.V_Monthly_Summary AS 
(SELECT 
	DATETRUNC(month,OrderDate) OrderMonth,
	SUM(Sales) TotalSales,
	COUNT(OrderID) TotalOrders,
	SUM(Quantity) TotalQuantities 
	FROM Sales.Orders
	GROUP BY DATETRUNC(month,OrderDate)
)

-- If the view exists, uncomment and run this query
/* DROP VIEW Sales.V_Monthly_Summary; */ 