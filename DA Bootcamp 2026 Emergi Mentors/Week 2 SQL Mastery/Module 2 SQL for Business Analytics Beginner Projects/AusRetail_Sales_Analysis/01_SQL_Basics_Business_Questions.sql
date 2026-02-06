/*
================================================================================
VIDEO 1: SQL BASICS THROUGH BUSINESS QUESTIONS
================================================================================
Business Context: AusRetail store manager needs answers to operational questions
Duration: 15 minutes
Learning: SELECT, FROM, WHERE, COUNT - taught through real business problems

BUSINESS SCENARIO:
You're a data analyst at AusRetail (Australian retail chain, 50 stores).
The NSW Regional Manager emails you 4 urgent questions.
Let's answer them with SQL!

================================================================================
*/

USE AusRetail;
GO

PRINT '================================================================================';
PRINT 'VIDEO 1: SQL BASICS - BUSINESS QUESTIONS';
PRINT '================================================================================';
PRINT '';

-- ============================================================================
-- BUSINESS QUESTION 1: "Show me all stores in Victoria"
-- ============================================================================

PRINT 'QUESTION 1: Regional Manager asks "Which stores do we have in Victoria?"';
PRINT '';

/*
BUSINESS CONTEXT:
- Victoria planning team needs a list of all VIC stores
- They want store names, suburbs, and manager names
- Used for regional meetings and resource allocation

SQL CONCEPT: SELECT and WHERE (filtering)
*/

-- The Answer:
SELECT 
    store_name,
    suburb,
    manager_name,
    postcode
FROM stores
WHERE state = 'VIC';

/*
EXPLANATION:
- SELECT: Which columns do we want to see?
- FROM stores: Which table contains this data?
- WHERE state = 'VIC': Filter to only Victoria stores

RESULT: 18 stores in Victoria
*/

PRINT 'Expected: 18 Victorian stores';
PRINT '';

-- ============================================================================
-- BUSINESS QUESTION 2: "Which products cost more than $500?"
-- ============================================================================

PRINT 'QUESTION 2: Finance asks "List all premium products priced over $500"';
PRINT '';

/*
BUSINESS CONTEXT:
- Finance team reviewing high-value inventory
- Insurance requirements for expensive items
- Stock security planning

SQL CONCEPT: WHERE with numeric comparison
*/

-- The Answer:
SELECT 
    product_name,
    category,
    unit_price,
    unit_cost,
    (unit_price - unit_cost) AS profit_margin
FROM products
WHERE unit_price > 500
ORDER BY unit_price DESC;

/*
EXPLANATION:
- WHERE unit_price > 500: Numeric filter (no quotes for numbers!)
- Calculated column: (unit_price - unit_cost) shows profit per item
- AS profit_margin: Alias makes output readable for finance team
- ORDER BY unit_price DESC: Most expensive first

BUSINESS IMPACT:
Finance can see: "Samsung TV costs $899, we make $449 profit per unit"
*/

PRINT 'Expected: Premium electronics and appliances';
PRINT '';

-- ============================================================================
-- BUSINESS QUESTION 3: "How many transactions yesterday?"
-- ============================================================================

PRINT 'QUESTION 3: Operations asks "Transaction volume for December 3?"';
PRINT '';

/*
BUSINESS CONTEXT:
- Daily operational reporting
- Staffing decisions based on transaction volume
- Compare to previous days

SQL CONCEPT: COUNT aggregate function + date filtering
*/

-- The Answer:
SELECT 
    COUNT(*) AS total_transactions,
    SUM(amount) AS total_revenue,
    AVG(amount) AS average_transaction_value
FROM transactions
WHERE transaction_date = '2024-12-03';

/*
EXPLANATION:
- COUNT(*): How many rows (transactions)?
- SUM(amount): Add up all revenue
- AVG(amount): Average transaction size
- WHERE transaction_date = '2024-12-03': Specific date filter

DATES IN SQL:
- Always use format: 'YYYY-MM-DD'
- Single quotes required
- Australia uses DD/MM/YYYY in daily life, but SQL uses YYYY-MM-DD

BUSINESS IMPACT:
"Yesterday: 50 transactions, $12,500 revenue, $250 average basket"
*/

PRINT 'Expected: Transaction summary for Dec 3';
PRINT '';

-- ============================================================================
-- BUSINESS QUESTION 4: "Top-selling products this week?"
-- ============================================================================

