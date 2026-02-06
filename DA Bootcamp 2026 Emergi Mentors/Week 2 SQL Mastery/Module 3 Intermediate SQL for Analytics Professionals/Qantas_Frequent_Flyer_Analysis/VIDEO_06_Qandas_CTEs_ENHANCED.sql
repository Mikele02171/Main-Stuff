/*********************************************************************************
VIDEO 6: CTEs - COMMON TABLE EXPRESSIONS FOR READABLE ENTERPRISE SQL
Qandas Frequent Flyer - Tier Qualification Analysis (FICTITIOUS ORGANIZATION)
Enterprise SQL for Australian Data Analysts
Duration: 19 minutes | Intermediate-Advanced
ENHANCED VERSION - Includes ALL PDF Playbook Concepts + Practice Exercises

DISCLAIMER:
Qandas Frequent Flyer in this tutorial is a FICTITIOUS ORGANIZATION created for 
educational purposes only. This is NOT Qantas Airways. Any resemblance to actual 
airline loyalty programs is coincidental. This is a training scenario designed to 
teach SQL CTE concepts using realistic Australian business contexts.

BUSINESS SCENARIO (PDF PAGE 2):
You're a data analyst at Qandas (fictitious Australian airline).
Wednesday morning 10:00 AM. The Loyalty Program Manager emails:

"We're launching a status match campaign next week to compete with Virgin Australia.
I need a list of customers who are CLOSE to the next tier but haven't quite made it.
We'll offer them bonus points to push them over. Need this by EOD today!"

THE QANDAS FREQUENT FLYER TIERS (PDF PAGE 2):
- Bronze: 0-299 Status Credits (SC)
- Silver: 300-699 SC + 4 eligible flights
- Gold: 700-1,399 SC + 4 eligible flights  
- Platinum: 1,400+ SC + 4 eligible flights

THE COMPLEX BUSINESS LOGIC (PDF PAGE 2):
Find customers who:
✓ Have 250-299 SC (close to Silver) OR
✓ Have 650-699 SC (close to Gold) OR  
✓ Have 1,350-1,399 SC (close to Platinum)
✓ AND have 3+ eligible flights (1 flight away from requirement)
✓ AND active in last 6 months (recent flyers)

Calculate for each customer:
- How many SC needed to reach next tier?
- How many flights needed?
- Campaign priority (HIGH/MEDIUM/STANDARD)

THE DATA CHALLENGE (PDF PAGE 2):
Multiple calculations needed for EACH customer:
1. Total status credits earned
2. Count of eligible flights
3. Most recent flight date
4. Days since last flight
5. Tier opportunity identification
6. SC and flights needed calculations

THE NIGHTMARE APPROACH - NESTED SUBQUERIES (PDF PAGE 2):
SELECT ...
WHERE (SELECT SUM(sc) FROM flights WHERE ...) BETWEEN 250 AND 299
  AND (SELECT COUNT(*) FROM flights WHERE ...) >= 3
  AND (SELECT MAX(date) FROM flights WHERE ...) >= ...
   OR (SELECT SUM(sc) FROM flights WHERE ...) BETWEEN 650 AND 699
  AND (SELECT COUNT(*) FROM flights WHERE ...) >= 3
  ...

Problems with Nested Subqueries:
✗ Same calculation repeated 6+ times (inefficient!)
✗ Impossible to read (nested inside-out logic)
✗ Debugging nightmare (which subquery broke?)
✗ Maintenance hell (change one thing = find all copies)
✗ Can't explain to junior analysts

THE PROFESSIONAL SOLUTION: CTEs (PDF PAGE 2):
✓ Write each calculation ONCE, give it a name
✓ Build logic step-by-step (top to bottom)
✓ Easy to read, debug, and maintain
✓ Reusable and collaborative

LEARNING OBJECTIVES:
✓ CTE basics - WITH clause syntax (PDF Page 3)
✓ Chaining multiple CTEs together (PDF Page 4)
✓ CTEs referencing earlier CTEs (PDF Page 4)
✓ Production query with 5 CTEs (PDF Page 5)
✓ Replace complex subqueries with readable code
✓ Enterprise-grade SQL best practices
✓ Complete 5 practice exercises with solutions (PDF Page 6)
*********************************************************************************/

-- ============================================================================
-- STEP 1: CREATE DATABASE AND TABLES
-- ============================================================================

-- First, switch to master to avoid "currently in use" errors
USE master;
GO

-- Drop database if exists (fresh start)
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'Qandas_FrequentFlyer')
BEGIN
    PRINT 'Dropping existing Qandas_FrequentFlyer database...';
    ALTER DATABASE Qandas_FrequentFlyer SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Qandas_FrequentFlyer;
    PRINT '✅ Existing database dropped successfully';
END
GO

-- Create fresh database
CREATE DATABASE Qandas_FrequentFlyer;
GO

USE Qandas_FrequentFlyer;
GO

PRINT '=== Database Created: Qandas_FrequentFlyer (Fictitious Organization) ===';
GO

-- ============================================================================
-- STEP 2: CREATE TABLES
-- ============================================================================

-- Frequent flyer members table
CREATE TABLE members (
    member_id INT PRIMARY KEY,
    member_name NVARCHAR(100),
    email NVARCHAR(100),
    current_tier NVARCHAR(20),
    join_date DATE,
    home_city NVARCHAR(50)
);

-- Flight history table
CREATE TABLE flights (
    flight_id INT PRIMARY KEY,
    member_id INT FOREIGN KEY REFERENCES members(member_id),
    flight_date DATE,
    route NVARCHAR(100),
    flight_class NVARCHAR(20),
    status_credits INT,
    points_earned INT,
    eligible_flight BIT  -- 1 = counts toward tier qualification, 0 = doesn't
);

PRINT '=== Tables Created: members, flights ===';
GO

-- ============================================================================
-- STEP 3: INSERT REALISTIC SAMPLE DATA
-- ============================================================================

PRINT '';
PRINT '=== Generating Qandas Frequent Flyer Data ===';
PRINT 'Fictitious members with various tier qualification scenarios';
PRINT '';

-- Insert 20 frequent flyer members
INSERT INTO members VALUES
-- Bronze members (potential tier-close candidates)
(1001, 'Sarah Mitchell', 'sarah.mitchell@email.com', 'Bronze', '2022-03-15', 'Sydney'),
(1002, 'James Chen', 'james.chen@email.com', 'Bronze', '2023-01-20', 'Melbourne'),
(1003, 'Emma Thompson', 'emma.thompson@email.com', 'Bronze', '2021-06-10', 'Brisbane'),
(1004, 'Liam O''Connor', 'liam.oconnor@email.com', 'Bronze', '2022-08-25', 'Perth'),
(1005, 'Olivia Patel', 'olivia.patel@email.com', 'Bronze', '2023-02-14', 'Adelaide'),

-- Silver members (close to Gold - tier-close candidates)
(1006, 'William Zhang', 'william.zhang@email.com', 'Silver', '2021-04-05', 'Sydney'),
(1007, 'Ava Nguyen', 'ava.nguyen@email.com', 'Silver', '2022-07-18', 'Melbourne'),
(1008, 'Noah Williams', 'noah.williams@email.com', 'Silver', '2020-11-30', 'Brisbane'),
(1009, 'Isabella Brown', 'isabella.brown@email.com', 'Silver', '2022-05-22', 'Sydney'),
(1010, 'Mason Taylor', 'mason.taylor@email.com', 'Silver', '2021-09-14', 'Melbourne'),

-- Gold members (close to Platinum - tier-close candidates)
(1011, 'Sophia Anderson', 'sophia.anderson@email.com', 'Gold', '2020-02-10', 'Sydney'),
(1012, 'Lucas Martin', 'lucas.martin@email.com', 'Gold', '2019-12-05', 'Brisbane'),
(1013, 'Charlotte Garcia', 'charlotte.garcia@email.com', 'Gold', '2021-08-17', 'Perth'),

