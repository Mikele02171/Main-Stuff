-- customers who are from USA or have a score greater than 500
select *
from customers
where 
	country = 'USA' 
	OR score > 500;