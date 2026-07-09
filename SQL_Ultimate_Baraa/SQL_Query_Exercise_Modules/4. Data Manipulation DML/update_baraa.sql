-- Change the score of customer 6 to 0
-- Want customer id = 6 to be update, no where will effect all rows
update customers 
set score = 0
where id = 6;

-- Change score of customer with id 10 to 0 and update country to UK
update customers 
set score = 0,
	country = 'UK'
where id = 10;

-- Update all customers with a NULL score by setting their score to 0
update customers 
set score = 0
where score is NULL

select * from customers 