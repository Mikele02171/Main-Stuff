-- Combine the data from employees and customers into one table
USE SalesDB;


SELECT 
CustomerID,
FirstName,
LastName
FROM Sales.Customers

UNION

SELECT 
EmployeeID,
FirstName,
LastName
FROM Sales.Employees