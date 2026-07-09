-- All customers from Germany

select *
from customers 
where country = 'Germany';

--All customers not from Germany
select *
from customers 
where country != 'Germany';

--All customers score greater than 500
select *
from customers 
where score > 500;

--All customers score greater than or equal 500
select *
from customers 
where score >= 500;

--All customers score less than 500
select *
from customers 
where score < 500;

--All customers score less or equal 500
select *
from customers 
where score <= 500;