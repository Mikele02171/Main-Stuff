USE SalesDB;
SELECT
OrderID,
CreationTime,
EOMONTH(CreationTime) EndOfMonth,
DATETRUNC(month,CreationTime) StartofMonth,
CAST(DATETRUNC(month,CreationTime) as DATE) StartofMonth_ver2
FROM Sales.Orders