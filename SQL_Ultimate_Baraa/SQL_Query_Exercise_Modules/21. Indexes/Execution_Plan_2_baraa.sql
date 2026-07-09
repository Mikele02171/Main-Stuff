USE AdventureWorksDW2022;
SELECT
*
FROM FactResellerSales
ORDER BY SalesOrderNumber;


SELECT
*
FROM FactResellerSales
WHERE CarrierTrackingNumber = '4911-403C-98';

CREATE NONCLUSTERED INDEX idx_FactReseller_CTA
ON FactResellerSales (CarrierTrackingNumber)

SELECT 
	p.EnglishProductName AS ProductName,
	SUM(s.SalesAmount) AS TotalSales
FROM FactResellerSales s
JOIN DimProduct p
ON p.ProductKey = s.ProductKey
GROUP BY p.EnglishProductName; 