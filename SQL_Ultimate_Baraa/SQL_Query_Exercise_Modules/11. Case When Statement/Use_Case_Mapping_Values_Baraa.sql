/* Retrieve employee details with gender displayed as full text. */

USE SalesDB;

SELECT 
EmployeeID,
FirstName,
LastName,
Gender,
CASE 
	WHEN Gender = 'F' THEN 'Female'
	WHEN Gender = 'M' THEN 'Male'
	ELSE 'Not Avaiabile'
END GenderFullText
FROM Sales.Employees;


/* Retrieve customer details with abbreviated country code. */

SELECT 
	CustomerID,
	FirstName,
	LastName,
	Country,
	-- Full Form
	CASE
		WHEN Country = 'Germany' THEN 'DE'
		WHEN Country = 'USA' THEN 'US'
		ELSE 'n/a'
	END CountryAbbr,

	-- Quick Form (Works for only 1 column)
	CASE Country
		WHEN 'Germany' THEN 'DE'
		WHEN 'USA' THEN 'US'
		ELSE 'n/a'
	END CountryAbbr2
FROM Sales.Customers;

-- See possible Country values
SELECT DISTINCT Country FROM Sales.Customers;