-- Platinum members (already at top tier)
(1014, 'Ethan Rodriguez', 'ethan.rodriguez@email.com', 'Platinum', '2018-05-20', 'Sydney'),
(1015, 'Amelia Lee', 'amelia.lee@email.com', 'Platinum', '2019-03-12', 'Melbourne'),

-- Additional mixed tier members
(1016, 'Benjamin Kim', 'benjamin.kim@email.com', 'Bronze', '2023-04-08', 'Sydney'),
(1017, 'Harper Singh', 'harper.singh@email.com', 'Silver', '2022-10-15', 'Melbourne'),
(1018, 'Evelyn Tran', 'evelyn.tran@email.com', 'Gold', '2020-07-25', 'Brisbane'),
(1019, 'Alexander Liu', 'alexander.liu@email.com', 'Bronze', '2023-06-30', 'Perth'),
(1020, 'Mia Johnson', 'mia.johnson@email.com', 'Silver', '2021-11-20', 'Adelaide');

PRINT '✅ 20 members inserted across Bronze, Silver, Gold, Platinum tiers';

-- Insert flight data with TIER-CLOSE scenarios planted
DECLARE @today DATE = '2024-12-01';

-- Member 1001 (Sarah) - 280 SC, 3 eligible flights (CLOSE TO SILVER - needs 20 SC, 1 flight)
INSERT INTO flights VALUES
(2001, 1001, DATEADD(DAY, -45, @today), 'Sydney-Melbourne', 'Economy', 80, 1200, 1),
(2002, 1001, DATEADD(DAY, -60, @today), 'Melbourne-Brisbane', 'Economy', 100, 1500, 1),
(2003, 1001, DATEADD(DAY, -90, @today), 'Brisbane-Sydney', 'Economy', 100, 1500, 1);

-- Member 1002 (James) - 150 SC, 2 eligible flights (NOT tier-close, too few flights)
INSERT INTO flights VALUES
(2004, 1002, DATEADD(DAY, -30, @today), 'Melbourne-Sydney', 'Economy', 80, 1200, 1),
(2005, 1002, DATEADD(DAY, -120, @today), 'Sydney-Perth', 'Economy', 70, 1000, 1);

-- Member 1003 (Emma) - 260 SC, 4 eligible flights (CLOSE TO SILVER but already has 4 flights)
INSERT INTO flights VALUES
(2006, 1003, DATEADD(DAY, -20, @today), 'Brisbane-Sydney', 'Economy', 80, 1200, 1),
(2007, 1003, DATEADD(DAY, -40, @today), 'Sydney-Melbourne', 'Economy', 60, 900, 1),
(2008, 1003, DATEADD(DAY, -70, @today), 'Melbourne-Perth', 'Economy', 60, 900, 1),
(2009, 1003, DATEADD(DAY, -100, @today), 'Perth-Brisbane', 'Economy', 60, 900, 1);

-- Member 1004 (Liam) - 295 SC, 3 eligible flights (CLOSE TO SILVER - HIGH PRIORITY - needs only 5 SC!)
INSERT INTO flights VALUES
(2010, 1004, DATEADD(DAY, -15, @today), 'Perth-Sydney', 'Business', 120, 3000, 1),
(2011, 1004, DATEADD(DAY, -35, @today), 'Sydney-Melbourne', 'Economy', 85, 1300, 1),
(2012, 1004, DATEADD(DAY, -55, @today), 'Melbourne-Perth', 'Economy', 90, 1400, 1);

-- Member 1006 (William) - 665 SC, 3 eligible flights (CLOSE TO GOLD - needs 35 SC, 1 flight)
INSERT INTO flights VALUES
(2013, 1006, DATEADD(DAY, -25, @today), 'Sydney-Singapore', 'Business', 180, 4500, 1),
(2014, 1006, DATEADD(DAY, -50, @today), 'Singapore-London', 'Business', 250, 6000, 1),
(2015, 1006, DATEADD(DAY, -80, @today), 'London-Sydney', 'Business', 235, 5800, 1);

-- Member 1007 (Ava) - 680 SC, 3 eligible flights (CLOSE TO GOLD - needs 20 SC, 1 flight)
INSERT INTO flights VALUES
(2016, 1007, DATEADD(DAY, -10, @today), 'Melbourne-Tokyo', 'Business', 200, 5000, 1),
(2017, 1007, DATEADD(DAY, -40, @today), 'Tokyo-Sydney', 'Business', 240, 6000, 1),
(2018, 1007, DATEADD(DAY, -75, @today), 'Sydney-Melbourne', 'Business', 240, 6000, 1);

-- Member 1011 (Sophia) - 1375 SC, 3 eligible flights (CLOSE TO PLATINUM - needs 25 SC, 1 flight)
INSERT INTO flights VALUES
(2019, 1011, DATEADD(DAY, -12, @today), 'Sydney-Los Angeles', 'First', 450, 10000, 1),
(2020, 1011, DATEADD(DAY, -30, @today), 'Los Angeles-New York', 'First', 480, 11000, 1),
(2021, 1011, DATEADD(DAY, -65, @today), 'New York-Sydney', 'First', 445, 10500, 1);

-- Member 1012 (Lucas) - 1390 SC, 4 eligible flights (CLOSE TO PLATINUM but already has 4 flights)
INSERT INTO flights VALUES
(2022, 1012, DATEADD(DAY, -18, @today), 'Brisbane-Hong Kong', 'Business', 350, 8000, 1),
(2023, 1012, DATEADD(DAY, -45, @today), 'Hong Kong-London', 'Business', 380, 9000, 1),
(2024, 1012, DATEADD(DAY, -72, @today), 'London-Dubai', 'Business', 330, 7500, 1),
(2025, 1012, DATEADD(DAY, -95, @today), 'Dubai-Brisbane', 'Business', 330, 7500, 1);

-- Member 1014 (Ethan) - 1850 SC, 5 eligible flights (Already Platinum, well over requirement)
INSERT INTO flights VALUES
(2026, 1014, DATEADD(DAY, -8, @today), 'Sydney-San Francisco', 'First', 460, 11000, 1),
(2027, 1014, DATEADD(DAY, -22, @today), 'San Francisco-Tokyo', 'First', 420, 10000, 1),
(2028, 1014, DATEADD(DAY, -50, @today), 'Tokyo-Sydney', 'First', 450, 10500, 1),
(2029, 1014, DATEADD(DAY, -85, @today), 'Sydney-London', 'First', 260, 6000, 1),
(2030, 1014, DATEADD(DAY, -120, @today), 'London-Sydney', 'First', 260, 6000, 1);

-- Add some inactive members and regular flyers for practice exercises
INSERT INTO flights VALUES
-- Member 1008 (Noah) - Regular Silver, not tier-close
(2031, 1008, DATEADD(DAY, -35, @today), 'Brisbane-Sydney', 'Economy', 85, 1300, 1),
(2032, 1008, DATEADD(DAY, -60, @today), 'Sydney-Melbourne', 'Economy', 90, 1400, 1),
(2033, 1008, DATEADD(DAY, -90, @today), 'Melbourne-Brisbane', 'Economy', 85, 1300, 1),
(2034, 1008, DATEADD(DAY, -125, @today), 'Brisbane-Perth', 'Economy', 95, 1450, 1),

-- Member 1009 (Isabella) - Inactive for 8 months (for practice exercise)
(2035, 1009, DATEADD(DAY, -240, @today), 'Sydney-Melbourne', 'Business', 120, 3000, 1),
(2036, 1009, DATEADD(DAY, -270, @today), 'Melbourne-Brisbane', 'Business', 110, 2800, 1),

