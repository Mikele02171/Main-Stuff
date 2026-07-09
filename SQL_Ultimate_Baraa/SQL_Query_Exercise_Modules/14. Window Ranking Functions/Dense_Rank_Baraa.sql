USE SalesDB;

SELECT 
	OrderID,
	ProductID,
	Sales,
	DENSE_RANK() OVER(ORDER BY Sales DESC) SalesRank_Dense
FROM Sales.Orders;