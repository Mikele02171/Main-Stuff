USE SalesDB;
/* SELECT 
*
INTO #Orders
FROM Sales.Orders; */

DELETE FROM #Orders
WHERE OrderStatus = 'Delivered'


-- Save it into a database or else it gets deleted once you close it.
SELECT
*
INTO Sales.OrdersTest
FROM #Orders

--1. Load Data to TEMP Table
--2. Transform Data in TEMP Table
--3. Load TEMP Table into Permanent Table