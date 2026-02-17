/*******************************************************************************
SESSION 3: BUSINESS QUESTIONS - SQL EXECUTION SCRIPT
================================================================================
Pairs with: GAMMA_SLIDES_PLAYBOOK.md

STRUCTURE:
  - Data Exploration (understand before querying)
  - Scenario 1-4: Foundation scenarios
  - Scenario 5-8: Intermediate business logic
  - Scenario 9-11: Advanced strategic analysis

USAGE:
  Run queries incrementally as you discuss each scenario in the presentation.
  Validate results after every query before proceeding.
*******************************************************************************/

USE RetailAnalyticsDB;
GO

/*******************************************************************************
PART 0: DATA EXPLORATION
================================================================================
Before answering any business question, understand what data you have.
*******************************************************************************/

-- What tables exist in Gold layer?
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'gold'
ORDER BY TABLE_NAME;

-- Understand CustomerMart grain and structure
SELECT TOP 10 *
FROM gold.CustomerMart
ORDER BY TotalRevenue DESC;

-- Row count and null check
SELECT 
    COUNT(*) AS TotalCustomers,
    COUNT(Email) AS CustomersWithEmail,
    COUNT(DaysSinceLastOrder) AS CustomersWithOrders
FROM gold.CustomerMart;

-- Understand ProductPerformanceMart
SELECT TOP 10 *
FROM gold.ProductPerformanceMart
ORDER BY TotalRevenue DESC;

-- Understand MonthlySalesMart
SELECT TOP 12 *
FROM gold.MonthlySalesMart
ORDER BY SalesMonth DESC;

-- Date range in the data
SELECT 
    MIN(SalesMonth) AS EarliestMonth,
    MAX(SalesMonth) AS LatestMonth,
    DATEDIFF(MONTH, MIN(SalesMonth), MAX(SalesMonth)) AS MonthsOfData
FROM gold.MonthlySalesMart;


/*******************************************************************************
SCENARIO 1: FINANCE DASHBOARD
================================================================================
STAKEHOLDER: Sarah Chen, CFO
REQUEST: Monthly revenue for last 12 months for board meeting tomorrow
DECISION: Assess company growth trajectory
*******************************************************************************/

-- Step 1: View recent months
SELECT TOP 5
    SalesMonth,
    Revenue,
    TotalOrders
FROM gold.MonthlySalesMart
ORDER BY SalesMonth DESC;

-- Step 2: Last 12 months with board-friendly format
SELECT 
    SalesMonth,
    MonthName,
    [Year],
    Revenue,
    TotalOrders,
    AvgOrderValue
FROM gold.MonthlySalesMart
WHERE SalesMonth >= DATEADD(MONTH, -12, CAST(GETDATE() AS DATE))
ORDER BY SalesMonth ASC;

-- VALIDATION: 
-- ✓ Exactly 12 rows (or fewer if business is new)?
-- ✓ Revenue trending up?
-- ✓ December highest? (Holiday season)

-- Bonus: Add month-over-month growth
SELECT 
    SalesMonth,
    MonthName,
    Revenue,
    LAG(Revenue, 1) OVER (ORDER BY SalesMonth) AS PriorMonthRevenue,
    Revenue - LAG(Revenue, 1) OVER (ORDER BY SalesMonth) AS MoMChange,
    CASE 
        WHEN LAG(Revenue, 1) OVER (ORDER BY SalesMonth) > 0
        THEN CAST((Revenue - LAG(Revenue, 1) OVER (ORDER BY SalesMonth)) * 100.0 / 
             LAG(Revenue, 1) OVER (ORDER BY SalesMonth) AS DECIMAL(10,2))
        ELSE NULL
    END AS MoMGrowthPct
FROM gold.MonthlySalesMart
WHERE SalesMonth >= DATEADD(MONTH, -12, CAST(GETDATE() AS DATE))
ORDER BY SalesMonth ASC;


