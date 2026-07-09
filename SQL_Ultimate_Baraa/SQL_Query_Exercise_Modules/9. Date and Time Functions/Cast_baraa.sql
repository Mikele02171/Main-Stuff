USE SalesDB;
SELECT
-- Examples
cast('123' as int) as [String to Int],
cast(123 as varchar) as [Int To String],
CAST('2025-08-20' as date) as [String to Date],
CAST('2025-08-20' as datetime2) as [String to DateTime],

-- On the CreationTime col from the Sales.Orders Table
CreationTime,
CAST(CreationTime AS DATE) AS [Datetime to Date]
FROM Sales.Orders;