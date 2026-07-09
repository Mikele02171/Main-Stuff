-- Add a new column called email to the persons table
ALTER TABLE persons 
add email varchar(50) not null;

-- Remove the column phone from the persons table
ALTER TABLE persons 
drop column phone;

select * from persons;