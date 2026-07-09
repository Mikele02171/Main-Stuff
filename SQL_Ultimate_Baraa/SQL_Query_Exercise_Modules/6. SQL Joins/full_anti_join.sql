/* Find Customers with orders and Orders without Customers  */
SELECT *
FROM orders as o
FULL JOIN customers as c
ON c.id= o.customer_id
WHERE c.id IS NULL OR
o.customer_id IS NULL;


/* Get all customers along with their orders but only for customers who have placed an order (No inner join)  */
SELECT *
FROM customers as c
LEFT JOIN orders as o
ON c.id= o.customer_id
WHERE o.customer_id IS NOT NULL;
