-- Step 1: Define the Parameter 
ALTER PROCEDURE GetCustomerSummary @Country NVARCHAR(50) = 'USA' -- Add = USA, to our default when running the execution 
AS 
BEGIN 
SELECT
	COUNT(*) TotalCustomers,
	AVG(Score) AvgScore
FROM Sales.Customers
-- Step 2: Use the Parameter
WHERE Country = @Country;

-- Find the total Nr. of Orders and Total Sales
SELECT
COUNT(OrderID) TotalOrders,
SUM(Sales) TotalSales
FROM Sales.Orders o
JOIN Sales.Customers c
ON c.CustomerID = o.CustomerID
WHERE c.Country = @Country;
END

-- Step 3: Execute the Stored Procedure

EXEC GetCustomerSummary 
EXEC GetCustomerSummary @Country = 'Germany'
-- If the store procedure exists in SalesDB.
--DROP PROCEDURE GetCustomerSummmaryGermany 

