-- Provide View that combines details from orders, products, customers and employees
-- Make sure to use SalesDB as your database
-- USE SalesDB;
CREATE VIEW Sales.V_Order_Details AS (
SELECT 
COALESCE(c.FirstName,'') + ' ' + COALESCE(c.LastName,'') CustomerName,
o.OrderID,
o.OrderDate,
p.Product,
p.ProductID,
p.Category,
o.Sales,
o.Quantity
FROM Sales.Orders o
LEFT JOIN Sales.Products p 
ON p.ProductID = o.ProductID
LEFT JOIN Sales.Customers c
ON c.CustomerID = o.CustomerID
LEFT JOIN Sales.Employees e
ON e.EmployeeID = o.SalesPersonID
);

--SELECT * FROM Sales.V_Order_Details; --To check after running the view, select and execute this line only.