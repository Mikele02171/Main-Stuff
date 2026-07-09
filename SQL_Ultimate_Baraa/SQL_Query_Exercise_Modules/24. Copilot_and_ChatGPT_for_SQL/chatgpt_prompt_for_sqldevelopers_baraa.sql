USE SalesDB;

SELECT
	c.CustomerID,
	c.Country,
	SUM(o.sales) as TotalSales,
	RANK() OVER (PARTITION BY c.Country ORDER BY o.sales DESC) AS RankInCountry
FROM Sales.Customers c
LEFT JOIN Sales.Orders o
ON c.CustomerID = o.CustomerId
GROUP BY c.CustomerID, C.Country

/* Copy the following prompt into ChatGPT:

The Following SQL Server Query causing this error: Column 'Sales.Orders.Sales' is invalid in the select list because it is not contained in either an aggregate 
function or the GROUP BY clause. Do the Following: Explain the error message, 
Find the root cause of this issue. Suggest how to fix it. 
SELECT c.CustomerID, c.Country, SUM(o.sales) as TotalSales, 
RANK() OVER (PARTITION BY c.Country ORDER BY o.sales DESC) AS RankInCountry
FROM Sales.Customers c 
LEFT JOIN Sales.Orders o 
ON c.CustomerID = o.CustomerId 
GROUP BY c.CustomerID, C.Country

*/


WITH Series AS 
(
	-- Anchor Query
	SELECT 
	1 AS MyNumber
	UNION ALL
	-- Recursive Query
	SELECT
	MyNumber + 1
	FROM Series
	WHERE MyNumber < 20
)
-- Main Query
SELECT *
FROM Series


with CTE_Total_Sales as 
(Select 
CustomerID, sum(Sales) as TotalSales 
from Sales.Orders
group by CustomerID),
cte_customer_segments as 
(SELECT CustomerID, 
case when TotalSales > 100 then 'High Value'
when TotalSales between 50 and 100 then 'Medium Value'
else 'Low Value' end as CustomerSegment 
from CTE_Total_Sales)
select c.CustomerID, c.FirstName,c.LastName,
cts.TotalSales,ccs.CustomerSegment
FROM Sales.Customers c
left join CTE_Total_Sales cts
ON cts.CustomerID = c.CustomerID
left join cte_customer_segments ccs ON ccs.CustomerID = c.CustomerID


/* COPY THIS INTO CHATGPT:
Convert the following SQL query from SQL Server to my SQL

SELECT TOP 10
CustomerID,
Score,
ISNULL(Score,2) IsNullScore,
FirstName + ' ' + LastName AS FullName,
GETDATE() CurrentDateTime
FROM Sales.Customers

GPT Response:
SELECT
    CustomerID,
    Score,
    COALESCE(Score, 2) AS IsNullScore,
    CONCAT(FirstName, ' ', LastName) AS FullName,
    CURRENT_TIMESTAMP AS CurrentDateTime
FROM Sales.Customers
LIMIT 10;

*/