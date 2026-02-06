/*********************************************************************************
VIDEO 9: STORED PROCEDURES & FUNCTIONS - AUTOMATION & REUSABILITY
BHD Mining Operations - Daily Production Report Automation
Enterprise SQL for Australian Data Analysts
Duration: 19 minutes | Level: Advanced

⚠️ DISCLAIMER: FICTITIOUS ORGANIZATION
BHD Mining Operations is a FICTITIOUS company created for educational purposes only.
This scenario is inspired by real-world Australian mining operations but does not
represent any actual organization. All data, procedures, and business scenarios
are simulated for training purposes.

BUSINESS SCENARIO:
You're a data analyst at BHD Mining Operations (a fictitious Australian mining company).
Monday morning 8 AM. The Operations Manager walks in frustrated:
"Every day I spend 2 HOURS manually running the same queries for our daily production 
report. I need: safety incidents, equipment downtime, ore production by site, and 
shift performance. Can you automate this?"

THE CURRENT PROBLEM:
Operations team runs 15+ queries EVERY DAY manually:
1. Copy query from Word document
2. Paste into SSMS
3. Change date parameters manually ('2024-12-01' → '2024-12-02')
4. Export to Excel
5. Format results
6. Email to stakeholders

Time wasted: 2 hours/day = 10 hours/week = 520 hours/year = 13 WEEKS!
Cost: $80K/year in analyst time doing repetitive work

THE SOLUTION: STORED PROCEDURES
Package the entire workflow into ONE reusable procedure
Run with: EXEC DailyOperationsReport @ReportDate = '2024-12-01'
Time: 2 hours → 30 seconds (96% time savings!)
Annual savings: $75,000+

WHAT YOU'LL MASTER:
✓ Creating stored procedures with parameters
✓ Default parameters and NULL handling
✓ OUTPUT parameters (return multiple values)
✓ TRY...CATCH error handling
✓ Scalar functions (return single value)
✓ Table-valued functions (return tables)
✓ When to use procedures vs functions
✓ 5 practice exercises with solutions

PRODUCTION SKILLS:
🚀 Automating repetitive workflows
🔧 Building reusable code libraries
🎯 Parameter-driven reporting
💪 Enterprise-grade error handling
*********************************************************************************/

-- ============================================================================
-- STEP 1: CREATE DATABASE AND TABLES
-- ============================================================================

PRINT '';
PRINT '=============================================================';
PRINT 'VIDEO 9: STORED PROCEDURES & FUNCTIONS';
PRINT 'BHD Mining Operations - Report Automation';
PRINT '⚠️  FICTITIOUS COMPANY - Educational Purposes Only';
PRINT '=============================================================';
PRINT '';

-- Drop database if exists (fresh start)
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'BHD_Mining_Operations')
BEGIN
    PRINT '⚠️  Dropping existing database...';
    ALTER DATABASE BHD_Mining_Operations SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE BHD_Mining_Operations;
END
GO

CREATE DATABASE BHD_Mining_Operations;
GO

USE BHD_Mining_Operations;
GO

PRINT '✅ Database Created: BHD_Mining_Operations';
PRINT '';
GO

-- ============================================================================
-- STEP 2: CREATE TABLES (ENHANCED WITH PLAYBOOK FIELDS)
-- ============================================================================

PRINT '=== Creating Tables ===';
PRINT '';

-- Mining Sites Table
CREATE TABLE mining_sites (
    site_id INT PRIMARY KEY,
    site_name NVARCHAR(100) NOT NULL,
    site_location NVARCHAR(100) NOT NULL,
    state NVARCHAR(10) NOT NULL,
    commodity NVARCHAR(100) NOT NULL,
    operational BIT DEFAULT 1, -- Added from playbook
    capacity_tonnes_per_day DECIMAL(12,2) NULL -- Added for context
);

-- Daily Production Table
CREATE TABLE daily_production (
    production_id INT PRIMARY KEY IDENTITY(1,1),
    production_date DATE NOT NULL,
    site_id INT NOT NULL,
    shift NVARCHAR(20) NOT NULL CHECK (shift IN ('Day', 'Night')),
    ore_tonnes DECIMAL(12,2) NOT NULL CHECK (ore_tonnes >= 0),
    waste_tonnes DECIMAL(12,2) NOT NULL CHECK (waste_tonnes >= 0),
    equipment_hours DECIMAL(8,2) NOT NULL CHECK (equipment_hours >= 0),
    downtime_hours DECIMAL(6,2) NOT NULL CHECK (downtime_hours >= 0),
    efficiency_percent AS (CASE 
        WHEN equipment_hours > 0 
        THEN ROUND(((equipment_hours - downtime_hours) / equipment_hours) * 100, 2)
        ELSE 0 
    END) PERSISTED, -- Calculated column from playbook
    CONSTRAINT FK_Production_Site FOREIGN KEY (site_id) REFERENCES mining_sites(site_id)
);

-- Safety Incidents Table
CREATE TABLE safety_incidents (
    incident_id INT PRIMARY KEY IDENTITY(1,1),
    incident_date DATE NOT NULL,
    site_id INT NOT NULL,
    severity NVARCHAR(20) NOT NULL CHECK (severity IN ('Minor', 'Moderate', 'Severe')),
    incident_type NVARCHAR(100) NOT NULL,
    description NVARCHAR(500) NULL, -- Added for detail
    resolved BIT DEFAULT 0,
    resolved_date DATE NULL,
    CONSTRAINT FK_Incidents_Site FOREIGN KEY (site_id) REFERENCES mining_sites(site_id)
);

-- Error Log Table (Production Best Practice from playbook)
CREATE TABLE error_log (
    error_id INT PRIMARY KEY IDENTITY(1,1),
    error_message NVARCHAR(4000),
    error_procedure NVARCHAR(128),
    error_line INT,
    error_severity INT,
    error_state INT,
    logged_date DATETIME DEFAULT GETDATE(),
    logged_by NVARCHAR(128) DEFAULT SYSTEM_USER
);

PRINT '✅ Tables Created:';
PRINT '   • mining_sites (with operational flag)';
PRINT '   • daily_production (with efficiency calc)';
PRINT '   • safety_incidents (with resolution tracking)';
PRINT '   • error_log (production error tracking)';
PRINT '';
GO

-- ============================================================================
-- STEP 3: INSERT SAMPLE DATA (REALISTIC BHP OPERATIONS)
-- ============================================================================

PRINT '=== Inserting BHD Mining Operations Data ===';
PRINT '⚠️  Note: BHD is a fictitious organization created for training';
PRINT '';

-- BHD's fictitious Australian mining sites (inspired by real locations)
INSERT INTO mining_sites (site_id, site_name, site_location, state, commodity, operational, capacity_tonnes_per_day) VALUES
(1, 'Red Rock Mine', 'Roxby Downs, SA', 'SA', 'Copper, Uranium, Gold, Silver', 1, 250000),
(2, 'Mt Pioneer Coal', 'Muswellbrook, NSW', 'NSW', 'Thermal Coal', 1, 180000),
(3, 'Goldfields Operations', 'Kalgoorlie, WA', 'WA', 'Nickel', 1, 150000),
(4, 'Northern Iron', 'Pilbara, WA', 'WA', 'Iron Ore', 1, 300000),
(5, 'Western Ridge', 'Pilbara, WA', 'WA', 'Iron Ore', 1, 280000);

PRINT '✅ 5 BHD fictitious mining sites inserted';

-- Daily production (last 14 days for each site × 2 shifts)
DECLARE @StartDate DATE = DATEADD(DAY, -14, CAST(GETDATE() AS DATE));
DECLARE @CurrentDate DATE = @StartDate;
DECLARE @SiteID INT;
DECLARE @ProductionCount INT = 0;

WHILE @CurrentDate <= CAST(GETDATE() AS DATE)
BEGIN
    SET @SiteID = 1;
    WHILE @SiteID <= 5
    BEGIN
        -- Day shift (higher production)
        INSERT INTO daily_production (production_date, site_id, shift, ore_tonnes, waste_tonnes, equipment_hours, downtime_hours)
        VALUES (
            @CurrentDate,
            @SiteID,
            'Day',
            ROUND(8000 + (RAND() * 2000), 2),
            ROUND(12000 + (RAND() * 3000), 2),
            ROUND(20 + (RAND() * 4), 2),
            ROUND(RAND() * 2, 2)
        );
        
        -- Night shift (slightly lower production)
        INSERT INTO daily_production (production_date, site_id, shift, ore_tonnes, waste_tonnes, equipment_hours, downtime_hours)
        VALUES (
            @CurrentDate,
            @SiteID,
            'Night',
            ROUND(7500 + (RAND() * 2000), 2),
            ROUND(11000 + (RAND() * 3000), 2),
            ROUND(20 + (RAND() * 4), 2),
            ROUND(RAND() * 2, 2)
        );
        
        SET @SiteID = @SiteID + 1;
        SET @ProductionCount = @ProductionCount + 2;
    END
    
    SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
