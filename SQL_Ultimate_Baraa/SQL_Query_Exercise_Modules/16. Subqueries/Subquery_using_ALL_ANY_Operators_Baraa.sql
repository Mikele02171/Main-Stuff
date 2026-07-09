-- Find female employees whose salaries are greater
-- than the salaries of any male employees


USE SalesDB;

--Main Query
SELECT
	EmployeeID,
	FirstName,
	Salary
FROM Sales.Employees
WHERE Gender = 'F'
AND Salary > ANY( SELECT Salary FROM Sales.Employees WHERE Gender = 'M');


SELECT FirstName,Salary FROM Sales.Employees WHERE Gender = 'M';


-- Find female employees whose salaries are greater
-- than the salaries of all male employees
--Main Query
SELECT
	EmployeeID,
	FirstName,
	Salary
FROM Sales.Employees
WHERE Gender = 'F'
AND Salary > ALL( SELECT Salary FROM Sales.Employees WHERE Gender = 'M');