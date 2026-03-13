/*
  02_insert_bronze_data_FULL.sql
  - Loads synthetic data into bronze tables using set-based inserts
  - Counts approximate real-world volumes: 10 departments, 40 roles, 8 locations,
    3 employment types, 12 000 employees, 40 000 events and 120 000 absences
  - Deletes existing data before reloading
*/

USE TeamProject_EmployeeRetention;
GO
SET NOCOUNT ON;


---------------------------------------------------
-- CLEAR EXISTING DATA
---------------------------------------------------
DELETE FROM bronze.Absence;
DELETE FROM bronze.EmployeeEvent;
DELETE FROM bronze.Employee;
DELETE FROM bronze.EmploymentType;
DELETE FROM bronze.Role;
DELETE FROM bronze.Department;
DELETE FROM bronze.Location;
GO

---------------------------------------------------
-- TALLY TABLE (200,000)
---------------------------------------------------
IF OBJECT_ID('tempdb..#Numbers') IS NOT NULL DROP TABLE #Numbers;

;WITH N AS (
    SELECT TOP (200000)
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
SELECT n INTO #Numbers FROM N;
GO

---------------------------------------------------
-- LOCATIONS (8)
---------------------------------------------------
BEGIN TRAN;
INSERT INTO bronze.Location (LocationCode, LocationName, Region)
SELECT
    CONCAT('L', RIGHT('00' + CAST(n AS VARCHAR(2)), 2)),
    CONCAT('Location ', RIGHT('00' + CAST(n AS VARCHAR(2)), 2)),
    CASE (ABS(CHECKSUM(n*3)) % 4)
        WHEN 0 THEN 'North'
        WHEN 1 THEN 'South'
        WHEN 2 THEN 'East'
        ELSE 'West'
    END
FROM #Numbers
WHERE n <= 8;
COMMIT;
GO

---------------------------------------------------
-- DEPARTMENTS (10)
---------------------------------------------------
BEGIN TRAN;
INSERT INTO bronze.Department (DepartmentCode, DepartmentName)
SELECT
    CONCAT('D', RIGHT('00' + CAST(n AS VARCHAR(2)), 2)),
    CONCAT('Department ', RIGHT('00' + CAST(n AS VARCHAR(2)), 2))
FROM #Numbers
WHERE n <= 10;
COMMIT;
GO

---------------------------------------------------
-- ROLES (40)
---------------------------------------------------
BEGIN TRAN;
INSERT INTO bronze.Role (DepartmentID, RoleCode, RoleName)
SELECT
    1 + (ABS(CHECKSUM(n*5)) % 10),
    CONCAT('R', RIGHT('000' + CAST(n AS VARCHAR(3)), 3)),
    CONCAT('Role ', RIGHT('000' + CAST(n AS VARCHAR(3)), 3))
FROM #Numbers
WHERE n <= 40;
COMMIT;
GO

---------------------------------------------------
-- EMPLOYMENT TYPES (3)
---------------------------------------------------
BEGIN TRAN;
INSERT INTO bronze.EmploymentType (EmploymentTypeCode, EmploymentTypeName)
VALUES
('PERM','Permanent'),
('CON','Contract'),
('CAS','Casual');
COMMIT;
GO

---------------------------------------------------
-- EMPLOYEES (12,000)
---------------------------------------------------
BEGIN TRAN;
INSERT INTO bronze.Employee (
    EmployeeCode, FirstName, LastName, BirthDate, Gender,
    DepartmentID, RoleID, LocationID, EmploymentTypeID, ManagerID,
    HireDate, TerminationDate, TerminationReason, DuplicateFlag
)
SELECT
    CASE WHEN n % 100 < 2
         THEN CONCAT('EMP', RIGHT('000000' + CAST(n-1 AS VARCHAR(6)), 6))
         ELSE CONCAT('EMP', RIGHT('000000' + CAST(n   AS VARCHAR(6)), 6))
    END,
    CONCAT('First_', RIGHT('000000' + CAST(n AS VARCHAR(6)), 6)),
    CONCAT('Last_',  RIGHT('000000' + CAST(n AS VARCHAR(6)), 6)),
    DATEADD(DAY, -1 * (ABS(CHECKSUM(n*7)) % (60*365)), '2005-01-01'),
    CASE WHEN ABS(CHECKSUM(n*11)) % 2 = 0 THEN 'M' ELSE 'F' END,
    1 + (ABS(CHECKSUM(n*13)) % 10),
    1 + (ABS(CHECKSUM(n*17)) % 40),
    1 + (ABS(CHECKSUM(n*19)) % 8),
    1 + (ABS(CHECKSUM(n*23)) % 3),
    NULL, -- ManagerID will be mapped later (raw may contain nulls)
    DATEADD(DAY, -1 * (ABS(CHECKSUM(n*29)) % 3650), '2025-01-01'),
    CASE WHEN n % 10 = 0 THEN DATEADD(DAY, -1 * (ABS(CHECKSUM(n*31)) % 365), '2025-01-01') ELSE NULL END,
    CASE WHEN n % 10 = 0 THEN
        CASE (ABS(CHECKSUM(n*37)) % 3)
            WHEN 0 THEN 'Resignation'
            WHEN 1 THEN 'Retirement'
            ELSE 'Termination'
        END
    ELSE NULL END,
    CASE WHEN n % 100 < 2 THEN 1 ELSE 0 END
FROM #Numbers
WHERE n <= 12000;
COMMIT;
GO

---------------------------------------------------
-- EMPLOYEE EVENTS (40,000)
---------------------------------------------------
BEGIN TRAN;
INSERT INTO bronze.EmployeeEvent (
    EmployeeID, EventType, EventDate, DepartmentID, RoleID, LocationID, EmploymentTypeID, ManagerID, EventReason
)
SELECT
    1 + (ABS(CHECKSUM(n*41)) % 12000),
    CASE ABS(CHECKSUM(n*43)) % 6
        WHEN 0 THEN 'Hire'
        WHEN 1 THEN 'Transfer'
        WHEN 2 THEN 'Promotion'
        WHEN 3 THEN 'RoleChange'
        WHEN 4 THEN 'LocationChange'
        ELSE 'Termination'
    END,
    DATEADD(DAY, -1 * (ABS(CHECKSUM(n*47)) % 3650), '2025-01-01'),
    1 + (ABS(CHECKSUM(n*53)) % 10),
    1 + (ABS(CHECKSUM(n*59)) % 40),
    1 + (ABS(CHECKSUM(n*61)) % 8),
    1 + (ABS(CHECKSUM(n*67)) % 3),
    NULL,
    CASE ABS(CHECKSUM(n*71)) % 4
        WHEN 0 THEN 'New hire'
        WHEN 1 THEN 'Promotion to senior'
        WHEN 2 THEN 'Transfer to new team'
        ELSE 'Voluntary resignation'
    END
FROM #Numbers
WHERE n <= 40000;
COMMIT;
GO

---------------------------------------------------
-- ABSENCES (120,000)
---------------------------------------------------
BEGIN TRAN;
INSERT INTO bronze.Absence (
    EmployeeID, StartDate, EndDate, AbsenceType
)
SELECT
    1 + (ABS(CHECKSUM(n*73)) % 12000),
    DATEADD(DAY, -1 * (ABS(CHECKSUM(n*79)) % 3650), '2025-01-01'),
    DATEADD(DAY, -1 * (ABS(CHECKSUM(n*79)) % 3650) + 1 + (ABS(CHECKSUM(n*83)) % 10), '2025-01-01'),
    CASE ABS(CHECKSUM(n*89)) % 3
        WHEN 0 THEN 'Sick leave'
        WHEN 1 THEN 'Vacation'
        ELSE 'Parental leave'
    END
FROM #Numbers
WHERE n <= 120000;
COMMIT;
GO

DROP TABLE #Numbers;
GO

-- Validation
SELECT COUNT(*) AS DeptCount FROM bronze.Department;
SELECT COUNT(*) AS RoleCount FROM bronze.Role;
SELECT COUNT(*) AS LocationCount FROM bronze.Location;
SELECT COUNT(*) AS EmpTypeCount FROM bronze.EmploymentType;
SELECT COUNT(*) AS EmployeeCount FROM bronze.Employee;
SELECT COUNT(*) AS EventCount FROM bronze.EmployeeEvent;
SELECT COUNT(*) AS AbsenceCount FROM bronze.Absence;
GO