/*********************************************************************************
VIDEO 7: WINDOW FUNCTIONS - ADVANCED ANALYTICS & RANKING
Commondealth Bank - Customer Ranking & Running Totals (FICTITIOUS ORGANIZATION)
Enterprise SQL for Australian Data Analysts
Duration: 20 minutes | Advanced
ENHANCED VERSION - All Window Functions Explained Practically

DISCLAIMER:
Commondealth Bank in this tutorial is a FICTITIOUS ORGANIZATION created for 
educational purposes only. This is NOT Commonwealth Bank of Australia. Any 
resemblance to actual banking institutions is coincidental. This is a training 
scenario designed to teach SQL window functions using realistic business contexts.

BUSINESS SCENARIO:
You're a senior analyst at Commondealth Bank (fictitious Australian bank).
Thursday morning 9:00 AM. The Retail Banking Director walks into your office:

"I need a customer performance dashboard for Monday's board meeting. Show me:
1. Top 10 customers by deposit balance (ranked)
2. What percentile is each customer in? (top 10%? bottom 25%?)
3. Running total of deposits by signup date (cumulative growth)
4. Year-over-year balance comparison per customer
5. Each customer's rank within their state"

THE PROBLEM:
These questions require COMPARING each row to OTHER rows:
- Rank 1, 2, 3... (compare to all other customers)
- Percentile calculation (where do they stand in the distribution?)
- Running total (sum of current + all previous rows)
- Previous year value (compare to same customer last year)
- Rank within group (compare only to customers in same state)

TRADITIONAL SQL CAN'T DO THIS EASILY:
You'd need complex self-joins, subqueries, or cursors (slow and ugly!)

THE SOLUTION: WINDOW FUNCTIONS
Perform calculations ACROSS A SET OF ROWS related to the current row
Think of it as: "Looking through a window at nearby rows"

WINDOW FUNCTION TYPES YOU'LL MASTER:
1. ROW_NUMBER() - Sequential numbering (1, 2, 3...)
2. RANK() - Ranking with gaps for ties (1, 2, 2, 4...)
3. DENSE_RANK() - Ranking without gaps (1, 2, 2, 3...)
4. NTILE(n) - Divide into n equal buckets (quartiles, percentiles)
5. LAG() & LEAD() - Access previous/next row values
6. SUM() OVER() - Running totals
7. AVG() OVER() - Moving averages
8. PARTITION BY - Group calculations (rank within state)

LEARNING OBJECTIVES:
✓ Understand window functions vs regular aggregates
✓ Master ROW_NUMBER, RANK, DENSE_RANK
✓ Use NTILE for percentile analysis
✓ Apply LAG/LEAD for period-over-period comparisons
✓ Calculate running totals with SUM() OVER()
✓ Use PARTITION BY for group-wise calculations
✓ Complete 5 practice exercises with solutions
*********************************************************************************/

-- ============================================================================
-- STEP 1: CREATE DATABASE AND TABLES
-- ============================================================================

-- First, switch to master to avoid "currently in use" errors
USE master;
GO

-- Drop database if exists (fresh start)
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'Commondealth_Bank')
BEGIN
    PRINT 'Dropping existing Commondealth_Bank database...';
    ALTER DATABASE Commondealth_Bank SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Commondealth_Bank;
    PRINT '✅ Existing database dropped successfully';
END
GO

-- Create fresh database
CREATE DATABASE Commondealth_Bank;
GO

USE Commondealth_Bank;
GO

PRINT '=== Database Created: Commondealth_Bank (Fictitious Organization) ===';
GO

-- ============================================================================
-- STEP 2: CREATE TABLES
-- ============================================================================

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name NVARCHAR(100),
    state NVARCHAR(10),
    city NVARCHAR(50),
    account_type NVARCHAR(30),
    signup_date DATE,
    current_balance DECIMAL(15,2),
    balance_2023 DECIMAL(15,2),  -- For YoY comparison
    balance_2024 DECIMAL(15,2)
);

PRINT '=== Table Created: customers ===';
GO

-- ============================================================================
-- STEP 3: INSERT REALISTIC SAMPLE DATA
-- ============================================================================

PRINT '';
PRINT '=== Generating Commondealth Bank Customer Data ===';
PRINT 'Fictitious customers with various deposit balances';
PRINT '';

INSERT INTO customers VALUES
-- High-value NSW customers
(1001, 'Sarah Mitchell', 'NSW', 'Sydney', 'Premium Savings', '2022-01-15', 485000.00, 420000.00, 485000.00),
(1002, 'James Chen', 'NSW', 'Sydney', 'Investment Account', '2021-06-20', 750000.00, 680000.00, 750000.00),
(1003, 'Emma Thompson', 'NSW', 'Newcastle', 'Premium Savings', '2023-03-10', 125000.00, 0.00, 125000.00),
(1004, 'Liam O''Connor', 'NSW', 'Wollongong', 'Standard Savings', '2022-08-15', 68000.00, 55000.00, 68000.00),
(1005, 'Olivia Patel', 'NSW', 'Parramatta', 'Premium Savings', '2021-11-20', 320000.00, 280000.00, 320000.00),