-- Member 1013 (Charlotte) - Gold with good activity
(2037, 1013, DATEADD(DAY, -20, @today), 'Perth-Sydney', 'Business', 180, 4500, 1),
(2038, 1013, DATEADD(DAY, -48, @today), 'Sydney-Singapore', 'Business', 200, 5000, 1),
(2039, 1013, DATEADD(DAY, -78, @today), 'Singapore-Perth', 'Business', 195, 4800, 1),
(2040, 1013, DATEADD(DAY, -110, @today), 'Perth-Melbourne', 'Business', 190, 4700, 1),
(2041, 1013, DATEADD(DAY, -145, @today), 'Melbourne-Perth', 'Business', 185, 4600, 1);

PRINT '✅ Flight data inserted with TIER-CLOSE scenarios:';
PRINT '   • Sarah (280 SC, 3 flights) - CLOSE TO SILVER';
PRINT '   • Liam (295 SC, 3 flights) - CLOSE TO SILVER (HIGH PRIORITY!)';
PRINT '   • William (665 SC, 3 flights) - CLOSE TO GOLD';
PRINT '   • Ava (680 SC, 3 flights) - CLOSE TO GOLD (HIGH PRIORITY!)';
PRINT '   • Sophia (1375 SC, 3 flights) - CLOSE TO PLATINUM (HIGH PRIORITY!)';
PRINT '';
GO

-- ============================================================================
-- VALIDATION: Check row counts
-- ============================================================================
SELECT 'Members' AS TableName, COUNT(*) AS [RowCount] FROM members
UNION ALL
SELECT 'Flights' AS TableName, COUNT(*) AS [RowCount] FROM flights;
GO

PRINT '';
PRINT '=============================================================';
PRINT 'THE WEDNESDAY MORNING CHALLENGE (PDF PAGE 2)';
PRINT '=============================================================';
PRINT '10:00 AM Wednesday - Loyalty Manager''s Email:';
PRINT '"We''re launching a status match campaign next week"';
PRINT '"Need customers CLOSE to next tier but haven''t made it"';
PRINT '"Offer bonus points to push them over - need by EOD!"';
PRINT '';
PRINT 'Requirements:';
PRINT '  • Find customers within 50 SC of next tier';
PRINT '  • Must have 3+ eligible flights (1 away from requirement)';
PRINT '  • Active in last 6 months';
PRINT '  • Calculate: SC needed, flights needed, priority';
PRINT '';
PRINT 'The Data Challenge:';
PRINT '  • Total status credits per member';
PRINT '  • Count eligible flights per member';
PRINT '  • Most recent flight date';
PRINT '  • Days since last flight';
PRINT '  • Tier opportunity identification';
PRINT '  • SC and flights needed calculations';
PRINT '';
PRINT 'With nested subqueries: UNREADABLE NIGHTMARE';
PRINT 'With CTEs: Clean, readable, maintainable ✓';
PRINT '=============================================================';
PRINT '';
GO

-- ============================================================================
-- QUERY 1: CTE BASICS (PDF PAGE 3)
-- ============================================================================

PRINT '';
PRINT '=== QUERY 1: CTE BASICS - YOUR NEW BEST FRIEND (PDF PAGE 3) ===';
PRINT 'CTE = Common Table Expression';
PRINT 'A temporary named result set that exists only during query execution';
PRINT '';

-- Simple example: Member flight summary
WITH member_stats AS (
    SELECT 
        m.member_id,
        m.member_name,
        m.current_tier,
        SUM(f.status_credits) AS total_sc,
        COUNT(*) AS total_flights
    FROM members m
    LEFT JOIN flights f ON m.member_id = f.member_id
    GROUP BY m.member_id, m.member_name, m.current_tier
)
SELECT 
    member_id,
    member_name,
    current_tier,
    total_sc,
    total_flights
FROM member_stats
WHERE total_sc > 500
ORDER BY total_sc DESC;

PRINT '';
PRINT '✅ CTE Syntax Breakdown (PDF Page 3):';
PRINT '   WITH member_stats AS (';
PRINT '       SELECT ... GROUP BY ...  ← This defines the CTE';
PRINT '   )';
PRINT '   SELECT * FROM member_stats;  ← This uses the CTE';
PRINT '';
PRINT 'What Happens:';
PRINT '   1. CTE runs first: Calculates total_sc and total_flights';
PRINT '   2. Result stored temporarily as "member_stats"';
PRINT '   3. Main query treats member_stats like a table';
PRINT '   4. Filter: Only members with 500+ SC';
PRINT '   5. CTE disappears after query completes';
PRINT '';
PRINT 'The Readability Test (PDF Page 3):';
PRINT '   Show to junior analyst:';
PRINT '   • Subquery: "Uh... what''s happening here?"';
PRINT '   • CTE: "Oh! member_stats calculates totals, then filter. Got it!"';
PRINT '';
GO

-- ============================================================================
-- QUERY 2: SUBQUERY VS CTE COMPARISON (PDF PAGE 3)
-- ============================================================================

PRINT '';
PRINT '=== QUERY 2: WHY CTEs BEAT SUBQUERIES (PDF PAGE 3) ===';
PRINT 'Same result, dramatically different readability';
PRINT '';

-- BAD: Subquery approach (repeated calculations)
PRINT '❌ SUBQUERY APPROACH (Don''t do this!):';
PRINT '   SELECT member_id,';
PRINT '          (SELECT SUM(sc) FROM flights WHERE ...) AS total_sc,';
PRINT '          (SELECT COUNT(*) FROM flights WHERE ...) AS total_flights';
PRINT '   FROM members';
PRINT '   WHERE (SELECT SUM(sc) FROM flights WHERE ...) > 500;';
PRINT '   ^^^ SUM(sc) calculated TWICE! (SELECT + WHERE)';
PRINT '';

-- GOOD: CTE approach (calculate once)
PRINT '✓ CTE APPROACH (Professional!):';
WITH member_stats AS (
    SELECT 
        member_id,
        SUM(status_credits) AS total_sc,
        COUNT(*) AS total_flights
    FROM flights
    GROUP BY member_id
)
SELECT 
    m.member_id,
    m.member_name,
    ms.total_sc,
    ms.total_flights
FROM members m
LEFT JOIN member_stats ms ON m.member_id = ms.member_id
WHERE ms.total_sc > 500
ORDER BY ms.total_sc DESC;

PRINT '';
PRINT '✅ Key Advantages (PDF Page 3):';
PRINT '   ✓ Named & meaningful (member_stats tells you what it is)';
PRINT '   ✓ Calculated ONCE (not repeated in SELECT/WHERE)';
PRINT '   ✓ Top-to-bottom flow (not inside-out nesting)';
PRINT '   ✓ Testable (run CTE by itself to verify)';
PRINT '   ✓ Maintainable (change in one place)';
PRINT '';
GO

-- ============================================================================
-- QUERY 3: CHAINING MULTIPLE CTEs (PDF PAGE 4)
-- ============================================================================

PRINT '';
PRINT '=== QUERY 3: CHAINING MULTIPLE CTEs (PDF PAGE 4) ===';
PRINT 'Build complex logic step-by-step with named stages';
PRINT '';

WITH
-- Step 1: Total status credits per member
status_credits AS (
    SELECT 
        member_id,
        SUM(status_credits) AS total_sc
    FROM flights
    GROUP BY member_id
),
-- Step 2: Count eligible flights per member
eligible_flights AS (
    SELECT 
        member_id,
        COUNT(*) AS eligible_count
    FROM flights
    WHERE eligible_flight = 1
    GROUP BY member_id
),
-- Step 3: Last flight date per member
last_flight AS (
    SELECT 
        member_id,
        MAX(flight_date) AS last_flight_date
    FROM flights
    GROUP BY member_id
)
-- Step 4: Combine everything
SELECT 
    m.member_id,
    m.member_name,
    m.current_tier,
    ISNULL(sc.total_sc, 0) AS total_sc,
    ISNULL(ef.eligible_count, 0) AS eligible_flights,
    lf.last_flight_date,
    DATEDIFF(DAY, lf.last_flight_date, GETDATE()) AS days_since_last
