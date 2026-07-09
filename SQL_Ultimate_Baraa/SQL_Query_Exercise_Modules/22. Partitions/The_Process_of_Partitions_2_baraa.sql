-- Step 1: Create a Partition Function

CREATE PARTITION FUNCTION PartitionByYear (DATE)
AS RANGE LEFT FOR VALUES ('2023-12-31','2024-12-31','2025-12-31')

DROP PARTITION FUNCTION PartitionByYear;

-- Query lists all existing Partition Function

SELECT
	name,
	function_id,
	type,
	type_desc,
	boundary_value_on_right
FROM sys.partition_functions

-- Step 2: Create FileGroups

SELECT DB_NAME() AS CurrentDatabase;

ALTER DATABASE SalesDB ADD FILEGROUP FG_2023;
ALTER DATABASE SalesDB ADD FILEGROUP FG_2024;
ALTER DATABASE SalesDB ADD FILEGROUP FG_2025;
ALTER DATABASE SalesDB ADD FILEGROUP FG_2026;

-- If you want to remove the file group
ALTER DATABASE SalesDB REMOVE FILEGROUP FG_2023;
ALTER DATABASE SalesDB REMOVE FILEGROUP FG_2024;
ALTER DATABASE SalesDB REMOVE FILEGROUP FG_2025;
ALTER DATABASE SalesDB REMOVE FILEGROUP FG_2026;

-- Query lists all existing FileGroups
-- PRIMARY: Default Filegroup where all objects of database is stored.
SELECT *
FROM sys.filegroups
WHERE type = 'FG'


-- Step 3: Add .ndf Files to Each Filegroup
ALTER DATABASE SalesDB
ADD FILE
(
    NAME = P_2023,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\P_2023.ndf'
)
TO FILEGROUP FG_2023;

-- To help you access the filename
/* SELECT SERVERPROPERTY('InstanceDefaultDataPath') AS DataPath; */ 
ALTER DATABASE SalesDB
ADD FILE
(
    NAME = P_2023,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\P_2023.ndf'
)
TO FILEGROUP FG_2023;

ALTER DATABASE SalesDB
ADD FILE
(
    NAME = P_2024,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\P_2024.ndf'
)
TO FILEGROUP FG_2024;


ALTER DATABASE SalesDB
ADD FILE
(
    NAME = P_2025,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\P_2025.ndf'
)
TO FILEGROUP FG_2025;

ALTER DATABASE SalesDB
ADD FILE
(
    NAME = P_2026,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\P_2026.ndf'
)
TO FILEGROUP FG_2026;

SELECT
    fg.name AS FilegroupName,
    mf.name AS LogicalFileName,
    mf.physical_name AS PhysicalFilePath,
    mf.size/128 AS SizeInMB
FROM sys.filegroups fg
JOIN sys.master_files mf ON fg.data_space_id = mf.data_space_id
WHERE mf.database_id = DB_ID('SalesDB');

-- Step 4: Create Partition Scheme

CREATE PARTITION SCHEME SchemePartitionByYear
AS PARTITION PartitionByYear
-- NOTE: Sort the Filegroups according to the result of the Function's Partitions
TO (FG_2023,FG_2024,FG_2025,FG_2026)
-- NOTE: 3 Boundaries = 4 Partitions = 4 Filegroups

-- Query lists all Partition Scheme
SELECT
    ps.name AS PartitionSchemeName,
    pf.name AS PartitionFunctionName,
    ds.destination_id AS PartitionNumber,
    fg.name AS FilegroupName
FROM sys.partition_schemes ps
JOIN sys.partition_functions pf ON ps.function_id = pf.function_id
JOIN sys.destination_data_spaces ds ON ps.data_space_id = ds.partition_scheme_id
JOIN sys.filegroups fg ON ds.data_space_id = fg.data_space_id