-- Find the products that have a price 
-- higher than the average price of all products

USE SalesDB;
--Mainquery 
SELECT 
*
FROM
	--Subquery
	(SELECT
	ProductID,
	Price,
	AVG(Price) OVER() AvgPrice
	FROM Sales.Products)t --t: alias t is table
	-- TIP: To check the intermediate results of a subquery, highlight it and execute
WHERE Price > AvgPrice;

-- Rank Customers based on their total amount of sales
--MainQuery
SELECT
*,
RANK() OVER (ORDER BY TotalSales DESC) CustomerRank
FROM
-- SubQuery
	(SELECT
		CustomerID,
		SUM(Sales) TotalSales
	FROM Sales.Orders
	Group by CustomerID)t;