FROM members m
LEFT JOIN status_credits sc ON m.member_id = sc.member_id
LEFT JOIN eligible_flights ef ON m.member_id = ef.member_id
LEFT JOIN last_flight lf ON m.member_id = lf.member_id
ORDER BY total_sc DESC;

PRINT '';
PRINT '✅ Chaining Multiple CTEs (PDF Page 4):';
PRINT '   WITH';
PRINT '       cte1 AS (SELECT ...),  ← Step 1';
PRINT '       cte2 AS (SELECT ...),  ← Step 2 (comma!)';
PRINT '       cte3 AS (SELECT ...)   ← Step 3 (NO comma on last!)';
PRINT '   SELECT ... FROM cte1 JOIN cte2 JOIN cte3';
PRINT '';
PRINT 'What Happened:';
PRINT '   Step 1: status_credits calculates SC per member';
PRINT '   Step 2: eligible_flights counts qualifying flights';
PRINT '   Step 3: last_flight finds most recent date';
PRINT '   Step 4: Main query JOINs all three together';
PRINT '';
PRINT '💡 Debugging Advantage (PDF Page 4):';
PRINT '   Want to test Step 2 alone?';
PRINT '   Just SELECT * FROM eligible_flights;';
PRINT '   Can''t do that with nested subqueries!';
PRINT '';
GO

-- ============================================================================
-- QUERY 4: CTEs REFERENCING OTHER CTEs (PDF PAGE 4)
-- ============================================================================

PRINT '';
PRINT '=== QUERY 4: CTEs REFERENCING OTHER CTEs (PDF PAGE 4) ===';
PRINT 'Later CTEs can SELECT FROM earlier CTEs - Build on previous work!';
PRINT '';

WITH
-- Step 1: Calculate total SC per member
member_sc AS (
    SELECT 
        member_id,
        SUM(status_credits) AS total_sc
    FROM flights
    GROUP BY member_id
),
-- Step 2: Use Step 1 to determine tier earned
tier_earned AS (
    SELECT 
        m.member_id,
        m.member_name,
        m.current_tier,
        ISNULL(sc.total_sc, 0) AS total_sc,
        CASE
            WHEN sc.total_sc >= 1400 THEN 'Platinum'
            WHEN sc.total_sc >= 700 THEN 'Gold'
            WHEN sc.total_sc >= 300 THEN 'Silver'
            ELSE 'Bronze'
        END AS earned_tier
    FROM members m
    LEFT JOIN member_sc sc ON m.member_id = sc.member_id
    --            ^^^^^^^^^ Using Step 1!
),
-- Step 3: Use Step 2 to find mismatches
tier_mismatches AS (
    SELECT 
        *,
        CASE
            WHEN current_tier <> earned_tier THEN 'UPGRADE ELIGIBLE'
            WHEN current_tier = earned_tier THEN 'OK'
            ELSE 'CHECK'
        END AS tier_status
    FROM tier_earned
    --   ^^^^^^^^^^^ Using Step 2!
)
-- Final: Show only upgrade opportunities
SELECT 
    member_id,
    member_name,
    current_tier,
    earned_tier,
    total_sc,
    tier_status
FROM tier_mismatches
WHERE tier_status = 'UPGRADE ELIGIBLE'
ORDER BY total_sc DESC;

PRINT '';
PRINT '✅ CTEs Referencing CTEs (PDF Page 4):';
PRINT '   member_sc → tier_earned → tier_mismatches → final query';
PRINT '   Each step builds on the previous';
PRINT '   Logic flows TOP to BOTTOM (easy to follow!)';
PRINT '';
PRINT 'The Flow (PDF Page 4):';
PRINT '   1. Calculate current year SC';
PRINT '   2. Determine tier they''ve earned (uses Step 1)';
PRINT '   3. Check if current tier matches earned tier (uses Step 2)';
PRINT '   4. Generate upgrade letters (uses Step 3)';
PRINT '';
PRINT '💡 Performance Note (PDF Page 4):';
PRINT '   SQL Server is smart about CTEs';
PRINT '   It doesn''t materialize each CTE separately';
PRINT '   It optimizes the entire query as a whole';
PRINT '   CTEs = readability WITHOUT performance penalty!';
PRINT '';
GO

-- ============================================================================
-- QUERY 5: PRODUCTION QUERY - TIER-CLOSE CAMPAIGN (PDF PAGE 5)
-- ============================================================================

PRINT '';
PRINT '=== QUERY 5: PRODUCTION QUERY - TIER-CLOSE CAMPAIGN (PDF PAGE 5) ===';
PRINT 'The complete solution with 5 CTEs - Production-grade enterprise SQL';
PRINT '';

WITH
-- Step 1: Total status credits per member
member_status_credits AS (
    SELECT 
        member_id,
        SUM(status_credits) AS total_sc
    FROM flights
    GROUP BY member_id
),
-- Step 2: Eligible flight count per member
member_eligible_flights AS (
    SELECT 
        member_id,
        COUNT(*) AS eligible_flights
    FROM flights
    WHERE eligible_flight = 1
    GROUP BY member_id
),
-- Step 3: Most recent flight per member
member_last_flight AS (
    SELECT 
        member_id,
        MAX(flight_date) AS last_flight_date
    FROM flights
    GROUP BY member_id
),
-- Step 4: Combine all metrics into member summary
member_summary AS (
    SELECT 
        m.member_id,
        m.member_name,
        m.email,
        m.current_tier,
        ISNULL(sc.total_sc, 0) AS total_sc,
        ISNULL(ef.eligible_flights, 0) AS eligible_flights,
        lf.last_flight_date,
        DATEDIFF(DAY, lf.last_flight_date, GETDATE()) AS days_since_last
    FROM members m
    LEFT JOIN member_status_credits sc ON m.member_id = sc.member_id
    LEFT JOIN member_eligible_flights ef ON m.member_id = ef.member_id
    LEFT JOIN member_last_flight lf ON m.member_id = lf.member_id
),
-- Step 5: Identify tier-close customers and calculate needs
tier_close_customers AS (
    SELECT 
        *,
        CASE
            WHEN total_sc BETWEEN 250 AND 299 THEN 'Close to Silver'
            WHEN total_sc BETWEEN 650 AND 699 THEN 'Close to Gold'
            WHEN total_sc BETWEEN 1350 AND 1399 THEN 'Close to Platinum'
        END AS tier_opportunity,
        CASE
            WHEN total_sc BETWEEN 250 AND 299 THEN 300 - total_sc
            WHEN total_sc BETWEEN 650 AND 699 THEN 700 - total_sc
            WHEN total_sc BETWEEN 1350 AND 1399 THEN 1400 - total_sc
        END AS sc_needed,
        4 - eligible_flights AS flights_needed
    FROM member_summary
    WHERE (total_sc BETWEEN 250 AND 299
        OR total_sc BETWEEN 650 AND 699
        OR total_sc BETWEEN 1350 AND 1399)
)
-- Final: Filtered, prioritized campaign list
SELECT 
    member_id,
    member_name,
    email,
    current_tier,
    tier_opportunity,
    total_sc,
    sc_needed,
    eligible_flights,
    flights_needed,
    days_since_last,
    CASE
        WHEN sc_needed <= 20 AND flights_needed = 1 THEN 'HIGH PRIORITY'
        WHEN sc_needed <= 50 AND flights_needed = 1 THEN 'MEDIUM PRIORITY'
        ELSE 'STANDARD'
    END AS campaign_priority,
    CONCAT('Offer ', sc_needed * 2, ' bonus points') AS bonus_offer
FROM tier_close_customers
WHERE eligible_flights >= 3
  AND days_since_last <= 180
ORDER BY 
    CASE 
        WHEN sc_needed <= 20 AND flights_needed = 1 THEN 1
        WHEN sc_needed <= 50 AND flights_needed = 1 THEN 2
        ELSE 3
    END,
    sc_needed;

