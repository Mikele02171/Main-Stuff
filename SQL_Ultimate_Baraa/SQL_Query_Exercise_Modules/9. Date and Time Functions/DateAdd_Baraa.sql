USE SalesDB;
SELECT
OrderID,
OrderDate,
DATEADD(day,-10,OrderDate) as TenDaysBefore,
DATEADD(month,3,OrderDate) as ThreeMonthsLater,
DATEADD(year,2,OrderDate) as TwoYearsLater
FROM Sales.Orders;
