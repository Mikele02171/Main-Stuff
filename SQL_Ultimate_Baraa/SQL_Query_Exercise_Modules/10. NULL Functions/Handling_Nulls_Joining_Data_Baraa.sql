/* Sort the customers from lowest to highest scores,
with NULLs appearing last */


USE SalesDB;

SELECT 
CustomerID,
Score,
--COALESCE(Score,99999), -- Lazy Method
CASE WHEN Score IS NULL THEN 1 ELSE 0 END AS Flag
FROM Sales.Customers
ORDER BY CASE WHEN Score IS NULL THEN 1 ELSE 0 END, Score;