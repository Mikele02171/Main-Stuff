/*
  03_silver_clean_transform.sql
  - Creates Silver tables (cleaned/standardised + constraints)
  - Uses proper key mapping tables (no correlated subqueries)
  - Preserves raw EmployeeEventID via BronzeEventID for stable mapping
  - Logs DQ counts
*/

USE TeamProject_EmployeeRetention;
GO

SET NOCOUNT ON;

-- Drop Silver tables in dependency order
IF OBJECT_ID('silver.Absence','U')        IS NOT NULL DROP TABLE silver.Absence;
IF OBJECT_ID('silver.EmployeeEvent','U')  IS NOT NULL DROP TABLE silver.EmployeeEvent;
IF OBJECT_ID('silver.Employee','U')       IS NOT NULL DROP TABLE silver.Employee;
IF OBJECT_ID('silver.EmploymentType','U') IS NOT NULL DROP TABLE silver.EmploymentType;
IF OBJECT_ID('silver.Role','U')           IS NOT NULL DROP TABLE silver.Role;
IF OBJECT_ID('silver.Department','U')     IS NOT NULL DROP TABLE silver.Department;
IF OBJECT_ID('silver.Location','U')       IS NOT NULL DROP TABLE silver.Location;
GO

-- Create Silver schema if not exists
CREATE SCHEMA silver;
GO

-- Silver: Department
CREATE TABLE silver.Department (
    DepartmentKey  INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_silver_Department PRIMARY KEY,
    DepartmentCode NVARCHAR(20)  NOT NULL,
    DepartmentName NVARCHAR(100) NOT NULL,
    CONSTRAINT UQ_silver_Department UNIQUE (DepartmentCode)
);

-- Silver: Role
CREATE TABLE silver.Role (
    RoleKey     INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_silver_Role PRIMARY KEY,
    DepartmentKey INT NOT NULL,
    RoleCode    NVARCHAR(20)  NOT NULL,
    RoleName    NVARCHAR(100) NOT NULL,
    CONSTRAINT UQ_silver_Role UNIQUE (RoleCode),
    CONSTRAINT FK_silver_Role_Department FOREIGN KEY (DepartmentKey) REFERENCES silver.Department(DepartmentKey)
);

-- Silver: Location
CREATE TABLE silver.Location (
    LocationKey   INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_silver_Location PRIMARY KEY,
    LocationCode  NVARCHAR(20)  NOT NULL,
    LocationName  NVARCHAR(100) NOT NULL,
    Region        NVARCHAR(50)  NOT NULL,
    CONSTRAINT UQ_silver_Location UNIQUE (LocationCode)
);

-- Silver: Employment Type
CREATE TABLE silver.EmploymentType (
    EmploymentTypeKey  INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_silver_EmploymentType PRIMARY KEY,
    EmploymentTypeCode NVARCHAR(10)  NOT NULL,
    EmploymentTypeName NVARCHAR(50)  NOT NULL,
    CONSTRAINT UQ_silver_EmploymentType UNIQUE (EmploymentTypeCode)
);

-- Silver: Employee (deduped by EmployeeCode)
CREATE TABLE silver.Employee (
    EmployeeKey      INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_silver_Employee PRIMARY KEY,
    EmployeeCode     NVARCHAR(25) NOT NULL,
    FirstName        NVARCHAR(100) NOT NULL,
    LastName         NVARCHAR(100) NOT NULL,
    BirthDate        DATE NOT NULL,
    Gender           CHAR(1) NOT NULL,
    DepartmentKey    INT NOT NULL,
    RoleKey          INT NOT NULL,
    LocationKey      INT NOT NULL,
    EmploymentTypeKey INT NOT NULL,
    ManagerKey       INT NULL,
    HireDate         DATE NOT NULL,
    TerminationDate  DATE NULL,
    TerminationReason NVARCHAR(100) NULL,
    CONSTRAINT UQ_silver_Employee UNIQUE (EmployeeCode),
    CONSTRAINT FK_silver_Employee_Department FOREIGN KEY (DepartmentKey) REFERENCES silver.Department(DepartmentKey),
    CONSTRAINT FK_silver_Employee_Role       FOREIGN KEY (RoleKey)       REFERENCES silver.Role(RoleKey),
    CONSTRAINT FK_silver_Employee_Location   FOREIGN KEY (LocationKey)   REFERENCES silver.Location(LocationKey),
    CONSTRAINT FK_silver_Employee_EmpType    FOREIGN KEY (EmploymentTypeKey) REFERENCES silver.EmploymentType(EmploymentTypeKey),
    CONSTRAINT FK_silver_Employee_Manager    FOREIGN KEY (ManagerKey) REFERENCES silver.Employee(EmployeeKey)
);