-- High-value VIC customers
(1006, 'William Zhang', 'VIC', 'Melbourne', 'Investment Account', '2020-05-10', 890000.00, 820000.00, 890000.00),
(1007, 'Ava Nguyen', 'VIC', 'Melbourne', 'Premium Savings', '2022-02-28', 425000.00, 360000.00, 425000.00),
(1008, 'Noah Williams', 'VIC', 'Geelong', 'Standard Savings', '2023-07-15', 95000.00, 0.00, 95000.00),
(1009, 'Isabella Brown', 'VIC', 'Carlton', 'Premium Savings', '2021-09-05', 510000.00, 470000.00, 510000.00),
(1010, 'Mason Taylor', 'VIC', 'Richmond', 'Investment Account', '2020-12-12', 670000.00, 610000.00, 670000.00),

-- QLD customers (mix of high and mid-value)
(1011, 'Sophia Anderson', 'QLD', 'Brisbane', 'Premium Savings', '2022-04-20', 380000.00, 330000.00, 380000.00),
(1012, 'Lucas Martin', 'QLD', 'Gold Coast', 'Standard Savings', '2023-05-18', 82000.00, 0.00, 82000.00),
(1013, 'Charlotte Garcia', 'QLD', 'Cairns', 'Premium Savings', '2021-10-10', 240000.00, 215000.00, 240000.00),
(1014, 'Ethan Rodriguez', 'QLD', 'Townsville', 'Standard Savings', '2022-11-25', 105000.00, 88000.00, 105000.00),
(1015, 'Amelia Lee', 'QLD', 'Brisbane', 'Investment Account', '2020-08-15', 625000.00, 570000.00, 625000.00),

-- WA and SA customers
(1016, 'Benjamin Kim', 'WA', 'Perth', 'Premium Savings', '2021-03-12', 355000.00, 310000.00, 355000.00),
(1017, 'Harper Singh', 'WA', 'Fremantle', 'Investment Account', '2022-07-08', 540000.00, 490000.00, 540000.00),
(1018, 'Evelyn Tran', 'SA', 'Adelaide', 'Premium Savings', '2023-01-20', 145000.00, 0.00, 145000.00),
(1019, 'Alexander Liu', 'SA', 'Adelaide', 'Standard Savings', '2022-09-14', 78000.00, 62000.00, 78000.00),
(1020, 'Mia Johnson', 'SA', 'Adelaide', 'Premium Savings', '2021-12-05', 290000.00, 255000.00, 290000.00),

-- Additional customers with IDENTICAL balances to create TIES (demonstrates RANK vs DENSE_RANK)
(1021, 'Daniel Cooper', 'NSW', 'Sydney', 'Premium Savings', '2022-03-18', 320000.00, 280000.00, 320000.00),  -- TIE with Olivia
(1022, 'Sophie Taylor', 'VIC', 'Melbourne', 'Premium Savings', '2022-05-22', 380000.00, 330000.00, 380000.00),  -- TIE with Sophia
(1023, 'Ryan Martinez', 'QLD', 'Brisbane', 'Premium Savings', '2022-06-30', 290000.00, 255000.00, 290000.00),  -- TIE with Mia
(1024, 'Grace Wilson', 'NSW', 'Newcastle', 'Premium Savings', '2022-08-11', 485000.00, 420000.00, 485000.00),  -- TIE with Sarah
(1025, 'Oscar Brown', 'VIC', 'Geelong', 'Premium Savings', '2022-09-25', 240000.00, 215000.00, 240000.00);  -- TIE with Charlotte

PRINT '✅ 25 customers inserted across NSW, VIC, QLD, WA, SA';
PRINT '   Balance range: $68K - $890K';
PRINT '   Account types: Standard, Premium, Investment';
PRINT '   ** IMPORTANT: 5 customers with IDENTICAL balances to demonstrate RANK vs DENSE_RANK **';
PRINT '   Ties: $485K (2 customers), $380K (2), $320K (2), $290K (2), $240K (2)';
PRINT '';
GO

-- ============================================================================
-- VALIDATION: Check row counts and summary statistics
-- ============================================================================
SELECT 
    COUNT(*) AS total_customers,
    MIN(current_balance) AS min_balance,
    MAX(current_balance) AS max_balance,
    ROUND(AVG(current_balance), 2) AS avg_balance,
    SUM(current_balance) / 1000000 AS total_deposits_millions
FROM customers;
GO

PRINT '';
PRINT '=============================================================';
PRINT 'THE THURSDAY MORNING CHALLENGE';
PRINT '=============================================================';
PRINT '9:00 AM Thursday - Director''s Request:';
PRINT '"I need a customer performance dashboard for Monday"';
PRINT '';
PRINT 'Requirements:';
PRINT '  • Top 10 customers ranked by balance';
PRINT '  • Customer percentiles (top 10%? bottom 25%?)';
PRINT '  • Running total of deposits over time';
PRINT '  • Year-over-year balance comparison';
PRINT '  • State-wise customer rankings';
PRINT '';
PRINT 'The Challenge:';
PRINT '  Regular SQL aggregates (SUM, AVG, COUNT) collapse rows';
PRINT '  These questions need EACH ROW compared to OTHER ROWS';
PRINT '  Window functions solve this!';
PRINT '';
PRINT '  Example: Rank customers 1, 2, 3... by balance';
PRINT '  Regular RANK would be a mess of subqueries';
PRINT '  Window function: ROW_NUMBER() OVER (ORDER BY balance DESC)';
PRINT '=============================================================';
PRINT '';
GO

