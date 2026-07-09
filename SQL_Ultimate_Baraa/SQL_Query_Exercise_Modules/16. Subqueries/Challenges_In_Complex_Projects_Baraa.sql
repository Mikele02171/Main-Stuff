
-- Metadata [Data about Data]
-- Displays Table Catalog, Table Schema, Table Name and Column respectively (including details of data types etc.)
SELECT
*
FROM INFORMATION_SCHEMA.COLUMNS;

-- Checks all tables shown in SQL Server
SELECT
DISTINCT TABLE_NAME
FROM INFORMATION_SCHEMA.COLUMNS;