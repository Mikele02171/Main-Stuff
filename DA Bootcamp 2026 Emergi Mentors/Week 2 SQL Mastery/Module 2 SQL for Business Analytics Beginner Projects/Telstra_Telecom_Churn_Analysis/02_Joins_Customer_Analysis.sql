/*
================================================================================
VIDEO 2: JOINS - CONNECTING BUSINESS DATA
================================================================================
Business Context: TelstraTelco customer usage analysis - connecting customer info with usage data
Duration: 18 minutes
Learning: INNER JOIN, LEFT JOIN, table aliases, when to use each type

BUSINESS SCENARIO:
You're a data analyst at TelstraTelco .
Customer Success team needs to:
1. Match customer names with their data usage
2. Find customers with ZERO usage (churn risk!)
3. Analyze usage patterns by plan tier

The problem: Customer data and usage data are in SEPARATE tables.
Solution: JOINs

================================================================================
*/

USE AusRetail;
GO

PRINT '================================================================================';
PRINT 'VIDEO 2: JOINS - CONNECTING CUSTOMER DATA';
PRINT '================================================================================';
PRINT '';

-- ============================================================================
-- SETUP: Create sample Telstra-style tables for this demo
-- ============================================================================

PRINT 'Creating Telstra demo tables...';
PRINT '';

-- Telstra customers table
IF OBJECT_ID('telstra_customers', 'U') IS NOT NULL DROP TABLE telstra_customers; --Comment out if this tables exists. 
CREATE TABLE telstra_customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    plan_tier VARCHAR(20), -- Bronze, Silver, Gold
    monthly_fee DECIMAL(10,2),
    state VARCHAR(3),
    signup_date DATE
);

-- Telstra usage records table
IF OBJECT_ID('telstra_usage', 'U') IS NOT NULL DROP TABLE telstra_usage;
CREATE TABLE telstra_usage (
    usage_id INT PRIMARY KEY,
    customer_id INT,
    usage_month DATE,
    data_used_gb DECIMAL(10,2),
    calls_minutes INT,
    sms_count INT
);

-- Insert sample data
INSERT INTO telstra_customers VALUES
(101, 'Sarah Williams', 'Gold', 99.00, 'NSW', '2023-01-15'),
(102, 'Michael Zhang', 'Silver', 69.00, 'VIC', '2023-02-20'),
(103, 'Emma Thompson', 'Gold', 99.00, 'QLD', '2023-03-10'),
(104, 'James O''Brien', 'Bronze', 49.00, 'NSW', '2023-04-05'),
(105, 'Olivia Chen', 'Gold', 99.00, 'VIC', '2023-05-18'),
(106, 'Noah Anderson', 'Silver', 69.00, 'NSW', '2023-06-22'),
(107, 'Sophia Kumar', 'Bronze', 49.00, 'QLD', '2023-07-11'),
(108, 'William Taylor', 'Gold', 99.00, 'VIC', '2024-11-25'), -- New customer, no usage yet!
(109, 'Ava Martin', 'Silver', 69.00, 'NSW', '2024-12-01'),   -- New customer, no usage yet!
(110, 'Lucas Brown', 'Bronze', 49.00, 'QLD', '2024-12-15');  -- New customer, no usage yet!

INSERT INTO telstra_usage VALUES
-- November 2024 usage
(1, 101, '2024-11-01', 45.5, 320, 150),
(2, 102, '2024-11-01', 22.3, 180, 80),
(3, 103, '2024-11-01', 67.8, 420, 200),
(4, 104, '2024-11-01', 5.2, 90, 30),
(5, 105, '2024-11-01', 88.9, 510, 250),
(6, 106, '2024-11-01', 31.4, 220, 110),
(7, 107, '2024-11-01', 8.7, 60, 25),
-- December 2024 usage
(8, 101, '2024-12-01', 52.3, 340, 160),
(9, 102, '2024-12-01', 28.9, 200, 95),
(10, 103, '2024-12-01', 71.2, 450, 220),
(11, 104, '2024-12-01', 6.8, 100, 35),
(12, 105, '2024-12-01', 92.5, 530, 270),
(13, 106, '2024-12-01', 35.7, 240, 120),
(14, 107, '2024-12-01', 9.3, 70, 28);
-- NOTE: Customers 108, 109, 110 have NO usage records!

PRINT 'Telstra demo tables created';
PRINT '';