-- ============================================================================
-- CONCEPT 1: WINDOW FUNCTIONS VS REGULAR AGGREGATES
-- ============================================================================

PRINT '';
PRINT '=== CONCEPT 1: WINDOW FUNCTIONS VS REGULAR AGGREGATES ===';
PRINT 'Understanding the fundamental difference';
PRINT '';

-- Regular aggregate (collapses rows)
PRINT '--- Regular Aggregate (Collapses ALL rows to ONE) ---';
SELECT 
    AVG(current_balance) AS average_balance,
    COUNT(*) AS total_customers,
    SUM(current_balance) AS total_deposits
FROM customers;

PRINT '';
PRINT 'Result: ONE row with overall statistics';
PRINT '';

-- Window function (keeps all rows, adds calculation)
PRINT '--- Window Function (Keeps ALL rows, adds column) ---';
SELECT 
    customer_name,
    state,
    current_balance,
    AVG(current_balance) OVER () AS average_balance,
    ROUND(current_balance - AVG(current_balance) OVER (), 2) AS difference_from_avg,
    CASE 
        WHEN current_balance > AVG(current_balance) OVER () THEN 'Above Average'
        ELSE 'Below Average'
    END AS performance
FROM customers
ORDER BY current_balance DESC;

PRINT '';
PRINT '✅ Window Function Advantage:';
PRINT '   • Each row keeps its identity (customer name, balance)';
PRINT '   • AVG() OVER () adds average as a NEW COLUMN';
PRINT '   • Can now compare each customer to the average';
PRINT '   • 20 rows in → 20 rows out (not collapsed!)';
PRINT '';
PRINT '💡 The OVER() Clause:';
PRINT '   This is what makes it a "window" function';
PRINT '   Defines the "window" of rows to calculate over';
PRINT '   Empty OVER() = all rows in the result set';
PRINT '';
GO

-- ============================================================================
-- CONCEPT 2: ROW_NUMBER() - SEQUENTIAL RANKING
-- ============================================================================

PRINT '';
PRINT '=== CONCEPT 2: ROW_NUMBER() - SEQUENTIAL NUMBERING ===';
PRINT 'Assign sequential numbers: 1, 2, 3, 4, 5...';
PRINT 'Even if there are ties, each row gets unique number';
PRINT '';

SELECT 
    ROW_NUMBER() OVER (ORDER BY current_balance DESC) AS customer_rank,
    customer_name,
    state,
    city,
    account_type,
    current_balance,
    CASE 
        WHEN ROW_NUMBER() OVER (ORDER BY current_balance DESC) <= 5 THEN 'VIP Customer'
        WHEN ROW_NUMBER() OVER (ORDER BY current_balance DESC) <= 10 THEN 'Premium Customer'
        ELSE 'Standard Customer'
    END AS customer_tier
FROM customers
ORDER BY customer_rank;

PRINT '';
PRINT '✅ ROW_NUMBER() Syntax:';
PRINT '   ROW_NUMBER() OVER (ORDER BY column DESC)';
PRINT '   • Orders by balance (high to low)';
PRINT '   • Assigns 1, 2, 3... in that order';
PRINT '   • Always unique (no duplicates)';
PRINT '';
PRINT '💡 Use Cases:';
PRINT '   • "Show me the top 10 customers"';
PRINT '   • "Who is customer #5 by balance?"';
PRINT '   • Pagination (rows 1-10, 11-20, etc.)';
PRINT '';
GO

-- ============================================================================
-- CONCEPT 3: RANK() vs DENSE_RANK()
-- ============================================================================

PRINT '';
PRINT '=== CONCEPT 3: RANK() vs DENSE_RANK() ===';
PRINT 'What happens when values are TIED?';
PRINT 'Creating realistic ties to show the difference clearly';
PRINT '';

-- First, show the actual balances to demonstrate ties
PRINT '--- Step 1: Create ties by rounding to nearest $50K ---';
WITH balance_rounded AS (
    SELECT 
        customer_name,
        state,
        current_balance,
        ROUND(current_balance / 50000, 0) * 50000 AS balance_50k  -- Round to nearest 50K to create ties
    FROM customers
)
SELECT 
    customer_name,
    state,
    current_balance AS actual_balance,
    balance_50k AS rounded_balance
FROM balance_rounded
ORDER BY balance_50k DESC, current_balance DESC;

