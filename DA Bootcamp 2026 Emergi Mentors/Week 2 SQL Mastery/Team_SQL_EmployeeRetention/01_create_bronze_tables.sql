/*
  01_create_bronze_tables.sql
  - Creates Bronze raw tables (minimal constraints) for employee retention
  - Creates dq logging table
*/

USE TeamProject_EmployeeRetention;
GO

-- Drop tables in dependency-safe order
IF OBJECT_ID('bronze.Absence','U')          IS NOT NULL DROP TABLE bronze.Absence;
GO

IF OBJECT_ID('bronze.EmployeeEvent','U')    IS NOT NULL DROP TABLE bronze.EmployeeEvent;
GO

IF OBJECT_ID('bronze.Employee','U')         IS NOT NULL DROP TABLE bronze.Employee;
GO

IF OBJECT_ID('bronze.EmploymentType','U')   IS NOT NULL DROP TABLE bronze.EmploymentType;
GO

IF OBJECT_ID('bronze.Role','U')             IS NOT NULL DROP TABLE bronze.Role;
GO

IF OBJECT_ID('bronze.Department','U')       IS NOT NULL DROP TABLE bronze.Department;
GO

IF OBJECT_ID('bronze.Location','U')         IS NOT NULL DROP TABLE bronze.Location;
GO

IF OBJECT_ID('dq.DataQualityLog','U') IS NOT NULL DROP TABLE dq.DataQualityLog;
GO

-- Create bronze and dq schema (if not exists)
CREATE SCHEMA bronze;
GO

CREATE SCHEMA dq;
GO


-- Department (raw)
CREATE TABLE bronze.Department (
    DepartmentID   INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_bronze_Department PRIMARY KEY,
    DepartmentCode NVARCHAR(20)  NOT NULL,
    DepartmentName NVARCHAR(100) NOT NULL,
    CreatedDTTM    DATETIME2(0)  NOT NULL CONSTRAINT DF_bronze_Department_Created DEFAULT SYSUTCDATETIME()
);

-- Role (raw)
CREATE TABLE bronze.Role (
    RoleID        INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_bronze_Role PRIMARY KEY,
    DepartmentID  INT NULL,
    RoleCode      NVARCHAR(20)  NOT NULL,
    RoleName      NVARCHAR(100) NOT NULL,
    CreatedDTTM   DATETIME2(0)  NOT NULL CONSTRAINT DF_bronze_Role_Created DEFAULT SYSUTCDATETIME()
);

-- Location (raw)
CREATE TABLE bronze.Location (
    LocationID    INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_bronze_Location PRIMARY KEY,
    LocationCode  NVARCHAR(20)  NOT NULL,
    LocationName  NVARCHAR(100) NOT NULL,
    Region        NVARCHAR(50)  NOT NULL,
    CreatedDTTM   DATETIME2(0)  NOT NULL CONSTRAINT DF_bronze_Location_Created DEFAULT SYSUTCDATETIME()
);

-- Employment type (raw)
CREATE TABLE bronze.EmploymentType (
    EmploymentTypeID   INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_bronze_EmploymentType PRIMARY KEY,
    EmploymentTypeCode NVARCHAR(10)  NOT NULL,
    EmploymentTypeName NVARCHAR(50)  NOT NULL,
    CreatedDTTM        DATETIME2(0)  NOT NULL CONSTRAINT DF_bronze_EmpType_Created DEFAULT SYSUTCDATETIME()
);

-- Employee (raw) - de-identified; synthetic IDs only
CREATE TABLE bronze.Employee (
    EmployeeID       INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_bronze_Employee PRIMARY KEY,
    EmployeeCode     NVARCHAR(25) NOT NULL,  -- business key (synthetic)
    FirstName        NVARCHAR(100) NOT NULL,
    LastName         NVARCHAR(100) NOT NULL,
    BirthDate        DATE         NOT NULL,
    Gender           CHAR(1)      NOT NULL,
    DepartmentID     INT NULL,
    RoleID           INT NULL,
    LocationID       INT NULL,
    EmploymentTypeID INT NULL,
    ManagerID        INT NULL,
    HireDate         DATE NOT NULL,
    TerminationDate  DATE NULL,
    TerminationReason NVARCHAR(100) NULL,
    DuplicateFlag    BIT NOT NULL CONSTRAINT DF_bronze_Employee_Dup DEFAULT (0),
    CreatedDTTM      DATETIME2(0) NOT NULL CONSTRAINT DF_bronze_Employee_Created DEFAULT SYSUTCDATETIME()
);

-- Employee events (raw)
CREATE TABLE bronze.EmployeeEvent (
    EmployeeEventID  INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_bronze_EmployeeEvent PRIMARY KEY,
    EmployeeID       INT NULL,
    EventType        NVARCHAR(20)  NOT NULL,
    EventDate        DATE         NOT NULL,
    DepartmentID     INT NULL,
    RoleID           INT NULL,
    LocationID       INT NULL,
    EmploymentTypeID INT NULL,
    ManagerID        INT NULL,
    EventReason      NVARCHAR(100) NULL,
    CreatedDTTM      DATETIME2(0) NOT NULL CONSTRAINT DF_bronze_Event_Created DEFAULT SYSUTCDATETIME()
);

-- Absence (raw)
CREATE TABLE bronze.Absence (
    AbsenceID    INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_bronze_Absence PRIMARY KEY,
    EmployeeID   INT NULL,
    StartDate    DATE NOT NULL,
    EndDate      DATE NOT NULL,
    AbsenceType  NVARCHAR(50) NOT NULL,
    CreatedDTTM  DATETIME2(0) NOT NULL CONSTRAINT DF_bronze_Absence_Created DEFAULT SYSUTCDATETIME()
);


-- Data Quality log
CREATE TABLE dq.DataQualityLog (
    LogID       INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_dq_DataQualityLog PRIMARY KEY,
    TableName   NVARCHAR(128) NOT NULL,
    CheckName   NVARCHAR(256) NOT NULL,
    CheckResult NVARCHAR(256) NOT NULL,
    ErrorCount  INT NOT NULL,
    RunDTTM     DATETIME2(0) NOT NULL CONSTRAINT DF_dq_Run DEFAULT SYSUTCDATETIME()
);
GO

-- Validation
SELECT COUNT(*) AS RawTables FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'bronze';
GO