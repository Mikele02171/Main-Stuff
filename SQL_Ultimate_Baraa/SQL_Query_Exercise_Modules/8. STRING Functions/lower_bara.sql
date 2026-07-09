--Transform the customer's first name to lower case
USE MyDatabase;
SELECT 
first_name,
country,
concat(first_name, '-', country) AS name_country,
LOWER(first_name) as Low_Name
FROM customers