END

PRINT '✅ ' + CAST(@ProductionCount AS NVARCHAR(10)) + ' production records inserted (15 days × 5 sites × 2 shifts)';

-- Safety incidents (realistic incidents over last 14 days)
INSERT INTO safety_incidents (incident_date, site_id, severity, incident_type, description, resolved, resolved_date) VALUES
(DATEADD(DAY, -13, GETDATE()), 1, 'Minor', 'Slip and fall', 'Employee slipped on wet floor near processing area', 1, DATEADD(DAY, -12, GETDATE())),
(DATEADD(DAY, -12, GETDATE()), 2, 'Minor', 'Equipment malfunction', 'Conveyor belt stopped unexpectedly', 1, DATEADD(DAY, -11, GETDATE())),
(DATEADD(DAY, -10, GETDATE()), 3, 'Moderate', 'Near miss - vehicle collision', 'Haul truck nearly collided with light vehicle', 1, DATEADD(DAY, -8, GETDATE())),
(DATEADD(DAY, -9, GETDATE()), 4, 'Minor', 'First aid required', 'Minor cut requiring first aid', 1, DATEADD(DAY, -9, GETDATE())),
(DATEADD(DAY, -7, GETDATE()), 2, 'Moderate', 'Equipment damage', 'Excavator hydraulic line rupture', 0, NULL),
(DATEADD(DAY, -5, GETDATE()), 5, 'Minor', 'PPE violation', 'Worker not wearing hard hat in designated area', 1, DATEADD(DAY, -4, GETDATE())),
(DATEADD(DAY, -3, GETDATE()), 1, 'Severe', 'Medical treatment injury', 'Operator injured, medical treatment required', 0, NULL),
(DATEADD(DAY, -2, GETDATE()), 3, 'Minor', 'Spill incident', 'Small hydraulic oil spill, contained immediately', 1, DATEADD(DAY, -1, GETDATE())),
(DATEADD(DAY, -1, GETDATE()), 4, 'Moderate', 'Fire alarm activation', 'False alarm from dust accumulation', 1, DATEADD(DAY, -1, GETDATE())),
(GETDATE(), 2, 'Severe', 'Equipment rollover', 'Light vehicle rollover, driver injured', 0, NULL);

PRINT '✅ 10 safety incidents inserted (with realistic details)';
PRINT '';
GO

-- ============================================================================
-- VALIDATION QUERIES
-- ============================================================================

PRINT '=== Data Validation ===';
PRINT '';

SELECT 
    'mining_sites' AS TableName, 
    COUNT(*) AS Row_Count, --RowCount is a keyword, use Row_Count
    'Operational sites' AS Description
FROM mining_sites
UNION ALL
SELECT 
    'daily_production', 
    COUNT(*),
    CAST(COUNT(DISTINCT production_date) AS NVARCHAR(10)) + ' days of data'
FROM daily_production
UNION ALL
SELECT 
    'safety_incidents', 
    COUNT(*),
    CAST(SUM(CASE WHEN resolved = 0 THEN 1 ELSE 0 END) AS NVARCHAR(10)) + ' unresolved'
FROM safety_incidents;

PRINT '';
GO

-- ============================================================================
-- BUSINESS PROBLEM EXPLANATION
-- ============================================================================

PRINT '';
PRINT '=============================================================';
PRINT 'BUSINESS PROBLEM: THE MONDAY MORNING FRUSTRATION';
PRINT '=============================================================';
PRINT '';
PRINT '8:00 AM Monday - Operations Manager Walks In:';
PRINT '"I''m FRUSTRATED! Every single day I waste 2 HOURS running';
PRINT 'the same queries for our daily production report!"';
PRINT '';
PRINT 'The Daily Manual Nightmare:';
PRINT '  Step 1-3:  Open Word document with 15+ saved queries';
PRINT '             Copy first query → Paste into SSMS';
PRINT '  Step 4-5:  Manually change date: ''2024-12-01'' → ''2024-12-02''';
PRINT '             Run query';
PRINT '  Step 6-7:  Copy results to Excel → Format cells';
PRINT '  Step 8-10: Repeat for NEXT query (14 more times!)';
PRINT '             Compile all → Email to stakeholders';
PRINT '';
PRINT 'Time Wasted: 2 hours EVERY DAY';
PRINT '  • Weekly:  10 hours';
PRINT '  • Annual:  520 hours = 13 WEEKS of work!';
PRINT '  • Cost:    $80,000 in analyst time';
PRINT '';
PRINT 'Reports Needed Daily:';
PRINT '  1. Production Summary (ore tonnes by site and shift)';
PRINT '  2. Equipment Downtime Analysis';
PRINT '  3. Safety Incidents (by severity and status)';
PRINT '  4. Efficiency Metrics (equipment utilisation %)';
PRINT '  5. Site Comparisons (yesterday vs last week)';
PRINT '  6. Shift Performance Rankings';
PRINT '  ... 10 more reports!';
PRINT '';
PRINT 'The "Copy-Paste-Change-Date" Hell:';
PRINT '  ✗ Manual date changes → Human errors';
PRINT '  ✗ Copy-paste mistakes → Wrong data in reports';
PRINT '  ✗ Inconsistent calculations → Different analysts calculate differently';
PRINT '  ✗ No version control → "Which query is the latest?"';
PRINT '  ✗ Time-consuming → 2 hours EVERY day';
PRINT '';
PRINT 'THE SOLUTION: AUTOMATION WITH STORED PROCEDURES';
PRINT '';
PRINT '  Before (Manual):';
PRINT '    Open Word → Copy Query 1 → Paste → Change date → Run → Export';
PRINT '    Repeat 15 times → 2 hours';
PRINT '';
PRINT '  After (Automated):';
PRINT '    EXEC DailyOperationsReport @ReportDate = ''2024-12-01''';
PRINT '    → 30 seconds → Done!';
PRINT '';
PRINT 'Benefits:';
PRINT '  ✓ ONE stored procedure replaces 15 queries';
PRINT '  ✓ Date passed as PARAMETER (no manual changes)';
PRINT '  ✓ 30 seconds execution time (vs 2 hours)';
PRINT '  ✓ $75K+ annual SAVINGS';
PRINT '  ✓ Consistent logic, zero errors';
PRINT '';
PRINT '=============================================================';
PRINT '';
GO

-- ============================================================================
-- CONCEPT 1: BASIC STORED PROCEDURE
-- ============================================================================

PRINT '';
PRINT '=============================================================';
PRINT 'CONCEPT 1: CREATING A BASIC STORED PROCEDURE';
PRINT '=============================================================';
PRINT '';
PRINT 'What Is a Stored Procedure?';
PRINT '  • Pre-compiled SQL code STORED in the database';
PRINT '  • Like creating a custom "program" that runs on demand';
PRINT '  • Accept inputs (parameters), perform logic, return results';
PRINT '';
PRINT 'Think of it as:';
PRINT '  Regular query = Recipe written on paper (write every time)';
PRINT '  Stored procedure = Recipe saved in cookbook (reuse anytime)';
PRINT '';
PRINT 'Benefits:';
PRINT '  ✓ Reusability - Write once, use everywhere';
PRINT '  ✓ Performance - Pre-compiled, optimised execution';
PRINT '  ✓ Security - Grant EXECUTE permission, hide table access';
PRINT '  ✓ Maintainability - Change in one place, affects all uses';
PRINT '  ✓ Consistency - Same logic, same results every time';
PRINT '';
GO

-- Drop if exists
IF OBJECT_ID('GetSiteProduction', 'P') IS NOT NULL
    DROP PROCEDURE GetSiteProduction;
GO

PRINT 'Creating Procedure: GetSiteProduction';
PRINT '';
GO

CREATE PROCEDURE GetSiteProduction
    @SiteID INT
