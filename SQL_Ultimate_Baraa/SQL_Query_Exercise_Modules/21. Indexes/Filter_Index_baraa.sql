USE SalesDB;
SELECT * FROM Sales.Customers
WHERE Country = 'USA'

CREATE NONCLUSTERED INDEX idx_Customers_Country
ON Sales.Customers (Country)
WHERE Country = 'USA'