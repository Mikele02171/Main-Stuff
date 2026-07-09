/* Get orders without matching customers */

SELECT *
FROM customers as c
RIGHT JOIN orders as o
ON c.id= o.customer_id
WHERE c.id IS NULL;



SELECT *
FROM orders as o
LEFT JOIN customers as c
ON c.id= o.customer_id
WHERE c.id IS NULL;