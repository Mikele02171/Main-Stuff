SELECT 
ISDATE('123') DateCheck1,
ISDATE('2025-08-20') DateCheck2, 
ISDATE('20-08-2025') DateCheck3, -- Returns 0 because SQL Server does not understand the format
ISDATE('2025') DateCheck4,
ISDATE('08') DateCheck5;


SELECT 
--CAST(OrderDate AS Date) OrderDate, (Will not convert date and/or time from character string)
OrderDate,
ISDATE(OrderDate),
CASE WHEN ISDATE(OrderDate) = 1 
	THEN CAST(OrderDate AS DATE)
	ELSE '9999-01-01'
END NewOrderDate
FROM(
SELECT '2025-08-20' AS OrderDate UNION
SELECT '2025-08-21' UNION 
SELECT '2025-08-23' UNION 
SELECT '2025-08')t
-- WHERE ISDATE(OrderDate) = 0, where date is not valid