AS
BEGIN
    /*
    Purpose: Get all production data for a specific mining site
    Parameters: @SiteID (1=Red Rock Mine, 2=Mt Pioneer, etc.)
    Returns: Production records with site details
    Example: EXEC GetSiteProduction @SiteID = 1;
    */
    
    SELECT 
        ms.site_name,
        ms.site_location,
        ms.state,
        dp.production_date,
        dp.shift,
        dp.ore_tonnes,
        dp.waste_tonnes,
        dp.equipment_hours,
        dp.downtime_hours,
        dp.efficiency_percent
    FROM daily_production dp
    JOIN mining_sites ms ON dp.site_id = ms.site_id
    WHERE dp.site_id = @SiteID
    ORDER BY dp.production_date DESC, dp.shift;
END
GO

PRINT '✅ Procedure created: GetSiteProduction';
PRINT '';
PRINT 'Testing the procedure...';
PRINT '';
PRINT '--- Test 1: Red Rock Mine (Site 1) ---';
EXEC GetSiteProduction @SiteID = 1;

PRINT '';
PRINT '--- Test 2: Northern Iron (Site 4) ---';
EXEC GetSiteProduction @SiteID = 4;

PRINT '';
PRINT 'KEY CONCEPT:';
PRINT '  Same procedure, different parameter → Different results!';
PRINT '  EXEC GetSiteProduction @SiteID = 1; → Red Rock Mine data';
PRINT '  EXEC GetSiteProduction @SiteID = 4; → Northern Iron data';
PRINT '';
GO

-- ============================================================================
-- CONCEPT 2: MULTIPLE PARAMETERS
-- ============================================================================

PRINT '';
PRINT '=============================================================';
PRINT 'CONCEPT 2: PROCEDURES WITH MULTIPLE PARAMETERS';
PRINT '=============================================================';
PRINT '';

IF OBJECT_ID('GetProductionByDateRange', 'P') IS NOT NULL
    DROP PROCEDURE GetProductionByDateRange;
GO

CREATE PROCEDURE GetProductionByDateRange
    @StartDate DATE,
    @EndDate DATE,
    @SiteID INT
AS
BEGIN
    /*
    Purpose: Get production data for a date range and specific site
    Parameters: 
        @StartDate - Beginning of date range
        @EndDate - End of date range  
        @SiteID - Which mining site
    Returns: Filtered production records
    Example: EXEC GetProductionByDateRange 
               @StartDate = '2024-12-01', 
               @EndDate = '2024-12-07', 
               @SiteID = 1;
    */
    
    SELECT 
        ms.site_name,
        dp.production_date,
        dp.shift,
        dp.ore_tonnes,
        dp.waste_tonnes,
        dp.downtime_hours,
        dp.efficiency_percent
    FROM daily_production dp
    JOIN mining_sites ms ON dp.site_id = ms.site_id
    WHERE dp.production_date BETWEEN @StartDate AND @EndDate
      AND dp.site_id = @SiteID
    ORDER BY dp.production_date, dp.shift;
END
GO

PRINT '✅ Procedure created: GetProductionByDateRange';
PRINT '';
PRINT 'Testing with 3 parameters...';
PRINT '';

DECLARE @TestStart DATE = DATEADD(DAY, -7, GETDATE());
DECLARE @TestEnd DATE = GETDATE();

PRINT '--- Last 7 days for Red Rock Mine ---';
EXEC GetProductionByDateRange 
    @StartDate = @TestStart,
    @EndDate = @TestEnd,
    @SiteID = 1;

PRINT '';
GO

-- ============================================================================
-- CONCEPT 3: DEFAULT PARAMETERS (FROM PLAYBOOK)
-- ============================================================================

PRINT '';
PRINT '=============================================================';
PRINT 'CONCEPT 3: DEFAULT PARAMETERS - MAKING PARAMETERS OPTIONAL';
PRINT '=============================================================';
PRINT '';
PRINT 'Problem: What if user doesn''t provide a parameter?';
PRINT '         Force them to type every parameter every time? Annoying!';
PRINT '';
PRINT 'Solution: DEFAULT VALUES';
PRINT '';

IF OBJECT_ID('GetProductionFlexible', 'P') IS NOT NULL
    DROP PROCEDURE GetProductionFlexible;
GO

CREATE PROCEDURE GetProductionFlexible
    @StartDate DATE = NULL,          -- Default to NULL
    @EndDate DATE = NULL,            -- Optional
    @SiteID INT = NULL               -- Optional
AS
BEGIN
    /*
    Purpose: Flexible production query with optional filters
    Parameters: All optional - defaults to last 7 days, all sites
    
    Call Options:
      EXEC GetProductionFlexible;  -- Last 7 days, all sites
      EXEC GetProductionFlexible @SiteID = 1;  -- Last 7 days, Red Rock Mine only
      EXEC GetProductionFlexible @StartDate = '2024-12-01', @EndDate = '2024-12-07';
    */
    
    -- Set defaults if not provided
    IF @StartDate IS NULL SET @StartDate = DATEADD(DAY, -7, GETDATE());
    IF @EndDate IS NULL SET @EndDate = CAST(GETDATE() AS DATE);
    
    SELECT 
        ms.site_name,
        dp.production_date,
        dp.shift,
        SUM(dp.ore_tonnes) AS total_ore,
        SUM(dp.waste_tonnes) AS total_waste,
        AVG(dp.efficiency_percent) AS avg_efficiency
    FROM daily_production dp
    JOIN mining_sites ms ON dp.site_id = ms.site_id
    WHERE dp.production_date BETWEEN @StartDate AND @EndDate
      AND (@SiteID IS NULL OR dp.site_id = @SiteID)  -- Optional filter pattern!
    GROUP BY ms.site_name, dp.production_date, dp.shift
    ORDER BY ms.site_name, dp.production_date, dp.shift;
END
GO

PRINT '✅ Procedure created: GetProductionFlexible';
PRINT '';
PRINT 'KEY PATTERN: (@SiteID IS NULL OR site_id = @SiteID)';
PRINT '  • If @SiteID IS NULL → Condition TRUE for all rows (no filter)';
PRINT '  • If @SiteID = 1 → Only rows where site_id = 1';
PRINT '  • This is a STANDARD pattern for optional filters!';
PRINT '';
PRINT 'Testing different call variations...';
PRINT '';

PRINT '--- Call 1: No parameters (uses defaults: last 7 days, all sites) ---';
EXEC GetProductionFlexible;

PRINT '';
PRINT '--- Call 2: Filter by site only ---';
EXEC GetProductionFlexible @SiteID = 1;

PRINT '';
PRINT '--- Call 3: Custom date range, all sites ---';
DECLARE @StartDate datetime = DATEADD(DAY, -3, GETDATE());
DECLARE @EndDate   datetime = GETDATE();

EXEC GetProductionFlexible 
    @StartDate = @StartDate,
    @EndDate = @EndDate;
--@StartDate = (SELECT DATEADD(DAY, -3, GETDATE())),
--@EndDate = (SELECT GETDATE());

PRINT '';
GO

-- ============================================================================
-- CONCEPT 4: OUTPUT PARAMETERS (FROM PLAYBOOK)
-- ============================================================================

PRINT '';
PRINT '=============================================================';
PRINT 'CONCEPT 4: OUTPUT PARAMETERS - RETURNING CALCULATED VALUES';
PRINT '=============================================================';
PRINT '';
PRINT 'Problem: Procedure runs calculations. How to GET those values';
PRINT '         back to the caller?';
PRINT '';
PRINT 'Solution: OUTPUT PARAMETERS';
PRINT '';

IF OBJECT_ID('GetSiteSummary', 'P') IS NOT NULL
    DROP PROCEDURE GetSiteSummary;
GO

CREATE PROCEDURE GetSiteSummary
    @SiteID INT,
    @TotalOre DECIMAL(12,2) OUTPUT,           -- OUTPUT parameter
    @TotalIncidents INT OUTPUT,                -- OUTPUT parameter
    @DowntimePercent DECIMAL(5,2) OUTPUT       -- OUTPUT parameter