PRINT '';
PRINT '--- Step 2: Apply all three ranking functions ---';
WITH balance_rounded AS (
    SELECT 
        customer_name,
        state,
        current_balance,
        ROUND(current_balance / 50000, 0) * 50000 AS balance_50k
    FROM customers
)
SELECT 
    ROW_NUMBER() OVER (ORDER BY balance_50k DESC) AS row_number,
    RANK() OVER (ORDER BY balance_50k DESC) AS rank_with_gaps,
    DENSE_RANK() OVER (ORDER BY balance_50k DESC) AS dense_rank_no_gaps,
    customer_name,
    state,
    balance_50k AS rounded_to_50k,
    current_balance AS actual_balance
FROM balance_rounded
ORDER BY balance_50k DESC, current_balance DESC;

PRINT '';
PRINT '✅ Understanding the Differences with TIES:';
PRINT '';
PRINT '   Example with ties at $900K (William), $750K (James), and $500K (Isabella + Ava):';
PRINT '';
PRINT '   Balance    | ROW_NUMBER | RANK()     | DENSE_RANK()';
PRINT '   --------   | ---------- | ---------- | ------------';
PRINT '   $900K      | 1          | 1          | 1';
PRINT '   $750K      | 2          | 2          | 2';
PRINT '   $700K      | 3          | 3          | 3';
PRINT '   $650K      | 4          | 4          | 4';
PRINT '   $550K      | 5          | 5          | 5';
PRINT '   $500K (1)  | 6          | 6          | 6  ← First person at $500K';
PRINT '   $500K (2)  | 7          | 6 (TIE!)   | 6  ← Second person at $500K (TIED)';
PRINT '   $500K (3)  | 8          | 6 (TIE!)   | 6  ← Third person at $500K (TIED)';
PRINT '   $450K      | 9          | 9 ← GAP!   | 7  ← NO GAP';
PRINT '   $400K      | 10         | 10         | 8';
PRINT '';
PRINT '   Notice: RANK() skips to 9 (gap of 3 because 3 people tied)';
PRINT '           DENSE_RANK() continues to 7 (no gap, continuous)';
PRINT '';
PRINT '💡 When to Use Each:';
PRINT '   • ROW_NUMBER() - Pagination, need exactly N rows, ties broken arbitrarily';
PRINT '   • RANK() - Olympic medals (1st, 2nd, 2nd, 4th place - notice skip to 4th!)';
PRINT '   • DENSE_RANK() - Product tiers (Tier 1, Tier 2, Tier 3 - no skipping)';
PRINT '';
PRINT 'Real Business Example:';
PRINT '   Sales Competition:';
PRINT '     - Top 3 get bonus (use RANK - if 3 people tie for 2nd, all get bonus)';
PRINT '   Customer Segmentation:';
PRINT '     - Group into 5 tiers (use DENSE_RANK - want continuous tiers 1-5)';
PRINT '';
GO

-- ============================================================================
-- CONCEPT 4: NTILE() - PERCENTILE BUCKETS
-- ============================================================================

PRINT '';
PRINT '=== CONCEPT 4: NTILE() - DIVIDE INTO EQUAL BUCKETS ===';
PRINT 'NTILE(4) = quartiles, NTILE(10) = deciles, NTILE(100) = percentiles';
PRINT '';

SELECT 
    customer_name,
    state,
    current_balance,
    NTILE(4) OVER (ORDER BY current_balance DESC) AS quartile,
    NTILE(10) OVER (ORDER BY current_balance DESC) AS decile,
    CASE 
        WHEN NTILE(4) OVER (ORDER BY current_balance DESC) = 1 THEN 'Top 25% (VIP)'
        WHEN NTILE(4) OVER (ORDER BY current_balance DESC) = 2 THEN '25-50% (Premium)'
        WHEN NTILE(4) OVER (ORDER BY current_balance DESC) = 3 THEN '50-75% (Standard)'
        ELSE 'Bottom 25% (Basic)'
    END AS customer_segment,
    CASE 
        WHEN NTILE(10) OVER (ORDER BY current_balance DESC) = 1 THEN 'Top 10%'
        WHEN NTILE(10) OVER (ORDER BY current_balance DESC) <= 3 THEN 'Top 30%'
        WHEN NTILE(10) OVER (ORDER BY current_balance DESC) <= 5 THEN 'Top 50%'
        ELSE 'Bottom 50%'
    END AS percentile_group
FROM customers
ORDER BY current_balance DESC;

PRINT '';
PRINT '✅ NTILE() Syntax:';
PRINT '   NTILE(n) OVER (ORDER BY balance DESC)';
PRINT '   • Divides customers into n equal groups';
PRINT '   • Group 1 = top portion, Group n = bottom portion';
PRINT '';
PRINT '💡 Business Applications:';
PRINT '   • NTILE(4) - Quartile analysis (VIP, Premium, Standard, Basic)';
PRINT '   • NTILE(10) - Decile analysis (top 10%, top 20%...)';
PRINT '   • NTILE(100) - Percentile analysis (top 1%, top 5%...)';
PRINT '   • Customer segmentation for marketing campaigns';
PRINT '';
GO

-- ============================================================================
-- CONCEPT 5: LAG() and LEAD() - ACCESSING ADJACENT ROWS
-- ============================================================================

PRINT '';
PRINT '=== CONCEPT 5: LAG() and LEAD() - PREVIOUS/NEXT ROW ===';
PRINT 'LAG() = Look at PREVIOUS row, LEAD() = Look at NEXT row';
PRINT '';

