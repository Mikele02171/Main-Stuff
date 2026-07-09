-- Generate a sequence of Numbers from 1 to 20.

WITH Series AS (
-- Anchor Query
SELECT
1 AS MyNumber
UNION ALL
-- Recursive QUery
SELECT 
MyNumber + 1 
FROM Series
WHERE MyNumber < 1000 -- Define the filter when we want to terminate the loop
)

-- Main Query
SELECT * FROM Series
OPTION (MAXRECURSION 5000); -- Rasies the safety limit to 5000. Helps successfully return 1000 rows without crashing


USE SalesDB;
-- Task 1: Show the employee hierarchy by displaying each employee's level within the organization

WITH CTE_Emp_Hierarchy AS
(
    -- Anchor Query
	SELECT
		EmployeeID,
		FirstName,
		ManagerID,
		1 AS Level
	FROM Sales.Employees
	WHERE ManagerID is NULL
	UNION ALL 
	-- Recursive Query
	SELECT
		e.EmployeeID,
		e.FirstName,
		e.ManagerID,
		Level + 1
	FROM Sales.Employees AS e
	INNER JOIN CTE_Emp_Hierarchy ceh
	ON e.ManagerID = ceh.EmployeeID
)

-- Main Query
SELECT 
*
FROM CTE_Emp_Hierarchy;


	SELECT
		EmployeeID,
		FirstName,
		ManagerID,
		1 AS Level
	FROM Sales.Employees