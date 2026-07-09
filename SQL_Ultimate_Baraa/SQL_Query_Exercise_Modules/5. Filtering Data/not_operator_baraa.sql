-- customers scores with a score not less than 500
select *
from customers
where score >= 500; 

--Still works, using not (reverse the condition).
select *
from customers
where not score < 500; 