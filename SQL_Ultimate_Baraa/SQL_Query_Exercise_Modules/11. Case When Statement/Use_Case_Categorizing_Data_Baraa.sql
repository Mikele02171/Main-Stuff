/* 
Create report showing total sales for each of the following categories:
High (sales over 50), Medium (sales 21-50), and Low (Sales 20 or less).
Sort the categories from highest sales to lowest.
*/

USE SalesDB;


SELECT 
Category,
SUM(Sales) AS TotalSales
FROM(
	SELECT 
	OrderID,
	Sales,
	CASE
		WHEN Sales > 50 THEN 'High'
		WHEN Sales > 20 THEN 'Medium'
		ELSE 'Low'
	END Category
	FROM Sales.Orders)
t
GROUP BY Category
ORDER BY TotalSales DESC