-- Silver: EmployeeEvent (transactional) – keep BronzeEventID for stable mapping
CREATE TABLE silver.EmployeeEvent (
    EventKey        INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_silver_EmployeeEvent PRIMARY KEY,
    BronzeEventID   INT NOT NULL,
    EmployeeKey     INT NOT NULL,
    EventType       NVARCHAR(20)  NOT NULL,
    EventDate       DATE NOT NULL,
    DepartmentKey   INT NOT NULL,
    RoleKey         INT NOT NULL,
    LocationKey     INT NOT NULL,
    EmploymentTypeKey INT NOT NULL,
    ManagerKey      INT NULL,
    EventReason     NVARCHAR(100) NULL,
    CONSTRAINT UQ_silver_Event UNIQUE (BronzeEventID),
    CONSTRAINT FK_silver_Event_Employee       FOREIGN KEY (EmployeeKey)       REFERENCES silver.Employee(EmployeeKey),
    CONSTRAINT FK_silver_Event_Department     FOREIGN KEY (DepartmentKey)     REFERENCES silver.Department(DepartmentKey),
    CONSTRAINT FK_silver_Event_Role           FOREIGN KEY (RoleKey)           REFERENCES silver.Role(RoleKey),
    CONSTRAINT FK_silver_Event_Location       FOREIGN KEY (LocationKey)       REFERENCES silver.Location(LocationKey),
    CONSTRAINT FK_silver_Event_EmpType        FOREIGN KEY (EmploymentTypeKey) REFERENCES silver.EmploymentType(EmploymentTypeKey),
    CONSTRAINT FK_silver_Event_Manager        FOREIGN KEY (ManagerKey)        REFERENCES silver.Employee(EmployeeKey)
);

-- Silver: Absence
CREATE TABLE silver.Absence (
    AbsenceKey   INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_silver_Absence PRIMARY KEY,
    EmployeeKey  INT NOT NULL,
    StartDate    DATE NOT NULL,
    EndDate      DATE NOT NULL,
    AbsenceType  NVARCHAR(50) NOT NULL,
    DaysAbsent   AS (DATEDIFF(DAY, StartDate, EndDate) + 1) PERSISTED,
    CONSTRAINT FK_silver_Absence_Employee FOREIGN KEY (EmployeeKey) REFERENCES silver.Employee(EmployeeKey)
);
GO

/* =========================
   LOAD SILVER (SET-BASED)
   ========================= */

-- 1) Departments
INSERT INTO silver.Department (DepartmentCode, DepartmentName)
SELECT DISTINCT DepartmentCode,
       CONCAT(UPPER(LEFT(LTRIM(RTRIM(DepartmentName)),1)), LOWER(SUBSTRING(LTRIM(RTRIM(DepartmentName)),2,200)))
FROM bronze.Department;

-- Mapping table for Department
IF OBJECT_ID('tempdb..#DeptMap') IS NOT NULL DROP TABLE #DeptMap;
SELECT b.DepartmentID, s.DepartmentKey
INTO #DeptMap
FROM bronze.Department b
JOIN silver.Department s ON s.DepartmentCode = b.DepartmentCode;

-- 2) Roles (standardise casing)
INSERT INTO silver.Role (DepartmentKey, RoleCode, RoleName)
SELECT
    dm.DepartmentKey,
    b.RoleCode,
    CONCAT(UPPER(LEFT(LTRIM(RTRIM(b.RoleName)),1)), LOWER(SUBSTRING(LTRIM(RTRIM(b.RoleName)),2,200)))
FROM bronze.Role b
JOIN #DeptMap dm ON dm.DepartmentID = b.DepartmentID;

