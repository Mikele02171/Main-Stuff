-- All Customers from either Germany or USA

-- Using the or operator
select *
from customers
where country = 'Germany' or country = 'USA';

-- Using IN 
select *
from customers
where country IN ('Germany','USA');