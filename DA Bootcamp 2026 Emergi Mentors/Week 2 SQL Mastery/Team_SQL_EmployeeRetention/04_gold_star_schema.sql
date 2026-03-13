/*
  04_gold_star_schema.sql
  - Builds Gold star schema for employee retention
  - Proper DimEmployee with surrogate key and references to department, role, location and employment type
  - FactEmployeeSnapshot is one row per employee per month (snapshot grain)
  - FactEmployeeEvents records each event
  - FactAbsence records absence periods
*/

USE TeamProject_EmployeeRetention;
GO

SET NOCOUNT ON;

-- Drop facts first
IF OBJECT_ID('gold.FactAbsence','U')        IS NOT NULL DROP TABLE gold.FactAbsence;
IF OBJECT_ID('gold.FactEmployeeEvents','U')  IS NOT NULL DROP TABLE gold.FactEmployeeEvents;
IF OBJECT_ID('gold.FactEmployeeSnapshot','U') IS NOT NULL DROP TABLE gold.FactEmployeeSnapshot;

-- Drop dimensions
IF OBJECT_ID('gold.DimEmploymentType','U') IS NOT NULL DROP TABLE gold.DimEmploymentType;
IF OBJECT_ID('gold.DimLocation','U')        IS NOT NULL DROP TABLE gold.DimLocation;
IF OBJECT_ID('gold.DimRole','U')            IS NOT NULL DROP TABLE gold.DimRole;
IF OBJECT_ID('gold.DimDepartment','U')      IS NOT NULL DROP TABLE gold.DimDepartment;
IF OBJECT_ID('gold.DimEmployee','U')        IS NOT NULL DROP TABLE gold.DimEmployee;
IF OBJECT_ID('gold.DimDate','U')            IS NOT NULL DROP TABLE gold.DimDate;
GO

--Creating gold, pres and etl schema (if not exists)
CREATE SCHEMA gold;
GO

CREATE SCHEMA pres;
GO

CREATE SCHEMA etl;
GO

-- Dimensions
CREATE TABLE gold.DimDate (
    DateKey    INT NOT NULL CONSTRAINT PK_gold_DimDate PRIMARY KEY,
    [Date]     DATE NOT NULL,
    [Day]      INT  NOT NULL,
    [Month]    INT  NOT NULL,
    MonthName  NVARCHAR(20) NOT NULL,
    [Quarter]  INT  NOT NULL,
    [Year]     INT  NOT NULL,
    IsWeekend  BIT  NOT NULL
);

CREATE TABLE gold.DimDepartment (
    DepartmentKey  INT NOT NULL CONSTRAINT PK_gold_DimDepartment PRIMARY KEY,
    DepartmentCode NVARCHAR(20) NOT NULL,
    DepartmentName NVARCHAR(100) NOT NULL
);

CREATE TABLE gold.DimRole (
    RoleKey        INT NOT NULL CONSTRAINT PK_gold_DimRole PRIMARY KEY,
    DepartmentKey  INT NOT NULL,
    RoleCode       NVARCHAR(20) NOT NULL,
    RoleName       NVARCHAR(100) NOT NULL,
    CONSTRAINT FK_gold_DimRole_Department FOREIGN KEY (DepartmentKey) REFERENCES gold.DimDepartment(DepartmentKey)
);

CREATE TABLE gold.DimLocation (
    LocationKey   INT NOT NULL CONSTRAINT PK_gold_DimLocation PRIMARY KEY,
    LocationCode  NVARCHAR(20) NOT NULL,
    LocationName  NVARCHAR(100) NOT NULL,
    Region        NVARCHAR(50) NOT NULL
);

CREATE TABLE gold.DimEmploymentType (
    EmploymentTypeKey  INT NOT NULL CONSTRAINT PK_gold_DimEmploymentType PRIMARY KEY,
    EmploymentTypeCode NVARCHAR(10) NOT NULL,
    EmploymentTypeName NVARCHAR(50) NOT NULL
);

