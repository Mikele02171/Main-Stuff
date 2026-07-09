
USE SalesDB;

ALTER PROCEDURE GetCustomerSummary @Country NVARCHAR(50) = 'USA' -- Add = USA, to our default when running the execution 
AS 
BEGIN 

BEGIN TRY 
-- DECLARE VARIABLES
DECLARE @TotalCustomers INT, @AvgScore FLOAT;

-- Prepare and Cleanup Data
IF EXISTS (SELECT 1 FROM Sales.Customers WHERE Score IS NULL AND Country = @Country)
BEGIN 
    PRINT('Updating NULL Scores to 0');
	UPDATE Sales.Customers
	SET Score = 0
	WHERE Score IS NULL AND Country = @Country
END 


ELSE
BEGIN
	PRINT('No NULL Scores found')
END;


-- Genrating Reports
SELECT
	@TotalCustomers = COUNT(*),
	@AvgScore = AVG(Score) 
FROM Sales.Customers
WHERE Country = @Country;


PRINT 'Total Customers from ' + @Country + ':'+ CAST(@TotalCustomers AS NVARCHAR);
PRINT 'Average Score from '+ @Country + ':'+ CAST(@AvgScore AS NVARCHAR);

-- Find the total Nr. of Orders and Total Sales
SELECT
	COUNT(OrderID) TotalOrders,
	SUM(Sales) TotalSales,
	1/0
FROM Sales.Orders o
JOIN Sales.Customers c
ON c.CustomerID = o.CustomerID
WHERE c.Country = @Country;

END TRY

BEGIN CATCH
	PRINT('An error occured-.');
	PRINT('Error Message: ' + ERROR_MESSAGE());
	PRINT('Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR));
	PRINT('Error Line: ' + CAST(ERROR_LINE() AS NVARCHAR));
	PRINT('Error Prodecure: ' + CAST(ERROR_PROCEDURE() AS NVARCHAR));
END CATCH
END
GO

-- Execute the Stored Procedure

EXEC GetCustomerSummary; 
EXEC GetCustomerSummary @Country = 'Germany';
-- If the store procedure exists in SalesDB.