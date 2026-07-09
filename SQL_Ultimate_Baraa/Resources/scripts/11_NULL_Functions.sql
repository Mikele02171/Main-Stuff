/* ==============================================================================
   SQL NULL Functions
-------------------------------------------------------------------------------
   This script highlights essential SQL functions for managing NULL values.
   It demonstrates how to handle NULLs in data aggregation, mathematical operations,
   sorting, and comparisons. These techniques help maintain data integrity 
   and ensure accurate query results.

   Table of Contents:
     1. Handle NULL - Data Aggregation
     2. Handle NULL - Mathematical Operators
     3. Handle NULL - Sorting Data
     4. NULLIF - Division by Zero
     5. IS NULL - IS NOT NULL
     6. LEFT ANTI JOIN
     7. NULLs vs Empty String vs Blank Spaces
===============================================================================
*/

/* ==============================================================================
   HANDLE NULL - DATA AGGREGATION
===============================================================================*/

/* TASK 1: 
   Find the average scores of the customers.
   Uses COALESCE to replace NULL Score with 0.
*/
SELECT
    CustomerID,
    Score,
    COALESCE(Score, 0) AS Score2,
    AVG(Score) OVER () AS AvgScores,
    AVG(COALESCE(Score, 0)) OVER () AS AvgScores2
FROM Sales.Customers;

/* ==============================================================================
   HANDLE NULL - MATHEMATICAL OPERATORS
===============================================================================*/

/* TASK 2: 
   Display the full name of customers in a single field by merging their
   first and last names, and add 10 bonus points to each customer's score.
*/
SELECT
    CustomerID,
    FirstName,
    LastName,
    FirstName + ' ' + COALESCE(LastName, '') AS FullName,
    Score,
    COALESCE(Score, 0) + 10 AS ScoreWithBonus
FROM Sales.Customers;

/* ==============================================================================
   HANDLE NULL - SORTING DATA
===============================================================================*/

/* TASK 3: 
   Sort the customers from lowest to highest scores,
   with NULL values appearing last.
*/
SELECT
    CustomerID,
    Score
FROM Sales.Customers
ORDER BY CASE WHEN Score IS NULL THEN 1 ELSE 0 END, Score;

/* ==============================================================================
   NULLIF - DIVISION BY ZERO
===============================================================================*/

/* TASK 4: 
   Find the sales price for each order by dividing sales by quantity.
   Uses NULLIF to avoid division by zero.
*/
SELECT
    OrderID,
    Sales,
    Quantity,
    Sales / NULLIF(Quantity, 0) AS Price
FROM Sales.Orders;

/* ==============================================================================
   IS NULL - IS NOT NULL
===============================================================================*/

/* TASK 5: 
   Identify the customers who have no scores 
*/
SELECT *
FROM Sales.Customers
WHERE Score IS NULL;

/* TASK 6: 
   Identify the customers who have scores 
*/
SELECT *
FROM Sales.Customers
WHERE Score IS NOT NULL;

/* ==============================================================================
   LEFT ANTI JOIN
===============================================================================*/

/* TASK 7: 
   List all details for customers who have not placed any orders 
*/
SELECT
    c.*,
    o.OrderID
FROM Sales.Customers AS c
LEFT JOIN Sales.Orders AS o
    ON c.CustomerID = o.CustomerID
WHERE o.CustomerID IS NULL;

/* ==============================================================================
   NULLs vs EMPTY STRING vs BLANK SPACES
===============================================================================*/

/* TASK 8: 
   Demonstrate differences between NULL, empty strings, and blank spaces 
*/
WITH Orders AS (
    SELECT 1 AS Id, 'A' AS Category UNION
    SELECT 2, NULL UNION
    SELECT 3, '' UNION
    SELECT 4, '  '
)
SELECT 
    *,
    DATALENGTH(Category) AS LenCategory,
    TRIM(Category) AS Policy1,
    NULLIF(TRIM(Category), '') AS Policy2,
    COALESCE(NULLIF(TRIM(Category), ''), 'unknown') AS Policy3
FROM Orders;