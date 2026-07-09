
-- Step 1: Define the Parameter 
ALTER PROCEDURE GetCustomerSummary @Country NVARCHAR(50) = 'USA' -- Add = USA, to our default when running the execution 
AS 
BEGIN 
SELECT
	COUNT(*) TotalCustomers,
	AVG(Score) AvgScore
FROM Sales.Customers
-- Step 2: Use the Parameter
WHERE Country = @Country
END

-- Execture the Stored Procedure,
-- Step 3: Execute the Stored Procedure
EXEC GetCustomerSummary @Country = 'Germany'
EXEC GetCustomerSummary @Country = 'USA'

EXEC GetCustomerSummary 
-- If the store procedure exists in SalesDB.
--DROP PROCEDURE GetCustomerSummmaryGermany 