-- Customers scores falls in the range between 100 and 500

-- USING BETWEEN 
select *
from customers 
where score between 100 and 500;


-- Using by Comparison 
select *
from customers 
where score >= 100 and score <= 500;