--Retrieve the first and last two characters of each first name
use MyDatabase;
SELECT 
first_name,
LEFT(TRIM(first_name),2) as first_2_char,
RIGHT(TRIM(first_name),2) as last_2_char
FROM customers