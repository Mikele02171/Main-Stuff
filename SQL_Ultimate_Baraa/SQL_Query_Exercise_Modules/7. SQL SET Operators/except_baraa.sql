/* Find Customers who are not costumers at the same time: Order does matter here*/

USE SalesDB;


SELECT 
EmployeeID,
FirstName,
LastName
FROM Sales.Employees

EXCEPT

SELECT 
CustomerID,
FirstName,
LastName
FROM Sales.Customers