PRINT '';
PRINT '✅ What Loyalty Manager Gets (PDF Page 5):';
PRINT '   Name           | Tier Opportunity  | SC  | Needed | Flights | Priority';
PRINT '   Liam O''Connor   | Close to Silver   | 295 | 5      | 3       | HIGH';
PRINT '   Ava Nguyen      | Close to Gold     | 680 | 20     | 3       | HIGH';
PRINT '   Sophia Anderson | Close to Platinum | 1375| 25     | 3       | HIGH';
PRINT '   William Zhang   | Close to Gold     | 665 | 35     | 3       | MEDIUM';
PRINT '   Sarah Mitchell  | Close to Silver   | 280 | 20     | 3       | MEDIUM';
PRINT '';
PRINT '📊 Business Impact (PDF Page 5):';
PRINT '   ✓ 5 customers identified for personalized offers';
PRINT '   ✓ Lifetime value: 1 Gold member = $1,500/year';
PRINT '   ✓ Expected 80% conversion rate';
PRINT '   ✓ Prevent defection to Virgin Australia';
PRINT '   ✓ Query runtime: <1 second (production-ready)';
PRINT '';
PRINT '💡 Why This Query Is Professional (PDF Page 5):';
PRINT '   ✓ 5 clear steps with meaningful names';
PRINT '   ✓ Anyone can understand the logic flow';
PRINT '   ✓ Easy to modify (change one CTE, not whole query)';
PRINT '   ✓ Testable (run each CTE individually)';
PRINT '   ✓ Documented (CTE names explain themselves)';
PRINT '   ✓ Maintainable (future analysts can update it)';
PRINT '';
GO

--FROM THE SLIDES IF THE 5 CTES QUERIES ABOVE DOES NOT WORK
WITH-- Step 1: Total status credits
member_status_credits AS (
    SELECT 
        member_id,
        SUM(status_credits) AS total_sc
    FROM flights
    GROUP BY member_id
),-- Step 2: Eligible flight count
member_eligible_flights AS (
    SELECT 
        member_id,
        COUNT(*) AS eligible_flights
    FROM flights
    WHERE eligible_flight = 1
    GROUP BY member_id
),-- Step 3: Most recent flight
member_last_flight AS (
    SELECT 
        member_id,
        MAX(flight_date) AS last_flight_date
    FROM flights
    GROUP BY member_id
),-- Step 4: Combine all metrics
member_summary AS (
    SELECT 
        m.member_id,
        m.member_name,
        m.email,
        m.current_tier,
        ISNULL(sc.total_sc, 0) AS total_sc,
        ISNULL(ef.eligible_flights, 0) AS eligible_flights,
        lf.last_flight_date,
        CASE 
            WHEN lf.last_flight_date IS NOT NULL 
            THEN DATEDIFF(DAY, lf.last_flight_date, '2024-12-01')
            ELSE NULL
        END AS days_since_last
    FROM members m
    LEFT JOIN member_status_credits sc ON m.member_id = sc.member_id
    LEFT JOIN member_eligible_flights ef ON m.member_id = ef.member_id
    LEFT JOIN member_last_flight lf ON m.member_id = lf.member_id
),-- Step 5: Identify tier-close customers
tier_close_customers AS (
    SELECT 
        *,
        CASE
            WHEN total_sc BETWEEN 250 AND 299 THEN 'Close to Silver'
            WHEN total_sc BETWEEN 650 AND 699 THEN 'Close to Gold'
            WHEN total_sc BETWEEN 1350 AND 1399 THEN 'Close to Platinum'
            ELSE NULL
        END AS tier_opportunity,
        CASE
            WHEN total_sc BETWEEN 250 AND 299 THEN 300 - total_sc
            WHEN total_sc BETWEEN 650 AND 699 THEN 700 - total_sc
            WHEN total_sc BETWEEN 1350 AND 1399 THEN 1400 - total_sc
            ELSE NULL
        END AS sc_needed,
        4 - eligible_flights AS flights_needed
    FROM member_summary
    WHERE (total_sc BETWEEN 250 AND 299
        OR total_sc BETWEEN 650 AND 699
        OR total_sc BETWEEN 1350 AND 1399)
)-- Final: Filtered, prioritised list
SELECT 
    member_id,
    member_name,
    email,
    current_tier,
    tier_opportunity,
    total_sc,
    sc_needed,
    eligible_flights,
    flights_needed,
    days_since_last,
    CASE
        WHEN sc_needed <= 20 AND flights_needed = 1 THEN 'HIGH PRIORITY'
        WHEN sc_needed <= 50 AND flights_needed = 1 THEN 'MEDIUM PRIORITY'
        ELSE 'STANDARD'
    END AS campaign_priority,
    CONCAT('Offer ', sc_needed * 2, ' bonus points') AS offer
FROM tier_close_customers
WHERE eligible_flights >= 3
    AND days_since_last IS NOT NULL
    AND days_since_last <= 180
ORDER BY 
    CASE 
        WHEN sc_needed <= 20 AND flights_needed = 1 THEN 1
        WHEN sc_needed <= 50 AND flights_needed = 1 THEN 2
        ELSE 3
    END,
    sc_needed;

-- ============================================================================
-- PRACTICE EXERCISE 1: BASIC CTE - MEMBER FLIGHT SUMMARY (PDF PAGE 6)
-- ============================================================================

PRINT '';
PRINT '=============================================================';
PRINT 'PRACTICE EXERCISES (PDF PAGE 6)';
PRINT '=============================================================';
PRINT '';
PRINT '=== EXERCISE 1: BASIC CTE - MEMBER FLIGHT SUMMARY (Beginner) ===';
PRINT 'Create CTE showing each member''s total flights and total SC';
PRINT 'Filter to show only members with 3+ flights';
PRINT '';

-- SOLUTION:
WITH member_flight_summary AS (
    SELECT 
        m.member_id,
        m.member_name,
        m.current_tier,
        COUNT(f.flight_id) AS total_flights,
        ISNULL(SUM(f.status_credits), 0) AS total_sc,
        ISNULL(SUM(f.points_earned), 0) AS total_points
    FROM members m
    LEFT JOIN flights f ON m.member_id = f.member_id
    GROUP BY m.member_id, m.member_name, m.current_tier
)
SELECT 
    member_id,
    member_name,
    current_tier,
    total_flights,
    total_sc,
    total_points
FROM member_flight_summary
WHERE total_flights >= 3
ORDER BY total_sc DESC;

PRINT '';
PRINT '✅ SOLUTION EXPLAINED:';
PRINT '   • One CTE with SUM and COUNT aggregations';
PRINT '   • WHERE clause in main query filters 3+ flights';
PRINT '   • ISNULL handles members with no flights';
PRINT '';
PRINT 'Business Use Case:';
PRINT '   Identify active members for retention campaigns';
PRINT '   Segment by flight frequency';
PRINT '';
GO

-- ============================================================================
-- PRACTICE EXERCISE 2: MULTIPLE CTEs - PREMIUM VS ECONOMY (PDF PAGE 6)
-- ============================================================================

PRINT '';
PRINT '=== EXERCISE 2: MULTIPLE CTEs - PREMIUM VS ECONOMY (Intermediate) ===';
PRINT 'Compare premium (Business/First) vs Economy SC per member';
PRINT '';

-- SOLUTION:
WITH
-- CTE 1: Business/First class flights per member
premium_flights AS (
    SELECT 
        member_id,
        COUNT(*) AS premium_flight_count,
        SUM(status_credits) AS premium_sc,
        SUM(points_earned) AS premium_points
    FROM flights
    WHERE flight_class IN ('Business', 'First')
    GROUP BY member_id
),
-- CTE 2: Economy flights per member
economy_flights AS (
    SELECT 
        member_id,
        COUNT(*) AS economy_flight_count,
        SUM(status_credits) AS economy_sc,
        SUM(points_earned) AS economy_points
    FROM flights
    WHERE flight_class = 'Economy'
    GROUP BY member_id
)
-- Join both CTEs to compare
SELECT 
    m.member_id,
    m.member_name,
    m.current_tier,
    ISNULL(p.premium_flight_count, 0) AS premium_flights,
    ISNULL(p.premium_sc, 0) AS premium_sc,
    ISNULL(e.economy_flight_count, 0) AS economy_flights,
    ISNULL(e.economy_sc, 0) AS economy_sc,
    ISNULL(p.premium_sc, 0) + ISNULL(e.economy_sc, 0) AS total_sc,
    CASE 
        WHEN ISNULL(p.premium_sc, 0) > ISNULL(e.economy_sc, 0) THEN 'Premium Flyer'
        WHEN ISNULL(e.economy_sc, 0) > ISNULL(p.premium_sc, 0) THEN 'Economy Flyer'
        ELSE 'Mixed'
    END AS flyer_profile
