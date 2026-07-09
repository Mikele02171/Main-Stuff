-- Step 1: Write a Query
-- For US Customers Find the Total Number of Customers and the Average Score

USE SalesDB;
SELECT
	COUNT(*) TotalCustomers,
	AVG(Score) AvgScore
FROM Sales.Customers
WHERE Country = 'USA';

-- Step 2: Turning the Query Into a Stored Procedure
CREATE PROCEDURE GetCustomerSummary AS 
BEGIN 
SELECT
	COUNT(*) TotalCustomers,
	AVG(Score) AvgScore
FROM Sales.Customers
WHERE Country = 'USA'
END

-- Step 3: Execute the stored procedure
EXEC GetCustomerSummary

-- For German Customers Find the Total Number of Customers and the Average
CREATE PROCEDURE GetCustomerSummmaryGermany AS 
BEGIN 
SELECT
	COUNT(*) TotalCustomers,
	AVG(Score) AvgScore
FROM Sales.Customers
WHERE Country = 'Germany'
END

EXEC GetCustomerSummaryGermany

