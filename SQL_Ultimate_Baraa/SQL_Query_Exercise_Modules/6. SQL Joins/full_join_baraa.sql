-- All customers and orders, even there is no match
SELECT
c.id,
c.first_name,
o.order_id,
o.sales
FROM customers as c
FULL JOIN orders AS o
ON c.id = o.customer_id;
