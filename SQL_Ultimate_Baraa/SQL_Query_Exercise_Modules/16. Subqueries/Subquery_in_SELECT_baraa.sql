-- Show the Product IDs, product names, prices and the total number of orders
USE SalesDB;
-- Main Query: gets executed second
SELECT
ProductID,
Product,
Price,
-- Subquery [MUST RETURN 1 VALUE]: gets executed first
	(SELECT 
	COUNT(*)
	FROM Sales.Orders) AS TotalOrders
FROM Sales.Products;