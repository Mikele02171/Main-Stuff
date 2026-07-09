/* Using SalesDB, Retreive a list of all orders, along with the related customer, product, and employee details. 
For each order, display:
Order ID, Customer's name, Product Name, Sales, Price, Sales person's name */ 

USE SalesDB;

-- My Attempt
SELECT 
o.OrderID,
c.FirstName + ' ' + c.LastName as CustomerName,
p.Product,
o.Sales,
p.Price,
e.FirstName + ' ' + e.LastName as SalesName
FROM Sales.Orders AS o
LEFT JOIN Sales.Customers AS c 
ON o.CustomerID = c.CustomerID
LEFT JOIN Sales.Products as p
ON o.ProductID = p.ProductID
LEFT JOIN Sales.Employees as e
ON o.SalesPersonID = e.EmployeeID;

--Baraa's Solution [shows first and last name for Customers and Employees]
SELECT 
o.OrderID,
c.FirstName,
c.LastName,
p.Product,
o.Sales,
p.Price,
e.FirstName,
e.LastName 
FROM Sales.Orders AS o
LEFT JOIN Sales.Customers AS c 
ON o.CustomerID = c.CustomerID
LEFT JOIN Sales.Products as p
ON o.ProductID = p.ProductID
LEFT JOIN Sales.Employees as e
ON o.SalesPersonID = e.EmployeeID;