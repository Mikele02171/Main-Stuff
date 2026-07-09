-- Step 5: Create the Partitioned Table
CREATE TABLE Sales.Orders_Partitioned
(
	OrderID INT,
	OrderDate DATE,
	Sales INT
) ON SchemePartitionByYear (OrderDate)

-- Step 6: Insert Data Into the Partitioned Table
INSERT INTO Sales.Orders_Partitioned VALUES (1, '2023-05-15',100);
INSERT INTO Sales.Orders_Partitioned VALUES (1, '2024-07-20',50);
INSERT INTO Sales.Orders_Partitioned VALUES (1, '2025-12-31',50);
INSERT INTO Sales.Orders_Partitioned VALUES (1, '2026-01-01',100);

SELECT * FROM Sales.Orders_Partitioned;

SELECT 
	p.partition_number AS PartitionNumber,
	f.name AS PartitionFileGroup,
	p.rows AS NumberOfRows
FROM sys.partitions p
JOIN sys.destination_data_spaces dds ON p.partition_number = dds.destination_id
JOIN sys.filegroups f ON dds.data_space_id = f.data_space_id
WHERE OBJECT_NAME(p.object_id) = 'Orders_Partitioned';



