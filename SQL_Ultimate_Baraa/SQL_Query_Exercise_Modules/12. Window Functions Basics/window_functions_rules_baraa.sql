USE SalesDB;
SELECT 
OrderID,
OrderDate,
OrderStatus,
Sales,
SUM(Sales) OVER (PARTITION BY OrderStatus) TotalSales
FROM Sales.Orders
ORDER BY SUM(Sales) OVER (PARTITION BY OrderStatus);

SELECT 
	OrderID,
	OrderDate,
	OrderStatus,
	Sales
	--SUM(SUM(Sales) OVER (PARTITION BY OrderStatus)) OVER (PARTITION BY OrderStatus) TotalSales [Rule 2]
FROM Sales.Orders
ORDER BY SUM(Sales) OVER (PARTITION BY OrderStatus);


-- Find the total sales for each order status, only for two products 101 and 102
SELECT 
	OrderID,
	OrderDate,
	OrderStatus,
	ProductID,
	Sales,
	SUM(Sales) OVER (PARTITION BY OrderStatus) TotalSales
FROM Sales.Orders
WHERE ProductID IN (101,102);

--Rank Customers based on their total sales
SELECT 
	CustomerID,
	SUM(Sales) TotalSales,
	RANK() OVER(ORDER BY SUM(Sales) DESC) RankCustomers
FROM Sales.Orders
GROUP BY CustomerID;