CREATE TABLE gold.DimEmployee (
    EmployeeKey       INT NOT NULL CONSTRAINT PK_gold_DimEmployee PRIMARY KEY,
    EmployeeCode      NVARCHAR(25) NOT NULL,
    FirstName         NVARCHAR(100) NOT NULL,
    LastName          NVARCHAR(100) NOT NULL,
    BirthDate         DATE NOT NULL,
    Gender            CHAR(1) NOT NULL,
    DepartmentKey     INT NOT NULL,
    RoleKey           INT NOT NULL,
    LocationKey       INT NOT NULL,
    EmploymentTypeKey INT NOT NULL,
    ManagerKey        INT NULL,
    HireDate          DATE NOT NULL,
    TerminationDate   DATE NULL,
    TerminationReason NVARCHAR(100) NULL,
    CONSTRAINT FK_gold_DimEmp_Department  FOREIGN KEY (DepartmentKey)     REFERENCES gold.DimDepartment(DepartmentKey),
    CONSTRAINT FK_gold_DimEmp_Role        FOREIGN KEY (RoleKey)           REFERENCES gold.DimRole(RoleKey),
    CONSTRAINT FK_gold_DimEmp_Location    FOREIGN KEY (LocationKey)       REFERENCES gold.DimLocation(LocationKey),
    CONSTRAINT FK_gold_DimEmp_EmpType     FOREIGN KEY (EmploymentTypeKey) REFERENCES gold.DimEmploymentType(EmploymentTypeKey),
    CONSTRAINT FK_gold_DimEmp_Manager     FOREIGN KEY (ManagerKey)        REFERENCES gold.DimEmployee(EmployeeKey)
);

-- Facts
CREATE TABLE gold.FactEmployeeSnapshot (
    SnapshotID     BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_gold_FactEmpSnapshot PRIMARY KEY,
    EmployeeKey    INT NOT NULL,
    DepartmentKey  INT NOT NULL,
    RoleKey        INT NOT NULL,
    LocationKey    INT NOT NULL,
    EmploymentTypeKey INT NOT NULL,
    ManagerKey     INT NULL,
    DateKey        INT NOT NULL,
    TenureMonths   INT NOT NULL,
    ActiveFlag     BIT NOT NULL,
    TerminatedFlag BIT NOT NULL,
    CONSTRAINT FK_gold_FS_Emp     FOREIGN KEY (EmployeeKey)       REFERENCES gold.DimEmployee(EmployeeKey),
    CONSTRAINT FK_gold_FS_Dept    FOREIGN KEY (DepartmentKey)      REFERENCES gold.DimDepartment(DepartmentKey),
    CONSTRAINT FK_gold_FS_Role    FOREIGN KEY (RoleKey)            REFERENCES gold.DimRole(RoleKey),
    CONSTRAINT FK_gold_FS_Loc     FOREIGN KEY (LocationKey)        REFERENCES gold.DimLocation(LocationKey),
    CONSTRAINT FK_gold_FS_EmpType FOREIGN KEY (EmploymentTypeKey)  REFERENCES gold.DimEmploymentType(EmploymentTypeKey),
    CONSTRAINT FK_gold_FS_Manager FOREIGN KEY (ManagerKey)         REFERENCES gold.DimEmployee(EmployeeKey),
    CONSTRAINT FK_gold_FS_Date    FOREIGN KEY (DateKey)            REFERENCES gold.DimDate(DateKey)
);

CREATE TABLE gold.FactEmployeeEvents (
    EventKey       INT NOT NULL CONSTRAINT PK_gold_FactEmployeeEvents PRIMARY KEY,
    EmployeeKey    INT NOT NULL,
    DateKey        INT NOT NULL,
    DepartmentKey  INT NOT NULL,
    RoleKey        INT NOT NULL,
    LocationKey    INT NOT NULL,
    EmploymentTypeKey INT NOT NULL,
    ManagerKey     INT NULL,
    EventType      NVARCHAR(20)  NOT NULL,
    EventReason    NVARCHAR(100) NULL,
    CONSTRAINT FK_gold_FE_Emp     FOREIGN KEY (EmployeeKey)       REFERENCES gold.DimEmployee(EmployeeKey),
    CONSTRAINT FK_gold_FE_Date    FOREIGN KEY (DateKey)            REFERENCES gold.DimDate(DateKey),
    CONSTRAINT FK_gold_FE_Dept    FOREIGN KEY (DepartmentKey)      REFERENCES gold.DimDepartment(DepartmentKey),
    CONSTRAINT FK_gold_FE_Role    FOREIGN KEY (RoleKey)            REFERENCES gold.DimRole(RoleKey),
    CONSTRAINT FK_gold_FE_Loc     FOREIGN KEY (LocationKey)        REFERENCES gold.DimLocation(LocationKey),
    CONSTRAINT FK_gold_FE_EmpType FOREIGN KEY (EmploymentTypeKey)  REFERENCES gold.DimEmploymentType(EmploymentTypeKey),
    CONSTRAINT FK_gold_FE_Manager FOREIGN KEY (ManagerKey)         REFERENCES gold.DimEmployee(EmployeeKey)
);

