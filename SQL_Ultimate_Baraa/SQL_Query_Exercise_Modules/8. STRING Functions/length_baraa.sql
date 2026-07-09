--Calculate the first_name length of all customers
USE MyDatabase;
Select 
first_name,
len(first_name) as name_len
from customers;