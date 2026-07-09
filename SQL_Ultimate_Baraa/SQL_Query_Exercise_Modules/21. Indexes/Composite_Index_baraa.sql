SELECT 
*
FROM Sales.DBCustomers
WHERE Country = 'USA' AND Score > 500

-- NOTE: The columns of Index Order must match the order in your query

CREATE INDEX idx_DBCustomers_CountryScore
ON Sales.DBCustomers (Country, Score)