FROM members m
LEFT JOIN premium_flights p ON m.member_id = p.member_id
LEFT JOIN economy_flights e ON m.member_id = e.member_id
WHERE ISNULL(p.premium_flight_count, 0) + ISNULL(e.economy_flight_count, 0) > 0
ORDER BY total_sc DESC;

PRINT '';
PRINT '✅ SOLUTION EXPLAINED:';
PRINT '   • Two separate CTEs with WHERE flight_class filters';
PRINT '   • Main query JOINs both CTEs';
PRINT '   • Categorizes members as Premium/Economy/Mixed';
PRINT '';
PRINT 'Business Use Case:';
PRINT '   Identify high-value premium customers';
PRINT '   Target upsell campaigns to Economy flyers';
PRINT '   Personalize marketing by flying preference';
PRINT '';
GO

-- ============================================================================
-- PRACTICE EXERCISE 3: CTE CHAIN - ROUTE POPULARITY (PDF PAGE 6)
-- ============================================================================

PRINT '';
PRINT '=== EXERCISE 3: CTE CHAIN - ROUTE POPULARITY (Intermediate) ===';
PRINT 'Build 3-step chain: Count flights → Avg SC → Rank routes';
PRINT '';

-- SOLUTION:
WITH
-- Step 1: Count flights per route
route_flight_count AS (
    SELECT 
        route,
        COUNT(*) AS total_flights,
        COUNT(DISTINCT member_id) AS unique_members
    FROM flights
    GROUP BY route
),
-- Step 2: Calculate average SC per route
route_avg_sc AS (
    SELECT 
        route,
        AVG(status_credits) AS avg_sc_per_flight,
        SUM(status_credits) AS total_sc_on_route
    FROM flights
    GROUP BY route
),
-- Step 3: Rank routes by total flights (using Step 1)
route_ranked AS (
    SELECT 
        rfc.route,
        rfc.total_flights,
        rfc.unique_members,
        rasc.avg_sc_per_flight,
        rasc.total_sc_on_route,
        ROW_NUMBER() OVER (ORDER BY rfc.total_flights DESC) AS popularity_rank
    FROM route_flight_count rfc
    JOIN route_avg_sc rasc ON rfc.route = rasc.route
)
-- Final: Show top 5 routes
SELECT TOP 5
    popularity_rank,
    route,
    total_flights,
    unique_members,
    ROUND(avg_sc_per_flight, 0) AS avg_sc,
    total_sc_on_route
FROM route_ranked
ORDER BY popularity_rank;

PRINT '';
PRINT '✅ SOLUTION EXPLAINED:';
PRINT '   • Step 1: Count flights per route';
PRINT '   • Step 2: Calculate average SC per route';
PRINT '   • Step 3: Use ROW_NUMBER() to rank routes';
PRINT '   • Final: TOP 5 most popular routes';
PRINT '';
PRINT 'Business Use Case:';
PRINT '   Capacity planning for popular routes';
PRINT '   Revenue optimization';
PRINT '   Partnership opportunities with destinations';
PRINT '';
GO

-- ============================================================================
-- PRACTICE EXERCISE 4: TIER UPGRADE CANDIDATES (PDF PAGE 6)
-- ============================================================================

PRINT '';
PRINT '=== EXERCISE 4: TIER UPGRADE CANDIDATES (Advanced) ===';
PRINT 'Find Silver members with 600-650 SC (close to Gold at 700)';
PRINT 'Filter: 3+ eligible flights, active in last 6 months';
PRINT '';

-- SOLUTION:
WITH
-- Step 1: Calculate total SC
member_sc AS (
    SELECT 
        member_id,
        SUM(status_credits) AS total_sc
    FROM flights
    GROUP BY member_id
),
-- Step 2: Count eligible flights
member_eligible AS (
    SELECT 
        member_id,
        COUNT(*) AS eligible_flights
    FROM flights
    WHERE eligible_flight = 1
    GROUP BY member_id
),
-- Step 3: Get last flight date
member_recency AS (
    SELECT 
        member_id,
        MAX(flight_date) AS last_flight_date,
        DATEDIFF(DAY, MAX(flight_date), GETDATE()) AS days_since_last
    FROM flights
    GROUP BY member_id
),
-- Step 4: Combine and identify upgrade candidates
upgrade_candidates AS (
    SELECT 
        m.member_id,
        m.member_name,
        m.email,
        m.current_tier,
        ISNULL(sc.total_sc, 0) AS total_sc,
        ISNULL(me.eligible_flights, 0) AS eligible_flights,
        mr.last_flight_date,
        mr.days_since_last,
        700 - ISNULL(sc.total_sc, 0) AS sc_needed_for_gold
    FROM members m
    LEFT JOIN member_sc sc ON m.member_id = sc.member_id
    LEFT JOIN member_eligible me ON m.member_id = me.member_id
    LEFT JOIN member_recency mr ON m.member_id = mr.member_id
    WHERE m.current_tier = 'Silver'
      AND sc.total_sc BETWEEN 600 AND 650
)
-- Final: Filter and prioritize
SELECT 
    member_id,
    member_name,
    email,
    current_tier,
    total_sc,
    sc_needed_for_gold,
    eligible_flights,
    days_since_last,
    CASE 
        WHEN eligible_flights >= 3 AND days_since_last <= 180 THEN 'CAMPAIGN ELIGIBLE'
        WHEN eligible_flights < 3 THEN 'NEEDS MORE FLIGHTS'
        WHEN days_since_last > 180 THEN 'INACTIVE'
    END AS campaign_status
FROM upgrade_candidates
WHERE eligible_flights >= 3
  AND days_since_last <= 180
ORDER BY sc_needed_for_gold;

PRINT '';
PRINT '✅ SOLUTION EXPLAINED:';
PRINT '   • Similar pattern to tier_close_customers query';
PRINT '   • Filters: Silver tier, 600-650 SC range';
PRINT '   • Additional filters: 3+ flights, <180 days inactive';
PRINT '   • Calculates SC needed to reach Gold (700)';
PRINT '';
PRINT 'Business Use Case:';
PRINT '   Targeted Gold tier upgrade campaign';
PRINT '   Prevent customer churn to competitors';
PRINT '   Maximize tier progression revenue';
PRINT '';
GO

-- ============================================================================
-- PRACTICE EXERCISE 5: INACTIVE HIGH-VALUE MEMBERS (PDF PAGE 6)
-- ============================================================================

PRINT '';
PRINT '=== EXERCISE 5: INACTIVE HIGH-VALUE MEMBERS (Advanced) ===';
PRINT 'Find Gold/Platinum members who haven''t flown in 12+ months';
PRINT 'Calculate lifetime SC, last flight, months inactive';
PRINT '';

