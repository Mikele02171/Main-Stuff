/* Find the average scores of customers and treat Nulls as 0.
Additionally provide such CustomerID and LastName. */
USE SalesDB;

SELECT 
CustomerID,
LastName,
Score,

-- Replace All Null Scores with 0
CASE 
	WHEN Score IS NULL THEN 0
	ELSE Score
END ScoreClean,

-- Include NULLS as 0's to account the average score
AVG(CASE 
		WHEN Score IS NULL THEN 0
		ELSE Score
	END) OVER () AvgCustomerClean,

AVG(Score) OVER() AvgCustomer
FROM Sales.Customers;

-- Count how many times each customer has made an order 
-- With Sales greater than 30. 


SELECT 
	CustomerID,
	/* Step 1: Create Flag with binary values (0,1) to mark rows that meet certain criteria */
	/* Step 2: Summarize the binary flag */
	SUM(CASE 
		WHEN Sales > 30 THEN 1
		ELSE 0
	END) TotalOrderHighSales,
	COUNT(*) TotalOrders
FROM Sales.Orders
GROUP BY CustomerID