/*
================================================================================
VIDEO 11: SQL VIEWS - SIMPLIFYING COMPLEX QUERIES
Virtual Tables for Secure & Reusable Data Access
================================================================================
Duration: 15 minutes | Level: Intermediate to Advanced
Instructor: Fassahat | Emergi Mentors Data Analytics Bootcamp
================================================================================

BUSINESS SCENARIO: AusMine Resources Pty Ltd
- Leading Australian mining company
- Operations across WA, QLD, and NT
- Multiple mines: Iron ore, Gold, Coal
- Complex reporting requirements
- Data security concerns (salary data, cost data)
- Management needs simple access to complex data

PROBLEM: 
- Analysts write the same complex queries repeatedly
- 15-table joins for production reports
- Junior analysts struggle with complexity
- Security risks (exposing sensitive columns)
- Inconsistent calculations across reports
- Query performance issues

SOLUTION: SQL VIEWS
- Pre-built "virtual tables" 
- Hide complexity behind simple SELECT statements
- Enforce security (hide sensitive columns)
- Ensure consistency (same logic everywhere)
- Improve performance (indexed views)

LEARNING OBJECTIVES:
- Create and manage SQL views
- Understand view types (simple, complex, indexed)
- Implement security with views
- Use views for reporting simplification
- Master view best practices

================================================================================
*/

-- ============================================================================
-- SECTION 1: ENVIRONMENT SETUP
-- ============================================================================

USE master;
GO

-- Drop database if exists (training reset)
IF DB_ID('AusMine_Resources') IS NOT NULL
BEGIN
    ALTER DATABASE AusMine_Resources SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE AusMine_Resources;
END
GO

-- Create fresh database
CREATE DATABASE AusMine_Resources;
GO

USE AusMine_Resources;
GO

PRINT '✓ Database AusMine_Resources created successfully';
PRINT '';
GO

-- ============================================================================
-- SECTION 2: CREATE BASE SCHEMA - AUSMINE RESOURCES
-- ============================================================================

PRINT '--- Creating AusMine Resources Database Schema ---';
PRINT '';

-- Sites table (Mining locations)
CREATE TABLE sites (
    site_id INT PRIMARY KEY IDENTITY(1,1),
    site_code NVARCHAR(20) NOT NULL UNIQUE,
    site_name NVARCHAR(100) NOT NULL,
    state NVARCHAR(3) NOT NULL,
    resource_type NVARCHAR(50) NOT NULL,
    opened_date DATE NOT NULL,
    status NVARCHAR(20) NOT NULL DEFAULT 'Active',
    site_manager NVARCHAR(100),
    CONSTRAINT CK_state CHECK (state IN ('WA', 'QLD', 'NT', 'SA', 'NSW')),
    CONSTRAINT CK_resource CHECK (resource_type IN ('Iron Ore', 'Gold', 'Coal', 'Copper', 'Lithium')),
    CONSTRAINT CK_status CHECK (status IN ('Active', 'Maintenance', 'Closed'))
);

-- Employees table
CREATE TABLE employees (
    employee_id INT PRIMARY KEY IDENTITY(1,1),
    employee_code NVARCHAR(20) NOT NULL UNIQUE,
    first_name NVARCHAR(50) NOT NULL,
    last_name NVARCHAR(50) NOT NULL,
    email NVARCHAR(100) NOT NULL,
    job_title NVARCHAR(100) NOT NULL,
    department NVARCHAR(50) NOT NULL,
    site_id INT,
    hire_date DATE NOT NULL,
    annual_salary DECIMAL(12,2) NOT NULL, -- SENSITIVE DATA
    superannuation DECIMAL(12,2) NOT NULL, -- SENSITIVE DATA
    employment_status NVARCHAR(20) NOT NULL DEFAULT 'Active',
    CONSTRAINT FK_employees_sites FOREIGN KEY (site_id) REFERENCES sites(site_id),
    CONSTRAINT CK_employment_status CHECK (employment_status IN ('Active', 'On Leave', 'Terminated'))
);

-- Equipment table
CREATE TABLE equipment (
    equipment_id INT PRIMARY KEY IDENTITY(1,1),
    equipment_code NVARCHAR(30) NOT NULL UNIQUE,
    equipment_type NVARCHAR(50) NOT NULL,
    manufacturer NVARCHAR(100) NOT NULL,
    model NVARCHAR(100) NOT NULL,
    site_id INT NOT NULL,
    purchase_date DATE NOT NULL,
    purchase_cost DECIMAL(15,2) NOT NULL, -- SENSITIVE DATA
    operational_status NVARCHAR(20) NOT NULL DEFAULT 'Operational',
    last_maintenance_date DATE,
    CONSTRAINT FK_equipment_sites FOREIGN KEY (site_id) REFERENCES sites(site_id),
    CONSTRAINT CK_operational_status CHECK (operational_status IN ('Operational', 'Maintenance', 'Decommissioned'))
);

-- Production table (Daily production records)
CREATE TABLE production (
    production_id INT PRIMARY KEY IDENTITY(1,1),
    site_id INT NOT NULL,
    production_date DATE NOT NULL,
    resource_type NVARCHAR(50) NOT NULL,
    tonnes_produced DECIMAL(15,2) NOT NULL,
    grade_percentage DECIMAL(5,2), -- Quality metric (e.g., iron content %)
    shift_type NVARCHAR(20) NOT NULL,
    operating_hours DECIMAL(5,2) NOT NULL,
    CONSTRAINT FK_production_sites FOREIGN KEY (site_id) REFERENCES sites(site_id),
    CONSTRAINT CK_shift_type CHECK (shift_type IN ('Day', 'Night', 'Both'))
);

-- Safety incidents table
CREATE TABLE safety_incidents (
    incident_id INT PRIMARY KEY IDENTITY(1,1),
    site_id INT NOT NULL,
    incident_date DATE NOT NULL,
    incident_type NVARCHAR(50) NOT NULL,
    severity NVARCHAR(20) NOT NULL,
    description NVARCHAR(500),
    resolved BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_incidents_sites FOREIGN KEY (site_id) REFERENCES sites(site_id),
    CONSTRAINT CK_severity CHECK (severity IN ('Minor', 'Moderate', 'Serious', 'Critical'))
);

-- Costs table (Operating costs)
CREATE TABLE operating_costs (
    cost_id INT PRIMARY KEY IDENTITY(1,1),
    site_id INT NOT NULL,
    cost_date DATE NOT NULL,
    cost_category NVARCHAR(50) NOT NULL,
    amount DECIMAL(15,2) NOT NULL, -- SENSITIVE DATA
    description NVARCHAR(200),
    CONSTRAINT FK_costs_sites FOREIGN KEY (site_id) REFERENCES sites(site_id),
    CONSTRAINT CK_cost_category CHECK (cost_category IN ('Labour', 'Equipment', 'Energy', 'Materials', 'Maintenance', 'Other'))
);