/*******************************************************************************
SCENARIO 2: VIP CUSTOMER LIST
================================================================================
STAKEHOLDER: James Wu, Marketing Director
REQUEST: Top 50 customers for exclusive product launch event
DECISION: Who receives hand-written invitations to $50K event
*******************************************************************************/

-- Step 1: View top customers
SELECT TOP 10
    CustomerID,
    CustomerName,
    Email,
    TotalRevenue,
    TotalOrders,
    Segment
FROM gold.CustomerMart
ORDER BY TotalRevenue DESC;

-- Step 2: Top 50 with validation columns
SELECT TOP 50
    CustomerID,
    CustomerName,
    Email,
    TotalRevenue,
    TotalOrders,
    DaysSinceLastOrder,
    Segment
FROM gold.CustomerMart
WHERE TotalOrders > 0  -- Exclude never-purchased
ORDER BY TotalRevenue DESC;

-- VALIDATION:
-- ✓ Most are "Champions" or "Loyal Customers"?
-- ✓ Revenue ranges reasonable? ($5K-$50K)
-- ✓ None have suspiciously high DaysSinceLastOrder?

-- Bonus: Flag at-risk VIPs
SELECT TOP 50
    CustomerID,
    CustomerName,
    Email,
    TotalRevenue,
    DaysSinceLastOrder,
    Segment,
    CASE 
        WHEN DaysSinceLastOrder > 90 THEN '⚠️ CHURN RISK'
        ELSE 'Active'
    END AS ActivityStatus
FROM gold.CustomerMart
WHERE TotalOrders > 0
ORDER BY TotalRevenue DESC;


/*******************************************************************************
SCENARIO 3: HIGH-RISK PRODUCT RETURNS
================================================================================
STAKEHOLDER: Lisa Rodriguez, Operations Manager
REQUEST: Products with high return rates for quality investigation
DECISION: Fix quality issues or discontinue products
*******************************************************************************/

-- Step 1: Understand return rate distribution
SELECT 
    MIN(ReturnRate) AS MinReturnRate,
    AVG(ReturnRate) AS AvgReturnRate,
    MAX(ReturnRate) AS MaxReturnRate
FROM gold.ProductPerformanceMart
WHERE TotalUnitsSold > 10;

-- Step 2: High return rate products (>15%, statistically significant volume)
SELECT 
    ProductName,
    Category,
    Subcategory,
    TotalUnitsSold,
    TotalReturns,
    ReturnRate,
    TotalRevenue
FROM gold.ProductPerformanceMart
WHERE ReturnRate > 15.00
  AND TotalUnitsSold > 10  -- Meaningful sample size
ORDER BY ReturnRate DESC;

-- VALIDATION:
-- ✓ Return rates actually high? (>15% above 8-12% retail average)
-- ✓ Products have meaningful volume?
-- ✓ Any patterns by category?

-- Bonus: Calculate revenue at risk
SELECT 
    Category,
    COUNT(*) AS HighReturnProducts,
    SUM(TotalRevenue) AS RevenueAtRisk,
    AVG(ReturnRate) AS AvgReturnRate
FROM gold.ProductPerformanceMart
WHERE ReturnRate > 15.00
  AND TotalUnitsSold > 10
GROUP BY Category
ORDER BY RevenueAtRisk DESC;


/*******************************************************************************
SCENARIO 4: CUSTOMER HEALTH SCORING
================================================================================
STAKEHOLDER: Michael Torres, Sales Director
REQUEST: Prioritize customers for sales team outreach (limited capacity)
DECISION: Which 200 customers should reps contact this month
*******************************************************************************/

-- Step 1: View customer recency distribution
SELECT 
    CASE 
        WHEN DaysSinceLastOrder <= 60 THEN '0-60 days'
        WHEN DaysSinceLastOrder <= 120 THEN '61-120 days'
        WHEN DaysSinceLastOrder <= 180 THEN '121-180 days'
        ELSE '180+ days'
    END AS RecencyBucket,
    COUNT(*) AS CustomerCount
