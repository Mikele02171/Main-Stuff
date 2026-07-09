/* Generate all possible combinations of customers and orders. */

USE Mydatabase;
SELECT *
FROM customers as C
CROSS JOIN orders as O;