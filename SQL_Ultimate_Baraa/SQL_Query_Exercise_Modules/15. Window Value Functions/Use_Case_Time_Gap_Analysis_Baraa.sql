-- Find the average shipping duration in days for each month
USE SalesDB;
SELECT 
	MONTH(OrderDate) AS OrderDate,
	AVG(DATEDIFF(day,OrderDate,ShipDate)) AvgShip
FROM Sales.Orders
GROUP BY MONTH(OrderDate);

-- Time Gap Analysis
-- Find the number of days between each order and the previous order
SELECT
	OrderID,
	OrderDate CurrentOrderDate,
	LAG(OrderDate) OVER (ORDER BY OrderDate) PreviousOrderDate,
	DATEDIFF(day,LAG(OrderDate) OVER (ORDER BY OrderDate),OrderDate) NrOfDays
FROM Sales.Orders;