FROM gold.CustomerMart
WHERE TotalOrders > 0
GROUP BY 
    CASE 
        WHEN DaysSinceLastOrder <= 60 THEN '0-60 days'
        WHEN DaysSinceLastOrder <= 120 THEN '61-120 days'
        WHEN DaysSinceLastOrder <= 180 THEN '121-180 days'
        ELSE '180+ days'
    END
ORDER BY RecencyBucket;

-- Step 2: Categorize all customers by health
SELECT 
    CustomerID,
    CustomerName,
    DaysSinceLastOrder,
    TotalRevenue,
    TotalOrders,
    CASE 
        WHEN DaysSinceLastOrder <= 60 THEN 'Healthy'
        WHEN DaysSinceLastOrder <= 120 THEN 'At Risk'
        ELSE 'Critical'
    END AS CustomerHealth
FROM gold.CustomerMart
WHERE TotalOrders > 0
ORDER BY TotalRevenue DESC;

-- VALIDATION:
-- ✓ Distribution reasonable? (~60% Healthy, ~25% At Risk, ~15% Critical)
-- ✓ High-revenue customers in "Critical"? (Big problem if yes)

-- Step 3: Prioritize by health + value (top 200 for sales team)
WITH HealthScoring AS (
    SELECT 
        CustomerID,
        CustomerName,
        Email,
        DaysSinceLastOrder,
        TotalRevenue,
        TotalOrders,
        CASE 
            WHEN DaysSinceLastOrder <= 60 THEN 'Healthy'
            WHEN DaysSinceLastOrder <= 120 THEN 'At Risk'
            ELSE 'Critical'
        END AS CustomerHealth,
        CASE 
            WHEN DaysSinceLastOrder <= 60 THEN 1
            WHEN DaysSinceLastOrder <= 120 THEN 2
            ELSE 3
        END AS HealthPriority
    FROM gold.CustomerMart
    WHERE TotalOrders > 0
)
SELECT TOP 200
    CustomerID,
    CustomerName,
    Email,
    DaysSinceLastOrder,
    TotalRevenue,
    CustomerHealth,
    CASE CustomerHealth
        WHEN 'Critical' THEN 'HIGH PRIORITY - Churn Risk'
        WHEN 'At Risk' THEN 'MEDIUM PRIORITY - Proactive Outreach'
        ELSE 'LOW PRIORITY - Maintain Relationship'
    END AS SalesAction
FROM HealthScoring
ORDER BY 
    HealthPriority DESC,  -- Critical first
    TotalRevenue DESC;    -- High-value first within each health tier


/*******************************************************************************
SCENARIO 5: CATEGORY PERFORMANCE DEEP DIVE
================================================================================
STAKEHOLDER: Emma Davis, Product Manager
REQUEST: Category performance for $2M annual budget allocation
DECISION: Which categories get investment, which get cut
*******************************************************************************/

-- Step 1: Category-level aggregations
SELECT 
    Category,
    COUNT(*) AS TotalProducts,
    SUM(TotalRevenue) AS CategoryRevenue,
    SUM(TotalUnitsSold) AS CategoryUnitsSold,
    AVG(AvgSellingPrice) AS AvgPrice,
    AVG(ReturnRate) AS AvgReturnRate,
    -- % of total company revenue
    CAST(SUM(TotalRevenue) * 100.0 / (SELECT SUM(TotalRevenue) FROM gold.ProductPerformanceMart) 
         AS DECIMAL(5,2)) AS PctOfTotalRevenue
FROM gold.ProductPerformanceMart
GROUP BY Category
ORDER BY CategoryRevenue DESC;

-- VALIDATION:
-- ✓ Revenue percentages add to 100%?
-- ✓ Return rates vary by category? (Electronics typically higher)

-- Step 2: Best product per category
WITH RankedProducts AS (
    SELECT 
        Category,
        ProductName,
        TotalRevenue,
        TotalUnitsSold,
        ReturnRate,
        ROW_NUMBER() OVER (PARTITION BY Category ORDER BY TotalRevenue DESC) AS RankInCategory
    FROM gold.ProductPerformanceMart
)
SELECT 
    Category,
    ProductName AS BestProduct,
    TotalRevenue,
    TotalUnitsSold,
    ReturnRate