AS
BEGIN
    /*
    Purpose: Calculate summary metrics for a site
    Parameters: 
        @SiteID - Input
        @TotalOre - OUTPUT (returns total ore produced)
        @TotalIncidents - OUTPUT (returns unresolved incident count)
        @DowntimePercent - OUTPUT (returns downtime percentage)
        
    Example:
        DECLARE @Ore DECIMAL(12,2), @Incidents INT, @Downtime DECIMAL(5,2);
        EXEC GetSiteSummary @SiteID = 1, 
             @TotalOre = @Ore OUTPUT,
             @TotalIncidents = @Incidents OUTPUT,
             @DowntimePercent = @Downtime OUTPUT;
        PRINT 'Total Ore: ' + CAST(@Ore AS NVARCHAR(20));
    */
    
    -- Calculate total ore
    SELECT @TotalOre = SUM(ore_tonnes)
    FROM daily_production
    WHERE site_id = @SiteID;
    
    -- Count unresolved incidents
    SELECT @TotalIncidents = COUNT(*)
    FROM safety_incidents
    WHERE site_id = @SiteID AND resolved = 0;
    
    -- Calculate downtime percentage
    SELECT @DowntimePercent = 
        ROUND((SUM(downtime_hours) / NULLIF(SUM(equipment_hours), 0)) * 100, 2)
    FROM daily_production
    WHERE site_id = @SiteID;
END
GO

PRINT '✅ Procedure created: GetSiteSummary';
PRINT '';
PRINT 'Testing OUTPUT parameters...';
PRINT '';

-- Declare variables to receive OUTPUT values
DECLARE @Ore DECIMAL(12,2);
DECLARE @Incidents INT;
DECLARE @Downtime DECIMAL(5,2);

-- Call procedure with OUTPUT keyword
EXEC GetSiteSummary 
    @SiteID = 1,
    @TotalOre = @Ore OUTPUT,
    @TotalIncidents = @Incidents OUTPUT,
    @DowntimePercent = @Downtime OUTPUT;

-- Use the returned values
PRINT '--- Red Rock Mine Summary ---';
PRINT 'Total Ore: ' + CAST(@Ore AS NVARCHAR(20)) + ' tonnes';
PRINT 'Unresolved Incidents: ' + CAST(@Incidents AS NVARCHAR(10));
PRINT 'Downtime: ' + CAST(@Downtime AS NVARCHAR(10)) + '%';
PRINT '';

PRINT 'KEY CONCEPT:';
PRINT '  OUTPUT parameters return MULTIPLE calculated values';
PRINT '  • Must declare variables to receive values';
PRINT '  • Must use OUTPUT keyword when calling';
PRINT '  • Values available after procedure executes';
PRINT '';
GO

-- ============================================================================
-- CONCEPT 5: ERROR HANDLING WITH TRY...CATCH (FROM PLAYBOOK)
-- ============================================================================

PRINT '';
PRINT '=============================================================';
PRINT 'CONCEPT 5: ERROR HANDLING - PRODUCTION-READY CODE';
PRINT '=============================================================';
PRINT '';
PRINT 'Why Error Handling Matters:';
PRINT '  Production scenario: User runs procedure with SiteID = 999';
PRINT '  • Without error handling → Query returns no rows, user confused';
PRINT '  • With error handling → "Error: Site ID 999 not found" (clear!)';
PRINT '';
PRINT 'Consequences of no error handling:';
PRINT '  ✗ Silent failures (no data returned, user doesn''t know why)';
PRINT '  ✗ Cryptic SQL error messages users don''t understand';
PRINT '  ✗ Procedures crash mid-execution';
PRINT '  ✗ Data corruption (partial updates)';
PRINT '';
PRINT 'Error handling = Professional, production-ready code!';
PRINT '';

IF OBJECT_ID('GetSafeProductionReport', 'P') IS NOT NULL
    DROP PROCEDURE GetSafeProductionReport;
GO

CREATE PROCEDURE GetSafeProductionReport
    @SiteID INT,
    @ReportDate DATE
AS
BEGIN
    /*
    Purpose: Production report with comprehensive error handling
    Parameters: @SiteID, @ReportDate
    Features: Input validation, existence checks, error logging
    Example: EXEC GetSafeProductionReport @SiteID = 1, @ReportDate = '2024-12-01';
    */
    
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Validation 1: Check inputs not NULL
        IF @SiteID IS NULL OR @SiteID <= 0
            THROW 50001, 'Invalid Site ID. Must be a positive integer.', 1;
        
        IF @ReportDate IS NULL
            THROW 50002, 'Report date required. Cannot be NULL.', 1;
        
        -- Validation 2: Check date not in future
        IF @ReportDate > CAST(GETDATE() AS DATE)
            THROW 50003, 'Report date cannot be in the future.', 1;
        
        -- Validation 3: Check site exists
        IF NOT EXISTS (SELECT 1 FROM mining_sites WHERE site_id = @SiteID)
            THROW 50004, 'Site ID does not exist. Check mining_sites table.', 1;
        
        -- Validation 4: Check site is operational
        IF EXISTS (SELECT 1 FROM mining_sites WHERE site_id = @SiteID AND operational = 0)
            THROW 50005, 'Site is not currently operational.', 1;
        
        -- If all validations pass, return data
        SELECT 
            ms.site_name,
            ms.site_location,
            dp.production_date,
            dp.shift,
            dp.ore_tonnes,
            dp.waste_tonnes,
            dp.downtime_hours,
            dp.efficiency_percent,
            CASE 
                WHEN dp.efficiency_percent >= 90 THEN 'Excellent'
                WHEN dp.efficiency_percent >= 80 THEN 'Good'
                WHEN dp.efficiency_percent >= 70 THEN 'Fair'
                ELSE 'Needs Improvement'
            END AS performance_rating
        FROM daily_production dp
        JOIN mining_sites ms ON dp.site_id = ms.site_id
        WHERE dp.site_id = @SiteID
          AND dp.production_date = @ReportDate
        ORDER BY dp.shift;
        
        -- Success message
        DECLARE @SuccessMsg NVARCHAR(200);
        SET @SuccessMsg = 'Report generated successfully for ' + 
                          (SELECT site_name FROM mining_sites WHERE site_id = @SiteID) +
                          ' on ' + CONVERT(NVARCHAR(10), @ReportDate, 120);
        PRINT @SuccessMsg;
        
    END TRY
    BEGIN CATCH
        -- Capture error details
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProcedure NVARCHAR(128) = ERROR_PROCEDURE();
        
        -- Log error to error_log table
        INSERT INTO error_log (error_message, error_procedure, error_line, error_severity, error_state)
        VALUES (@ErrorMessage, @ErrorProcedure, @ErrorLine, @ErrorSeverity, @ErrorState);
        
        -- Print user-friendly error
        PRINT '❌ ERROR in ' + ISNULL(@ErrorProcedure, 'Unknown Procedure');
        PRINT '   Line: ' + CAST(@ErrorLine AS NVARCHAR(10));
        PRINT '   Message: ' + @ErrorMessage;
        
        -- Re-throw error to caller
        THROW;
    END CATCH
END
GO

PRINT '✅ Procedure created: GetSafeProductionReport';
PRINT '';
PRINT 'Testing error handling...';
PRINT '';

PRINT '--- Test 1: Valid call (should work) ---';

DECLARE @ReportDate datetime = DATEADD(DAY, -1, CAST(GETDATE() AS date));

EXEC GetSafeProductionReport
    @SiteID = 1,
    @ReportDate = @ReportDate;
--EXEC GetSafeProductionReport 
--    @SiteID = 1, 
--    @ReportDate = (SELECT DATEADD(DAY, -1, CAST(GETDATE() AS DATE)));

--DECLARE @ReportDate date;



PRINT '';
PRINT '--- Test 2: Invalid SiteID (should trigger error) ---';
BEGIN TRY
    EXEC GetSafeProductionReport @SiteID = 999, @ReportDate = '2024-12-01';
END TRY
BEGIN CATCH
    PRINT 'Caught expected error: ' + ERROR_MESSAGE();
END CATCH

PRINT '';
PRINT '--- Test 3: NULL date (should trigger error) ---';
BEGIN TRY
    EXEC GetSafeProductionReport @SiteID = 1, @ReportDate = NULL;
END TRY
BEGIN CATCH
    PRINT 'Caught expected error: ' + ERROR_MESSAGE();
END CATCH

PRINT '';
PRINT '--- Test 4: Future date (should trigger error) ---';
BEGIN TRY
    EXEC GetSafeProductionReport @SiteID = 1, @ReportDate = '2025-12-31';
END TRY
BEGIN CATCH
    PRINT 'Caught expected error: ' + ERROR_MESSAGE();
END CATCH

PRINT '';
PRINT 'KEY CONCEPT:';
PRINT '  TRY...CATCH provides:';
PRINT '  ✓ Input validation';
PRINT '  ✓ Clear error messages';
PRINT '  ✓ Error logging';
PRINT '  ✓ Graceful failure handling';
PRINT '';

