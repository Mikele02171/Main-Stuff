-- Combine the data from employees and customers into one table including duplicates
USE SalesDB;


SELECT 
CustomerID,
FirstName,
LastName
FROM Sales.Customers

UNION ALL

SELECT 
EmployeeID,
FirstName,
LastName
FROM Sales.Employees