SELECT 
    customer_name,
    signup_date,
    current_balance,
    LAG(customer_name) OVER (ORDER BY signup_date) AS previous_customer,
    LAG(current_balance) OVER (ORDER BY signup_date) AS previous_balance,
    LEAD(customer_name) OVER (ORDER BY signup_date) AS next_customer,
    ROUND(current_balance - LAG(current_balance) OVER (ORDER BY signup_date), 2) AS balance_diff_from_prev,
    DATEDIFF(DAY, LAG(signup_date) OVER (ORDER BY signup_date), signup_date) AS days_since_prev_signup
FROM customers
ORDER BY signup_date;

PRINT '';
PRINT '✅ LAG() and LEAD() Syntax:';
PRINT '   LAG(column, offset) OVER (ORDER BY date)';
PRINT '   • Gets value from previous row (offset = 1 by default)';
PRINT '   LEAD(column, offset) OVER (ORDER BY date)';
PRINT '   • Gets value from next row (offset = 1 by default)';
PRINT '';
PRINT '💡 Use Cases:';
PRINT '   • Period-over-period comparisons (this month vs last month)';
PRINT '   • Sequential pattern detection';
PRINT '   • Calculating differences between consecutive rows';
PRINT '   • Time gap analysis (days between events)';
PRINT '';
GO

-- ============================================================================
-- CONCEPT 6: YEAR-OVER-YEAR COMPARISON
-- ============================================================================

PRINT '';
PRINT '=== CONCEPT 6: YEAR-OVER-YEAR BALANCE COMPARISON ===';
PRINT 'Compare 2024 balance to 2023 balance for growth analysis';
PRINT '';

SELECT 
    customer_name,
    state,
    account_type,
    balance_2023,
    balance_2024 AS current_balance,
    balance_2024 - balance_2023 AS yoy_growth_amount,
    CASE 
        WHEN balance_2023 > 0 
        THEN ROUND(((balance_2024 - balance_2023) / balance_2023) * 100, 1)
        ELSE NULL
    END AS yoy_growth_percent,
    CASE 
        WHEN balance_2024 - balance_2023 > 50000 THEN 'High Growth'
        WHEN balance_2024 - balance_2023 > 20000 THEN 'Moderate Growth'
        WHEN balance_2024 - balance_2023 > 0 THEN 'Slight Growth'
        WHEN balance_2024 = balance_2023 THEN 'No Change'
        ELSE 'Decline'
    END AS growth_category
FROM customers
WHERE balance_2023 > 0  -- Only customers who existed in 2023
ORDER BY yoy_growth_percent DESC;

PRINT '';
PRINT '✅ YoY Analysis Insights:';
PRINT '   • Identifies customers growing their deposits';
PRINT '   • Flags high-value growth customers for rewards';
PRINT '   • Spots declining balances for retention campaigns';
PRINT '';
PRINT '💡 Business Decisions:';
PRINT '   • High Growth (>$50K) → Offer premium investment products';
PRINT '   • Moderate Growth → Maintain current relationship';
PRINT '   • Decline → Investigate why, retention campaign';
PRINT '';
GO

-- ============================================================================
-- CONCEPT 7: RUNNING TOTALS WITH SUM() OVER()
-- ============================================================================

PRINT '';
PRINT '=== CONCEPT 7: RUNNING TOTALS (CUMULATIVE SUM) ===';
PRINT 'Sum of current row + all previous rows';
PRINT 'Shows cumulative deposit growth as customers signed up';
PRINT '';

SELECT 
    customer_name,
    signup_date,
    current_balance,
    SUM(current_balance) OVER (ORDER BY signup_date) AS running_total,
    ROUND(SUM(current_balance) OVER (ORDER BY signup_date) / 1000000, 2) AS running_total_millions,
    ROUND((SUM(current_balance) OVER (ORDER BY signup_date) / 
           (SELECT SUM(current_balance) FROM customers)) * 100, 1) AS percent_of_total
FROM customers
ORDER BY signup_date;

PRINT '';
PRINT '✅ Running Total Syntax:';
PRINT '   SUM(column) OVER (ORDER BY date)';
PRINT '   • Calculates cumulative sum as you move down rows';
PRINT '   • Each row = current value + all previous values';
PRINT '';
PRINT '💡 Business Applications:';
PRINT '   • Cumulative revenue by month';
PRINT '   • Customer acquisition growth over time';
PRINT '   • Year-to-date (YTD) calculations';
PRINT '   • Milestone tracking (when did we hit $5M?)';
PRINT '';
GO

-- ============================================================================
-- CONCEPT 8: PARTITION BY - GROUP-WISE CALCULATIONS
-- ============================================================================

PRINT '';
PRINT '=== CONCEPT 8: PARTITION BY - RANK WITHIN GROUPS ===';
PRINT 'Calculate rankings SEPARATELY for each state';
PRINT '';

