-- Rank the orders based on their sales from highest to lowest
USE SalesDB;

SELECT 
	OrderID,
	ProductID,
	Sales,
	ROW_NUMBER() OVER(ORDER BY Sales DESC) SalesRank_Row
FROM Sales.Orders;