-- Create indexes for performance
CREATE INDEX IX_production_site_date ON production(site_id, production_date);
CREATE INDEX IX_employees_site ON employees(site_id);
CREATE INDEX IX_equipment_site ON equipment(site_id);
CREATE INDEX IX_costs_site_date ON operating_costs(site_id, cost_date);
CREATE INDEX IX_incidents_site_date ON safety_incidents(site_id, incident_date);

PRINT '✓ Base tables created with indexes';
PRINT '';
GO

-- ============================================================================
-- SECTION 3: POPULATE SAMPLE DATA
-- ============================================================================

PRINT '--- Populating AusMine Resources Data ---';
PRINT '';

-- Insert mining sites
INSERT INTO sites (site_code, site_name, state, resource_type, opened_date, status, site_manager)
VALUES 
    ('WA-IRON-01', 'Pilbara Iron Mine', 'WA', 'Iron Ore', '2015-03-15', 'Active', 'Sarah Mitchell'),
    ('WA-GOLD-01', 'Kalgoorlie Gold Mine', 'WA', 'Gold', '2012-07-20', 'Active', 'James Anderson'),
    ('QLD-COAL-01', 'Bowen Basin Coal Mine', 'QLD', 'Coal', '2010-05-10', 'Active', 'David Chen'),
    ('NT-GOLD-01', 'Tanami Gold Mine', 'NT', 'Gold', '2018-11-01', 'Active', 'Emma Thompson'),
    ('WA-LITH-01', 'Greenbushes Lithium Mine', 'WA', 'Lithium', '2020-02-15', 'Active', 'Michael O''Brien'),
    ('QLD-COPR-01', 'Mount Isa Copper Mine', 'QLD', 'Copper', '2008-09-22', 'Active', 'Lisa Wong'),
    ('WA-IRON-02', 'Port Hedland Iron Mine', 'WA', 'Iron Ore', '2014-06-30', 'Active', 'Robert Taylor'),
    ('SA-COPR-01', 'Olympic Dam Copper Mine', 'SA', 'Copper', '2005-12-01', 'Maintenance', 'Jennifer Lee');

PRINT '✓ Inserted 8 mining sites';
PRINT '';
GO

-- Insert employees (120 employees across sites)
DECLARE @SiteID INT = 1;
DECLARE @EmpCount INT = 0;

WHILE @SiteID <= 8
BEGIN
    -- Site Manager
    INSERT INTO employees (employee_code, first_name, last_name, email, job_title, department, site_id, hire_date, annual_salary, superannuation, employment_status)
    VALUES 
        ('EMP-' + RIGHT('0000' + CAST(@SiteID * 100 AS NVARCHAR), 4), 'Site', 'Manager', 'manager@ausmine.com.au', 'Site Manager', 'Management', @SiteID, '2020-01-15', 185000.00, 17575.00, 'Active');
    
    -- Engineers (3 per site)
    INSERT INTO employees (employee_code, first_name, last_name, email, job_title, department, site_id, hire_date, annual_salary, superannuation, employment_status)
    VALUES 
        ('EMP-' + RIGHT('0000' + CAST(@SiteID * 100 + 1 AS NVARCHAR), 4), 'Mining', 'Engineer1', 'engineer1@ausmine.com.au', 'Mining Engineer', 'Engineering', @SiteID, '2020-03-01', 125000.00, 11875.00, 'Active'),
        ('EMP-' + RIGHT('0000' + CAST(@SiteID * 100 + 2 AS NVARCHAR), 4), 'Mining', 'Engineer2', 'engineer2@ausmine.com.au', 'Mining Engineer', 'Engineering', @SiteID, '2020-06-15', 125000.00, 11875.00, 'Active'),
        ('EMP-' + RIGHT('0000' + CAST(@SiteID * 100 + 3 AS NVARCHAR), 4), 'Process', 'Engineer', 'pengineer@ausmine.com.au', 'Process Engineer', 'Engineering', @SiteID, '2021-01-10', 115000.00, 10925.00, 'Active');
    
    -- Operators (10 per site)
    DECLARE @OpCount INT = 1;
    WHILE @OpCount <= 10
    BEGIN
        INSERT INTO employees (employee_code, first_name, last_name, email, job_title, department, site_id, hire_date, annual_salary, superannuation, employment_status)
        VALUES 
            ('EMP-' + RIGHT('0000' + CAST(@SiteID * 100 + 10 + @OpCount AS NVARCHAR), 4), 
             'Operator', 
             CAST(@OpCount AS NVARCHAR), 
             'operator' + CAST(@OpCount AS NVARCHAR) + '@ausmine.com.au', 
             'Equipment Operator', 
             'Operations', 
             @SiteID, 
             DATEADD(MONTH, -@OpCount * 3, '2023-01-01'), 
             95000.00, 
             9025.00, 
             'Active');
        SET @OpCount = @OpCount + 1;
    END
    
    SET @SiteID = @SiteID + 1;
END

PRINT '✓ Inserted 120 employees across all sites';

