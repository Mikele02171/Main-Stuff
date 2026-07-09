/* Display the full name of customers in a single field by merging their first and last names
and add 10 bonus points to each customer score.*/

USE SalesDB;

SELECT 
CustomerID,
FirstName,
LastName,
COALESCE(LastName,'') LastName2, -- Remove Last Names containing NULL Values.
FirstName + ' ' + COALESCE(LastName,'n/a')  as FullName,
Score,
COALESCE(Score,0) + 10 as ScoreWithBonus
FROM Sales.Customers;