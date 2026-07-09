-- Find the average sales across all orders
-- And Find the average sales for each product 
-- Additionally provide details such Order ID, order date.

USE SalesDB;

-- 1. Use Case: Overall Analysis Quick Summary or snapshot of the entire dataset
SELECT 
	OrderID,
	OrderDate,
	Sales,
	ProductID,
	AVG(Sales) OVER () AvgSales,
	-- 2. Use Case: Total Per Groups: Group-wise analysis, to understand patterns
	-- within different categories
	AVG(Sales) OVER (PARTITION BY ProductID) AvgSalesByProducts
FROM Sales.Orders;

-- Find the average scores of customers
-- Additionally provide details such CustomerID and LastName
SELECT 
	CustomerID,
	LastName,
	Score,
	AVG(COALESCE(Score,0)) OVER () AvgScoreWithoutNulls
FROM Sales.Customers;


-- Find all orders where sales are higher than the average sales across all orders
-- 3. USE CASE. Compare to average: Helps to evaluate whether a value is above or below
-- the average.
SELECT 
*
FROM (
SELECT
	OrderID,
	ProductID,
	Sales,
	AVG(Sales) OVER () AvgSales
FROM Sales.Orders)t
WHERE Sales > AvgSales;