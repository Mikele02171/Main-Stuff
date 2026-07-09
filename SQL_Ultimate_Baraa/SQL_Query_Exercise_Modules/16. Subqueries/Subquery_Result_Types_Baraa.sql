USE SalesDB;

-- Example of Scalar Subquery
SELECT
AVG(Sales)
FROM Sales.Orders;

-- Example of Row Query
SELECT
CustomerID
FROM Sales.Orders;

-- Example of Table Query
SELECT
OrderID,
OrderDate
FROM Sales.Orders;