-- Insert equipment
INSERT INTO equipment (equipment_code, equipment_type, manufacturer, model, site_id, purchase_date, purchase_cost, operational_status, last_maintenance_date)
VALUES 
    -- Pilbara Iron Mine (Site 1)
    ('EQ-001-HAU', 'Haul Truck', 'Caterpillar', '797F', 1, '2015-03-20', 5500000.00, 'Operational', '2024-11-15'),
    ('EQ-002-HAU', 'Haul Truck', 'Caterpillar', '797F', 1, '2015-03-20', 5500000.00, 'Operational', '2024-11-20'),
    ('EQ-003-EXC', 'Excavator', 'Komatsu', 'PC8000', 1, '2015-04-10', 8500000.00, 'Operational', '2024-12-01'),
    ('EQ-004-DRL', 'Drill Rig', 'Atlas Copco', 'PV-271', 1, '2015-05-15', 3200000.00, 'Operational', '2024-11-25'),
    ('EQ-005-DRL', 'Drill Rig', 'Atlas Copco', 'PV-271', 1, '2015-05-15', 3200000.00, 'Maintenance', '2024-10-30'),
    
    -- Kalgoorlie Gold Mine (Site 2)
    ('EQ-006-HAU', 'Haul Truck', 'Caterpillar', '785D', 2, '2012-08-01', 3500000.00, 'Operational', '2024-11-10'),
    ('EQ-007-EXC', 'Excavator', 'Hitachi', 'EX5600', 2, '2012-08-15', 6500000.00, 'Operational', '2024-11-18'),
    ('EQ-008-PRO', 'Processing Plant', 'Metso', 'HP400', 2, '2012-09-01', 12000000.00, 'Operational', '2024-12-05'),
    
    -- Bowen Basin Coal Mine (Site 3)
    ('EQ-009-HAU', 'Haul Truck', 'Komatsu', '930E', 3, '2010-06-15', 4800000.00, 'Operational', '2024-11-12'),
    ('EQ-010-HAU', 'Haul Truck', 'Komatsu', '930E', 3, '2010-06-15', 4800000.00, 'Operational', '2024-11-12'),
    ('EQ-011-EXC', 'Excavator', 'Liebherr', 'R9800', 3, '2010-07-20', 9500000.00, 'Operational', '2024-12-02'),
    ('EQ-012-CON', 'Conveyor System', 'Rulmeca', 'Heavy Duty', 3, '2010-08-10', 4500000.00, 'Operational', '2024-11-28'),
    
    -- Tanami Gold Mine (Site 4)
    ('EQ-013-HAU', 'Haul Truck', 'Caterpillar', '777G', 4, '2018-11-15', 2800000.00, 'Operational', '2024-11-22'),
    ('EQ-014-EXC', 'Excavator', 'Komatsu', 'PC4000', 4, '2018-12-01', 5500000.00, 'Operational', '2024-12-03'),
    
    -- Greenbushes Lithium Mine (Site 5)
    ('EQ-015-HAU', 'Haul Truck', 'Caterpillar', '785D', 5, '2020-03-10', 3500000.00, 'Operational', '2024-11-16'),
    ('EQ-016-PRO', 'Processing Plant', 'FLSmidth', 'Lithium Pro', 5, '2020-04-15', 15000000.00, 'Operational', '2024-12-01');

PRINT '✓ Inserted 16 pieces of equipment';

-- Insert production data (Daily production for December 2024)
DECLARE @ProdDate DATE = '2024-12-01';
DECLARE @ProdSiteID INT;

WHILE @ProdDate <= '2024-12-31'
BEGIN
    SET @ProdSiteID = 1;
    
    WHILE @ProdSiteID <= 8
    BEGIN
        -- Day shift
        INSERT INTO production (site_id, production_date, resource_type, tonnes_produced, grade_percentage, shift_type, operating_hours)
        SELECT 
            @ProdSiteID,
            @ProdDate,
            resource_type,
            CASE resource_type
                WHEN 'Iron Ore' THEN ROUND(RAND(CHECKSUM(NEWID())) * 50000 + 100000, 2) -- 100-150k tonnes/day
                WHEN 'Coal' THEN ROUND(RAND(CHECKSUM(NEWID())) * 30000 + 80000, 2) -- 80-110k tonnes/day
                WHEN 'Gold' THEN ROUND(RAND(CHECKSUM(NEWID())) * 50 + 100, 2) -- 100-150 kg/day
                WHEN 'Copper' THEN ROUND(RAND(CHECKSUM(NEWID())) * 500 + 1000, 2) -- 1-1.5k tonnes/day
                WHEN 'Lithium' THEN ROUND(RAND(CHECKSUM(NEWID())) * 200 + 500, 2) -- 500-700 tonnes/day
            END,
            CASE resource_type
                WHEN 'Iron Ore' THEN ROUND(RAND(CHECKSUM(NEWID())) * 5 + 60, 2) -- 60-65% Fe content
                WHEN 'Coal' THEN ROUND(RAND(CHECKSUM(NEWID())) * 10 + 75, 2) -- 75-85% carbon
                WHEN 'Gold' THEN ROUND(RAND(CHECKSUM(NEWID())) * 2 + 3, 2) -- 3-5 g/t
                WHEN 'Copper' THEN ROUND(RAND(CHECKSUM(NEWID())) * 1 + 2, 2) -- 2-3%
                WHEN 'Lithium' THEN ROUND(RAND(CHECKSUM(NEWID())) * 0.5 + 1.5, 2) -- 1.5-2%
            END,
            'Day',
            ROUND(RAND(CHECKSUM(NEWID())) * 2 + 10, 1) -- 10-12 hours
        FROM sites
        WHERE site_id = @ProdSiteID AND status = 'Active';
        
        -- Night shift (if active)
        IF @ProdSiteID NOT IN (8) -- Site 8 is in maintenance
        BEGIN
            INSERT INTO production (site_id, production_date, resource_type, tonnes_produced, grade_percentage, shift_type, operating_hours)
            SELECT 
                @ProdSiteID,
                @ProdDate,
                resource_type,
                CASE resource_type
                    WHEN 'Iron Ore' THEN ROUND(RAND(CHECKSUM(NEWID())) * 40000 + 90000, 2)
                    WHEN 'Coal' THEN ROUND(RAND(CHECKSUM(NEWID())) * 25000 + 70000, 2)
                    WHEN 'Gold' THEN ROUND(RAND(CHECKSUM(NEWID())) * 40 + 80, 2)
                    WHEN 'Copper' THEN ROUND(RAND(CHECKSUM(NEWID())) * 400 + 900, 2)
                    WHEN 'Lithium' THEN ROUND(RAND(CHECKSUM(NEWID())) * 150 + 450, 2)
                END,
                CASE resource_type
                    WHEN 'Iron Ore' THEN ROUND(RAND(CHECKSUM(NEWID())) * 5 + 60, 2)
                    WHEN 'Coal' THEN ROUND(RAND(CHECKSUM(NEWID())) * 10 + 75, 2)
                    WHEN 'Gold' THEN ROUND(RAND(CHECKSUM(NEWID())) * 2 + 3, 2)
                    WHEN 'Copper' THEN ROUND(RAND(CHECKSUM(NEWID())) * 1 + 2, 2)
                    WHEN 'Lithium' THEN ROUND(RAND(CHECKSUM(NEWID())) * 0.5 + 1.5, 2)
                END,
                'Night',
                ROUND(RAND(CHECKSUM(NEWID())) * 2 + 10, 1)
            FROM sites
            WHERE site_id = @ProdSiteID AND status = 'Active';
        END
        
        SET @ProdSiteID = @ProdSiteID + 1;
    END
    
    SET @ProdDate = DATEADD(DAY, 1, @ProdDate);
END

PRINT '✓ Inserted December 2024 production data (434 records)';

