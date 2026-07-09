-- Find the average scores of the customers 
USE SalesDB;
SELECT 
CustomerID,
Score,
COALESCE(Score,0) Score2, --Replace Null values to 0
AVG(Score) OVER () AvgScores, --Do not account null values
AVG(COALESCE(Score,0)) OVER() AvgScores2 --Replace Null Values to 0, then average them
FROM Sales.Customers;