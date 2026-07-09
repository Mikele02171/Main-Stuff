-- Get only 3 costumers 
select TOP 3 * from customers

-- Get top 3 customers based on score
select TOP 3 *
from customers
order by score desc

-- Get bottom 2 customers based on score
select TOP 2 *
from customers
order by score ASC

--Two most recent orders
select top 2 * 
from orders 
order by order_date desc