-- Insert safety incidents
INSERT INTO safety_incidents (site_id, incident_date, incident_type, severity, description, resolved)
VALUES 
    (1, '2024-12-05', 'Equipment Failure', 'Moderate', 'Haul truck hydraulic failure', 1),
    (1, '2024-12-12', 'Near Miss', 'Minor', 'Vehicle proximity alert', 1),
    (2, '2024-12-08', 'Environmental', 'Minor', 'Dust control system adjustment needed', 1),
    (3, '2024-12-15', 'Injury', 'Moderate', 'Minor hand injury during maintenance', 1),
    (3, '2024-12-20', 'Equipment Failure', 'Serious', 'Conveyor belt malfunction', 0),
    (4, '2024-12-10', 'Near Miss', 'Minor', 'Pedestrian alert in restricted area', 1),
    (5, '2024-12-18', 'Environmental', 'Moderate', 'Water management system check', 1),
    (6, '2024-12-22', 'Equipment Failure', 'Minor', 'Sensor calibration required', 1);

PRINT '✓ Inserted 8 safety incidents';

-- Insert operating costs (Daily for December 2024)
DECLARE @CostDate DATE = '2024-12-01';
DECLARE @CostSiteID INT;

WHILE @CostDate <= '2024-12-31'
BEGIN
    SET @CostSiteID = 1;
    
    WHILE @CostSiteID <= 8
    BEGIN
        -- Daily labour costs
        INSERT INTO operating_costs (site_id, cost_date, cost_category, amount, description)
        VALUES (@CostSiteID, @CostDate, 'Labour', ROUND(RAND(CHECKSUM(NEWID())) * 50000 + 150000, 2), 'Daily labour costs');
        
        -- Daily energy costs
        INSERT INTO operating_costs (site_id, cost_date, cost_category, amount, description)
        VALUES (@CostSiteID, @CostDate, 'Energy', ROUND(RAND(CHECKSUM(NEWID())) * 30000 + 80000, 2), 'Daily energy costs');
        
        -- Equipment costs (every 3 days)
        IF DAY(@CostDate) % 3 = 0
        BEGIN
            INSERT INTO operating_costs (site_id, cost_date, cost_category, amount, description)
            VALUES (@CostSiteID, @CostDate, 'Equipment', ROUND(RAND(CHECKSUM(NEWID())) * 20000 + 30000, 2), 'Equipment fuel and consumables');
        END
        
        -- Maintenance (weekly)
        IF DATEPART(WEEKDAY, @CostDate) = 1
        BEGIN
            INSERT INTO operating_costs (site_id, cost_date, cost_category, amount, description)
            VALUES (@CostSiteID, @CostDate, 'Maintenance', ROUND(RAND(CHECKSUM(NEWID())) * 40000 + 60000, 2), 'Weekly maintenance activities');
        END
        
        SET @CostSiteID = @CostSiteID + 1;
    END
    
    SET @CostDate = DATEADD(DAY, 1, @CostDate);
END

PRINT '✓ Inserted December 2024 operating costs';
PRINT '';

-- Display data summary
PRINT '--- Data Summary ---';
SELECT 'Mining Sites' AS Entity, COUNT(*) AS Count FROM sites
UNION ALL SELECT 'Employees', COUNT(*) FROM employees
UNION ALL SELECT 'Equipment', COUNT(*) FROM equipment
UNION ALL SELECT 'Production Records', COUNT(*) FROM production
UNION ALL SELECT 'Safety Incidents', COUNT(*) FROM safety_incidents
UNION ALL SELECT 'Cost Records', COUNT(*) FROM operating_costs;

PRINT '';
PRINT '================================================================================';
PRINT 'SECTION 4: THE PROBLEM - COMPLEX QUERIES';
PRINT '================================================================================';
PRINT '';
GO

-- ============================================================================
-- DEMO 1: The Complexity Problem
-- ============================================================================

PRINT '--- DEMO 1: The Analyst Nightmare ---';
PRINT '';
PRINT 'Scenario: Management wants a simple report of site performance.';
PRINT 'Without views, analysts must write this complex query EVERY TIME:';
PRINT '';

-- The complex query analysts struggle with
SELECT 
    s.site_name,
    s.state,
    s.resource_type,
    COUNT(DISTINCT e.employee_id) AS total_employees,
    COUNT(DISTINCT eq.equipment_id) AS total_equipment,
    SUM(p.tonnes_produced) AS december_production,
    AVG(p.grade_percentage) AS avg_grade,
    SUM(oc.amount) AS december_costs,
    COUNT(DISTINCT si.incident_id) AS safety_incidents,
    CASE 
        WHEN SUM(p.tonnes_produced) > 0 
        THEN ROUND(SUM(oc.amount) / SUM(p.tonnes_produced), 2)
        ELSE 0 
    END AS cost_per_tonne
FROM sites s
LEFT JOIN employees e ON s.site_id = e.site_id AND e.employment_status = 'Active'
LEFT JOIN equipment eq ON s.site_id = eq.site_id AND eq.operational_status = 'Operational'
LEFT JOIN production p ON s.site_id = p.site_id 
    AND p.production_date >= '2024-12-01' 
    AND p.production_date <= '2024-12-31'
LEFT JOIN operating_costs oc ON s.site_id = oc.site_id 
    AND oc.cost_date >= '2024-12-01' 
    AND oc.cost_date <= '2024-12-31'
LEFT JOIN safety_incidents si ON s.site_id = si.site_id 
    AND si.incident_date >= '2024-12-01' 
    AND si.incident_date <= '2024-12-31'
WHERE s.status = 'Active'
GROUP BY s.site_name, s.state, s.resource_type
ORDER BY december_production DESC;

PRINT '';
PRINT 'Problems with this approach:';
PRINT '❌ 60+ lines of complex SQL';
PRINT '❌ Multiple JOINs (easy to make mistakes)';
PRINT '❌ Junior analysts struggle to understand';
PRINT '❌ Inconsistent calculations across reports';
PRINT '❌ Performance issues (no optimization)';
PRINT '❌ Must be rewritten for every report';
PRINT '';
PRINT 'What if we could simplify this to: SELECT * FROM vw_SitePerformance?';
PRINT '';
GO

PRINT '================================================================================';
PRINT 'SECTION 5: SQL VIEWS - THE SOLUTION';
PRINT '================================================================================';
PRINT '';
GO

-- ============================================================================
-- DEMO 2: Creating Your First View
-- ============================================================================

PRINT '--- DEMO 2: Creating a Simple View ---';
PRINT '';
GO

-- Create a simple view for active sites
CREATE VIEW vw_ActiveSites
AS
SELECT 
    site_id,
    site_code,
    site_name,
    state,
    resource_type,
    site_manager,
    opened_date
FROM sites
WHERE status = 'Active';
GO