PRINT 'QUESTION 4: Inventory Manager asks "What products sold most this week?"';
PRINT '';

/*
BUSINESS CONTEXT:
- Restock decisions
- Identify bestsellers
- Supplier order planning

SQL CONCEPT: GROUP BY + aggregate functions
*/

-- The Answer:
SELECT 
    p.product_name,
    p.category,
    COUNT(t.transaction_id) AS times_sold,
    SUM(t.quantity) AS total_units_sold,
    SUM(t.amount) AS total_revenue
FROM transactions t
JOIN products p ON t.product_id = p.product_id
WHERE t.transaction_date >= '2024-12-01'  -- This week (Dec 1-7)
  AND t.transaction_date < '2024-12-08'
GROUP BY p.product_name, p.category
ORDER BY total_revenue DESC;

/*
EXPLANATION:
- JOIN: Connect transactions to products (get product names)
- WHERE with date range: >= Dec 1 AND < Dec 8 (captures full week)
- GROUP BY: Summarize per product
- COUNT: How many times purchased
- SUM: Total units and revenue
- ORDER BY DESC: Highest revenue first

BUSINESS IMPACT:
"Samsung TVs: sold 12 times, 15 units, $13,485 revenue → HIGH PRIORITY RESTOCK"
*/

PRINT 'Expected: Products ranked by revenue';
PRINT '';

-- ============================================================================
-- PUTTING IT ALL TOGETHER: BUSINESS DASHBOARD QUERY
-- ============================================================================

PRINT 'BONUS: Complete store performance dashboard';
PRINT '';

/*
BUSINESS CONTEXT:
Executive dashboard showing:
- Per-store transaction counts
- Revenue totals
- Average transaction values
- Sorted by revenue (best performers first)
*/

SELECT 
    s.state,
    s.store_name,
    s.suburb,
    COUNT(t.transaction_id) AS total_transactions,
    SUM(t.amount) AS total_revenue,
    AVG(t.amount) AS avg_transaction_value,
    MAX(t.transaction_date) AS last_transaction_date
FROM stores s
LEFT JOIN transactions t ON s.store_id = t.store_id
WHERE t.transaction_date >= '2024-10-01'  -- Q4 2024
  AND t.transaction_date < '2025-01-01'
GROUP BY s.state, s.store_name, s.suburb
ORDER BY total_revenue DESC;

/*
EXPLANATION:
- LEFT JOIN: Include stores even with ZERO transactions (important!)
- Multiple aggregates: COUNT, SUM, AVG, MAX all in one query
- GROUP BY: Per store summary
- Date range: Entire Q4 (Oct-Dec 2024)

BUSINESS IMPACT:
"Sydney CBD: $45,000 revenue this quarter → TOP PERFORMER
 Rockhampton: $1,200 revenue → NEEDS ATTENTION"
 
This query becomes the CEO's weekly dashboard
*/

-- ============================================================================
-- KEY TAKEAWAYS
-- ============================================================================

/*
WHAT YOU LEARNED:

1. SELECT: Choose which columns to show
2. FROM: Specify the table
3. WHERE: Filter rows (text uses 'quotes', numbers don't)
4. COUNT, SUM, AVG: Aggregate functions for business metrics
5. JOIN: Connect related tables
6. GROUP BY: Summarize data by category
7. ORDER BY: Sort results

BUSINESS VALUE:
- Answer manager questions in SECONDS (not hours in Excel)
- Consistent, repeatable queries
- Real-time operational insights
- Foundation for dashboards and reports

NEXT VIDEO:
Video 2 - JOINs: Connecting customer data with transaction data
*/

PRINT '';
PRINT '================================================================================';
PRINT 'VIDEO 1 COMPLETE';
PRINT '';
PRINT 'Practice Exercise:';
PRINT 'Try this: "Show all NSW stores opened after 2022-01-01"';
PRINT '';
PRINT 'Solution at bottom of this script...';
PRINT '';
PRINT '';
PRINT '';
PRINT '';
PRINT '-- SOLUTION:';
PRINT '-- SELECT store_name, suburb, opened_date';
PRINT '-- FROM stores';
PRINT '-- WHERE state = ''NSW'' AND opened_date >= ''2022-01-01''';
PRINT '-- ORDER BY opened_date;';
PRINT '';
PRINT '================================================================================';
GO
