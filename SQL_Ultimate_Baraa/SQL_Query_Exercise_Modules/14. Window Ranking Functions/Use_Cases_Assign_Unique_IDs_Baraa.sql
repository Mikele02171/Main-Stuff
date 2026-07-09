-- Assign unique IDs to the rows of
-- the 'Orders Archive' table
-- USE CASE: ASSIGN UNIQUE IDS:



-- Help to assign unique idenifier for each row to help paginating
USE SalesDB;

SELECT 
ROW_NUMBER() OVER (ORDER BY OrderID, OrderDate) UniqueID,
*
FROM Sales.OrdersArchive;

--PAGINATING: The Process of breaking down a large data into smaller, more manageable chunks