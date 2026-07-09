
-- Step 1: Create Sales Employee Logs Table
CREATE TABLE Sales.EmployeeLogs (
	LogID INT IDENTITY(1,1) PRIMARY KEY,
	EmployeeID INT,
	LogMessage VARCHAR(255),
	LogDate DATE
)

-- Step 2: Create Trigger on Employees Table
CREATE TRIGGER trg_AfterInsertEmployee ON Sales.Employees
AFTER INSERT
AS 
BEGIN 
 INSERT INTO Sales.EmployeeLogs (EmployeeID, LogMessage, LogDate)
 SELECT 
	 EmployeeID,
	 'New Employee Added =' + CAST(EmployeeID AS VARCHAR),
	 GETDATE()
 FROM INSERTED

END

-- Step 3: Insert New Data into Employees as you go.
INSERT INTO Sales.Employees
VALUES(7,'Maria','Doe','HR', '1988-01-12','F',80000,3)

SELECT * FROM Sales.EmployeeLogs