FROM RankedProducts
WHERE RankInCategory = 1
ORDER BY TotalRevenue DESC;


/*******************************************************************************
SCENARIO 6: SEGMENT ECONOMICS
================================================================================
STAKEHOLDER: David Kim, Senior Financial Analyst
REQUEST: Customer segment breakdown for Series B investor presentation
DECISION: Demonstrates customer quality to justify $20M valuation
*******************************************************************************/

-- Segment performance with customer quality metrics
SELECT 
    Segment,
    COUNT(*) AS CustomerCount,
    SUM(TotalRevenue) AS SegmentRevenue,
    AVG(TotalRevenue) AS AvgRevenuePerCustomer,
    AVG(TotalOrders) AS AvgOrdersPerCustomer,
    AVG(AvgOrderValue) AS AvgOrderValue,
    -- % of total revenue
    CAST(SUM(TotalRevenue) * 100.0 / (SELECT SUM(TotalRevenue) FROM gold.CustomerMart) 
         AS DECIMAL(5,2)) AS PctOfTotalRevenue,
    -- % of customer base
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM gold.CustomerMart WHERE TotalOrders > 0) 
         AS DECIMAL(5,2)) AS PctOfCustomerBase
FROM gold.CustomerMart
WHERE TotalOrders > 0
GROUP BY Segment
ORDER BY SegmentRevenue DESC;

-- VALIDATION:
-- ✓ Does 20% of customers drive 60%+ of revenue? (Pareto principle)
-- ✓ Segment names align with marketing categories?


/*******************************************************************************
SCENARIO 7: CAMPAIGN TIMING ANALYSIS
================================================================================
STAKEHOLDER: Rachel Green, Marketing Manager
REQUEST: Best days/months for $50K email campaigns
DECISION: When to launch Q1 campaign for maximum ROI
*******************************************************************************/

-- Day of week patterns
SELECT 
    DATENAME(WEEKDAY, SalesDate) AS DayOfWeek,
    DATEPART(WEEKDAY, SalesDate) AS DayNumber,
    COUNT(*) AS TotalDays,
    AVG(Revenue) AS AvgDailyRevenue,
    AVG(TotalOrders) AS AvgDailyOrders,
    AVG(TotalCustomers) AS AvgDailyCustomers
FROM gold.DailySalesMart
GROUP BY 
    DATENAME(WEEKDAY, SalesDate),
    DATEPART(WEEKDAY, SalesDate)
ORDER BY DayNumber;

-- VALIDATION:
-- ✓ Weekend vs weekday patterns make sense for retail?
-- ✓ Sufficient data points per day? (Count > 50)

-- Monthly seasonality
SELECT 
    MonthName,
    [Month],
    AVG(Revenue) AS AvgMonthlyRevenue,
    AVG(TotalOrders) AS AvgMonthlyOrders,
    COUNT(*) AS YearsOfData
FROM gold.MonthlySalesMart
GROUP BY MonthName, [Month]
ORDER BY [Month];

-- VALIDATION:
-- ✓ Australian seasonality? (Jun = EOFY, Nov-Dec = Christmas)


/*******************************************************************************
SCENARIO 8: YEAR-OVER-YEAR GROWTH
================================================================================
STAKEHOLDER: Tom Anderson, COO
REQUEST: YoY growth for board's market share assessment
DECISION: Expand into new markets or optimize existing ones
*******************************************************************************/

-- Month-over-month comparison with prior year
SELECT 
    curr.[Year],
    curr.[Month],
    curr.MonthName,
    curr.Revenue AS CurrentYearRevenue,
    curr.TotalOrders AS CurrentYearOrders,
    prior.Revenue AS PriorYearRevenue,
    prior.TotalOrders AS PriorYearOrders,
    -- Growth calculations
    curr.Revenue - prior.Revenue AS GrowthDollars,
    CASE 
        WHEN prior.Revenue > 0 
        THEN CAST((curr.Revenue - prior.Revenue) * 100.0 / prior.Revenue AS DECIMAL(10,2))
        ELSE NULL 
    END AS GrowthPercent
