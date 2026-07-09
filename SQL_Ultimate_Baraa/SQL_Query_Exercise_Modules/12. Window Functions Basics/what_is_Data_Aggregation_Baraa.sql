USE MyDatabase;

SELECT 
customer_id,
COUNT(*) as total_nr_orders,-- Find the total number of orders
SUM(Sales) as total_sales, -- Find the total sales of all orders
AVG(Sales) as avg_sales, -- Find the average sales of all orders
MAX(Sales) as highest_sales, -- Highest Sales among customers
MIN(Sales) as lowest_sales -- Lowest Sales among customers
FROM orders
GROUP BY customer_id;

-- Additional Exercise 
USE SalesDB;
SELECT 
CustomerID,
COUNT(*) as total_nr_scores,-- Find the total number of customer scores
SUM(Score) as total_scores, -- Find the total scores of all customers
AVG(Score) as avg_scores, -- Find the average scores of all customers
MAX(Score) as highest_scores, -- Highest Scores among customers
MIN(Score) as lowest_scores -- Lowest Scores among customers
FROM Sales.Customers
GROUP BY CustomerID;