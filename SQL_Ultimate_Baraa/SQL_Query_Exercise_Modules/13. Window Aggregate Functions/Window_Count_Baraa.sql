-- Find the total number of orders
USE SalesDB;

-- 1. Use Case Overall Analysis:
-- Quick summary or snapshot of the entire dataset
SELECT 
COUNT(*) TotalOrders
FROM Sales.Orders;

-- Find the total number of orders additionally provide details such order id and order date

SELECT
	OrderID,
	OrderDate,
	COUNT(*) OVER() TotalOrders
FROM Sales.Orders;

-- Find the total number of orders for each customer
-- 2. Use Case: Total per groups: Group-wise analysis,
-- to understand patterns within different categories
SELECT
	CustomerID,
	OrderID,
	OrderDate,
	COUNT(*) OVER(PARTITION BY CustomerID) OrdersbyCustomers
FROM Sales.Orders;

-- Find the total number of customers,
-- additionally provide all customer's details
-- 3. Use Case Data Quality Check: Detecting number of NULLS by comparing to total number of rows.
-- 5 minus 4 equals ` [1 null in scores]
SELECT
	*,
	COUNT(*) OVER() TotalCustomersStar,
	COUNT(1) OVER() TotalCustomersOne,
	COUNT(Score) OVER() TotalScores,
	COUNT(Country) OVER() TotalCountries
FROM Sales.Customers;

-- Check whether the table 'Orders' contains any duplicate rows
SELECT 
*
FROM (
	SELECT
		OrderID,
		COUNT(*) OVER (PARTITION BY OrderID) CheckPK
	FROM Sales.OrdersArchive
)t WHERE CheckPK > 1