CREATE TABLE gold.FactAbsence (
    AbsenceKey     INT NOT NULL CONSTRAINT PK_gold_FactAbsence PRIMARY KEY,
    EmployeeKey    INT NOT NULL,
    StartDateKey   INT NOT NULL,
    EndDateKey     INT NOT NULL,
    DaysAbsent     INT NOT NULL,
    AbsenceType    NVARCHAR(50) NOT NULL,
    CONSTRAINT FK_gold_FA_Emp      FOREIGN KEY (EmployeeKey)  REFERENCES gold.DimEmployee(EmployeeKey),
    CONSTRAINT FK_gold_FA_Start    FOREIGN KEY (StartDateKey) REFERENCES gold.DimDate(DateKey),
    CONSTRAINT FK_gold_FA_End      FOREIGN KEY (EndDateKey)   REFERENCES gold.DimDate(DateKey)
);
GO

/* =========================
   LOAD GOLD DIMENSIONS
   ========================= */

-- DimDepartment
INSERT INTO gold.DimDepartment (DepartmentKey, DepartmentCode, DepartmentName)
SELECT DepartmentKey, DepartmentCode, DepartmentName
FROM silver.Department;

-- DimRole
INSERT INTO gold.DimRole (RoleKey, DepartmentKey, RoleCode, RoleName)
SELECT RoleKey, DepartmentKey, RoleCode, RoleName
FROM silver.Role;

-- DimLocation
INSERT INTO gold.DimLocation (LocationKey, LocationCode, LocationName, Region)
SELECT LocationKey, LocationCode, LocationName, Region
FROM silver.Location;

-- DimEmploymentType
INSERT INTO gold.DimEmploymentType (EmploymentTypeKey, EmploymentTypeCode, EmploymentTypeName)
SELECT EmploymentTypeKey, EmploymentTypeCode, EmploymentTypeName
FROM silver.EmploymentType;

-- DimEmployee
INSERT INTO gold.DimEmployee (
    EmployeeKey, EmployeeCode, FirstName, LastName, BirthDate, Gender,
    DepartmentKey, RoleKey, LocationKey, EmploymentTypeKey, ManagerKey,
    HireDate, TerminationDate, TerminationReason
)
SELECT
    e.EmployeeKey,
    e.EmployeeCode,
    e.FirstName,
    e.LastName,
    e.BirthDate,
    e.Gender,
    e.DepartmentKey,
    e.RoleKey,
    e.LocationKey,
    e.EmploymentTypeKey,
    e.ManagerKey,
    e.HireDate,
    e.TerminationDate,
    e.TerminationReason
FROM silver.Employee e;

-- DimDate from hires, terminations, events and absences
--;WITH AllDates AS (
--    SELECT CAST(HireDate AS date) AS DateVal FROM silver.Employee
--    UNION
--    SELECT CAST(TerminationDate AS date) FROM silver.Employee WHERE TerminationDate IS NOT NULL
--    UNION
--    SELECT EventDate FROM silver.EmployeeEvent
--    UNION
--    SELECT StartDate FROM silver.Absence
--    UNION
--    SELECT EndDate FROM silver.Absence
--)
--INSERT INTO gold.DimDate (DateKey, [Date], [Day], [Month], MonthName, [Quarter], [Year], IsWeekend)
--SELECT
--    CONVERT(INT, FORMAT(DateVal,'yyyyMMdd')) AS DateKey,
--    DateVal,
--    DAY(DateVal) AS [Day],
--    MONTH(DateVal) AS [Month],
--    DATENAME(MONTH, DateVal) AS MonthName,
--    DATEPART(QUARTER, DateVal) AS [Quarter],
--    YEAR(DateVal) AS [Year],
--    CASE WHEN DATEPART(WEEKDAY, DateVal) IN (1,7) THEN 1 ELSE 0 END AS IsWeekend
--FROM AllDates
--GROUP BY DateVal;
--GO

-- Populate all months between first hire and 2 years after last termination
DECLARE @MinHire DATE = (SELECT MIN(HireDate) FROM silver.Employee);
DECLARE @MaxEnd  DATE = (SELECT DATEADD(YEAR,2, MAX(ISNULL(TerminationDate,GETDATE()))) FROM silver.Employee);

;WITH MonthSeries AS (
    SELECT @MinHire AS MonthStart
    UNION ALL
    SELECT DATEADD(MONTH,1,MonthStart)
    FROM MonthSeries
    WHERE MonthStart < @MaxEnd
)
INSERT INTO gold.DimDate (DateKey,[Date],[Day],[Month],MonthName,[Quarter],[Year],IsWeekend)
SELECT 
    CONVERT(INT, FORMAT(EOMONTH(MonthStart),'yyyyMMdd')),
    EOMONTH(MonthStart),
    DAY(EOMONTH(MonthStart)),
    MONTH(EOMONTH(MonthStart)),
    DATENAME(MONTH, EOMONTH(MonthStart)),
    DATEPART(QUARTER, EOMONTH(MonthStart)),
    YEAR(EOMONTH(MonthStart)),
    CASE WHEN DATEPART(WEEKDAY, EOMONTH(MonthStart)) IN (1,7) THEN 1 ELSE 0 END