SELECT 
    state,
    customer_name,
    current_balance,
    -- Overall rank (across all states)
    ROW_NUMBER() OVER (ORDER BY current_balance DESC) AS overall_rank,
    -- Rank within state only
    ROW_NUMBER() OVER (PARTITION BY state ORDER BY current_balance DESC) AS rank_in_state,
    -- State statistics
    COUNT(*) OVER (PARTITION BY state) AS customers_in_state,
    ROUND(AVG(current_balance) OVER (PARTITION BY state), 2) AS state_avg_balance,
    -- Comparison to state average
    ROUND(current_balance - AVG(current_balance) OVER (PARTITION BY state), 2) AS diff_from_state_avg
FROM customers
ORDER BY state, rank_in_state;

PRINT '';
PRINT '✅ PARTITION BY Syntax:';
PRINT '   ROW_NUMBER() OVER (PARTITION BY state ORDER BY balance DESC)';
PRINT '   • PARTITION BY state = Restart ranking for each state';
PRINT '   • Like GROUP BY, but doesn''t collapse rows';
PRINT '';
PRINT '💡 Use Cases:';
PRINT '   • Top N per category (top 3 customers per state)';
PRINT '   • Group-wise statistics (average per department)';
PRINT '   • Regional comparisons (sales rep vs regional average)';
PRINT '';
GO

-- ============================================================================
-- CONCEPT 9: PRODUCTION DASHBOARD QUERY
-- ============================================================================

PRINT '';
PRINT '=== CONCEPT 9: COMPLETE EXECUTIVE DASHBOARD ===';
PRINT 'All window functions combined in one production query';
PRINT '';

WITH customer_analytics AS (
    SELECT 
        customer_id,
        customer_name,
        state,
        account_type,
        signup_date,
        current_balance,
        balance_2023,
        balance_2024,
        
        -- Rankings
        ROW_NUMBER() OVER (ORDER BY current_balance DESC) AS overall_rank,
        RANK() OVER (ORDER BY current_balance DESC) AS rank_with_ties,
        ROW_NUMBER() OVER (PARTITION BY state ORDER BY current_balance DESC) AS state_rank,
        
        -- Percentiles
        NTILE(4) OVER (ORDER BY current_balance DESC) AS quartile,
        NTILE(10) OVER (ORDER BY current_balance DESC) AS decile,
        
        -- Growth metrics
        balance_2024 - balance_2023 AS yoy_growth,
        CASE 
            WHEN balance_2023 > 0 
            THEN ROUND(((balance_2024 - balance_2023) / balance_2023) * 100, 1)
            ELSE NULL
        END AS yoy_growth_percent,
        
        -- Running total
        SUM(current_balance) OVER (ORDER BY signup_date) AS running_total,
        
        -- State statistics
        AVG(current_balance) OVER (PARTITION BY state) AS state_avg_balance,
        COUNT(*) OVER (PARTITION BY state) AS state_customer_count
        
    FROM customers
)
SELECT 
    overall_rank,
    customer_name,
    state,
    account_type,
    current_balance,
    state_rank,
    CASE 
        WHEN quartile = 1 THEN 'Top 25% (VIP)'
        WHEN quartile = 2 THEN '25-50% (Premium)'
        WHEN quartile = 3 THEN '50-75% (Standard)'
        ELSE 'Bottom 25% (Basic)'
    END AS customer_segment,
    yoy_growth_percent,
    ROUND(running_total / 1000000, 2) AS cumulative_deposits_millions,
    ROUND(state_avg_balance, 2) AS state_avg
FROM customer_analytics
ORDER BY overall_rank;

PRINT '';
PRINT '✅ Production Dashboard Delivers:';
PRINT '   • Overall rankings (1-20)';
PRINT '   • State-wise rankings (top customer per state)';
PRINT '   • Customer segmentation (VIP, Premium, Standard, Basic)';
PRINT '   • Year-over-year growth percentages';
PRINT '   • Cumulative deposit growth over time';
PRINT '';
GO

-- ============================================================================
-- PRACTICE EXERCISE 1: TOP 5 CUSTOMERS PER STATE
-- ============================================================================

PRINT '';
PRINT '=============================================================';
PRINT 'PRACTICE EXERCISES';
PRINT '=============================================================';
PRINT '';
PRINT '=== EXERCISE 1: TOP 5 CUSTOMERS PER STATE (Intermediate) ===';
PRINT 'Use ROW_NUMBER() with PARTITION BY to find top 5 in each state';
PRINT '';

-- SOLUTION:
WITH ranked_customers AS (
    SELECT 
        state,
        customer_name,
        current_balance,
        ROW_NUMBER() OVER (PARTITION BY state ORDER BY current_balance DESC) AS rank_in_state
    FROM customers
)
SELECT 
    state,
    rank_in_state,
    customer_name,
    current_balance
FROM ranked_customers
WHERE rank_in_state <= 5
ORDER BY state, rank_in_state;

PRINT '';
PRINT '✅ SOLUTION EXPLAINED:';
PRINT '   • CTE ranks customers within each state';
PRINT '   • PARTITION BY state restarts ranking per state';
PRINT '   • WHERE rank <= 5 filters to top 5';
PRINT '';
PRINT 'Business Use Case:';
PRINT '   Regional VIP programs (reward top 5 per state)';
PRINT '   State manager KPIs (track top performers)';
PRINT '';
GO

