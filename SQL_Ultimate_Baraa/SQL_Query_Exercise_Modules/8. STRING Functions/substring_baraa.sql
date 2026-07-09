--Retrieve a list of customers' first names after removing the first character
USE MyDatabase;
SELECT
first_name,
SUBSTRING(TRIM(first_name),2,LEN(first_name)) as sub_name
from customers