FROM MonthSeries
WHERE NOT EXISTS (SELECT 1 FROM gold.DimDate d WHERE d.DateKey = CONVERT(INT, FORMAT(EOMONTH(MonthStart),'yyyyMMdd')))
OPTION (MAXRECURSION 0);

/* =========================
   LOAD GOLD FACTS
   ========================= */

-- FactEmployeeEvents
INSERT INTO gold.FactEmployeeEvents (
    EventKey, EmployeeKey, DateKey, DepartmentKey, RoleKey, LocationKey, EmploymentTypeKey, ManagerKey, EventType, EventReason
)
SELECT
    se.EventKey,
    se.EmployeeKey,
    CONVERT(INT, FORMAT(se.EventDate,'yyyyMMdd')) AS DateKey,
    se.DepartmentKey,
    se.RoleKey,
    se.LocationKey,
    se.EmploymentTypeKey,
    se.ManagerKey,
    se.EventType,
    se.EventReason
FROM silver.EmployeeEvent se;


-- FactAbsence
INSERT INTO gold.FactAbsence (
    AbsenceKey, EmployeeKey, StartDateKey, EndDateKey, DaysAbsent, AbsenceType
)
SELECT
    sa.AbsenceKey,
    sa.EmployeeKey,
    CONVERT(INT, FORMAT(sa.StartDate,'yyyyMMdd')) AS StartDateKey,
    CONVERT(INT, FORMAT(sa.EndDate,'yyyyMMdd'))   AS EndDateKey,
    sa.DaysAbsent,
    sa.AbsenceType
FROM silver.Absence sa;

-- FactEmployeeSnapshot
-- Generate snapshots per month between hire date and termination date (or current date)
DECLARE @MaxSnapshotDate DATE = (SELECT MAX([Date]) FROM gold.DimDate);

;WITH EmployeeDates AS (
    SELECT e.EmployeeKey, e.DepartmentKey, e.RoleKey, e.LocationKey, e.EmploymentTypeKey, e.ManagerKey,
           e.HireDate,
           e.TerminationDate, --FIX: include this column
           ISNULL(e.TerminationDate, @MaxSnapshotDate) AS EndDate
    FROM silver.Employee e
),
Numbers AS (
    SELECT TOP (240) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
    FROM sys.all_objects
)
INSERT INTO gold.FactEmployeeSnapshot (
    EmployeeKey, DepartmentKey, RoleKey, LocationKey, EmploymentTypeKey, ManagerKey, DateKey, TenureMonths, ActiveFlag, TerminatedFlag
)
SELECT
    ed.EmployeeKey,
    ed.DepartmentKey,
    ed.RoleKey,
    ed.LocationKey,
    ed.EmploymentTypeKey,
    ed.ManagerKey,
    CONVERT(INT, FORMAT(EOMONTH(DATEADD(MONTH, n, ed.HireDate)),'yyyyMMdd')) AS DateKey,
    DATEDIFF(MONTH, ed.HireDate, DATEADD(MONTH, n, ed.HireDate)) AS TenureMonths,
    CASE WHEN DATEADD(MONTH, n, ed.HireDate) <= ed.EndDate THEN 1 ELSE 0 END AS ActiveFlag,
    CASE WHEN ed.TerminationDate IS NOT NULL AND DATEADD(MONTH, n, ed.HireDate) >= ed.TerminationDate THEN 1 ELSE 0 END AS TerminatedFlag
    --CASE WHEN DATEADD(MONTH, n, ed.HireDate) >= ed.EndDate THEN 1 ELSE 0 END AS TerminatedFlag
FROM EmployeeDates ed
CROSS JOIN Numbers
WHERE DATEADD(MONTH, n, ed.HireDate) <= ed.EndDate;
GO

-- Validation
SELECT COUNT(*) AS DimEmployeeCount FROM gold.DimEmployee;
SELECT COUNT(*) AS FactSnapshotRows FROM gold.FactEmployeeSnapshot;
SELECT COUNT(*) AS FactEventRows FROM gold.FactEmployeeEvents;
SELECT COUNT(*) AS FactAbsenceRows FROM gold.FactAbsence;
GO

-- Now save these tables as csvs for use in Power BI and other tools that will connect to the gold layer without direct SQL access.
-- You can use SQL Server Management Studio's export feature or write queries to output the data in CSV format.
SELECT * FROM gold.DimEmployee;
SELECT * FROM gold.FactEmployeeSnapshot;
SELECT * FROM gold.FactEmployeeEvents;
SELECT * FROM gold.FactAbsence;