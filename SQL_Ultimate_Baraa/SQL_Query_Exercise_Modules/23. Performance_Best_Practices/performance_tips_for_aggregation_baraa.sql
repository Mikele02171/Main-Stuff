-- ========================================================================================
-- Tip 16: Use Columnstore Index for Aggregations on Large Table
-- ========================================================================================

SELECT CustomerID, COUNT(OrderID) AS OrderCount
FROM Sales.Orders
GROUP BY CustomerID

CREATE CLUSTERED COLUMNSTORE INDEX idx_Orders_Columnstore ON Sales.Orders


-- ========================================================================================
-- Tip 17: Pre-Aggregate Data and store it in new Table for Reporting
-- ========================================================================================

SELECT MONTH(OrderDate) OrderYear, SUM(Sales) AS TotalSales
INTO Sales.SalesSummary
FROM Sales.Orders
GROUP BY MONTH(OrderDate)

SELECT OrderYear, TotalSales FROM Sales.SalesSummary