-- Show error log
PRINT 'Errors logged during testing:';
SELECT 
    error_id,
    error_message,
    error_procedure,
    error_line,
    logged_date
FROM error_log
ORDER BY logged_date DESC;

PRINT '';
GO

-- ============================================================================
-- CONCEPT 6: COMPREHENSIVE DAILY OPERATIONS REPORT (PLAYBOOK MAIN EXAMPLE)
-- ============================================================================

PRINT '';
PRINT '=============================================================';
PRINT 'CONCEPT 6: THE BIG WIN - DAILY OPERATIONS REPORT';
PRINT '=============================================================';
PRINT '';
PRINT 'This is the procedure that saves 2 hours per day!';
PRINT 'Replaces 15+ manual queries with ONE automated procedure.';
PRINT '';

IF OBJECT_ID('DailyOperationsReport', 'P') IS NOT NULL
    DROP PROCEDURE DailyOperationsReport;
GO

CREATE PROCEDURE DailyOperationsReport
    @ReportDate DATE = NULL-- Defaults to yesterday
AS 
BEGIN
    /*
    ============================================================
    DAILY OPERATIONS REPORT - THE $75K AUTOMATION
    ============================================================
    
    Purpose: Comprehensive daily production report for all BHD sites
             (BHD = Fictitious mining company for training)
    
    What it replaces:
      • 15+ separate queries run manually every day
      • 2 hours of copy-paste-change-date work
      • Inconsistent calculations across analysts
      
    What it delivers:
      ✓ Production summary by site and shift
      ✓ Equipment downtime analysis
      ✓ Safety incidents (unresolved)
      ✓ Efficiency metrics
      ✓ Site comparisons (vs previous day)
      ✓ Shift performance rankings
      
    Time: 2 hours → 30 seconds (96% time savings!)
    Savings: $75,000+ annually
    
    Usage:
      EXEC DailyOperationsReport;  -- Yesterday's report
      EXEC DailyOperationsReport @ReportDate = '2024-12-01';  -- Specific date
    ============================================================
    */
    
    SET NOCOUNT ON;
   
    -- Default to yesterday if not provided
    IF @ReportDate IS NULL 
        SET @ReportDate = DATEADD(DAY, -1, CAST(GETDATE() AS DATE));
    
    DECLARE @PreviousDay DATE = DATEADD(DAY, -1, @ReportDate);
    
    PRINT '';
    PRINT '============================================================';
    PRINT 'BHD MINING OPERATIONS - DAILY PRODUCTION REPORT';
    PRINT '⚠️  FICTITIOUS COMPANY - Educational Training Scenario';
    PRINT 'Report Date: ' + CONVERT(VARCHAR(20), @ReportDate, 107);
    PRINT 'Generated: ' + CONVERT(VARCHAR(20), GETDATE(), 120);
    PRINT '============================================================';
    PRINT '';
END;
GO
    -- ========================================
    -- SECTION 1: PRODUCTION SUMMARY
    -- ========================================
    PRINT '--- SECTION 1: PRODUCTION SUMMARY BY SITE AND SHIFT ---';
    PRINT '';

    --DECLARE @ReportDate datetime = DATEADD(DAY, -1, CAST(GETDATE() AS DATE)); If the stored procedure Concept 6 @ReportDate does not work

    SELECT 
        ms.site_name AS Site,
        ms.state AS State,
        dp.shift AS Shift,
        SUM(dp.ore_tonnes) AS OreProduced_Tonnes,
        SUM(dp.waste_tonnes) AS WasteRemoved_Tonnes,
        ROUND(SUM(dp.ore_tonnes) / NULLIF(SUM(dp.waste_tonnes), 0), 2) AS OreToWasteRatio,
        SUM(dp.equipment_hours) AS TotalEquipmentHours,
        SUM(dp.downtime_hours) AS TotalDowntimeHours,
        AVG(dp.efficiency_percent) AS AvgEfficiency_Percent
    FROM daily_production dp
    JOIN mining_sites ms ON dp.site_id = ms.site_id
    WHERE dp.production_date = @ReportDate
    GROUP BY ms.site_name, ms.state, dp.shift
    ORDER BY ms.site_name, dp.shift;
    
    PRINT '';
    
    -- ========================================
    -- SECTION 2: EQUIPMENT DOWNTIME ANALYSIS
    -- ========================================
    PRINT '--- SECTION 2: EQUIPMENT DOWNTIME ANALYSIS ---';
    PRINT '';

 
    SELECT 
        ms.site_name AS Site,
        SUM(dp.downtime_hours) AS TotalDowntime_Hours,
        SUM(dp.equipment_hours) AS TotalOperatingHours,
        ROUND((SUM(dp.downtime_hours) / NULLIF(SUM(dp.equipment_hours), 0)) * 100, 2) AS DowntimePercent,
        CASE 
            WHEN ROUND((SUM(dp.downtime_hours) / NULLIF(SUM(dp.equipment_hours), 0)) * 100, 2) > 10 THEN '🔴 Critical'
            WHEN ROUND((SUM(dp.downtime_hours) / NULLIF(SUM(dp.equipment_hours), 0)) * 100, 2) > 5 THEN '🟡 Warning'
            ELSE '🟢 Normal'
        END AS Status
    FROM daily_production dp
    JOIN mining_sites ms ON dp.site_id = ms.site_id
    WHERE dp.production_date = @ReportDate
    GROUP BY ms.site_name
    ORDER BY DowntimePercent DESC;
    
    PRINT '';
    
    -- ========================================
    -- SECTION 3: SAFETY INCIDENTS
    -- ========================================
    PRINT '--- SECTION 3: SAFETY INCIDENTS (UNRESOLVED) ---';
    PRINT '';
    
    SELECT 
        si.incident_id AS IncidentID,
        si.incident_date AS Date,
        ms.site_name AS Site,
        si.severity AS Severity,
        si.incident_type AS Type,
        si.description AS Description,
        DATEDIFF(DAY, si.incident_date, GETDATE()) AS DaysOpen
    FROM safety_incidents si
    JOIN mining_sites ms ON si.site_id = ms.site_id
    WHERE si.resolved = 0
    ORDER BY 
        CASE si.severity 
            WHEN 'Severe' THEN 1 
            WHEN 'Moderate' THEN 2 
            ELSE 3 
        END,
        si.incident_date;
    
    PRINT '';
    
    -- ========================================
    -- SECTION 4: EFFICIENCY METRICS
    -- ========================================
    PRINT '--- SECTION 4: EFFICIENCY METRICS ---';
    PRINT '';
    
    SELECT 
        ms.site_name AS Site,
        AVG(dp.efficiency_percent) AS AvgEfficiency,
        MIN(dp.efficiency_percent) AS MinEfficiency,
        MAX(dp.efficiency_percent) AS MaxEfficiency,
        CASE 
            WHEN AVG(dp.efficiency_percent) >= 90 THEN '⭐ Excellent'
            WHEN AVG(dp.efficiency_percent) >= 80 THEN '✅ Good'
            WHEN AVG(dp.efficiency_percent) >= 70 THEN '⚠️ Fair'
            ELSE '❌ Needs Improvement'
        END AS Rating
    FROM daily_production dp
    JOIN mining_sites ms ON dp.site_id = ms.site_id
    WHERE dp.production_date = @ReportDate
    GROUP BY ms.site_name
    ORDER BY AvgEfficiency DESC;
    
    PRINT '';
    
    -- ========================================
    -- SECTION 5: SITE COMPARISONS (vs Previous Day)
    -- ========================================
    PRINT '--- SECTION 5: SITE COMPARISONS (Yesterday vs Previous Day) ---';
    PRINT '';

    DECLARE @ReportDate DATE NULL;
    SELECT 
        ms.site_name AS Site,
        SUM(CASE WHEN dp.production_date = @ReportDate THEN dp.ore_tonnes ELSE 0 END) AS OreToday,
        SUM(CASE WHEN dp.production_date = @PreviousDay THEN dp.ore_tonnes ELSE 0 END) AS OreYesterday,
        SUM(CASE WHEN dp.production_date = @ReportDate THEN dp.ore_tonnes ELSE 0 END) - 
        SUM(CASE WHEN dp.production_date = @PreviousDay THEN dp.ore_tonnes ELSE 0 END) AS Change_Tonnes,
        ROUND(
            ((SUM(CASE WHEN dp.production_date = @ReportDate THEN dp.ore_tonnes ELSE 0 END) - SUM(CASE WHEN dp.production_date = @PreviousDay THEN dp.ore_tonnes ELSE 0 END)) /
             NULLIF(SUM(CASE WHEN dp.production_date = @PreviousDay THEN dp.ore_tonnes ELSE 0 END), 0)) * 100,
        2) AS ChangePercent
    FROM daily_production dp
    JOIN mining_sites ms ON dp.site_id = ms.site_id
    WHERE dp.production_date IN (@ReportDate, @PreviousDay)
    GROUP BY ms.site_name
    ORDER BY ChangePercent DESC;
    
    PRINT '';
    
    -- ========================================
    -- SECTION 6: SHIFT PERFORMANCE RANKINGS
    -- ========================================
    PRINT '--- SECTION 6: SHIFT PERFORMANCE RANKINGS ---';
    PRINT '';
    
    SELECT 
        ROW_NUMBER() OVER (ORDER BY SUM(dp.ore_tonnes) DESC) AS Rank,
        ms.site_name AS Site,
        dp.shift AS Shift,
        SUM(dp.ore_tonnes) AS OreProduced,
        AVG(dp.efficiency_percent) AS AvgEfficiency,
        CASE 
            WHEN ROW_NUMBER() OVER (ORDER BY SUM(dp.ore_tonnes) DESC) <= 3 THEN '🏆 Top Performer'
            ELSE ''
        END AS Award
    FROM daily_production dp
    JOIN mining_sites ms ON dp.site_id = ms.site_id
    WHERE dp.production_date = @ReportDate
    GROUP BY ms.site_name, dp.shift
    ORDER BY OreProduced DESC;
    
    PRINT '';
    PRINT '============================================================';
    PRINT 'REPORT COMPLETE';
    PRINT '============================================================';
    PRINT '';
    PRINT 'Executive Summary:';
    
    -- Calculate totals
    DECLARE @TotalOre DECIMAL(12,2);
    DECLARE @TotalWaste DECIMAL(12,2);
    DECLARE @TotalIncidents INT;
    DECLARE @AvgEfficiency DECIMAL(5,2);
    
    SELECT 
        @TotalOre = SUM(ore_tonnes),
        @TotalWaste = SUM(waste_tonnes),
        @AvgEfficiency = AVG(efficiency_percent)
    FROM daily_production
    WHERE production_date = @ReportDate;
    
    SELECT @TotalIncidents = COUNT(*)
    FROM safety_incidents
    WHERE resolved = 0;
    
    PRINT '  Total Ore Produced: ' + FORMAT(@TotalOre, 'N2') + ' tonnes';
    PRINT '  Total Waste Removed: ' + FORMAT(@TotalWaste, 'N2') + ' tonnes';
    PRINT '  Average Efficiency: ' + CAST(@AvgEfficiency AS NVARCHAR(10)) + '%';
    PRINT '  Unresolved Incidents: ' + CAST(@TotalIncidents AS NVARCHAR(10));
    PRINT '';
    PRINT '✅ Time to generate: 30 seconds';
    PRINT '✅ Previous manual process: 2 hours';
    PRINT '✅ Time saved: 96%';
    PRINT '';
    
