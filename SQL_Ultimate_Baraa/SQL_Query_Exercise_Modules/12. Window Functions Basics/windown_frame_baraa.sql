USE SalesDB;
SELECT 
	OrderID, 
	OrderDate,
	Sales,
	SUM(Sales) OVER (PARTITION BY OrderStatus ORDER BY OrderDate
	ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING) TotalSales
FROM Sales.Orders;

SELECT 
	OrderID, 
	OrderDate,
	Sales,
	SUM(Sales) OVER (PARTITION BY OrderStatus ORDER BY OrderDate
	ROWS BETWEEN CURRENT ROW AND CURRENT ROW) TotalSales
FROM Sales.Orders;


SELECT 
	OrderID, 
	OrderDate,
	Sales,
	SUM(Sales) OVER (PARTITION BY OrderStatus ORDER BY OrderDate
	ROWS UNBOUNDED PRECEDING) TotalSales
FROM Sales.Orders;

SELECT 
	OrderID, 
	OrderDate,
	Sales,
	SUM(Sales) OVER (PARTITION BY OrderStatus ORDER BY OrderDate
	ROWS UNBOUNDED PRECEDING) TotalSales
FROM Sales.Orders;

SELECT 
	OrderID, 
	OrderDate,
	Sales
	--SUM(Sales) OVER (PARTITION BY OrderStatus ORDER BY OrderDate ROWS UNBOUNDED fOLLOWING) TotalSales
	--SUM(Sales) OVER (PARTITION BY OrderStatus ORDER BY OrderDate ROWS 1 FOLLOWING) TotalSales
FROM Sales.Orders;

SELECT 
	OrderID, 
	OrderDate,
	OrderStatus,
	Sales,
	SUM(Sales) OVER (PARTITION BY OrderStatus ORDER BY OrderDate 
	ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) TotalSales
FROM Sales.Orders;

