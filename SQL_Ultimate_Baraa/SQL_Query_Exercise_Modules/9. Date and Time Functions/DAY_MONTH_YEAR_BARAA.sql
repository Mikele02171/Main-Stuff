USE SalesDB;
SELECT 
OrderID,
CreationTime,
YEAR(CreationTime) Year,
Month(CreationTime) Month,
DAY(CreationTime) Day
FROM Sales.Orders