CREATE CLUSTERED COLUMNSTORE INDEX idx_DBCustomers_CS
ON Sales.DBCustomers

DROP INDEX idx_DBCustomers_CS ON Sales.DBCustomers

CREATE NONCLUSTERED COLUMNSTORE INDEX idx_DBCustomers_CS_FirstName
ON Sales.DBCustomers (FirstName)

DROP INDEX [idx_DBCustomers_CustomerID] ON Sales.DBCustomers