-- SOLUTION:
WITH
-- Step 1: Calculate lifetime SC per member
member_lifetime_sc AS (
    SELECT 
        member_id,
        SUM(status_credits) AS lifetime_sc,
        SUM(points_earned) AS lifetime_points,
        COUNT(*) AS total_flights
    FROM flights
    GROUP BY member_id
),
-- Step 2: Get last flight information
member_last_activity AS (
    SELECT 
        member_id,
        MAX(flight_date) AS last_flight_date,
        DATEDIFF(MONTH, MAX(flight_date), GETDATE()) AS months_inactive,
        DATEDIFF(DAY, MAX(flight_date), GETDATE()) AS days_inactive
    FROM flights
    GROUP BY member_id
),
-- Step 3: Combine and identify inactive high-value members
inactive_high_value AS (
    SELECT 
        m.member_id,
        m.member_name,
        m.email,
        m.current_tier,
        m.home_city,
        ISNULL(lsc.lifetime_sc, 0) AS lifetime_sc,
        ISNULL(lsc.lifetime_points, 0) AS lifetime_points,
        ISNULL(lsc.total_flights, 0) AS total_flights,
        la.last_flight_date,
        la.months_inactive,
        la.days_inactive
    FROM members m
    LEFT JOIN member_lifetime_sc lsc ON m.member_id = lsc.member_id
    LEFT JOIN member_last_activity la ON m.member_id = la.member_id
    WHERE m.current_tier IN ('Gold', 'Platinum')
      AND la.months_inactive >= 12
)
-- Final: Win-back campaign recommendations
SELECT 
    member_id,
    member_name,
    email,
    current_tier,
    home_city,
    lifetime_sc,
    lifetime_points,
    total_flights,
    last_flight_date,
    months_inactive,
    CASE 
        WHEN months_inactive >= 24 THEN 'CRITICAL - 2+ years inactive'
        WHEN months_inactive >= 18 THEN 'HIGH RISK - 18+ months'
        WHEN months_inactive >= 12 THEN 'AT RISK - 12+ months'
    END AS risk_category,
    CASE 
        WHEN current_tier = 'Platinum' THEN 'Offer 20,000 bonus points'
        WHEN current_tier = 'Gold' THEN 'Offer 10,000 bonus points'
    END AS win_back_offer
FROM inactive_high_value
ORDER BY 
    CASE 
        WHEN current_tier = 'Platinum' THEN 1
        WHEN current_tier = 'Gold' THEN 2
    END,
    months_inactive DESC;

PRINT '';
PRINT '✅ SOLUTION EXPLAINED:';
PRINT '   • Step 1: Calculate lifetime value (SC, points, flights)';
PRINT '   • Step 2: Determine inactivity period (months/days)';
PRINT '   • Step 3: Filter Gold/Platinum with 12+ months inactive';
PRINT '   • Risk categorization and personalized win-back offers';
PRINT '';
PRINT 'Business Use Case:';
PRINT '   Prevent high-value customer churn';
PRINT '   Win-back campaigns for dormant premium members';
PRINT '   Estimate revenue at risk from inactive accounts';
PRINT '';
GO

-- ============================================================================
-- BUSINESS IMPACT SUMMARY
-- ============================================================================

PRINT '';
PRINT '=============================================================';
PRINT 'THE WEDNESDAY AFTERNOON VICTORY';
PRINT '=============================================================';
PRINT '';
PRINT '10:00 AM: Loyalty Manager requests tier-close campaign list';
PRINT '11:00 AM: CTEs written and tested (5-step breakdown)';
PRINT '2:00 PM: Results delivered (with time for lunch!)';
PRINT '3:00 PM: Loyalty Manager approves campaign';
PRINT 'Campaign Launch: Next Monday';
PRINT '';
PRINT 'Business Results:';
PRINT '   ✓ 5 tier-close customers identified';
PRINT '   ✓ Personalized bonus offers: 10-50 bonus points each';
PRINT '   ✓ Prevent defection to Virgin Australia';
PRINT '   ✓ Save $1,500/customer in lifetime value';
PRINT '   ✓ Campaign ready in <4 hours (vs 2 days manual)';
PRINT '';
PRINT 'Your Impact:';
PRINT '   ✓ 5 customers upgraded to next tier';
PRINT '   ✓ Revenue protected and enhanced';
PRINT '   ✓ Loyalty team: "This is exactly what we need!"';
PRINT '';
PRINT '=============================================================';
GO

-- ============================================================================
-- KEY LEARNING POINTS - ALL PDF CONCEPTS COVERED
-- ============================================================================

PRINT '';
PRINT '=============================================================';
PRINT 'WHAT YOU MASTERED IN 19 MINUTES (PDF PAGE 6)';
PRINT '=============================================================';
PRINT '';
PRINT 'Technical Skills:';
PRINT '  ✓ CTE syntax (WITH clause)';
PRINT '  ✓ Naming CTEs meaningfully';
PRINT '  ✓ Chaining multiple CTEs';
PRINT '  ✓ CTEs referencing earlier CTEs';
PRINT '  ✓ Replacing nested subqueries with CTEs';
PRINT '  ✓ Step-by-step business logic';
PRINT '  ✓ Debugging complex queries easily';
PRINT '  ✓ Enterprise-grade SQL patterns';
PRINT '  ✓ All 5 practice exercises completed';
PRINT '';
PRINT 'Business Skills:';
PRINT '  ✓ Tier qualification logic';
PRINT '  ✓ Customer segmentation';
PRINT '  ✓ Campaign targeting';
PRINT '  ✓ Priority scoring';
PRINT '  ✓ Personalized offers';
PRINT '  ✓ Churn prevention strategies';
PRINT '';
PRINT 'Career Skills:';
PRINT '  ✓ Writing readable enterprise SQL';
PRINT '  ✓ Collaborating with junior analysts';
PRINT '  ✓ Maintaining production queries';
PRINT '  ✓ Explaining complex logic simply';
PRINT '  ✓ Code review best practices';
PRINT '';
PRINT 'SQL Mastery Progression (PDF Page 6):';
PRINT '  Video 1: Basic SELECT, WHERE, JOIN';
PRINT '  Video 2: INNER vs LEFT JOIN';
PRINT '  Video 3: GROUP BY aggregations';
PRINT '  Video 4: Time intelligence (YoY, MoM)';
PRINT '  Video 5: Subqueries (outliers, per-group)';
PRINT '  Video 6: CTEs (readable complex SQL) ← YOU ARE HERE ✓';
PRINT '  Next: Window Functions (advanced analytics)';
PRINT '';
PRINT 'Why CTEs Matter in Enterprise (PDF Page 6):';
PRINT '  • Every major company uses CTEs in production';
PRINT '  • Data warehouse ETL processes = chained CTEs';
PRINT '  • Executive reports = multi-step CTE logic';
PRINT '  • Code reviews demand readable SQL = CTEs win';
PRINT '  • Junior analyst onboarding = CTEs teach faster';
PRINT '';
PRINT 'Interview Value:';
PRINT '  "How do you make complex SQL readable?" → CTEs!';
PRINT '  "Explain your query approach" → Show CTE breakdown';
PRINT '  "Debug this nested query" → Rewrite with CTEs';
PRINT '';
PRINT 'Real-World Applications:';
PRINT '  • Financial reporting: Multi-tier calculations';
PRINT '  • Sales analytics: Funnel stage breakdowns';
PRINT '  • Marketing: Campaign segment identification';
PRINT '  • Operations: Multi-step quality checks';
PRINT '  • Product: User journey analysis';
PRINT '';
PRINT '=============================================================';
PRINT '';
GO

-- ============================================================================
-- BEST PRACTICE REMINDERS
-- ============================================================================

PRINT '';
PRINT '=============================================================';
PRINT 'CTE BEST PRACTICES (PDF PAGE 6)';
PRINT '=============================================================';
PRINT '';
PRINT 'DO:';
PRINT '  ✓ Use CTEs to break logic into named steps';
PRINT '  ✓ Calculate once in CTE, reference by name';
PRINT '  ✓ Use CTEs as "chapters" in your query story';
PRINT '  ✓ Give CTEs meaningful names (member_summary, tier_close)';
PRINT '  ✓ Test each CTE individually during development';
PRINT '';
PRINT 'DON''T:';
PRINT '  ✗ Nest subqueries 3+ levels deep';
PRINT '  ✗ Repeat same calculation multiple times';
PRINT '  ✗ Write 200-line queries without structure';
PRINT '  ✗ Use vague CTE names (temp1, temp2)';
PRINT '  ✗ Forget commas between CTEs (syntax error!)';
PRINT '';
PRINT 'Remember:';
PRINT '  • WITH starts the CTE section';
PRINT '  • Each CTE: name AS (SELECT ...)';
PRINT '  • Separate CTEs with COMMAS';
PRINT '  • NO comma after the last CTE';
PRINT '  • Main query comes after all CTEs';
PRINT '';
PRINT '=============================================================';
PRINT '';
GO

