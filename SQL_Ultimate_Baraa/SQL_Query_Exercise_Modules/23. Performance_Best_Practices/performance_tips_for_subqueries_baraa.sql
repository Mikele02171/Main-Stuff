-- JOIN (Best Practice: If the Performance equals to EXISTS)
SELECT o.OrderID, o.Sales
FROM Sales.Orders o
INNER JOIN Sales.Customers c
ON o.CustomerID = c.CustomerID
WHERE c.Country = 'USA'

-- EXISTS (Best Practice: Use it for Large Tables)
SELECT o.OrderID, o.Sales
FROM Sales.Orders o 
WHERE EXISTS (
SELECT 1 FROM 
Sales.Customers c
WHERE c.CustomerID = o.CustomerID
AND c.Country = 'USA')

-- IN (Bad Practice)
SELECT o.OrderID, o.Sales
FROM Sales.Orders o
WHERE o.CustomerID IN 
(
SELECT CustomerID
FROM Sales.Customers 
WHERE Country = 'USA'
)

-- ========================================================================================
-- Tip 19: Avoid Redundant Logic in Your Query
-- ========================================================================================

-- Bad Practice
SELECT EmployeeID, FirstName, 'Above Average' Status
FROM Sales.Employees
WHERE Salary > (SELECT AVG(Salary) FROM Sales.Employees)
UNION ALL
SELECT EmployeeID, FirstName, 'Below Average' Status
FROM Sales.Employees
WHERE Salary < (SELECT AVG(Salary) FROM Sales.Employees)

-- Good Practice
SELECT 
EmployeeID,
FirstName,
CASE
WHEN Salary > AVG(Salary) OVER () THEN 'Above Average'
WHEN Salary < AVG(Salary) OVER () THEN 'Below Average'
ELSE 'Average'
END AS Status 
FROM Sales.Employees 

--NOTE: Spot reduandant queries? Review and fix them!    