IF OBJECT_ID('tempdb..#RoleMap') IS NOT NULL DROP TABLE #RoleMap;
SELECT b.RoleID, s.RoleKey
INTO #RoleMap
FROM bronze.Role b
JOIN silver.Role s ON s.RoleCode = b.RoleCode;

-- 3) Locations
INSERT INTO silver.Location (LocationCode, LocationName, Region)
SELECT DISTINCT LocationCode,
       CONCAT(UPPER(LEFT(LTRIM(RTRIM(LocationName)),1)), LOWER(SUBSTRING(LTRIM(RTRIM(LocationName)),2,200))) AS LocationName,
       Region
FROM bronze.Location;

IF OBJECT_ID('tempdb..#LocMap') IS NOT NULL DROP TABLE #LocMap;
SELECT b.LocationID, s.LocationKey
INTO #LocMap
FROM bronze.Location b
JOIN silver.Location s ON s.LocationCode = b.LocationCode;

-- 4) Employment types
INSERT INTO silver.EmploymentType (EmploymentTypeCode, EmploymentTypeName)
SELECT DISTINCT EmploymentTypeCode,
       CONCAT(UPPER(LEFT(LTRIM(RTRIM(EmploymentTypeName)),1)), LOWER(SUBSTRING(LTRIM(RTRIM(EmploymentTypeName)),2,200)))
FROM bronze.EmploymentType;

IF OBJECT_ID('tempdb..#EmpTypeMap') IS NOT NULL DROP TABLE #EmpTypeMap;
SELECT b.EmploymentTypeID, s.EmploymentTypeKey
INTO #EmpTypeMap
FROM bronze.EmploymentType b
JOIN silver.EmploymentType s ON s.EmploymentTypeCode = b.EmploymentTypeCode;

-- 5) Employees (dedupe by EmployeeCode; map manager later)
;WITH Src AS (
    SELECT
        b.EmployeeID,
        b.EmployeeCode,
        b.FirstName,
        b.LastName,
        b.BirthDate,
        b.Gender,
        b.DepartmentID,
        b.RoleID,
        b.LocationID,
        b.EmploymentTypeID,
        b.ManagerID,
        b.HireDate,
        CASE
            WHEN b.TerminationDate IS NULL THEN NULL
            WHEN DATEDIFF(DAY, b.HireDate, b.TerminationDate) < 0 THEN NULL
            ELSE b.TerminationDate
        END AS CleanTerminationDate,
        b.TerminationReason,
        ROW_NUMBER() OVER (PARTITION BY b.EmployeeCode ORDER BY b.EmployeeID) AS rn
    FROM bronze.Employee b
)
INSERT INTO silver.Employee (
    EmployeeCode, FirstName, LastName, BirthDate, Gender,
    DepartmentKey, RoleKey, LocationKey, EmploymentTypeKey, ManagerKey,
    HireDate, TerminationDate, TerminationReason
)
SELECT
    s.EmployeeCode,
    CONCAT(UPPER(LEFT(LTRIM(RTRIM(s.FirstName)),1)), LOWER(SUBSTRING(LTRIM(RTRIM(s.FirstName)),2,200))) AS FirstName,
    CONCAT(UPPER(LEFT(LTRIM(RTRIM(s.LastName)),1)), LOWER(SUBSTRING(LTRIM(RTRIM(s.LastName)),2,200)))  AS LastName,
    s.BirthDate,
    s.Gender,
    dm.DepartmentKey,
    rm.RoleKey,
    lm.LocationKey,
    em.EmploymentTypeKey,
    NULL, -- ManagerKey mapped after insertion
    s.HireDate,
    s.CleanTerminationDate,
    s.TerminationReason
FROM Src s
JOIN #DeptMap   dm ON dm.DepartmentID   = s.DepartmentID
JOIN #RoleMap   rm ON rm.RoleID         = s.RoleID
JOIN #LocMap    lm ON lm.LocationID     = s.LocationID
JOIN #EmpTypeMap em ON em.EmploymentTypeID = s.EmploymentTypeID
WHERE s.rn = 1;

