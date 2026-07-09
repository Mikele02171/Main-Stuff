-- Find the higest and lowest sales across 
-- all orders and the highest and lowest sales 
-- for each product. Additionally provide details 
-- such order Id, order date
USE SalesDB;

SELECT 
	OrderID,
	OrderDate,
	Sales,
	ProductID,
	-- 1. USE CASE: Overall analysis: Quick summary or snapshot of the entire dataset
    MIN(Sales) OVER () LowestSales,
	MAX(Sales) OVER () HighestSales,
	-- 2 USE CASE: Total per groups: Group-wise analysis, to understand
	-- patterns within different categories.
	MIN(Sales) OVER (PARTITION BY ProductID) LowestSalesbyProduct,
	MAX(Sales) OVER (PARTITION BY ProductID) HighestSalesbyProduct
FROM Sales.Orders;

-- Show the employees who have the highest salaries+
SELECT
*
FROM 
(
	SELECT 
	*,
	MAX(Salary) OVER() HighestSalary
	FROM Sales.Employees)t 
WHERE Salary = HighestSalary;

-- Calculate the deviation of each sale from 
-- both the minimum and maximum sales amounts.

SELECT 
	OrderID,
	OrderDate,
	Sales,
	ProductID,
    MIN(Sales) OVER () LowestSales,
	MAX(Sales) OVER () HighestSales,
	-- 3. USE CASE: COMPARE TO EXTREMES: Help to evaluate how well 
	-- a value is performing relative to the extremes. 
	-- Distance from extreme: The lower the deviation, the closer the data point
	-- is to the extreme.
	Sales - MIN(Sales) OVER() DeviationFromMin,
	MAX(Sales) OVER() - Sales DeviationFromMax
FROM Sales.Orders;