-- ============================================================================
-- PRACTICE EXERCISE 2: MONTH-OVER-MONTH SIGNUP GROWTH
-- ============================================================================

PRINT '';
PRINT '=== EXERCISE 2: MONTH-OVER-MONTH SIGNUP ANALYSIS (Advanced) ===';
PRINT 'Use LAG() to compare signups month-over-month';
PRINT '';

-- SOLUTION:
WITH monthly_signups AS (
    SELECT 
        YEAR(signup_date) AS signup_year,
        MONTH(signup_date) AS signup_month,
        DATENAME(MONTH, signup_date) AS month_name,
        COUNT(*) AS new_customers,
        SUM(current_balance) AS total_deposits
    FROM customers
    GROUP BY YEAR(signup_date), MONTH(signup_date), DATENAME(MONTH, signup_date)
)
SELECT 
    signup_year,
    signup_month,
    month_name,
    new_customers,
    LAG(new_customers) OVER (ORDER BY signup_year, signup_month) AS prev_month_customers,
    new_customers - LAG(new_customers) OVER (ORDER BY signup_year, signup_month) AS mom_change,
    ROUND(total_deposits / 1000000, 2) AS deposits_millions
FROM monthly_signups
ORDER BY signup_year, signup_month;

PRINT '';
PRINT '✅ SOLUTION EXPLAINED:';
PRINT '   • Step 1: Aggregate signups by month';
PRINT '   • Step 2: LAG() gets previous month''s count';
PRINT '   • Step 3: Calculate month-over-month change';
PRINT '';
PRINT 'Business Use Case:';
PRINT '   Track customer acquisition trends';
PRINT '   Identify seasonality in signups';
PRINT '   Measure marketing campaign effectiveness';
PRINT '';
GO

-- ============================================================================
-- PRACTICE EXERCISE 3: MOVING AVERAGE
-- ============================================================================

PRINT '';
PRINT '=== EXERCISE 3: 3-CUSTOMER MOVING AVERAGE (Advanced) ===';
PRINT 'Calculate average of current + 2 previous customers';
PRINT '';

