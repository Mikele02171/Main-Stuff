USE SalesDB;
SELECT 
OrderID,
Sales,
NTILE(1) OVER (ORDER BY Sales DESC) OneBucket, -- (Bucket Size) 10 = 10/1
NTILE(2) OVER (ORDER BY Sales DESC) TwoBuckets, -- (Bucket Size) 5 = 10/2
NTILE(3) OVER (ORDER BY Sales DESC) ThreeBuckets, -- (Bucket Size) ~3 = 10/3
NTILE(4) OVER (ORDER BY Sales DESC) FourBuckets -- (Bucket Size) ~2 = 10/4
FROM Sales.Orders;

-- Segment all orders into 3 categories: high, medium and low sales.
SELECT 
*,
CASE WHEN Buckets = 1 THEN 'High'
WHEN Buckets = 2 THEN 'Medium'
WHEN Buckets = 3 THEN 'Low'
END SalesSegmentations FROM 
(SELECT 
	OrderID,
	Sales,
	NTILE(3) OVER (ORDER BY Sales DESC) Buckets
FROM Sales.Orders)t
;

-- In order to export the data, divide the orders into 2 groups.
SELECT 
NTILE(2) OVER (ORDER BY OrderId DESC) Buckets,
*
FROM Sales.Orders;