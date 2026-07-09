-- Find the total Sales Across all orders
USE SalesDB;
SELECT
SUM(Sales) TotalSales
FROM Sales.Orders;


-- Find the total Sales for each product 
-- NOTE: Result Granularity: The Number of rows in the output is defined by the dimension.
SELECT
ProductID,
SUM(Sales) TotalSales
FROM Sales.Orders
GROUP By ProductID;

-- Find the total Sales for each product, additionally provide details such as order id and order date

SELECT
	OrderID,
	OrderDate,
	ProductID,
	SUM(Sales) OVER(PARTITION By ProductID) TotalSalesByProducts
FROM Sales.Orders;