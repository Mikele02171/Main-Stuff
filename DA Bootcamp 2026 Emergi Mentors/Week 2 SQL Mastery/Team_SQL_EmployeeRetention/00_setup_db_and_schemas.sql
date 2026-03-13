/*
 * Script 00 – Setup Database and Schemas
 *
 * Drops any existing TeamProject_EmployeeRetention database, creates a fresh
 * database and defines the schemas required for the Medallion architecture.
 * Run this script once at the beginning of the project.
 */
SELECT name 
FROM sys.databases
WHERE name LIKE '%EmployeeRetention%';


USE master;
GO

IF DB_ID('TeamProject_EmployeeRetention') IS NOT NULL
BEGIN
    ALTER DATABASE TeamProject_EmployeeRetention SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE TeamProject_EmployeeRetention;
END
GO

CREATE DATABASE TeamProject_EmployeeRetention;
GO


-- Create schemas representing Medallion layers and supporting schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO

CREATE SCHEMA pres;
GO

CREATE SCHEMA etl;
GO

CREATE SCHEMA dq;
GO

-- Validation
SELECT name AS CreatedDatabase FROM sys.databases WHERE name = 'TeamProject_EmployeeRetention';
GO

SELECT name AS CreatedSchema FROM sys.schemas WHERE name IN ('bronze','silver','gold','pres','etl','dq');
GO