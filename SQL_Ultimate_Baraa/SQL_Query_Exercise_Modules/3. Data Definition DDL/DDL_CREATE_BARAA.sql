-- Create table called persons 
/* with 
columns: id, person_name, birth_date,and phone */
create table persons
(
id int not null,
person_name varchar(50) not null,
birth_date Date,
phone varchar(15) not null,
constraint pk_persons primary key(id)
)
