-- USE CASE:
-- Identify duplicates: Identify and remove duplicate rows to improve data quality

--Identify duplicate rows in the table 'Orders Archive' and return a clean result 
--without any duplicates 

--NOTE: If the rank exceeds 1, it indicates that the primary key is not unique.


USE SalesDB;
SELECT * FROM
(SELECT 
ROW_NUMBER() OVER (Partition By OrderID Order By CreationTime DESC) rn,
*
FROM Sales.OrdersArchive)t WHERE rn>1;