END
GO

PRINT '✅ Procedure created: DailyOperationsReport';
PRINT '';
PRINT 'THE BIG WIN! This procedure replaces 15+ manual queries.';
PRINT '';
PRINT 'Testing the comprehensive report...';
PRINT '';

-- Execute the daily report
EXEC DailyOperationsReport;

PRINT '';
PRINT '=============================================================';
PRINT 'BUSINESS IMPACT ACHIEVED!';
PRINT '=============================================================';
PRINT '';
PRINT 'Before Automation:';
PRINT '  • 15+ queries in Word document';
PRINT '  • Manual execution daily';
PRINT '  • 2 hours of repetitive work';
PRINT '  • High error risk';
PRINT '  • Annual cost: $80,000';
PRINT '';
PRINT 'After Automation (ONE stored procedure):';
PRINT '  • EXEC DailyOperationsReport';
PRINT '  • 30 seconds execution';
PRINT '  • Automated, error-free';
PRINT '  • Consistent calculations';
PRINT '  • Annual savings: $75,000+';
PRINT '';
PRINT 'Result: 96% time savings!';
PRINT 'Impact: Operations Manager has 13 weeks back per year!';
PRINT '';
GO

-- ============================================================================
-- CONCEPT 7: SCALAR FUNCTIONS
-- ============================================================================

PRINT '';
PRINT '=============================================================';
PRINT 'CONCEPT 7: SCALAR FUNCTIONS - RETURN SINGLE VALUES';
PRINT '=============================================================';
PRINT '';
PRINT 'What Are Scalar Functions?';
PRINT '  • Return a SINGLE value (number, string, date)';
PRINT '  • Can be used in SELECT, WHERE, ORDER BY';
PRINT '  • Pure calculation (no side effects)';
PRINT '';
PRINT 'When to Use:';
PRINT '  ✓ Reusable calculations (discount, tax, conversion)';
PRINT '  ✓ String formatting';
PRINT '  ✓ Date calculations';
PRINT '  ✓ Business rule logic';
PRINT '';

IF OBJECT_ID('dbo.CalculateEfficiency', 'FN') IS NOT NULL
    DROP FUNCTION dbo.CalculateEfficiency;
GO

CREATE FUNCTION dbo.CalculateEfficiency
(
    @EquipmentHours DECIMAL(8,2),
    @DowntimeHours DECIMAL(6,2)
)
RETURNS DECIMAL(5,2)
AS
BEGIN
    /*
    Purpose: Calculate equipment efficiency percentage
    Parameters: @EquipmentHours, @DowntimeHours
    Returns: Efficiency % (0-100)
    Example: SELECT dbo.CalculateEfficiency(20, 2) → 90.00
    */
    
    DECLARE @Efficiency DECIMAL(5,2);
    
    IF @EquipmentHours > 0
        SET @Efficiency = ROUND(((@EquipmentHours - @DowntimeHours) / @EquipmentHours) * 100, 2);
    ELSE
        SET @Efficiency = 0;
    
    RETURN @Efficiency;
END
GO

PRINT '✅ Function created: dbo.CalculateEfficiency';
PRINT '';
PRINT 'Using scalar function in queries...';
PRINT '';

SELECT 
    site_id,
    production_date,
    shift,
    equipment_hours,
    downtime_hours,
    dbo.CalculateEfficiency(equipment_hours, downtime_hours) AS calculated_efficiency,
    efficiency_percent AS stored_efficiency
FROM daily_production
WHERE production_date = (SELECT MAX(production_date) FROM daily_production)
ORDER BY site_id, shift;

PRINT '';
GO

-- ============================================================================
-- CONCEPT 8: TABLE-VALUED FUNCTIONS
-- ============================================================================

PRINT '';
PRINT '=============================================================';
PRINT 'CONCEPT 8: TABLE-VALUED FUNCTIONS - RETURN TABLES';
PRINT '=============================================================';
PRINT '';
PRINT 'What Are Table-Valued Functions?';
PRINT '  • Return a TABLE of results';
PRINT '  • Can be used in FROM clause (like a view)';
PRINT '  • Parameter-driven filtering';
PRINT '';
PRINT 'When to Use:';
PRINT '  ✓ Reusable query logic';
PRINT '  ✓ Parameterized views';
PRINT '  ✓ Complex filtering rules';
PRINT '';

IF OBJECT_ID('dbo.GetHighDowntimeSites', 'IF') IS NOT NULL
    DROP FUNCTION dbo.GetHighDowntimeSites;
GO

CREATE FUNCTION dbo.GetHighDowntimeSites
(
    @ThresholdPercent DECIMAL(5,2)
)
RETURNS TABLE
AS
RETURN
(
    /*
    Purpose: Return sites with downtime above threshold
    Parameters: @ThresholdPercent (e.g., 5.0 for 5%)
    Returns: Table with site details and downtime metrics
    Example: SELECT * FROM dbo.GetHighDowntimeSites(5.0);
    */
    
    SELECT 
        ms.site_name,
        ms.site_location,
        ms.state,
        SUM(dp.downtime_hours) AS total_downtime_hours,
        SUM(dp.equipment_hours) AS total_equipment_hours,
        ROUND((SUM(dp.downtime_hours) / NULLIF(SUM(dp.equipment_hours), 0)) * 100, 2) AS downtime_percent,
        CASE 
            WHEN ROUND((SUM(dp.downtime_hours) / NULLIF(SUM(dp.equipment_hours), 0)) * 100, 2) > 10 THEN 'Critical'
            WHEN ROUND((SUM(dp.downtime_hours) / NULLIF(SUM(dp.equipment_hours), 0)) * 100, 2) > 5 THEN 'Warning'
            ELSE 'Normal'
        END AS status
    FROM daily_production dp
    JOIN mining_sites ms ON dp.site_id = ms.site_id
    WHERE dp.production_date >= DATEADD(DAY, -7, GETDATE())
    GROUP BY ms.site_name, ms.site_location, ms.state
    HAVING ROUND((SUM(dp.downtime_hours) / NULLIF(SUM(dp.equipment_hours), 0)) * 100, 2) > @ThresholdPercent
);
GO

