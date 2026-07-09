/* USE CASE: Search for missing information
Identify the customers who have no scores */
USE SalesDB;
SELECT 
*
FROM Sales.Customers
WHERE Score IS NULL;

-- Identify the customers who have has scores
SELECT 
*
FROM Sales.Customers
WHERE Score IS NOT NULL;

/* USE CASE: LEFT ANTI JOIN | RIGHT ANTI JOIN
-Use Case-*/
-- Finding the unmatched rows between two tables

/* List all details for customers who have not placed any orders */
SELECT 
c.*,
o.OrderID
FROM Sales.Customers c
LEFT JOIN Sales.Orders o
ON c.CustomerID = o.CustomerID
WHERE o.CustomerID IS NULL;