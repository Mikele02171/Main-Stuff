-- Find the sales price for each order by dividing the sales by the quantity.
USE SalesDB;
SELECT 
OrderID,
Sales,
Quantity,
/*Sales/Quantity AS Price -- Divide by Zero Error */
Sales/NULLIF(Quantity,0) AS Price
FROM Sales.Orders

