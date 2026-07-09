SELECT 
	tbl.name AS TableName,
	idx.name AS IndexName,
	s.avg_fragmentation_in_percent,
	s.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(),NULL,NULL,NULL,'LIMITED') AS s
	INNER JOIN sys.tables tbl
	ON s.object_id = tbl.object_id
	INNER JOIN sys.indexes AS idx
	ON idx.object_id = s.object_id
	AND idx.index_id = s.index_id
ORDER BY s.avg_fragmentation_in_percent DESC;

ALTER INDEX idx_Customers_CS_Country ON Sales.Customers REORGANIZE 

ALTER INDEX idx_Customers_Country ON Sales.Customers REBUILD