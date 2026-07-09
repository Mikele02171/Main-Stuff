USE SalesDB;
SELECT 
OrderID,
CreationTime,
FORMAT(CreationTime,'MM-dd-yyyy') USA_Format,
FORMAT(CreationTime,'dd-MM-yyyy') EU_Format,
FORMAT(CreationTime,'dd') dd,
FORMAT(CreationTime,'ddd') ddd,
FORMAT(CreationTime,'dddd') dddd,
FORMAT(CreationTime,'dddd') dd,
FORMAT(CreationTime,'MMM') MM,
FORMAT(CreationTime,'MMM') MMM,
FORMAT(CreationTime,'MMMM') MMMM
FROM Sales.Orders;

-- Show CreationTime using the following format:
-- Day Wed Jan Q1 2025 12:34:56 PM
SELECT
OrderID,
CreationTime,
'Day ' + FORMAT(CreationTime,'ddd MMM') + 
' Q' + DATENAME(quarter,CreationTIme) + ' ' +
FORMAT(CreationTime,'yyyy hh:mm:ss tt') AS CustomFormat
FROM Sales.Orders;

-- Formatting Use Case (Data Aggregations)
SELECT
FORMAT(OrderDate, 'MMM yy') OrderDat,
COUNT(*)
FROM Sales.Orders
GROUP BY FORMAT(OrderDate, 'MMM yy');
