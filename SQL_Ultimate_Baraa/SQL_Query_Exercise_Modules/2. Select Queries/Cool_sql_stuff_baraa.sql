select *
from customers;

select *
from orders;

select 123 as static_number;
select 'Hello' as static_string;

select
id,
first_name,
'New Customer' AS customer_type
FROM customers;

select *
from customers
where country = 'Germany';