-- SOLUTION:
SELECT 
    customer_name,
    signup_date,
    current_balance,
    ROUND(AVG(current_balance) OVER (
        ORDER BY signup_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS moving_avg_3_customers,
    ROUND(current_balance - AVG(current_balance) OVER (
        ORDER BY signup_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS diff_from_moving_avg
FROM customers
ORDER BY signup_date;

PRINT '';
PRINT '✅ SOLUTION EXPLAINED:';
PRINT '   • ROWS BETWEEN 2 PRECEDING AND CURRENT ROW';
PRINT '   • Creates a 3-row "sliding window"';
PRINT '   • Calculates average of those 3 rows';
PRINT '';
PRINT 'Business Use Case:';
PRINT '   Smooth out volatility in metrics';
PRINT '   Trend detection (is average balance increasing?)';
PRINT '   Forecasting based on recent patterns';
PRINT '';
GO

-- ============================================================================
-- PRACTICE EXERCISE 4: PERCENTILE RANK
-- ============================================================================

PRINT '';
PRINT '=== EXERCISE 4: PERCENTILE RANK CALCULATION (Intermediate) ===';
PRINT 'Use PERCENT_RANK() to show exact percentile position';
PRINT '';

-- SOLUTION:
SELECT 
    customer_name,
    current_balance,
    ROUND(PERCENT_RANK() OVER (ORDER BY current_balance) * 100, 1) AS percentile_rank,
    CASE 
        WHEN PERCENT_RANK() OVER (ORDER BY current_balance) >= 0.90 THEN 'Top 10%'
        WHEN PERCENT_RANK() OVER (ORDER BY current_balance) >= 0.75 THEN 'Top 25%'
        WHEN PERCENT_RANK() OVER (ORDER BY current_balance) >= 0.50 THEN 'Top 50%'
        ELSE 'Bottom 50%'
    END AS percentile_group
FROM customers
ORDER BY current_balance DESC;

PRINT '';
PRINT '✅ SOLUTION EXPLAINED:';
PRINT '   • PERCENT_RANK() calculates relative position (0 to 1)';
PRINT '   • Multiply by 100 for percentage (0% to 100%)';
PRINT '   • 90th percentile = better than 90% of customers';
PRINT '';
PRINT 'Business Use Case:';
PRINT '   Precise customer positioning';
PRINT '   Qualification thresholds (must be top 15%)';
PRINT '   Performance benchmarking';
PRINT '';
GO

-- ============================================================================
-- PRACTICE EXERCISE 5: FIRST AND LAST VALUES
-- ============================================================================

PRINT '';
PRINT '=== EXERCISE 5: FIRST AND LAST CUSTOMER PER STATE (Advanced) ===';
PRINT 'Use FIRST_VALUE() and LAST_VALUE() to find earliest/latest signups';
PRINT '';

-- SOLUTION:
SELECT DISTINCT
    state,
    FIRST_VALUE(customer_name) OVER (
        PARTITION BY state ORDER BY signup_date
    ) AS first_customer,
    FIRST_VALUE(signup_date) OVER (
        PARTITION BY state ORDER BY signup_date
    ) AS first_signup_date,
    LAST_VALUE(customer_name) OVER (
        PARTITION BY state ORDER BY signup_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_customer,
    LAST_VALUE(signup_date) OVER (
        PARTITION BY state ORDER BY signup_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_signup_date
FROM customers
ORDER BY state;

PRINT '';
PRINT '✅ SOLUTION EXPLAINED:';
PRINT '   • FIRST_VALUE() gets earliest signup in each state';
PRINT '   • LAST_VALUE() needs ROWS BETWEEN UNBOUNDED... to work correctly';
PRINT '   • DISTINCT removes duplicate rows';
PRINT '';
PRINT 'Business Use Case:';
PRINT '   Track customer acquisition timeline per region';
PRINT '   Identify longest-standing customers (loyalty rewards)';
PRINT '   Market penetration analysis';
PRINT '';
GO

-- ============================================================================
-- BUSINESS IMPACT SUMMARY
-- ============================================================================

PRINT '';
PRINT '=============================================================';
PRINT 'THE THURSDAY AFTERNOON VICTORY';
PRINT '=============================================================';
PRINT '';
PRINT '9:00 AM: Director requests performance dashboard';
PRINT '10:00 AM: Window functions queries written and tested';
PRINT '2:00 PM: Complete dashboard delivered';
PRINT 'Friday: Board meeting presentation ready';
PRINT '';
PRINT 'Dashboard Delivers:';
PRINT '   ✓ Top 10 customers ranked ($890K to $425K)';
PRINT '   ✓ Percentile analysis (VIP = top 25%)';
PRINT '   ✓ Running totals show $7.2M cumulative deposits';
PRINT '   ✓ YoY growth: Top performer +23.6% balance growth';
PRINT '   ✓ State rankings: #1 customer identified per state';
PRINT '';
PRINT 'Business Impact:';
PRINT '   ✓ VIP program targeting (top 25% = 5 customers)';
PRINT '   ✓ Growth customers identified for upsell opportunities';
PRINT '   ✓ Regional performance benchmarks established';
PRINT '   ✓ Executive decision-making enabled';
PRINT '';
PRINT '=============================================================';
GO

-- ============================================================================
-- KEY LEARNING POINTS
-- ============================================================================

PRINT '';
PRINT '=============================================================';
PRINT 'WINDOW FUNCTIONS MASTERED';
PRINT '=============================================================';
PRINT '';
PRINT 'Technical Skills:';
PRINT '  ✓ ROW_NUMBER() - Sequential numbering';
PRINT '  ✓ RANK() / DENSE_RANK() - Handling ties';
PRINT '  ✓ NTILE() - Percentile buckets';
PRINT '  ✓ LAG() / LEAD() - Previous/next row access';
PRINT '  ✓ SUM() OVER() - Running totals';
PRINT '  ✓ AVG() OVER() - Moving averages';
PRINT '  ✓ PARTITION BY - Group-wise calculations';
PRINT '  ✓ FIRST_VALUE() / LAST_VALUE() - Edge values';
PRINT '  ✓ PERCENT_RANK() - Exact percentiles';
PRINT '';
PRINT 'Business Skills:';
PRINT '  ✓ Customer segmentation (VIP, Premium, Standard)';
PRINT '  ✓ Performance benchmarking (top 10%, quartiles)';
PRINT '  ✓ Trend analysis (YoY growth, running totals)';
PRINT '  ✓ Regional comparisons (rank within state)';
PRINT '  ✓ Time-series analysis (moving averages)';
PRINT '';
PRINT 'Real-World Applications:';
PRINT '  • Sales leaderboards (rank by revenue)';
PRINT '  • Financial reporting (running totals, YoY)';
PRINT '  • Customer analytics (segmentation, percentiles)';
PRINT '  • HR analytics (employee rankings, salary bands)';
PRINT '  • Product analytics (top N per category)';
PRINT '';
PRINT 'Career Value:';
PRINT '  Window functions = Advanced analyst skill';
PRINT '  Essential for data science and analytics roles';
PRINT '  Interview favorite: "Find top 3 per group"';
PRINT '  Production dashboards rely heavily on window functions';
PRINT '';
PRINT '=============================================================';
PRINT '';
GO

PRINT '';
PRINT '=============================================================';
PRINT 'VIDEO 7 COMPLETE! ✓';
PRINT '=============================================================';
PRINT '';
PRINT 'What You Accomplished:';
PRINT '  ✓ Mastered 9 different window functions';
PRINT '  ✓ Built production-grade executive dashboard';
PRINT '  ✓ Completed 5 practice exercises';
PRINT '  ✓ Advanced to senior analyst SQL skills';
PRINT '';
PRINT 'Next Steps:';
PRINT '  • Practice with your own datasets';
PRINT '  • Combine CTEs + Window Functions (powerful!)';
PRINT '  • Build dashboards for your organization';
PRINT '';
PRINT 'You now have advanced SQL analytics superpowers! 🚀';
PRINT '';
PRINT '=============================================================';
GO
