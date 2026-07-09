
USE SalesDB;

ALTER PROCEDURE GetCustomerSummary @Country NVARCHAR(50) = 'USA' -- Add = USA, to our default when running the execution 
AS 
BEGIN 

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
	SUM(Sales) TotalSales
FROM Sales.Orders o
JOIN Sales.Customers c
ON c.CustomerID = o.CustomerID
WHERE c.Country = @Country;
END
GO

-- Execute the Stored Procedure

EXEC GetCustomerSummary; 
EXEC GetCustomerSummary @Country = 'Germany';
-- If the store procedure exists in SalesDB.