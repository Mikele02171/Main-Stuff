USE SalesDB;
SELECT 
	SCHEMA_NAME(t.schema_id) AS SchemaName,
	t.name AS TableName,
	s.name AS StatisticName,
	sp.last_updated AS LastUpdate,
	DATEDIFF(day,sp.last_updated, GETDATE()) As LastUpdateDay,
	sp.rows AS 'Rows',
	sp.modification_counter AS ModificationsSinceLastUpdate
FROM sys.stats AS s
JOIN sys.tables t 
ON s.object_id = t.object_id
CROSS APPLY sys.dm_db_stats_properties(s.object_id,s.stats_id) AS sp
ORDER BY
sp.modification_counter DESC;

UPDATE STATISTICS Sales.DBCustomers _WA_Sys_00000001_6EF57B66

UPDATE STATISTICS Sales.DBCustomers 
EXEC sp_updatestats