/* Get all customers along with their orders,
including orders without matching customers */

SELECT
c.id,
c.first_name,
o.order_id,
o.sales
FROM customers as c
RIGHT JOIN orders AS o
ON c.id = o.customer_id;

--Using Left Join
SELECT
c.id,
c.first_name,
o.order_id,
o.sales
FROM orders as o
LEFT JOIN customers AS c
ON o.customer_id = c.id;
