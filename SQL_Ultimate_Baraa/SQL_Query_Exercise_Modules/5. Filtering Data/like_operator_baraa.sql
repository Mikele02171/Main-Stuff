-- All customers whose first name starts with 'M'

select *
from customers 
where first_name like 'M%'

-- All customers whose first name ends with 'n'
select *
from customers 
where first_name like '%n'

-- All customers whose first name contains 'r'
select *
from customers 
where first_name like '%r%'

-- All customers whose first name contains 'r' in the third position
select *
from customers 
where first_name like '__r%'