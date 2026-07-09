SELECT *
INTO Sales.Order_NoPartition
FROM Sales.Orders_Partitioned;

SELECT *
FROM Sales.Order_NoPartition
WHERE OrderDate = '2026-01-01';

SELECT *
FROM Sales.Orders_Partitioned
WHERE OrderDate = '2026-01-01';


SELECT *
FROM Sales.Orders_Partitioned
WHERE OrderDate IN ('2026-01-01','2025-12-31');


SELECT *
FROM Sales.Order_NoPartition
WHERE OrderDate IN ('2026-01-01','2025-12-31');