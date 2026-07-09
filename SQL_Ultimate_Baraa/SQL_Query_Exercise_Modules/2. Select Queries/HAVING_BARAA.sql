-- FIND THE AVERAGE SCORE FOR EACH COUNTRY CONSIDERING ONLY CUSTOMERS WITH A SCORE NOT EQUAL TO 0
-- AN AVERAGE SCORE GREATER THAN 430

select
	id,
	country,
	avg(score) as average_score
from customers 
where score != 0
group by id,country
having avg(score) > 430