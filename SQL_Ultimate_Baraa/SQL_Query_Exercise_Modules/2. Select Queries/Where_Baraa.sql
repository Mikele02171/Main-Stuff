-- Customers score not equal to 0
SELECT 
*
FROM CUSTOMERS
WHERE score != 0

--Customers from Germany
SELECT 
*
FROM CUSTOMERS
WHERE Country = 'Germany'