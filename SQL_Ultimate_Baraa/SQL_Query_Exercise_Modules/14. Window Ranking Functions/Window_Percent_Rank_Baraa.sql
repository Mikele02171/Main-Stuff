-- Find the products that fall within the highest 40% of the prices.
USE SalesDB;

SELECT *,
CONCAT(DistRank*100,'%') DistRankPerc
FROM (
SELECT
	Product,
	Price,
	CUME_DIST() OVER (ORDER BY Price DESC) DistRank,
	PERCENT_RANK() OVER (ORDER BY Price DESC) PercentRank
FROM Sales.Products)t 
WHERE DistRank <=0.4;