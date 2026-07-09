-- Calculate the age of employees 
USE SalesDB;
SELECT
EmployeeID,
BirthDate,
DATEDIFF(year,BirthDate,GETDATE()) Age
FROM Sales.Employees;