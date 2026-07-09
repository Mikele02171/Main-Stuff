-- Rank each other based on their sales from highest to lowest
-- Additionally provide details such order Id, order date

USE SalesDB;
SELECT 
	OrderID, 
	OrderDate,
	Sales,
	RANK() OVER (ORDER BY Sales ASC) RankSales
FROM Sales.Orders