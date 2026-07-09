--Find Employees who are also customers
USE SalesDB;


SELECT 
CustomerID,
FirstName,
LastName
FROM Sales.Customers

INTERSECT 

SELECT 
EmployeeID,
FirstName,
LastName
FROM Sales.Employees