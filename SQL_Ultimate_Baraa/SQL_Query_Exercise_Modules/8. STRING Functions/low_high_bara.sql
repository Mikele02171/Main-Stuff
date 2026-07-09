--Transform the customer's first name to lower case, do the same in reverse
USE MyDatabase;
SELECT 
first_name,
country,
concat(first_name, '-', country) AS name_country,
LOWER(first_name) as Low_Name,
UPPER(first_name) as High_Name
FROM customers