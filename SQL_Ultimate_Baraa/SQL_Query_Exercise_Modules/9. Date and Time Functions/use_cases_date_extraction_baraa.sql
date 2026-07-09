--How many orders were placed each year?
USE SalesDB;
SELECT
YEAR(OrderDate) as year,
COUNT(*) NrofOrders
FROM Sales.Orders
GROUP BY YEAR(OrderDate);

--How many orders were placed each month?

SELECT
--Use DateName not Month easiler to read
DateName(month,OrderDate) as month,
COUNT(*) NrofOrders
FROM Sales.Orders
GROUP BY DateName(month,OrderDate);


--Show all orders that were placed during the month of February?
SELECT
*
FROM Sales.Orders
WHERE DateName(month,OrderDate) = 'February'
--WHERE MONTH(OrderDate) = 2; /* This is much faster than the string */ 