PRINT '✅ Function created: dbo.GetHighDowntimeSites';
PRINT '';
PRINT 'Using table-valued function...';
PRINT '';

PRINT '--- Sites with downtime > 3% ---';
SELECT * FROM dbo.GetHighDowntimeSites(3.0)
ORDER BY downtime_percent DESC;

PRINT '';
PRINT '--- Sites with downtime > 5% ---';
SELECT * FROM dbo.GetHighDowntimeSites(5.0)
ORDER BY downtime_percent DESC;

PRINT '';
GO

-- ============================================================================
-- PROCEDURES VS FUNCTIONS - DECISION GUIDE
-- ============================================================================

PRINT '';
PRINT '=============================================================';
PRINT 'PROCEDURES VS FUNCTIONS - WHEN TO USE WHAT?';
PRINT '=============================================================';
PRINT '';
PRINT 'Use STORED PROCEDURES when:';
PRINT '  ✓ Modifying data (INSERT, UPDATE, DELETE)';
PRINT '  ✓ Multiple result sets';
PRINT '  ✓ Complex business logic with transactions';
PRINT '  ✓ Error handling required (TRY...CATCH)';
PRINT '  ✓ Automating workflows';
PRINT '';
PRINT 'Use SCALAR FUNCTIONS when:';
PRINT '  ✓ Need to return a SINGLE calculated value';
PRINT '  ✓ Logic is used in SELECT, WHERE, ORDER BY';
PRINT '  ✓ Pure calculation (no side effects)';
PRINT '  ✓ Example: Calculate discount, format string, convert units';
PRINT '';
PRINT 'Use TABLE-VALUED FUNCTIONS when:';
PRINT '  ✓ Need to return a TABLE of results';
PRINT '  ✓ Reusable query logic';
PRINT '  ✓ Use like a parameterized view';
PRINT '  ✓ Example: Filter products, get time ranges, apply rules';
PRINT '';
PRINT 'Functions CANNOT:';
PRINT '  ✗ Modify data (INSERT, UPDATE, DELETE)';
PRINT '  ✗ Use TRY...CATCH';
PRINT '  ✗ Have side effects (PRINT, transactions)';
PRINT '  ✗ Call procedures';
PRINT '';
PRINT '=============================================================';
PRINT '';
GO

-- ============================================================================
-- PRACTICE EXERCISES
-- ============================================================================

PRINT '';
PRINT '=============================================================';
PRINT 'PRACTICE EXERCISES - TEST YOUR SKILLS';
PRINT '=============================================================';
PRINT '';
PRINT 'Exercise 1: Basic Procedure ⭐';
PRINT '  Create procedure: GetIncidentsBySeverity';
PRINT '  Parameter: @Severity (''Minor'', ''Moderate'', ''Severe'')';
PRINT '  Return: All incidents matching that severity';
PRINT '  Include: Site name, date, type, status';
PRINT '';
PRINT 'Exercise 2: Procedure with Defaults ⭐⭐';
PRINT '  Create procedure: GetProductionSummary';
PRINT '  Parameters: @StartDate, @EndDate (default to last 7 days)';
PRINT '  Return: Total ore and waste by site';
PRINT '  Include: Shift count, average efficiency';
PRINT '';
PRINT 'Exercise 3: Scalar Function ⭐⭐';
PRINT '  Create function: CalculateOreToWasteRatio';
PRINT '  Parameters: @OreTonnes, @WasteTonnes';
PRINT '  Return: Ratio as DECIMAL(5,2)';
PRINT '  Use: In SELECT to show ratio for each production record';
PRINT '';
PRINT 'Exercise 4: Table-Valued Function ⭐⭐⭐';
PRINT '  Create function: GetTopPerformingSites';
PRINT '  Parameter: @TopN (e.g., 3 for top 3 sites)';
PRINT '  Return: Top N sites by ore production';
PRINT '  Include: Site name, total ore, average efficiency';
PRINT '';
PRINT 'Exercise 5: Production Procedure with Error Handling ⭐⭐⭐';
PRINT '  Create procedure: UpdateIncidentStatus';
PRINT '  Parameters: @IncidentID, @Resolved (BIT)';
PRINT '  Validation: Check incident exists, not already resolved';
PRINT '  Action: Update resolved status and resolved_date';
PRINT '  Error Handling: TRY...CATCH with clear messages';
PRINT '';
PRINT '=============================================================';
PRINT '';
GO

-- ============================================================================
-- EXERCISE SOLUTIONS
-- ============================================================================

PRINT '';
PRINT '=============================================================';
PRINT 'EXERCISE SOLUTIONS (Try yourself first!)';
PRINT '=============================================================';
PRINT '';
GO

-- SOLUTION 1: GetIncidentsBySeverity
PRINT '--- SOLUTION 1: GetIncidentsBySeverity Procedure ---';
PRINT '';

IF OBJECT_ID('GetIncidentsBySeverity', 'P') IS NOT NULL
    DROP PROCEDURE GetIncidentsBySeverity;
GO

CREATE PROCEDURE GetIncidentsBySeverity
    @Severity NVARCHAR(20)
AS
BEGIN
    SELECT 
        si.incident_id,
        si.incident_date,
        ms.site_name,
        ms.state,
        si.severity,
        si.incident_type,
        si.description,
        CASE WHEN si.resolved = 1 THEN 'Resolved' ELSE 'Open' END AS status,
        si.resolved_date,
        CASE 
            WHEN si.resolved = 0 THEN DATEDIFF(DAY, si.incident_date, GETDATE())
            ELSE DATEDIFF(DAY, si.incident_date, si.resolved_date)
        END AS days_to_resolution
    FROM safety_incidents si
    JOIN mining_sites ms ON si.site_id = ms.site_id
    WHERE si.severity = @Severity
    ORDER BY si.incident_date DESC;
END
GO

PRINT 'Testing: EXEC GetIncidentsBySeverity @Severity = ''Moderate'';';
EXEC GetIncidentsBySeverity @Severity = 'Moderate';
PRINT '';
GO

-- SOLUTION 2: GetProductionSummary with Defaults
PRINT '--- SOLUTION 2: GetProductionSummary with Defaults ---';
PRINT '';

IF OBJECT_ID('GetProductionSummary', 'P') IS NOT NULL
    DROP PROCEDURE GetProductionSummary;
GO

CREATE PROCEDURE GetProductionSummary
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
AS
BEGIN
    -- Default to last 7 days if not provided
    IF @StartDate IS NULL SET @StartDate = DATEADD(DAY, -7, GETDATE());
    IF @EndDate IS NULL SET @EndDate = CAST(GETDATE() AS DATE);
    
    SELECT 
        ms.site_name,
        ms.state,
        SUM(dp.ore_tonnes) AS total_ore,
        SUM(dp.waste_tonnes) AS total_waste,
        ROUND(SUM(dp.ore_tonnes) / NULLIF(SUM(dp.waste_tonnes), 0), 2) AS ore_to_waste_ratio,
        COUNT(*) AS shift_count,
        AVG(dp.efficiency_percent) AS avg_efficiency,
        SUM(dp.downtime_hours) AS total_downtime
    FROM daily_production dp
    JOIN mining_sites ms ON dp.site_id = ms.site_id
    WHERE dp.production_date BETWEEN @StartDate AND @EndDate
    GROUP BY ms.site_name, ms.state
    ORDER BY total_ore DESC;
END
GO

PRINT 'Testing: EXEC GetProductionSummary; (uses defaults)';
EXEC GetProductionSummary;
PRINT '';
GO

-- SOLUTION 3: CalculateOreToWasteRatio Scalar Function
PRINT '--- SOLUTION 3: CalculateOreToWasteRatio Function ---';
PRINT '';

IF OBJECT_ID('dbo.CalculateOreToWasteRatio', 'FN') IS NOT NULL
    DROP FUNCTION dbo.CalculateOreToWasteRatio;
GO

