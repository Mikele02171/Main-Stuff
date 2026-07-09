Use SalesDB;
WITH Orders AS (
SELECT 1 Id, 'A' Category UNION 
SELECT 2, NULL UNION 
SELECT 3, '' UNION
SELECT 4, '  '
)
SELECT 
*,
DATALENGTH(Category) CategoryLen,
DATALENGTH(TRIM(Category)) Policy1, --After applying the trim
NULLIF(TRIM(Category),'') Policy2, -- Takes less storage, improve speed and performance
COALESCE(NULLIF(TRIM(Category),''),'unknown') Policy3
FROM orders