-- Build employee mapping after insertion
IF OBJECT_ID('tempdb..#EmpMap') IS NOT NULL DROP TABLE #EmpMap;
SELECT b.EmployeeID, s.EmployeeKey
INTO #EmpMap
FROM bronze.Employee b
JOIN silver.Employee s ON s.EmployeeCode = b.EmployeeCode;

-- Update ManagerKey using mapping (use cascade to self reference)
UPDATE s
SET ManagerKey = emgr.EmployeeKey
FROM silver.Employee s
JOIN bronze.Employee b ON b.EmployeeCode = s.EmployeeCode
LEFT JOIN #EmpMap emgr ON emgr.EmployeeID = b.ManagerID;

-- DQ log: invalid termination dates
INSERT INTO dq.DataQualityLog (TableName, CheckName, CheckResult, ErrorCount)
SELECT
    'bronze.Employee',
    'Termination date >= Hire date',
    'Logged (Silver nulls invalid termination)',
    COUNT(*)
FROM bronze.Employee
WHERE TerminationDate IS NOT NULL
  AND DATEDIFF(DAY, HireDate, TerminationDate) < 0;

-- 6) Employee events
INSERT INTO silver.EmployeeEvent (
    BronzeEventID, EmployeeKey, EventType, EventDate,
    DepartmentKey, RoleKey, LocationKey, EmploymentTypeKey, ManagerKey, EventReason
)
SELECT
    be.EmployeeEventID,
    em.EmployeeKey,
    CONCAT(UPPER(LEFT(LTRIM(RTRIM(be.EventType)),1)), LOWER(SUBSTRING(LTRIM(RTRIM(be.EventType)),2,200))) AS EventType,
    be.EventDate,
    dm.DepartmentKey,
    rm.RoleKey,
    lm.LocationKey,
    emt.EmploymentTypeKey,
    emgr.EmployeeKey,
    be.EventReason
FROM bronze.EmployeeEvent be
JOIN #EmpMap em   ON em.EmployeeID   = be.EmployeeID
JOIN #DeptMap dm  ON dm.DepartmentID = be.DepartmentID
JOIN #RoleMap rm  ON rm.RoleID       = be.RoleID
JOIN #LocMap  lm  ON lm.LocationID   = be.LocationID
JOIN #EmpTypeMap emt ON emt.EmploymentTypeID = be.EmploymentTypeID
LEFT JOIN #EmpMap emgr ON emgr.EmployeeID = be.ManagerID;

-- 7) Absence
INSERT INTO silver.Absence (EmployeeKey, StartDate, EndDate, AbsenceType)
SELECT
    em.EmployeeKey,
    ba.StartDate,
    CASE
        WHEN ba.EndDate < ba.StartDate THEN ba.StartDate
        ELSE ba.EndDate
    END AS EndDate,
    CONCAT(UPPER(LEFT(LTRIM(RTRIM(ba.AbsenceType)),1)), LOWER(SUBSTRING(LTRIM(RTRIM(ba.AbsenceType)),2,200))) AS AbsenceType
FROM bronze.Absence ba
JOIN #EmpMap em ON em.EmployeeID = ba.EmployeeID;

-- DQ log: absence end date >= start date
INSERT INTO dq.DataQualityLog (TableName, CheckName, CheckResult, ErrorCount)
SELECT
    'bronze.Absence',
    'EndDate >= StartDate',
    CASE WHEN COUNT(*) = 0 THEN 'Pass' ELSE 'Fail (fixed in Silver by swapping)' END,
    COUNT(*)
FROM bronze.Absence
WHERE EndDate < StartDate;

GO

-- Validation
SELECT (SELECT COUNT(*) FROM silver.Department) AS DeptCount,
       (SELECT COUNT(*) FROM silver.Role)       AS RoleCount,
       (SELECT COUNT(*) FROM silver.Location)   AS LocationCount,
       (SELECT COUNT(*) FROM silver.EmploymentType) AS EmpTypeCount,
       (SELECT COUNT(*) FROM silver.Employee)   AS EmployeeCount,
       (SELECT COUNT(*) FROM silver.EmployeeEvent) AS EventCount,
       (SELECT COUNT(*) FROM silver.Absence)    AS AbsenceCount;
SELECT TOP (5) * FROM dq.DataQualityLog ORDER BY RunDTTM DESC;
GO