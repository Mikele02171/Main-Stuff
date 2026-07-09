-- Calculate moving average of sales for each product over time
USE SalesDB;

SELECT 
	OrderID,
	ProductID,
	OrderDate, 
	Sales,
	AVG(Sales) OVER(PARTITION BY ProductID) AvgByProduct,
	-- NOTE: Over time analysis means sorting dates in ascending order
	AVG(Sales) OVER(PARTITION BY ProductID ORDER BY OrderDate) MovingAvg
FROM Sales.Orders;


-- Calculate moving average of sales for each product over time, including only the next order
SELECT 
	OrderID,
	ProductID,
	OrderDate, 
	Sales,
	AVG(Sales) OVER(PARTITION BY ProductID ORDER BY OrderDate ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING) RollingAvg
FROM Sales.Orders;