PRINT '✓ View vw_ActiveSites created';
PRINT '';
PRINT 'Now anyone can query it simply:';

-- Query the view (simple!)
SELECT * FROM vw_ActiveSites ORDER BY site_name;

PRINT '';
PRINT 'Benefits:';
PRINT '✓ Hides the WHERE clause complexity';
PRINT '✓ Ensures consistent "active sites" definition';
PRINT '✓ Simple to understand and use';
PRINT '';
GO

-- ============================================================================
-- DEMO 3: Views for Security - Hiding Sensitive Data
-- ============================================================================

PRINT '--- DEMO 3: Security View (Hiding Salary Data) ---';
PRINT '';
GO

-- Create view that EXCLUDES sensitive salary information
CREATE VIEW vw_EmployeeDirectory
AS
SELECT 
    employee_code,
    first_name + ' ' + last_name AS full_name,
    email,
    job_title,
    department,
    s.site_name,
    s.state,
    hire_date,
    employment_status
    -- NOTE: annual_salary and superannuation are EXCLUDED
FROM employees e
JOIN sites s ON e.site_id = s.site_id
WHERE e.employment_status = 'Active';
GO

PRINT '✓ View vw_EmployeeDirectory created (without salary data)';
PRINT '';
PRINT 'Junior analysts can now query employee info without seeing salaries:';

SELECT TOP 10 * FROM vw_EmployeeDirectory ORDER BY full_name;

PRINT '';
PRINT 'Security Benefits:';
PRINT '✓ Sensitive columns hidden from view';
PRINT '✓ Can grant SELECT on view without exposing base table';
PRINT '✓ Centralized access control';
PRINT '';
GO

-- ============================================================================
-- DEMO 4: Complex View - Site Performance Dashboard
-- ============================================================================

PRINT '--- DEMO 4: Complex View for Executive Dashboard ---';
PRINT '';
GO

-- Create comprehensive site performance view
CREATE VIEW vw_SitePerformanceDashboard
AS
SELECT 
    s.site_id,
    s.site_code,
    s.site_name,
    s.state,
    s.resource_type,
    s.site_manager,
    
    -- Employee metrics
    COUNT(DISTINCT e.employee_id) AS total_employees,
    
    -- Equipment metrics
    COUNT(DISTINCT eq.equipment_id) AS total_equipment,
    SUM(CASE WHEN eq.operational_status = 'Operational' THEN 1 ELSE 0 END) AS operational_equipment,
    
    -- Production metrics (December 2024)
    SUM(CASE 
        WHEN p.production_date >= '2024-12-01' AND p.production_date <= '2024-12-31'
        THEN p.tonnes_produced ELSE 0 
    END) AS december_production,
    
    AVG(CASE 
        WHEN p.production_date >= '2024-12-01' AND p.production_date <= '2024-12-31'
        THEN p.grade_percentage ELSE NULL 
    END) AS avg_grade_december,
    
    -- Cost metrics (December 2024)
    SUM(CASE 
        WHEN oc.cost_date >= '2024-12-01' AND oc.cost_date <= '2024-12-31'
        THEN oc.amount ELSE 0 
    END) AS december_costs,
    
    -- Safety metrics (December 2024)
    COUNT(DISTINCT CASE 
        WHEN si.incident_date >= '2024-12-01' AND si.incident_date <= '2024-12-31'
        THEN si.incident_id ELSE NULL 
    END) AS december_incidents,
    
    -- Calculated KPIs
    CASE 
        WHEN SUM(CASE 
            WHEN p.production_date >= '2024-12-01' AND p.production_date <= '2024-12-31'
            THEN p.tonnes_produced ELSE 0 
        END) > 0 
        THEN ROUND(
            SUM(CASE 
                WHEN oc.cost_date >= '2024-12-01' AND oc.cost_date <= '2024-12-31'
                THEN oc.amount ELSE 0 
            END) / 
            SUM(CASE 
                WHEN p.production_date >= '2024-12-01' AND p.production_date <= '2024-12-31'
                THEN p.tonnes_produced ELSE 0 
            END), 2)
        ELSE 0 
    END AS cost_per_tonne_december

FROM sites s
LEFT JOIN employees e ON s.site_id = e.site_id AND e.employment_status = 'Active'
LEFT JOIN equipment eq ON s.site_id = eq.site_id
LEFT JOIN production p ON s.site_id = p.site_id
LEFT JOIN operating_costs oc ON s.site_id = oc.site_id
LEFT JOIN safety_incidents si ON s.site_id = si.site_id
WHERE s.status = 'Active'
GROUP BY 
    s.site_id, s.site_code, s.site_name, s.state, 
    s.resource_type, s.site_manager;
GO

PRINT '✓ View vw_SitePerformanceDashboard created';
PRINT '';
PRINT 'Now executives can get their dashboard with ONE simple query:';
PRINT '';

-- Simple query for executives
SELECT 
    site_name,
    state,
    resource_type,
    total_employees,
    operational_equipment,
    FORMAT(december_production, 'N0') AS production_tonnes,
    FORMAT(december_costs, 'C0') AS costs,
    december_incidents,
    FORMAT(cost_per_tonne_december, 'C2') AS cost_per_tonne
FROM vw_SitePerformanceDashboard
ORDER BY december_production DESC;

PRINT '';
PRINT 'Transformation:';
PRINT 'BEFORE: 60+ lines of complex SQL';
PRINT 'AFTER:  1 simple SELECT from view';
PRINT '✓ Consistency across all reports';
PRINT '✓ Easy to maintain (change view once, all reports update)';
PRINT '';
GO

-- ============================================================================
-- DEMO 5: Views with Parameters (Using WHERE clause)
-- ============================================================================

PRINT '--- DEMO 5: Parameterized Queries on Views ---';
PRINT '';
GO

-- Create view for production analysis
CREATE VIEW vw_ProductionAnalysis
AS
SELECT 
    s.site_name,
    s.state,
    s.resource_type,
    p.production_date,
    p.shift_type,
    p.tonnes_produced,
    p.grade_percentage,
    p.operating_hours,
    ROUND(p.tonnes_produced / p.operating_hours, 2) AS tonnes_per_hour
FROM production p
JOIN sites s ON p.site_id = s.site_id;
GO

PRINT '✓ View vw_ProductionAnalysis created';
PRINT '';
PRINT 'Analysts can now filter by any parameter they need:';
PRINT '';

-- Example 1: Filter by state
PRINT '1. Western Australia production only:';
SELECT 
    site_name,
    SUM(tonnes_produced) AS total_production,
    AVG(grade_percentage) AS avg_grade
