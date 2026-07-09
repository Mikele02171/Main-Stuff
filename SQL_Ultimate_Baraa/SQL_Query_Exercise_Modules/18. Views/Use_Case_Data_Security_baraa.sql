
-- Provide a view for EU Sales Team
-- that combines details from all tables 
-- and excludes data related to the USA.
CREATE VIEW Sales.V_Order_Details_EU AS (
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
WHERE c.Country != 'USA')