FROM gold.MonthlySalesMart curr
LEFT JOIN gold.MonthlySalesMart prior
    ON curr.[Month] = prior.[Month]
    AND curr.[Year] = prior.[Year] + 1
WHERE curr.[Year] = (SELECT MAX([Year]) FROM gold.MonthlySalesMart)  -- Most recent year
ORDER BY curr.[Month];

-- VALIDATION:
-- ✓ Growth rates reasonable? (Retail typically 5-15% YoY)
-- ✓ Any months with negative growth? (Needs explanation)


/*******************************************************************************
SCENARIO 9: CUSTOMER COHORT RETENTION
================================================================================
STAKEHOLDER: Jennifer Park, CEO
REQUEST: Cohort retention for $3M customer acquisition budget planning
DECISION: How much to spend per customer based on LTV patterns
*******************************************************************************/

-- Cohort analysis: Registration year performance
WITH CustomerCohorts AS (
    SELECT 
        CustomerID,
        YEAR(RegistrationDate) AS CohortYear,
        TotalRevenue,
        DaysSinceLastOrder,
        CASE WHEN DaysSinceLastOrder <= 90 THEN 1 ELSE 0 END AS IsActive
    FROM gold.CustomerMart
    WHERE RegistrationDate IS NOT NULL
      AND TotalOrders > 0
)
SELECT 
    CohortYear,
    COUNT(*) AS CustomersRegistered,
    SUM(IsActive) AS CustomersStillActive,
    -- Retention rate
    CAST(SUM(IsActive) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS RetentionRate,
    -- Economic metrics
    AVG(TotalRevenue) AS AvgLifetimeValue,
    SUM(TotalRevenue) AS TotalCohortRevenue,
    -- Average age of cohort
    DATEDIFF(MONTH, CAST(CAST(CohortYear AS VARCHAR(4)) + '-01-01' AS DATE), GETDATE()) AS CohortAgeMonths
FROM CustomerCohorts
GROUP BY CohortYear
ORDER BY CohortYear DESC;

-- VALIDATION:
-- ✓ Older cohorts have lower retention? (Expected)
-- ✓ LTV increases with cohort age? (Good sign)
-- ✓ Recent cohorts smaller? (Business growing)


/*******************************************************************************
SCENARIO 10: RFM-BASED CAMPAIGN TARGETING
================================================================================
STAKEHOLDER: Dr. Alex Martinez, Head of Data Science
REQUEST: Prioritize 3 Q1 campaigns based on customer segments
DECISION: $150K marketing budget allocation across campaigns
*******************************************************************************/

-- Campaign A: Win-back (high-value at-risk/churned)
SELECT 
    'Campaign A: Win-Back' AS CampaignName,
    Segment,
    COUNT(*) AS TargetCustomers,
    SUM(MonetaryValue) AS HistoricalValue,
    AVG(RecencyDays) AS AvgDaysSinceLastOrder,
    AVG(Frequency) AS AvgPastOrders,
    'Email + Direct Mail' AS RecommendedChannel,
    '$75K Budget' AS Investment
FROM gold.CustomerRFM
WHERE Segment IN ('At Risk', 'Churned')
  AND MonetaryValue > 500
GROUP BY Segment

UNION ALL

-- Campaign B: Upsell (active high-value)
SELECT 
    'Campaign B: Upsell',
    Segment,
    COUNT(*),
    SUM(MonetaryValue),
    AVG(RecencyDays),
    AVG(Frequency),
    'Email + SMS',
    '$50K Budget'
FROM gold.CustomerRFM
WHERE Segment IN ('Champions', 'Loyal Customers')
GROUP BY Segment

UNION ALL

-- Campaign C: Nurture (new low-frequency)
SELECT 
    'Campaign C: Nurture',
    Segment,
    COUNT(*),
    SUM(MonetaryValue),
    AVG(RecencyDays),
    AVG(Frequency),
    'Email Only',
    '$25K Budget'
FROM gold.CustomerRFM
WHERE Segment IN ('Recent Customers', 'Potential Loyalists')
GROUP BY Segment
ORDER BY CampaignName;

-- VALIDATION:
-- ✓ Campaign A has highest historical value? (Justified for expensive channel)
-- ✓ Customer counts manageable? (Can't email 10,000 people personally)


/*******************************************************************************
SCENARIO 11: DAILY SALES ANOMALY DETECTION
================================================================================
STAKEHOLDER: Sarah Chen, CFO
REQUEST: Early warning system for revenue anomalies
DECISION: Catch data issues or market shocks within 24 hours
*******************************************************************************/

-- Daily revenue with 7-day moving average and anomaly flags
WITH DailyMetrics AS (
    SELECT 
        SalesDate,
        Revenue,
        TotalOrders,
        -- 7-day moving average
        AVG(Revenue) OVER (
            ORDER BY SalesDate 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS MovingAvg7Day,
        -- Prior day comparison
        LAG(Revenue, 1) OVER (ORDER BY SalesDate) AS PriorDayRevenue
    FROM gold.DailySalesMart
)
SELECT 
    SalesDate,
    DATENAME(WEEKDAY, SalesDate) AS DayOfWeek,
    Revenue,
    MovingAvg7Day,
    -- Deviation from moving average
    CASE 
        WHEN MovingAvg7Day > 0 
        THEN CAST((Revenue - MovingAvg7Day) * 100.0 / MovingAvg7Day AS DECIMAL(10,2))
        ELSE 0 
    END AS DeviationPct,
    -- Anomaly flag
    CASE 
        WHEN Revenue > MovingAvg7Day * 1.30 THEN '🔥 UP 30%+'
        WHEN Revenue < MovingAvg7Day * 0.70 THEN '⚠️ DOWN 30%+'
        ELSE 'Normal'
    END AS AnomalyFlag,
    TotalOrders,
    PriorDayRevenue
FROM DailyMetrics
WHERE SalesDate >= DATEADD(DAY, -60, CAST(GETDATE() AS DATE))
ORDER BY SalesDate DESC;

-- VALIDATION:
-- ✓ Flagged days have explanations? (weekends, holidays, data issues)
-- ✓ Moving average smooths out daily noise?
-- ✓ Any concerning patterns? (Consecutive down days)

-- Bonus: Count anomalies by type
SELECT 
    CASE 
        WHEN Revenue > MovingAvg7Day * 1.30 THEN 'Positive Spike'
        WHEN Revenue < MovingAvg7Day * 0.70 THEN 'Negative Spike'
        ELSE 'Normal'
    END AS AnomalyType,
    COUNT(*) AS DayCount,
    AVG(Revenue) AS AvgRevenue
FROM (
    SELECT 
        SalesDate,
        Revenue,
        AVG(Revenue) OVER (
            ORDER BY SalesDate 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS MovingAvg7Day
    FROM gold.DailySalesMart
    WHERE SalesDate >= DATEADD(DAY, -60, CAST(GETDATE() AS DATE))
) AS DailyMetrics
GROUP BY 
    CASE 
        WHEN Revenue > MovingAvg7Day * 1.30 THEN 'Positive Spike'
        WHEN Revenue < MovingAvg7Day * 0.70 THEN 'Negative Spike'
        ELSE 'Normal'
    END;


/*******************************************************************************
SESSION COMPLETE
================================================================================
You've executed 11 business scenarios using:
  ✓ Data exploration methodology
  ✓ Incremental query building
  ✓ Business validation at each step
  ✓ ROI-focused thinking

NEXT STEPS:
  1. Save useful queries to your personal library
  2. Practice modifying scenarios (change thresholds, time periods)
  3. Session 4: Learn HOW this warehouse was built (Bronze → Silver → Gold)

REMEMBER:
  Every query should drive a business decision.
  Every analysis should quantify impact.
  You're not just writing SQL - you're creating business value.
*******************************************************************************/
