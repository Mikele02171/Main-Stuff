--Find customers whose first name contains leading or trailing spaces
USE MyDatabase;
SELECT 
first_name,
LEN(first_name) as len_name,
LEN(TRIM(first_name)) as len_trim_name,
LEN(first_name) - LEN(TRIM(first_name)) as flag
FROM customers
WHERE first_name != TRIM(first_name)
-- WHERE LEN(first_name) != LEN(TRIM(first_name))