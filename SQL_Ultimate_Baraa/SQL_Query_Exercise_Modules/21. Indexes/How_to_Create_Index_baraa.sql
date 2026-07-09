
USE SalesDB;
SELECT *
INTO Sales.DBCustomers
FROM Sales.Customers;


SELECT *
FROM Sales.DBCustomers
WHERE CustomerID = 1;

-- Creating Indexes: NOTE: ONLY ONE CLUSTERED INDEX CAN BE CREATED PER TABLE.
CREATE CLUSTERED INDEX idx_DBCustomers_CustomerID 
ON Sales.DBCustomers (CustomerID)

CREATE CLUSTERED INDEX idx_DBCustomers_FirstName
ON Sales.DBCustomers (FirstName)

DROP INDEX idx_DBCustomers_CustomerID  on Sales.DBCustomers 


SELECT 
*
FROM Sales.DBCustomers
WHERE LastName = 'Brown'

CREATE NONCLUSTERED INDEX id_DBCustomers_LastName
ON Sales.DBCUstomers (LastName)


SELECT 
*
FROM Sales.DBCustomers
WHERE FirstName = 'Anna'

CREATE INDEX id_DBCustomers_FirstName
ON Sales.DBCUstomers (FirstName)