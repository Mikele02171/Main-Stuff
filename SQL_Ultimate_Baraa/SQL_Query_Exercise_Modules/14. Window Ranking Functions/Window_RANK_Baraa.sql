USE SalesDB;

SELECT 
	OrderID,
	ProductID,
	Sales,
	ROW_NUMBER() OVER(ORDER BY Sales DESC) SalesRank_Row,
	RANK() OVER(ORDER BY Sales DESC) SalesRank_Rank    
FROM Sales.Orders;