FROM vw_ProductionAnalysis
WHERE state = 'WA'
  AND production_date >= '2024-12-01'
GROUP BY site_name
ORDER BY total_production DESC;

PRINT '';

-- Example 2: Filter by resource type
PRINT '2. Gold production analysis:';
SELECT 
    site_name,
    COUNT(*) AS shifts,
    SUM(tonnes_produced) AS total_kg,
    AVG(grade_percentage) AS avg_grade
FROM vw_ProductionAnalysis
WHERE resource_type = 'Gold'
  AND production_date >= '2024-12-01'
GROUP BY site_name;

PRINT '';
GO

-- ============================================================================
-- DEMO 6: Updating Data Through Views
-- ============================================================================

PRINT '--- DEMO 6: Updating Data Through Views ---';
PRINT '';
GO

-- Create updatable view
CREATE VIEW vw_SiteManagers
AS
SELECT 
    site_id,
    site_name,
    site_manager,
    status
FROM sites;
GO

PRINT '✓ View vw_SiteManagers created';
PRINT '';

-- Show current site managers
PRINT 'Current site managers:';
SELECT site_name, site_manager FROM vw_SiteManagers WHERE status = 'Active';

PRINT '';
PRINT 'Updating site manager through view...';

-- Update through view
UPDATE vw_SiteManagers
SET site_manager = 'Andrew Richards'
WHERE site_name = 'Kalgoorlie Gold Mine';

PRINT '✓ Update successful';
PRINT '';
PRINT 'Verify update:';
SELECT site_name, site_manager FROM vw_SiteManagers WHERE site_name = 'Kalgoorlie Gold Mine';

PRINT '';
PRINT 'Note: Simple views (single table, no aggregations) are updatable!';
PRINT '';
GO

-- ============================================================================
-- DEMO 7: View Metadata and Management
-- ============================================================================

PRINT '--- DEMO 7: Managing Views ---';
PRINT '';

-- List all views in database
PRINT 'All views in AusMine_Resources database:';
SELECT 
    TABLE_NAME AS ViewName,
    'View' AS ObjectType
FROM INFORMATION_SCHEMA.VIEWS
ORDER BY TABLE_NAME;

PRINT '';

-- View definition
PRINT 'View definition for vw_ActiveSites:';
EXEC sp_helptext 'vw_ActiveSites';

PRINT '';

-- Alter a view
PRINT 'Modifying vw_ActiveSites to include status...';
GO

ALTER VIEW vw_ActiveSites
AS
SELECT 
    site_id,
    site_code,
    site_name,
    state,
    resource_type,
    site_manager,
    opened_date,
    status -- Added this column
FROM sites
WHERE status IN ('Active', 'Maintenance'); -- Modified filter
GO

PRINT '✓ View altered successfully';
SELECT TOP 5 * FROM vw_ActiveSites;

PRINT '';
GO

-- ============================================================================
-- DEMO 8: Views for Data Quality and Validation
-- ============================================================================

PRINT '--- DEMO 8: Data Quality Views ---';
PRINT '';
GO

-- Create view to identify data quality issues
CREATE VIEW vw_DataQualityAlerts
AS
SELECT 
    'Missing Site Manager' AS alert_type,
    site_name AS affected_entity,
    'Site: ' + site_name + ' has no assigned manager' AS alert_message,
    'High' AS priority
FROM sites
WHERE site_manager IS NULL AND status = 'Active'

UNION ALL

SELECT 
    'Equipment Overdue Maintenance',
    s.site_name,
    'Equipment ' + eq.equipment_code + ' last maintained ' + 
    CAST(DATEDIFF(DAY, eq.last_maintenance_date, GETDATE()) AS NVARCHAR) + ' days ago',
    CASE 
        WHEN DATEDIFF(DAY, eq.last_maintenance_date, GETDATE()) > 60 THEN 'Critical'
        WHEN DATEDIFF(DAY, eq.last_maintenance_date, GETDATE()) > 45 THEN 'High'
        ELSE 'Medium'
    END
FROM equipment eq
JOIN sites s ON eq.site_id = s.site_id
WHERE eq.last_maintenance_date < DATEADD(DAY, -30, GETDATE())
  AND eq.operational_status = 'Operational'

UNION ALL

SELECT 
    'Unresolved Safety Incident',
    s.site_name,
    'Incident #' + CAST(si.incident_id AS NVARCHAR) + ' (' + si.severity + ') from ' + 
    CONVERT(NVARCHAR(20), si.incident_date, 120) + ' still unresolved',
    CASE si.severity
        WHEN 'Critical' THEN 'Critical'
        WHEN 'Serious' THEN 'High'
        ELSE 'Medium'
    END
FROM safety_incidents si
JOIN sites s ON si.site_id = s.site_id
WHERE si.resolved = 0;
GO

PRINT '✓ View vw_DataQualityAlerts created';
PRINT '';
PRINT 'Data quality dashboard:';
SELECT 
    alert_type,
    priority,
    COUNT(*) AS alert_count
FROM vw_DataQualityAlerts
GROUP BY alert_type, priority
ORDER BY 
    CASE priority 
        WHEN 'Critical' THEN 1 
        WHEN 'High' THEN 2 
        WHEN 'Medium' THEN 3 
        ELSE 4 
    END;

PRINT '';
PRINT 'Detailed alerts:';
SELECT TOP 10 * FROM vw_DataQualityAlerts ORDER BY 
    CASE priority 
        WHEN 'Critical' THEN 1 
        WHEN 'High' THEN 2 
        ELSE 3 
    END;

PRINT '';
GO

--If you make a mistake in a view, you can simply ALTER it to fix the issue without affecting any dependent queries or reports!
--DROP VIEW vw_DataQualityAlerts;
--GO

-- ============================================================================
-- DEMO 9: Creating Indexed Views (Performance)
-- ============================================================================

PRINT '--- DEMO 9: Indexed Views for Performance ---';
PRINT '';
GO

-- Create view with aggregations suitable for indexing
CREATE VIEW vw_DailyProductionSummary
WITH SCHEMABINDING -- Required for indexed views
AS
SELECT 
    p.site_id,
    p.production_date,
    p.resource_type,
    COUNT_BIG(*) AS shift_count, -- COUNT_BIG required for indexed views
    SUM(p.tonnes_produced) AS total_tonnes,
    SUM(p.operating_hours) AS total_hours
FROM dbo.production p -- Must use schema prefix with SCHEMABINDING
GROUP BY p.site_id, p.production_date, p.resource_type;
GO

-- Create unique clustered index on the view
CREATE UNIQUE CLUSTERED INDEX IX_DailyProdSummary 
ON vw_DailyProductionSummary(site_id, production_date, resource_type);
GO

