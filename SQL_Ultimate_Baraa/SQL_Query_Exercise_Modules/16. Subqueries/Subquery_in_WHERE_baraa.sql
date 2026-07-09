-- Find the products that have a price higher than the average price of all products.
USE SalesDB;

-- Main Query
SELECT 
ProductID,
Price,
(SELECT AVG(Price) FROM Sales.Products) AvgPrice
FROM Sales.Products
WHERE Price > 
-- Subquery
(SELECT AVG(Price) FROM Sales.Products);