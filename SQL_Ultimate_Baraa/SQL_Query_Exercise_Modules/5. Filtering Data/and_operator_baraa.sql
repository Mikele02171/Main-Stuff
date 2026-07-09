-- customers who are from USA AND have a score greater than 500
select *
from customers
where 
	country = 'USA' 
	AND score > 500;

