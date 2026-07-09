--Total score for each country
select 
country,SUM(score) as total_score
from customers 
group by country

--Total score for each customer, country of origin 
select 
	first_name,
	country,
	SUM(score) as total_score
from customers 
group by country, first_name

--Total Score and total number of customers for each country
select
	country,
	COUNT(id) AS no_customers,
	SUM(score) as total_score
from customers 
group by country