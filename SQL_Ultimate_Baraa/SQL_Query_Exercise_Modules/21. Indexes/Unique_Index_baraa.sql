USE SalesDB;

SELECT * FROM Sales.Products

-- RULE: Duplicates in the columns will prevent creating a unique index.
CREATE UNIQUE NONCLUSTERED iNDEX idx_Products_Category
ON Sales.Products (Category)


CREATE UNIQUE NONCLUSTERED iNDEX idx_Products_Product
ON Sales.Products (Product)

INSERT INTO Sales.Products (ProductID, Product) VALUES (106, 'Caps')