CREATE FUNCTION dbo.CalculateOreToWasteRatio
(
    @OreTonnes DECIMAL(12,2),
    @WasteTonnes DECIMAL(12,2)
)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @Ratio DECIMAL(5,2);
    
    IF @WasteTonnes > 0
        SET @Ratio = ROUND(@OreTonnes / @WasteTonnes, 2);
    ELSE
        SET @Ratio = 0;
    
    RETURN @Ratio;
END
GO

PRINT 'Testing: Using function in SELECT...';
SELECT TOP 10
    site_id,
    production_date,
    shift,
    ore_tonnes,
    waste_tonnes,
    dbo.CalculateOreToWasteRatio(ore_tonnes, waste_tonnes) AS ore_waste_ratio
FROM daily_production
WHERE production_date = (SELECT MAX(production_date) FROM daily_production)
ORDER BY site_id, shift;
PRINT '';
GO

-- SOLUTION 4: GetTopPerformingSites Table-Valued Function
PRINT '--- SOLUTION 4: GetTopPerformingSites Function ---';
PRINT '';

IF OBJECT_ID('dbo.GetTopPerformingSites', 'IF') IS NOT NULL
    DROP FUNCTION dbo.GetTopPerformingSites;
GO

CREATE FUNCTION dbo.GetTopPerformingSites
(
    @TopN INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP (@TopN)
        ms.site_name,
        ms.state,
        ms.commodity,
        SUM(dp.ore_tonnes) AS total_ore_tonnes,
        AVG(dp.efficiency_percent) AS avg_efficiency,
        SUM(dp.downtime_hours) AS total_downtime,
        COUNT(*) AS production_records
    FROM daily_production dp
    JOIN mining_sites ms ON dp.site_id = ms.site_id
    WHERE dp.production_date >= DATEADD(DAY, -7, GETDATE())
    GROUP BY ms.site_name, ms.state, ms.commodity
    ORDER BY SUM(dp.ore_tonnes) DESC
);
GO

PRINT 'Testing: SELECT * FROM dbo.GetTopPerformingSites(3);';
SELECT * FROM dbo.GetTopPerformingSites(3);
PRINT '';
GO

-- SOLUTION 5: UpdateIncidentStatus with Error Handling
PRINT '--- SOLUTION 5: UpdateIncidentStatus Procedure ---';
PRINT '';

IF OBJECT_ID('UpdateIncidentStatus', 'P') IS NOT NULL
    DROP PROCEDURE UpdateIncidentStatus;
GO

CREATE PROCEDURE UpdateIncidentStatus
    @IncidentID INT,
    @Resolved BIT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Validation 1: Check incident exists
        IF NOT EXISTS (SELECT 1 FROM safety_incidents WHERE incident_id = @IncidentID)
            THROW 50001, 'Incident ID not found in database', 1;
        
        -- Validation 2: Check if already in requested state
        IF EXISTS (SELECT 1 FROM safety_incidents WHERE incident_id = @IncidentID AND resolved = @Resolved)
        BEGIN
            DECLARE @StatusMsg NVARCHAR(100) = CASE WHEN @Resolved = 1 THEN 'already resolved' ELSE 'already open' END;
            DECLARE @ErrMsg NVARCHAR(200) = 'Incident ' + CAST(@IncidentID AS NVARCHAR(10)) + ' is ' + @StatusMsg;
            THROW 50002, @ErrMsg, 1;
        END
        
        -- Update the incident
        UPDATE safety_incidents
        SET 
            resolved = @Resolved,
            resolved_date = CASE WHEN @Resolved = 1 THEN CAST(GETDATE() AS DATE) ELSE NULL END
        WHERE incident_id = @IncidentID;
        
        -- Success message
        DECLARE @SuccessMsg NVARCHAR(200);
        SET @SuccessMsg = '✅ Incident ' + CAST(@IncidentID AS NVARCHAR(10)) + 
                          CASE WHEN @Resolved = 1 THEN ' marked as RESOLVED' ELSE ' reopened' END;
        PRINT @SuccessMsg;
        
        -- Show updated incident
        SELECT 
            incident_id,
            incident_date,
            severity,
            incident_type,
            CASE WHEN resolved = 1 THEN 'Resolved' ELSE 'Open' END AS status,
            resolved_date
        FROM safety_incidents
        WHERE incident_id = @IncidentID;
        
    END TRY
    BEGIN CATCH
        -- Log and display error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        
        INSERT INTO error_log (error_message, error_procedure, error_line, error_severity, error_state)
        VALUES (@ErrorMessage, 'UpdateIncidentStatus', ERROR_LINE(), @ErrorSeverity, ERROR_STATE());
        
        PRINT '❌ Error: ' + @ErrorMessage;
        THROW;
    END CATCH
END
GO

PRINT 'Testing: Updating incident status...';
PRINT '';

PRINT '--- Test 1: Mark incident as resolved ---';
EXEC UpdateIncidentStatus @IncidentID = 5, @Resolved = 1;

PRINT '';
PRINT '--- Test 2: Try to resolve same incident again (should error) ---';
BEGIN TRY
    EXEC UpdateIncidentStatus @IncidentID = 5, @Resolved = 1;
END TRY
BEGIN CATCH
    PRINT 'Caught expected error: ' + ERROR_MESSAGE();
END CATCH

PRINT '';
PRINT '--- Test 3: Invalid incident ID (should error) ---';
BEGIN TRY
    EXEC UpdateIncidentStatus @IncidentID = 9999, @Resolved = 1;
END TRY
BEGIN CATCH
    PRINT 'Caught expected error: ' + ERROR_MESSAGE();
END CATCH

PRINT '';
GO

-- ============================================================================
-- FINAL SUMMARY AND BUSINESS IMPACT
-- ============================================================================

PRINT '';
PRINT '=============================================================';
PRINT 'VIDEO 9 COMPLETE! ✓';
PRINT '=============================================================';
PRINT '';
PRINT 'What You Mastered:';
PRINT '  ✓ Creating stored procedures with parameters';
PRINT '  ✓ Default parameters and NULL handling';
PRINT '  ✓ OUTPUT parameters for returning values';
PRINT '  ✓ TRY...CATCH error handling';
PRINT '  ✓ Creating scalar functions';
PRINT '  ✓ Creating table-valued functions';
PRINT '  ✓ When to use procedures vs functions';
PRINT '  ✓ 5 practice exercises with solutions';
PRINT '';
PRINT 'Business Value Delivered:';
PRINT '  ⏱️  2 hours → 30 seconds (96% time savings)';
PRINT '  💰 $75,000+ annual cost savings';
PRINT '  🔄 Automated daily operations report';
PRINT '  🛡️  Error handling prevents failures';
PRINT '  📊 Reusable calculation logic (efficiency, ratios)';
PRINT '';
PRINT 'Production Skills:';
PRINT '  🚀 Automating repetitive workflows';
PRINT '  🔧 Building reusable code libraries';
PRINT '  🎯 Parameter-driven reporting';
PRINT '  💪 Enterprise-grade error handling';
PRINT '';
PRINT 'Key Objects Created:';
PRINT '  • Procedures: GetSiteProduction, GetProductionByDateRange,';
PRINT '                GetProductionFlexible, GetSiteSummary,';
PRINT '                GetSafeProductionReport, DailyOperationsReport,';
PRINT '                GetIncidentsBySeverity, GetProductionSummary,';
PRINT '                UpdateIncidentStatus';
PRINT '  • Scalar Functions: CalculateEfficiency, CalculateOreToWasteRatio';
PRINT '  • Table-Valued Functions: GetHighDowntimeSites, GetTopPerformingSites';
PRINT '  • Tables: mining_sites, daily_production, safety_incidents, error_log';
PRINT '';
PRINT 'Next Video: Temp Tables & Table Variables';
PRINT '           (NAB Banking - Complex Multi-Step Workflows)';
PRINT '';
PRINT '=============================================================';
PRINT '';

-- Final data summary
SELECT 
    'Database Objects Created' AS Summary,
    (SELECT COUNT(*) FROM sys.procedures WHERE name LIKE 'Get%' OR name LIKE 'Update%' OR name = 'DailyOperationsReport') AS Procedures,
    (SELECT COUNT(*) FROM sys.objects WHERE type IN ('FN', 'IF', 'TF')) AS Functions,
    (SELECT COUNT(*) FROM sys.tables WHERE name <> 'sysdiagrams') AS Tables;

PRINT 'All objects created successfully! Database ready for use.';
PRINT '';
GO
