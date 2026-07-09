insert into customers (id,first_name,country,score)
values 
	(6,'Anna','USA',NULL),
	(7,'Sam',NULL,100); --NOTE (NULL,'Sam',NULL,100) cannot null into column id

insert into customers (id,first_name,country,score)
values 
	(8,'MICHAEL','AUS',NULL);

insert into customers 
values 
	(9,'RICK','AUS',NULL);

insert into customers (id,first_name)
values 
	(10,'SAHRA');

-- Insert data from 'customers' into 'persons'

insert into persons (id,person_name,birth_date,phone)
select 
	id,
	first_name,
	NULL,
	'Unknown'
from customers

select * from persons