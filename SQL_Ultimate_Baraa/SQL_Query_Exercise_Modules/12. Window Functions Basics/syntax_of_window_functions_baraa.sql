-- Find the total sales across all orders
-- Additionally provide details such Order Id, Order date
USE SalesDB;
SELECT 
OrderID,
OrderDate,
SUM(Sales) OVER () TotalSales
FROM Sales.Orders;

-- Find the total sales for each product, additionally provide details 
-- such order id and order date

SELECT 
OrderID,
OrderDate,
ProductID,
SUM(Sales) OVER (PARTITION BY ProductID) TotalSales
FROM Sales.Orders;

-- Find the total sales across all orders for each product, additionally provide details 
-- such order id and order date
SELECT 
OrderID,
OrderDate,
ProductID,
Sales,
SUM(Sales) OVER () TotalSales,
SUM(Sales) OVER (PARTITION BY ProductID) TotalSalesBy
FROM Sales.Orders;

-- Find the total sales for each combination of product and order status
SELECT 
OrderID,
OrderDate,
ProductID,
Sales,
SUM(Sales) OVER () TotalSales,
SUM(Sales) OVER (PARTITION BY ProductID) TotalSalesByProducts,
SUM(Sales) OVER (PARTITION BY ProductID, OrderStatus) SalesByProductsAndStatus
FROM Sales.Orders;