-- ============================================================================
-- BUSINESS QUESTION 1: "Show customer names WITH their usage"
-- ============================================================================

PRINT 'QUESTION 1: Customer Success asks "Match customer names with their Dec usage"';
PRINT '';

/*
BUSINESS CONTEXT:
- Usage table only has customer_id (101, 102, 103...)
- Need to show customer NAMES for reports
- Two tables must be connected: customers + usage

THE PROBLEM:
Customer names are in 'telstra_customers' table
Usage data is in 'telstra_usage' table

How do we connect them? JOINS!
*/

-- WRONG WAY (this doesn't work):
-- SELECT customer_name, data_used_gb 
-- FROM telstra_customers, telstra_usage;
-- Result: CARTESIAN PRODUCT (every customer × every usage record = chaos!)

-- RIGHT WAY: INNER JOIN
SELECT 
    c.customer_name,
    c.plan_tier,
    u.usage_month,
    u.data_used_gb,
    u.calls_minutes
FROM telstra_customers c
INNER JOIN telstra_usage u ON c.customer_id = u.customer_id
WHERE u.usage_month = '2024-12-01';

/*
EXPLANATION:

1. FROM telstra_customers c
   - 'c' is an ALIAS (shorthand for the table name)
   - Makes queries easier to read
   - Instead of typing 'telstra_customers.customer_name' we write 'c.customer_name'

2. INNER JOIN telstra_usage u ON c.customer_id = u.customer_id
   - INNER JOIN = "Only show records that MATCH in BOTH tables"
   - ON clause specifies HOW to match: customer_id must be equal
   - 'u' is alias for telstra_usage table

3. WHERE u.usage_month = '2024-12-01'
   - Filter to December only

RESULT: 7 customers with December usage

WHAT HAPPENED TO CUSTOMERS 108, 109, 110?
They have NO usage records, so INNER JOIN excludes them!

BUSINESS IMPACT:
"Here's everyone who used the network in December"
*/

PRINT 'Expected: 7 customers with December usage';
PRINT '';

-- ============================================================================
-- BUSINESS QUESTION 2: "Find customers with ZERO usage" (CHURN RISK!)
-- ============================================================================

PRINT 'QUESTION 2: Risk team asks "Which customers had NO usage in December?"';
PRINT '';

/*
BUSINESS CONTEXT:
- Customers paying monthly fees but not using the service = CHURN RISK
- Marketing needs to contact them with retention offers
- Critical to identify BEFORE they cancel

THE PROBLEM:
INNER JOIN only shows customers WITH usage
We need to see customers WITHOUT usage too!

SOLUTION: LEFT JOIN
*/

-- LEFT JOIN: Show ALL customers (even those with no usage)
SELECT 
    c.customer_id,
    c.customer_name,
    c.plan_tier,
    c.monthly_fee,
    u.data_used_gb,
    u.calls_minutes,
    CASE 
        WHEN u.usage_id IS NULL THEN 'CHURN RISK - No Usage!'
        ELSE 'Active'
    END AS status
FROM telstra_customers c
LEFT JOIN telstra_usage u ON c.customer_id = u.customer_id 
                           AND u.usage_month = '2024-12-01'
ORDER BY u.data_used_gb ASC;

/*
EXPLANATION:

1. LEFT JOIN = "Show ALL rows from LEFT table (customers), even if no match in RIGHT table (usage)"
   - LEFT table = telstra_customers (mentioned first)
   - RIGHT table = telstra_usage (joined second)

2. AND u.usage_month = '2024-12-01' in the JOIN condition
   - Filters usage to December BEFORE joining
   - More efficient than filtering in WHERE clause

3. CASE statement:
   - IF u.usage_id IS NULL (no usage record) → 'CHURN RISK'
   - ELSE → 'Active'
   - This flags problematic customers

4. ORDER BY u.data_used_gb ASC
   - NULL values (no usage) appear first
   - Easy to spot churn risks at top of report

RESULT: 10 customers total
- 7 with usage
- 3 with NULL (customers 108, 109, 110)

BUSINESS IMPACT:
Marketing sees: "William Taylor, Ava Martin, Lucas Brown - paying fees but NOT using service"
→ Send retention offer: "50% off next month if you stay!"
*/

PRINT 'Expected: 10 customers (7 active, 3 churn risk)';
PRINT '';

-- ============================================================================
-- INNER JOIN vs LEFT JOIN - VISUAL COMPARISON
-- ============================================================================

PRINT 'SIDE-BY-SIDE COMPARISON: INNER JOIN vs LEFT JOIN';
PRINT '';

PRINT '--- INNER JOIN (only matching records) ---';
SELECT 
    c.customer_name,
    c.plan_tier,
    u.data_used_gb
FROM telstra_customers c
INNER JOIN telstra_usage u ON c.customer_id = u.customer_id
WHERE u.usage_month = '2024-12-01';

PRINT '';
PRINT '--- LEFT JOIN (all customers, even without usage) ---';
SELECT 
    c.customer_name,
    c.plan_tier,
    ISNULL(u.data_used_gb, 0) AS data_used_gb  -- Replace NULL with 0
FROM telstra_customers c
LEFT JOIN telstra_usage u ON c.customer_id = u.customer_id 
                           AND u.usage_month = '2024-12-01';

/*
WHEN TO USE EACH:

INNER JOIN:
✅ "Show me customers WHO MADE purchases"
✅ "List products THAT SOLD"
✅ "Match orders WITH shipments"
Use when: You only care about records that exist in BOTH tables

LEFT JOIN:
✅ "Show ALL customers (even those who didn't purchase)"
✅ "List ALL products (even those that didn't sell)"
✅ "Find orders WITHOUT shipments" (problems!)
Use when: You need complete list from one table, matches optional

BUSINESS RULE OF THUMB:
- INNER JOIN = "Show me what happened"
- LEFT JOIN = "Show me what DIDN'T happen" (often more valuable!)
*/

PRINT '';

-- ============================================================================
-- BUSINESS QUESTION 3: "Usage summary by plan tier"
-- ============================================================================

PRINT 'QUESTION 3: Product team asks "Average usage by plan tier (Bronze/Silver/Gold)"';
PRINT '';

/*
BUSINESS CONTEXT:
- Are Gold customers actually using more data?
- Is the pricing model fair?
- Should we adjust plan limits?

ANALYSIS: JOIN + GROUP BY
*/

SELECT 
    c.plan_tier,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(u.usage_id) AS usage_records,
    AVG(u.data_used_gb) AS avg_data_gb,
    AVG(u.calls_minutes) AS avg_calls_minutes,
    AVG(c.monthly_fee) AS avg_monthly_fee
FROM telstra_customers c
LEFT JOIN telstra_usage u ON c.customer_id = u.customer_id
WHERE u.usage_month >= '2024-11-01' OR u.usage_month IS NULL  -- Nov-Dec + new customers
GROUP BY c.plan_tier
ORDER BY avg_monthly_fee DESC;

/*
EXPLANATION:

1. COUNT(DISTINCT c.customer_id) vs COUNT(u.usage_id)
   - DISTINCT prevents double-counting customers with multiple months
   - Usage_id count shows total usage records

2. AVG(u.data_used_gb)
   - Average data consumption per plan tier
   - NULL values (new customers) automatically excluded from average

3. LEFT JOIN ensures new customers (no usage yet) are counted in total_customers

RESULT INTERPRETATION:
Gold: $99/month, 45GB average → GOOD VALUE
Bronze: $49/month, 7GB average → UNDERUTILIZED

BUSINESS IMPACT:
"Bronze customers barely use 15% of their allowance → marketing opportunity!"
*/

PRINT 'Expected: Usage patterns by plan tier';
PRINT '';

-- ============================================================================
-- ADVANCED: MULTIPLE JOINS
-- ============================================================================

PRINT 'ADVANCED: Connecting 3 tables - Customers + Usage + Transactions';
PRINT '';

/*
BUSINESS CONTEXT:
Real-world scenarios often need data from 3+ tables
Example: "Show customer names, their usage, AND their purchase history"
*/

-- Join customers to BOTH usage AND transactions
SELECT 
    c.customer_name,
    c.plan_tier,
    SUM(u.data_used_gb) AS total_data_gb,
    COUNT(DISTINCT t.transaction_id) AS store_purchases,
    SUM(t.amount) AS total_spent_in_stores
FROM telstra_customers c
LEFT JOIN telstra_usage u ON c.customer_id = u.customer_id
LEFT JOIN customers cust ON c.customer_name = cust.customer_name  -- Name matching (not ideal but demonstrates concept)
LEFT JOIN transactions t ON cust.customer_id = t.customer_id
GROUP BY c.customer_name, c.plan_tier
ORDER BY total_data_gb DESC;

/*
EXPLANATION:
- First LEFT JOIN: customers → usage (telco data)
- Second LEFT JOIN: customers → retail customers (name match)
- Third LEFT JOIN: retail customers → transactions (purchase data)

This creates a 360° customer view:
"Sarah Williams: 97.8GB usage, 2 store purchases, $1,448 spent"

BUSINESS IMPACT:
Cross-sell opportunities: "High telco usage + high retail spend = Premium customer"
*/

PRINT 'Expected: Combined telco + retail customer view';
PRINT '';

-- ============================================================================
-- COMMON JOIN MISTAKES (AND HOW TO FIX THEM)
-- ============================================================================

PRINT 'COMMON MISTAKES TO AVOID:';
PRINT '';

/*
MISTAKE 1: Forgetting WHERE in JOIN condition
*/
-- WRONG (creates HUGE result set):
-- SELECT * FROM telstra_customers c
-- LEFT JOIN telstra_usage u ON c.customer_id = u.customer_id;
-- Result: EVERY customer matched with EVERY month of usage data!

-- RIGHT (filter in JOIN condition):
-- SELECT * FROM telstra_customers c
-- LEFT JOIN telstra_usage u ON c.customer_id = u.customer_id 
--                            AND u.usage_month = '2024-12-01';

/*
MISTAKE 2: Using WHERE instead of JOIN condition with LEFT JOIN
*/
-- WRONG (converts LEFT JOIN to INNER JOIN):
-- SELECT * FROM telstra_customers c
-- LEFT JOIN telstra_usage u ON c.customer_id = u.customer_id
-- WHERE u.usage_month = '2024-12-01';  -- Excludes customers with NULL usage!

-- RIGHT:
-- SELECT * FROM telstra_customers c
-- LEFT JOIN telstra_usage u ON c.customer_id = u.customer_id 
--                            AND u.usage_month = '2024-12-01';

/*
MISTAKE 3: Not using aliases with same column names
*/
-- CONFUSING:
-- SELECT customer_id, customer_name FROM telstra_customers c
-- JOIN telstra_usage u ON ... 
-- Error: "Ambiguous column name 'customer_id'"

-- CLEAR:
-- SELECT c.customer_id, c.customer_name FROM telstra_customers c
-- JOIN telstra_usage u ON c.customer_id = u.customer_id

PRINT 'See comments in script for common mistakes';
PRINT '';

-- ============================================================================
-- KEY TAKEAWAYS
-- ============================================================================

/*
WHAT YOU LEARNED:

1. JOINS connect related tables
   - Data is split across tables (normalization)
   - JOINs reassemble it for analysis

2. JOIN types:
   - INNER JOIN: Only matching records (intersection)
   - LEFT JOIN: All from left table, matches from right (even if NULL)
   - RIGHT JOIN: All from right table, matches from left (rarely used)
   - FULL OUTER JOIN: Everything from both (very rare)

3. Table aliases (c, u) improve readability

4. JOIN + GROUP BY = Powerful aggregations

5. LEFT JOIN finds "missing" data (often the most valuable insight!)

BUSINESS VALUE:
- Churn prediction: Find inactive customers
- 360° customer view: Combine data from multiple systems
- Data quality: Identify orphan records
- Performance analysis: Compare across categories

NEXT VIDEO:
Video 3 - Aggregations & Business Metrics: GROUP BY, HAVING, window functions
*/

-- ============================================================================
-- PRACTICE EXERCISE
-- ============================================================================

PRINT '';
PRINT '================================================================================';
PRINT 'VIDEO 2 COMPLETE';
PRINT '';
PRINT 'Practice Exercise:';
PRINT 'Find customers who signed up in 2024 but have ZERO total usage across all months';
PRINT '';
PRINT 'Hint: LEFT JOIN + WHERE usage_id IS NULL + YEAR(signup_date) = 2024';
PRINT '';
PRINT 'Solution at bottom...';
PRINT '';
PRINT '';
PRINT '';
PRINT '-- SOLUTION:';
PRINT '-- SELECT c.customer_name, c.signup_date, c.plan_tier';
PRINT '-- FROM telstra_customers c';
PRINT '-- LEFT JOIN telstra_usage u ON c.customer_id = u.customer_id';
PRINT '-- WHERE YEAR(c.signup_date) = 2024';
PRINT '--   AND u.usage_id IS NULL;';
PRINT '';
PRINT '-- Expected result: 3 customers (William, Ava, Lucas)';
PRINT '================================================================================';
GO