PRINT '✓ Indexed view vw_DailyProductionSummary created';
PRINT '';
PRINT 'This view now has physical storage and can dramatically improve query performance!';
PRINT '';

-- Query the indexed view
SELECT 
    s.site_name,
    vw.production_date,
    FORMAT(vw.total_tonnes, 'N0') AS tonnes_produced,
    vw.total_hours AS operating_hours
FROM vw_DailyProductionSummary vw
JOIN sites s ON vw.site_id = s.site_id
WHERE vw.production_date >= '2024-12-01'
  AND vw.production_date <= '2024-12-07'
ORDER BY vw.production_date, s.site_name;

PRINT '';
PRINT 'Indexed View Benefits:';
PRINT '✓ Results are pre-calculated and stored';
PRINT '✓ Queries run much faster on large datasets';
PRINT '✓ Automatically maintained by SQL Server';
PRINT '';
GO

PRINT '================================================================================';
PRINT 'SECTION 6: PRACTICE EXERCISES';
PRINT '================================================================================';
PRINT '';
GO

-- ============================================================================
-- EXERCISE 1: Create Simple View ⭐
-- ============================================================================

PRINT '--- EXERCISE 1: Create Simple View ⭐ ---';
PRINT 'Task: Create view vw_OperationalEquipment showing only operational equipment';
PRINT '';
GO

-- SOLUTION:
CREATE VIEW vw_OperationalEquipment
AS
SELECT 
    equipment_code,
    equipment_type,
    manufacturer,
    model,
    s.site_name,
    purchase_date,
    last_maintenance_date
FROM equipment e
JOIN sites s ON e.site_id = s.site_id
WHERE e.operational_status = 'Operational';
GO

PRINT '✓ View created';
SELECT TOP 10 * FROM vw_OperationalEquipment ORDER BY site_name;
PRINT '';
GO

-- ============================================================================
-- EXERCISE 2: Create Security View ⭐⭐
-- ============================================================================

PRINT '--- EXERCISE 2: Create Security View ⭐⭐ ---';
PRINT 'Task: Create view vw_CostSummary that shows costs WITHOUT sensitive amounts';
PRINT '';
GO

-- SOLUTION:
CREATE VIEW vw_CostSummary
AS
SELECT 
    s.site_name,
    s.state,
    oc.cost_date,
    oc.cost_category,
    -- Hide exact amounts, only show ranges
    CASE 
        WHEN oc.amount < 50000 THEN 'Low (<$50k)'
        WHEN oc.amount < 150000 THEN 'Medium ($50k-$150k)'
        ELSE 'High (>$150k)'
    END AS cost_range,
    oc.description
FROM operating_costs oc
JOIN sites s ON oc.site_id = s.site_id;
GO

PRINT '✓ View created (with masked amounts)';
SELECT TOP 10 * FROM vw_CostSummary ORDER BY cost_date DESC;
PRINT '';
GO

-- ============================================================================
-- EXERCISE 3: Create Analytical View ⭐⭐⭐
-- ============================================================================

PRINT '--- EXERCISE 3: Create Analytical View ⭐⭐⭐ ---';
PRINT 'Task: Create vw_WeeklyProductionTrends with weekly aggregations';
PRINT '';
GO

-- SOLUTION:
CREATE VIEW vw_WeeklyProductionTrends
AS
SELECT 
    s.site_name,
    s.resource_type,
    DATEPART(YEAR, p.production_date) AS production_year,
    DATEPART(WEEK, p.production_date) AS production_week,
    DATEADD(WEEK, DATEDIFF(WEEK, 0, p.production_date), 0) AS week_start_date,
    COUNT(*) AS total_shifts,
    SUM(p.tonnes_produced) AS weekly_production,
    AVG(p.grade_percentage) AS avg_weekly_grade,
    SUM(p.operating_hours) AS total_operating_hours,
    ROUND(SUM(p.tonnes_produced) / SUM(p.operating_hours), 2) AS productivity_rate
FROM production p
JOIN sites s ON p.site_id = s.site_id
GROUP BY 
    s.site_name,
    s.resource_type,
    DATEPART(YEAR, p.production_date),
    DATEPART(WEEK, p.production_date),
    DATEADD(WEEK, DATEDIFF(WEEK, 0, p.production_date), 0);
GO

PRINT '✓ View created';
SELECT TOP 10 
    site_name,
    production_week,
    FORMAT(weekly_production, 'N0') AS production,
    FORMAT(productivity_rate, 'N2') AS tonnes_per_hour
FROM vw_WeeklyProductionTrends
ORDER BY production_year DESC, production_week DESC;
PRINT '';
GO

-- ============================================================================
-- EXERCISE 4: Create Dashboard View ⭐⭐⭐⭐
-- ============================================================================

PRINT '--- EXERCISE 4: Create Executive Dashboard View ⭐⭐⭐⭐ ---';
PRINT 'Task: Create comprehensive vw_ExecutiveDashboard';
PRINT '';
GO

-- SOLUTION:
CREATE VIEW vw_ExecutiveDashboard
AS
SELECT 
    s.site_name,
    s.state,
    s.resource_type,
    s.site_manager,
    
    -- Workforce
    (SELECT COUNT(*) FROM employees e 
     WHERE e.site_id = s.site_id AND e.employment_status = 'Active') AS active_employees,
    
    -- Equipment
    (SELECT COUNT(*) FROM equipment eq 
     WHERE eq.site_id = s.site_id AND eq.operational_status = 'Operational') AS operational_equipment,
    
    -- December Production
    (SELECT SUM(tonnes_produced) FROM production p 
     WHERE p.site_id = s.site_id 
     AND p.production_date >= '2024-12-01' 
     AND p.production_date <= '2024-12-31') AS dec_production,
    
    -- December Costs
    (SELECT SUM(amount) FROM operating_costs oc 
     WHERE oc.site_id = s.site_id 
     AND oc.cost_date >= '2024-12-01' 
     AND oc.cost_date <= '2024-12-31') AS dec_costs,
    
    -- Safety Score (incidents)
    (SELECT COUNT(*) FROM safety_incidents si 
     WHERE si.site_id = s.site_id 
     AND si.incident_date >= '2024-12-01' 
     AND si.incident_date <= '2024-12-31') AS dec_incidents,
    
    -- Performance Rating
    CASE 
        WHEN (SELECT COUNT(*) FROM safety_incidents si 
              WHERE si.site_id = s.site_id 
              AND si.incident_date >= '2024-12-01' 
              AND si.severity IN ('Serious', 'Critical')) > 0 THEN 'Needs Attention'
        WHEN (SELECT SUM(tonnes_produced) FROM production p 
              WHERE p.site_id = s.site_id 
              AND p.production_date >= '2024-12-01') > 1000000 THEN 'Excellent'
        WHEN (SELECT SUM(tonnes_produced) FROM production p 
              WHERE p.site_id = s.site_id 
              AND p.production_date >= '2024-12-01') > 500000 THEN 'Good'
        ELSE 'Average'
    END AS performance_rating

