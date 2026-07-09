-- Find the lowest and highest sales for each product
USE SalesDB;
SELECT 
	OrderID, 
	ProductID,
	Sales,
	-- USE CASE: Compare to Extremes How well a value is performing relative to the extremes.
	First_value(Sales) over (partition by ProductID ORDER BY Sales) LowestSales,
	Last_value(Sales) over (partition by ProductID ORDER BY Sales ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) HighestSales,
	First_value(Sales) over (partition by ProductID ORDER BY Sales DESC) HighestSales2, --Same results for HighestSales
	MIN(Sales) OVER (PARTITION BY ProductID) LowestSales2,
	MAX(Sales) OVER (PARTITION BY ProductID) HighestSales3
FROM Sales.Orders;

-- Find the difference in sales between current and the lowest sales
SELECT 
	OrderID, 
	ProductID,
	Sales,
	First_value(Sales) over (partition by ProductID ORDER BY Sales) LowestSales,
	Last_value(Sales) over (partition by ProductID ORDER BY Sales ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) HighestSales,
	Sales - First_value(Sales) over (partition by ProductID ORDER BY Sales) AS SalesDifference
FROM Sales.Orders;