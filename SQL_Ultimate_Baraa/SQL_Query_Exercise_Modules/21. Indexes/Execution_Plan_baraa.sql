USE AdventureWorksDW2022;

-- Step 1
/* SELECT * 
INTO FactResellerSales_HP
FROM 
FactResellerSales; */
--NOTE: HP is Heaptable

-- Step 2
SELECT * 
FROM FactResellerSales_HP
ORDER BY SalesOrderNumber; 

-- Step 3
SELECT
*
FROM FactResellerSales_HP
WHERE CarrierTrackingNumber = '4911-403C-98';


--Step 4 
SELECT 
	p.EnglishProductName AS ProductName,
	SUM(s.SalesAmount) AS TotalSales
FROM FactResellerSales_HP s
JOIN DimProduct p
ON p.ProductKey = s.ProductKey
GROUP BY p.EnglishProductName; 

CREATE CLUSTERED COLUMNSTORE INDEX idx_FactResellerSalesHP
ON FactResellerSales_HP;