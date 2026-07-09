-- Show all customer details and find the total orders of each customer
USE SalesDB;

-- Main Query
SELECT 
*,
(SELECT COUNT(*) FROM Sales.Orders o WHERE o.CustomerID = c.CustomerID) TotalSales
FROM Sales.Customers c;
