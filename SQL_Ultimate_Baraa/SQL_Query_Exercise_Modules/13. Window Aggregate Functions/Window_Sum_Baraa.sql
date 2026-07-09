-- Find the total sales across all orders
-- And the total sales for each product
-- Additionally provide details such order Id, order Date
SELECT 
	OrderID,
	OrderDate,
	Sales,
	SUM(Sales) OVER () TotalSales,
	SUM(Sales) OVER (PARTITION BY ProductID) SalesByProducts
FROM Sales.Orders

/*Find the percentage contribution of each order’s sales to the total sales.
CLARIFICATION: Note: The task description says “find the 
percentage contribution of each product’s sales to the total sales.” 
This wording suggests
that sales should first be aggregated by ProductID. 
However, the query in the example calculates the percentage at the order level, 
meaning each order’s sales is compared to the total sales.

*/
SELECT 
	OrderID,
	OrderDate,
	Sales,
	SUM(Sales) OVER () TotalSales,
	ROUND(CAST(Sales AS Float)/SUM(Sales) OVER () * 100,2) PercentageTotal
FROM Sales.Orders;