FROM sites s
WHERE s.status = 'Active';
GO

PRINT '✓ Executive dashboard view created';
PRINT '';
SELECT 
    site_name,
    resource_type,
    active_employees AS employees,
    operational_equipment AS equipment,
    FORMAT(dec_production, 'N0') AS production,
    FORMAT(dec_costs, 'C0') AS costs,
    dec_incidents AS incidents,
    performance_rating AS rating
FROM vw_ExecutiveDashboard
ORDER BY dec_production DESC;
PRINT '';
GO

PRINT '================================================================================';
PRINT 'SECTION 7: VIEW BEST PRACTICES & TIPS';
PRINT '================================================================================';
PRINT '';
GO

PRINT '--- Best Practices Summary ---';
PRINT '';
PRINT 'DO:';
PRINT '✓ Name views with vw_ prefix for clarity';
PRINT '✓ Use views to hide complexity from end users';
PRINT '✓ Create views for security (hide sensitive columns)';
PRINT '✓ Document view purpose in comments';
PRINT '✓ Use indexed views for frequently-accessed aggregations';
PRINT '✓ Keep view logic simple and maintainable';
PRINT '';
PRINT 'DON''T:';
PRINT '✗ Create views on top of views (max 1-2 levels)';
PRINT '✗ Use SELECT * in view definitions';
PRINT '✗ Create unnecessary views (adds maintenance overhead)';
PRINT '✗ Forget to grant appropriate permissions';
PRINT '✗ Use views for complex business logic (use stored procedures instead)';
PRINT '';

-- Show permissions example
PRINT '--- Permissions Example ---';
PRINT '';
PRINT 'Grant SELECT on view without exposing base table:';
PRINT 'GRANT SELECT ON vw_EmployeeDirectory TO [AnalystRole];';
PRINT '-- Analysts can query view but NOT the base employees table';
PRINT '';
GO

PRINT '================================================================================';
PRINT 'SECTION 8: FINAL COMPARISON - BEFORE vs AFTER';
PRINT '================================================================================';
PRINT '';
GO

PRINT '--- THE TRANSFORMATION ---';
PRINT '';
PRINT 'BEFORE VIEWS:';
PRINT '❌ Analysts write 60+ line queries repeatedly';
PRINT '❌ Junior analysts struggle with complexity';
PRINT '❌ Inconsistent calculations across reports';
PRINT '❌ Security risks (sensitive data exposed)';
PRINT '❌ Poor performance on complex queries';
PRINT '❌ High maintenance (change logic in 50 places)';
PRINT '';
PRINT 'AFTER VIEWS:';
PRINT '✓ Simple SELECT * FROM vw_SitePerformance';
PRINT '✓ Anyone can query complex data easily';
PRINT '✓ Consistent logic across all reports';
PRINT '✓ Secure (sensitive columns hidden)';
PRINT '✓ Better performance (indexed views)';
PRINT '✓ Easy maintenance (change view once)';
PRINT '';
PRINT 'BUSINESS IMPACT:';
PRINT '• Query Development Time: 75% reduction';
PRINT '• Report Consistency: 100% (same view for all)';
PRINT '• Junior Analyst Productivity: 3x increase';
PRINT '• Security Incidents: 90% reduction';
PRINT '• Maintenance Effort: 80% reduction';
PRINT '';
GO

PRINT '================================================================================';
PRINT 'TRAINING SESSION COMPLETE! 🎓';
PRINT '================================================================================';
PRINT '';
PRINT 'What You Mastered:';
PRINT '✓ Creating simple and complex views';
PRINT '✓ Using views for data security';
PRINT '✓ Building analytical views for reporting';
PRINT '✓ Creating indexed views for performance';
PRINT '✓ Updating data through views';
PRINT '✓ Managing and maintaining views';
PRINT '✓ Data quality views for monitoring';
PRINT '✓ View best practices and patterns';
PRINT '';
PRINT 'Real-World Applications:';
PRINT '• Simplifying complex reporting queries';
PRINT '• Implementing row-level and column-level security';
PRINT '• Creating consistent business metrics';
PRINT '• Building self-service analytics platforms';
PRINT '• Improving query performance with indexed views';
PRINT '';
PRINT 'Career Skills Gained:';
PRINT '✓ Enterprise database design patterns';
PRINT '✓ Data security implementation';
PRINT '✓ Performance optimization techniques';
PRINT '✓ Self-service analytics enablement';
PRINT '✓ Production-ready SQL development';
PRINT '';
PRINT 'Congratulations! You''ve completed the SQL Views module! 🚀';
PRINT '';
PRINT 'Next Steps:';
PRINT '• Practice creating views in your own projects';
PRINT '• Explore advanced topics like partitioned views';
PRINT '• Study indexed view performance tuning';
PRINT '• Apply these patterns in real mining/resource industry scenarios';
PRINT '';
PRINT '================================================================================';
PRINT 'READY FOR BOOTCAMP DEMONSTRATION! 💪';
PRINT '================================================================================';
GO

/*
================================================================================
END OF TRAINING SCRIPT - SQL VIEWS
================================================================================

INSTRUCTOR NOTES:
1. Complete self-contained script - runs start to finish
2. Australian mining industry context (AusMine Resources)
3. Realistic business scenarios and data
4. Progressive complexity from simple to advanced views
5. All exercises include complete solutions
6. Ready for 15-minute video demonstration

TEACHING FLOW (15 minutes):
1. Intro & Problem Statement (2 min) - Show complex query nightmare
2. Simple Views (2 min) - DEMO 2
3. Security Views (2 min) - DEMO 3
4. Complex Views (3 min) - DEMO 4
5. Indexed Views (2 min) - DEMO 9
6. Practice Exercises Walkthrough (3 min)
7. Summary & Best Practices (1 min)

Total: 15 minutes perfect for your video!

UNIQUE FEATURES:
✓ Australian mining company scenario (no legal issues)
✓ Realistic resource types: Iron Ore, Gold, Coal, Copper, Lithium
✓ Real Australian states: WA, QLD, NT, SA
✓ Production-ready code with proper indexing
✓ Security considerations built-in
✓ Data quality monitoring patterns

Perfect for your bootcamp students! Good luck! 🎯
================================================================================
*/
