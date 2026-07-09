-- Concatenate first name and country into one column 
-- Show a list of customers' first names together with their country in one column

USE MyDatabase;

SELECT 
first_name,
country,
CONCAT(first_name,' ',country) AS name_country
FROM customers