PRINT '';
PRINT '=============================================================';
PRINT 'VIDEO 6 ENHANCED COMPLETE! ✓';
PRINT '=============================================================';
PRINT '';
PRINT 'Next Video Preview (PDF Page 6):';
PRINT '  Video 7: Window Functions - Advanced Analytics';
PRINT '  Scenario: Commonwealth Bank Customer Ranking';
PRINT '  Learn: ROW_NUMBER, RANK, DENSE_RANK, NTILE, running totals';
PRINT '  Duration: 20 minutes';
PRINT '  Why: CTEs + Window Functions = Advanced analyst superpowers!';
PRINT '';
PRINT 'Practice Challenge:';
PRINT '  • Complete all 5 exercises before Video 7';
PRINT '  • Try modifying tier thresholds (280-299 SC vs 250-299 SC)';
PRINT '  • Create your own CTE-based analysis';
PRINT '  • Real learning happens through practice!';
PRINT '';
PRINT 'You''re in the advanced tier now!';
PRINT 'Keep crushing it! 💪';
PRINT '';
PRINT '=============================================================';
GO



 SELECT 
    m.member_id,
    m.member_name,
    SUM(f.status_credits) AS total_sc,
    COUNT(*) AS total_flights
  FROM members m
  LEFT JOIN flights f ON m.member_id = f.member_id
  GROUP BY m.member_id, m.member_name;

  WITH member_stats AS (
  SELECT 
    m.member_id,
    m.member_name,
    SUM(f.status_credits) AS total_sc,
    COUNT(*) AS total_flights
  FROM members m
  LEFT JOIN flights f ON m.member_id = f.member_id
  GROUP BY m.member_id, m.member_name
)
SELECT *
FROM member_stats
WHERE total_sc > 500
ORDER BY total_sc DESC;




WITH
-- Step 1: Total status credits per member
status_credits AS (
  SELECT 
    member_id,
    SUM(status_credits) AS total_sc
  FROM flights
  GROUP BY member_id
),
-- Step 2: Count eligible flights per member
eligible_flights AS (
  SELECT 
    member_id,
    COUNT(*) AS eligible_count
  FROM flights
  WHERE eligible_flight = 1
  GROUP BY member_id
),
-- Step 3: Last flight date per member
last_flight AS (
  SELECT 
    member_id,
    MAX(flight_date) AS last_flight_date
  FROM flights
  GROUP BY member_id
)
-- Step 4: Combine everything
SELECT 
  m.member_name,
  sc.total_sc,
  ef.eligible_count,
  lf.last_flight_date
FROM members m
LEFT JOIN status_credits sc ON m.member_id = sc.member_id
LEFT JOIN eligible_flights ef ON m.member_id = ef.member_id
LEFT JOIN last_flight lf ON m.member_id = lf.member_id;


WITH
-- Step 1: Calculate total SC
member_sc AS (
    SELECT 
        member_id,
        SUM(status_credits) AS total_sc
    FROM flights
    GROUP BY member_id
),
-- Step 2: Use Step 1 to determine tier
tier_earned AS (
    SELECT 
        m.member_id,
        m.member_name,
        m.current_tier,
        ISNULL(sc.total_sc, 0) AS total_sc,
        CASE
            WHEN sc.total_sc >= 1400 THEN 'Platinum'
            WHEN sc.total_sc >= 700 THEN 'Gold'
            WHEN sc.total_sc >= 300 THEN 'Silver'
            ELSE 'Bronze'
        END AS earned_tier
    FROM members m
    LEFT JOIN member_sc sc ON m.member_id = sc.member_id
),
-- Step 3: Use Step 2 to find mismatches
tier_mismatches AS (
    SELECT 
        *,
        CASE
            WHEN current_tier <> earned_tier THEN 'MISMATCH'
            ELSE 'OK'
        END AS status
    FROM tier_earned
)
-- Final: Show only mismatches
SELECT *
FROM tier_mismatches
WHERE status = 'MISMATCH';


WITH
-- Step 1: Total status credits
member_status_credits AS (
    SELECT 
        member_id,
        SUM(status_credits) AS total_sc
    FROM flights
    GROUP BY member_id
),
-- Step 2: Eligible flight count
member_eligible_flights AS (
    SELECT 
        member_id,
        COUNT(*) AS eligible_flights
    FROM flights
    WHERE eligible_flight = 1
    GROUP BY member_id
),
-- Step 3: Most recent flight
member_last_flight AS (
    SELECT 
        member_id,
        MAX(flight_date) AS last_flight_date
    FROM flights
    GROUP BY member_id
),
-- Step 4: Combine all metrics
member_summary AS (
    SELECT 
        m.member_id,
        m.member_name,
        m.email,
        m.current_tier,
        ISNULL(sc.total_sc, 0) AS total_sc,
        ISNULL(ef.eligible_flights, 0) AS eligible_flights,
        lf.last_flight_date,
        CASE 
            WHEN lf.last_flight_date IS NOT NULL 
            THEN DATEDIFF(DAY, lf.last_flight_date, '2024-12-01')
            ELSE NULL
        END AS days_since_last
    FROM members m
    LEFT JOIN member_status_credits sc ON m.member_id = sc.member_id
    LEFT JOIN member_eligible_flights ef ON m.member_id = ef.member_id
    LEFT JOIN member_last_flight lf ON m.member_id = lf.member_id
),
-- Step 5: Identify tier-close customers
tier_close_customers AS (
    SELECT 
        *,
        CASE
            WHEN total_sc BETWEEN 250 AND 299 THEN 'Close to Silver'
            WHEN total_sc BETWEEN 650 AND 699 THEN 'Close to Gold'
            WHEN total_sc BETWEEN 1350 AND 1399 THEN 'Close to Platinum'
            ELSE NULL
        END AS tier_opportunity,
        CASE
            WHEN total_sc BETWEEN 250 AND 299 THEN 300 - total_sc
            WHEN total_sc BETWEEN 650 AND 699 THEN 700 - total_sc
            WHEN total_sc BETWEEN 1350 AND 1399 THEN 1400 - total_sc
            ELSE NULL
        END AS sc_needed,
        4 - eligible_flights AS flights_needed
    FROM member_summary
    WHERE (total_sc BETWEEN 250 AND 299
        OR total_sc BETWEEN 650 AND 699
        OR total_sc BETWEEN 1350 AND 1399)
)
-- Final: Filtered, prioritised list
SELECT 
    member_id,
    member_name,
    email,
    current_tier,
    tier_opportunity,
    total_sc,
    sc_needed,
    eligible_flights,
    flights_needed,
    days_since_last,
    CASE
        WHEN sc_needed <= 20 AND flights_needed = 1 THEN 'HIGH PRIORITY'
        WHEN sc_needed <= 50 AND flights_needed = 1 THEN 'MEDIUM PRIORITY'
        ELSE 'STANDARD'
    END AS campaign_priority,
    CONCAT('Offer ', sc_needed * 2, ' bonus points') AS offer
FROM tier_close_customers
WHERE eligible_flights >= 3
    AND days_since_last IS NOT NULL
    AND days_since_last <= 180
ORDER BY 
    CASE 
        WHEN sc_needed <= 20 AND flights_needed = 1 THEN 1
        WHEN sc_needed <= 50 AND flights_needed = 1 THEN 2
        ELSE 3
    END,
    sc_needed;
