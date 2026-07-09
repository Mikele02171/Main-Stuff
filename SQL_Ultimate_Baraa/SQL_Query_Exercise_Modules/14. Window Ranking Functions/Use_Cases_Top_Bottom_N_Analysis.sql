-- Find the top highest sales for each product
-- USE CASE: TOP N Analysis 
-- Analysis the top performers to do targeted marketing 
USE SalesDB;

SELECT * FROM (
SELECT 
	OrderID,
	ProductID,
	Sales,
	ROW_NUMBER() OVER (PARTITION BY ProductID ORDER BY Sales DESC) RankByProduct
FROM Sales.Orders)t WHERE RankByProduct=1;

-- Find the lowest 2 customers based on their total sales
-- USE CASE: BOTTOM N Analysis 
-- Help analysis the underperformance to manage risks and to do optimizations 
SELECT * FROM (
SELECT 
    CustomerID,
	SUM(Sales) TotalSales,
	-- 2-STEP Add Window Function to the query
	ROW_NUMBER() OVER (ORDER BY SUM(Sales)) RankCustomers
	FROM Sales.Orders
	-- 1-STEP Add GROUP BY to the query
	GROUP BY
	CustomerID
)t
WHERE RankCustomers <=2;

--RULE: Columns used in the GROUP BY and WINDOW Function must be the same

