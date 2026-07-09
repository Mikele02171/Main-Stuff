
USE SalesDB;

ALTER PROCEDURE GetCustomerSummary @Country NVARCHAR(50) = 'USA' -- Add = USA, to our default when running the execution 
AS 
BEGIN 

-- STEP 1: DECLARE VARIABLES
DECLARE @TotalCustomers INT, @AvgScore FLOAT;

SELECT
-- STEP 2: ASSIGN VALUES TO OUR PARAMETERS
	@TotalCustomers = COUNT(*),
	@AvgScore = AVG(Score) 
FROM Sales.Customers
WHERE Country = @Country;

-- STEP 3: USE VARIABLES
PRINT 'Total Customers from ' + @Country + ':'+ CAST(@TotalCustomers AS NVARCHAR);
PRINT 'Average Score from '+ @Country + ':'+ CAST(@AvgScore AS NVARCHAR);

-- Find the total Nr. of Orders and Total Sales
SELECT
	COUNT(OrderID) TotalOrders,
	SUM(Sales) TotalSales
FROM Sales.Orders o
JOIN Sales.Customers c
ON c.CustomerID = o.CustomerID
WHERE c.Country = @Country;
END
GO

-- Execute the Stored Procedure

EXEC GetCustomerSummary 
EXEC GetCustomerSummary @Country = 'Germany'
-- If the store procedure exists in SalesDB.
