-- Orders data are stored in seperate tables (Orders and OrdersArchive)
-- Combine all orders data into one report without duplicates 
USE SalesDB;

SELECT 
'Orders' AS SourceTable
,[orderid]
,[productid]
,[customerid]
,[salespersonid]
,[orderdate]
,[shipdate]
,[orderstatus]
,[shipaddress]
,[billaddress]
,[quantity]
,[sales]
,[creationtime]
FROM Sales.Orders
UNION 
SELECT 
'OrdersArchive' AS SourceTable
,[orderid]
,[productid]
,[customerid]
,[salespersonid]
,[orderdate]
,[shipdate]
,[orderstatus]
,[shipaddress]
,[billaddress]
,[quantity]
,[sales]
,[creationtime]
FROM Sales.OrdersArchive;