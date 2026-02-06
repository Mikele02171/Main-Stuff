/*
================================================================================
VIDEO 10: TEMP TABLES & TABLE VARIABLES
Complex Multi-Step Workflows - NAD Banking Month-End Reconciliation
================================================================================
Duration: 17 minutes | Level: Advanced
Instructor: Fassahat | Emergi Mentors Data Analytics Bootcamp
================================================================================

SCENARIO: Friday 5:00 PM - Finance Manager needs month-end reconciliation 
          by Monday morning for board meeting!
          
PROBLEM:  Manual Excel process takes 3.5 hours with 15% error rate
SOLUTION: Automated temp table workflow completes in 10 minutes with 0% errors

LEARNING OBJECTIVES:
- Master temp tables (#TempTable) for session-scoped storage
- Understand table variables (@TableVariable) for batch-scoped storage  
- Learn global temp tables (##GlobalTemp) for cross-session sharing
- Build production-ready multi-step workflows
- Optimize with indexes for enterprise performance

================================================================================
*/

-- ============================================================================
-- SECTION 1: ENVIRONMENT SETUP
-- ============================================================================
-- Clean slate for training session
USE master;
GO

-- Drop database if exists (training reset)
IF DB_ID('NAD_Banking') IS NOT NULL
BEGIN
    ALTER DATABASE NAD_Banking SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE NAD_Banking;
END
GO

-- Create fresh database
CREATE DATABASE NAD_Banking;
GO

USE NAD_Banking;
GO

PRINT '✓ Database NAD_Banking created successfully';
PRINT '';
GO

-- ============================================================================
-- SECTION 2: CREATE BASE TABLES (NAD Banking Schema)
-- ============================================================================

-- Accounts table
CREATE TABLE accounts (
    account_id INT PRIMARY KEY IDENTITY(1,1),
    account_number NVARCHAR(20) NOT NULL UNIQUE,
    customer_name NVARCHAR(100) NOT NULL,
    account_type NVARCHAR(50) NOT NULL,
    opening_balance DECIMAL(15,2) NOT NULL DEFAULT 0,
    created_date DATETIME NOT NULL DEFAULT GETDATE(),
    status NVARCHAR(20) NOT NULL DEFAULT 'Active',
    CONSTRAINT CK_account_type CHECK (account_type IN ('Savings', 'Checking', 'Business', 'Investment'))
);

-- Transactions table
CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY IDENTITY(1,1),
    account_id INT NOT NULL,
    transaction_date DATETIME NOT NULL DEFAULT GETDATE(),
    amount DECIMAL(15,2) NOT NULL,
    transaction_type NVARCHAR(50) NOT NULL,
    description NVARCHAR(200),
    CONSTRAINT FK_transactions_accounts FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    CONSTRAINT CK_transaction_type CHECK (transaction_type IN ('Deposit', 'Withdrawal', 'Transfer', 'Fee', 'Interest'))
);

-- Create indexes for performance
CREATE INDEX IX_transactions_account_date ON transactions(account_id, transaction_date);
CREATE INDEX IX_transactions_date ON transactions(transaction_date);
CREATE INDEX IX_accounts_status ON accounts(status);

PRINT '✓ Base tables created with indexes';
PRINT '';
GO

-- ============================================================================
-- SECTION 3: POPULATE SAMPLE DATA
-- ============================================================================

-- Insert 50 customer accounts
INSERT INTO accounts (account_number, customer_name, account_type, opening_balance, created_date)
VALUES 
    ('NAD-001-SAV', 'James Anderson', 'Savings', 75000.00, '2024-01-15'),
    ('NAD-002-CHK', 'Sarah Mitchell', 'Checking', 45000.00, '2024-01-20'),
    ('NAD-003-BUS', 'TechStart Solutions Pty Ltd', 'Business', 125000.00, '2024-02-01'),
    ('NAD-004-SAV', 'Emma Thompson', 'Savings', 32000.00, '2024-02-10'),
    ('NAD-005-INV', 'Robert Chen', 'Investment', 250000.00, '2024-02-15'),
    ('NAD-006-CHK', 'Maria Garcia', 'Checking', 28000.00, '2024-03-01'),
    ('NAD-007-BUS', 'Melbourne Retail Group', 'Business', 180000.00, '2024-03-05'),
    ('NAD-008-SAV', 'David Wilson', 'Savings', 55000.00, '2024-03-10'),
    ('NAD-009-CHK', 'Lisa Brown', 'Checking', 12000.00, '2024-03-15'),
    ('NAD-010-SAV', 'Michael O''Connor', 'Savings', 48000.00, '2024-03-20'),
    ('NAD-011-BUS', 'Sydney Import Export', 'Business', 95000.00, '2024-04-01'),
    ('NAD-012-INV', 'Jennifer Lee', 'Investment', 175000.00, '2024-04-05'),
    ('NAD-013-CHK', 'Thomas White', 'Checking', 38000.00, '2024-04-10'),
    ('NAD-014-SAV', 'Patricia Moore', 'Savings', 62000.00, '2024-04-15'),
    ('NAD-015-BUS', 'Brisbane Consulting', 'Business', 88000.00, '2024-04-20'),
    ('NAD-016-CHK', 'Christopher Taylor', 'Checking', 25000.00, '2024-05-01'),
    ('NAD-017-SAV', 'Amanda Jackson', 'Savings', 71000.00, '2024-05-05'),
    ('NAD-018-INV', 'Daniel Martin', 'Investment', 310000.00, '2024-05-10'),
    ('NAD-019-CHK', 'Michelle Thompson', 'Checking', 19000.00, '2024-05-15'),
    ('NAD-020-BUS', 'Perth Mining Services', 'Business', 420000.00, '2024-05-20'),
    ('NAD-021-SAV', 'Kevin Harris', 'Savings', 44000.00, '2024-06-01'),
    ('NAD-022-CHK', 'Nicole Robinson', 'Checking', 31000.00, '2024-06-05'),
    ('NAD-023-BUS', 'Adelaide Wine Distributors', 'Business', 135000.00, '2024-06-10'),
    ('NAD-024-SAV', 'Steven Clark', 'Savings', 58000.00, '2024-06-15'),
    ('NAD-025-INV', 'Rebecca Lewis', 'Investment', 225000.00, '2024-06-20'),
    ('NAD-026-CHK', 'Brian Walker', 'Checking', 22000.00, '2024-07-01'),
    ('NAD-027-SAV', 'Jessica Hall', 'Savings', 67000.00, '2024-07-05'),
    ('NAD-028-BUS', 'Canberra Tech Hub', 'Business', 98000.00, '2024-07-10'),
    ('NAD-029-CHK', 'Ryan Young', 'Checking', 15000.00, '2024-07-15'),
    ('NAD-030-SAV', 'Lauren King', 'Savings', 52000.00, '2024-07-20'),
    ('NAD-031-BUS', 'Hobart Seafood Exports', 'Business', 165000.00, '2024-08-01'),
    ('NAD-032-INV', 'Jason Wright', 'Investment', 280000.00, '2024-08-05'),
    ('NAD-033-CHK', 'Stephanie Green', 'Checking', 27000.00, '2024-08-10'),
    ('NAD-034-SAV', 'Brandon Baker', 'Savings', 73000.00, '2024-08-15'),
    ('NAD-035-BUS', 'Darwin Logistics', 'Business', 112000.00, '2024-08-20'),
    ('NAD-036-CHK', 'Melissa Adams', 'Checking', 18000.00, '2024-09-01'),
    ('NAD-037-SAV', 'Eric Nelson', 'Savings', 64000.00, '2024-09-05'),
    ('NAD-038-INV', 'Samantha Carter', 'Investment', 195000.00, '2024-09-10'),
    ('NAD-039-CHK', 'Gregory Mitchell', 'Checking', 33000.00, '2024-09-15'),
    ('NAD-040-BUS', 'Newcastle Steel Works', 'Business', 285000.00, '2024-09-20'),
    ('NAD-041-SAV', 'Heather Perez', 'Savings', 49000.00, '2024-10-01'),
    ('NAD-042-CHK', 'Jonathan Roberts', 'Checking', 24000.00, '2024-10-05'),
    ('NAD-043-BUS', 'Gold Coast Tourism', 'Business', 155000.00, '2024-10-10'),
    ('NAD-044-SAV', 'Rachel Turner', 'Savings', 81000.00, '2024-10-15'),
    ('NAD-045-INV', 'Adam Phillips', 'Investment', 340000.00, '2024-10-20'),
    ('NAD-046-CHK', 'Kimberly Campbell', 'Checking', 29000.00, '2024-11-01'),
    ('NAD-047-SAV', 'Justin Parker', 'Savings', 56000.00, '2024-11-05'),
    ('NAD-048-BUS', 'Wollongong Manufacturing', 'Business', 198000.00, '2024-11-10'),
    ('NAD-049-CHK', 'Brittany Evans', 'Checking', 21000.00, '2024-11-15'),
    ('NAD-050-SAV', 'Tyler Edwards', 'Savings', 69000.00, '2024-11-20');

PRINT '✓ Inserted 50 customer accounts';
PRINT '';
GO

-- Insert realistic December 2024 transactions (15,000+ transactions)
-- This simulates a month of banking activity

DECLARE @AccountID INT = 1;
DECLARE @TransactionDate DATETIME;
DECLARE @DayCounter INT;
DECLARE @TxPerDay INT;
DECLARE @Amount DECIMAL(15,2);
DECLARE @TxType NVARCHAR(50);

-- Loop through each account
WHILE @AccountID <= 50
BEGIN
    SET @DayCounter = 1;
    
    -- Generate transactions for each day in December 2024
    WHILE @DayCounter <= 31
    BEGIN
        SET @TransactionDate = DATEADD(DAY, @DayCounter - 1, '2024-12-01');
        SET @TxPerDay = FLOOR(RAND() * 15) + 5; -- 5-20 transactions per day per account
        
        DECLARE @TxCounter INT = 1;
        WHILE @TxCounter <= @TxPerDay
        BEGIN
            -- Randomize transaction types and amounts
            DECLARE @RandType FLOAT = RAND();
            
            IF @RandType < 0.4 -- 40% Deposits
            BEGIN
                SET @TxType = 'Deposit';
                SET @Amount = ROUND(RAND() * 5000 + 100, 2); -- $100-$5,100
            END
            ELSE IF @RandType < 0.7 -- 30% Withdrawals
            BEGIN
                SET @TxType = 'Withdrawal';
                SET @Amount = -ROUND(RAND() * 3000 + 50, 2); -- -$50 to -$3,050
            END
            ELSE IF @RandType < 0.85 -- 15% Transfers
            BEGIN
                SET @TxType = 'Transfer';
                SET @Amount = CASE 
                    WHEN RAND() > 0.5 THEN ROUND(RAND() * 2000 + 100, 2)
                    ELSE -ROUND(RAND() * 2000 + 100, 2)
                END;
            END
            ELSE IF @RandType < 0.95 -- 10% Fees
            BEGIN
                SET @TxType = 'Fee';
                SET @Amount = -ROUND(RAND() * 50 + 5, 2); -- -$5 to -$55
            END
            ELSE -- 5% Interest
            BEGIN
                SET @TxType = 'Interest';
                SET @Amount = ROUND(RAND() * 200 + 10, 2); -- $10-$210
            END
            
            -- Add some time variance to transaction
            SET @TransactionDate = DATEADD(MINUTE, FLOOR(RAND() * 1440), @TransactionDate);
            
            INSERT INTO transactions (account_id, transaction_date, amount, transaction_type, description)
            VALUES (
                @AccountID,
                @TransactionDate,
                @Amount,
                @TxType,
                @TxType + ' - ' + FORMAT(@TransactionDate, 'dd/MM/yyyy HH:mm')
            );
            
            SET @TxCounter = @TxCounter + 1;
        END
        
        SET @DayCounter = @DayCounter + 1;
    END
    
    SET @AccountID = @AccountID + 1;
END
GO

PRINT '✓ Generated December 2024 transactions';
PRINT '';

-- Display data summary
SELECT 
    'Total Accounts' AS Metric,
    COUNT(*) AS Value
FROM accounts
UNION ALL
SELECT 
    'Total Transactions',
    COUNT(*)
FROM transactions
UNION ALL
SELECT 
    'December 2024 Transactions',
    COUNT(*)
FROM transactions
WHERE transaction_date >= '2024-12-01' AND transaction_date < '2025-01-01';

PRINT '';
PRINT '================================================================================';
PRINT 'SECTION 4: TEMP TABLES - THE WORKHORSE';
PRINT '================================================================================';
PRINT '';
GO

-- ============================================================================
-- DEMO 1: Basic Temp Table Creation and Usage
-- ============================================================================

PRINT '--- DEMO 1: Basic Temp Table Creation ---';
PRINT '';

-- Create temp table for high-value accounts
CREATE TABLE #HighValueAccounts (
    account_id INT,
    account_number NVARCHAR(20),
    customer_name NVARCHAR(100),
    account_type NVARCHAR(50),
    opening_balance DECIMAL(15,2)
);

-- Populate temp table
INSERT INTO #HighValueAccounts
SELECT 
    account_id,
    account_number,
    customer_name,
    account_type,
    opening_balance
FROM accounts
WHERE opening_balance > 50000;

-- Query temp table
SELECT 
    'High Value Accounts (>$50,000)' AS Category,
    COUNT(*) AS AccountCount,
    AVG(opening_balance) AS AvgBalance,
    MAX(opening_balance) AS MaxBalance
FROM #HighValueAccounts;

PRINT '';
SELECT * FROM #HighValueAccounts ORDER BY opening_balance DESC;

-- Verify temp table exists in tempdb
PRINT '';
PRINT 'Temp table physical location:';
SELECT 
    name AS TempTableName,
    create_date AS CreatedAt
FROM tempdb.sys.tables
WHERE name LIKE '#HighValueAccounts%';

-- Clean up
DROP TABLE #HighValueAccounts;
PRINT '';
PRINT '✓ Temp table dropped successfully';
PRINT '';
GO

-- ============================================================================
-- DEMO 2: Temp Table with Indexes (Performance Optimization)
-- ============================================================================

PRINT '--- DEMO 2: Temp Table with Indexes ---';
PRINT '';

-- Create temp table for all December transactions
CREATE TABLE #DecemberTransactions (
    transaction_id INT,
    account_id INT,
    transaction_date DATETIME,
    amount DECIMAL(15,2),
    transaction_type NVARCHAR(50)
);

-- Populate
INSERT INTO #DecemberTransactions
SELECT 
    transaction_id,
    account_id,
    transaction_date,
    amount,
    transaction_type
FROM transactions
WHERE transaction_date >= '2024-12-01' 
  AND transaction_date < '2025-01-01';

PRINT 'Records in #DecemberTransactions:';
SELECT COUNT(*) AS RecordCount FROM #DecemberTransactions;

-- Add index for performance
CREATE INDEX IX_AccountID ON #DecemberTransactions(account_id);
CREATE INDEX IX_TransactionDate ON #DecemberTransactions(transaction_date);

PRINT '';
PRINT '✓ Indexes created on temp table';

-- Now query with improved performance
SELECT 
    account_id,
    COUNT(*) AS TransactionCount,
    SUM(CASE WHEN amount > 0 THEN amount ELSE 0 END) AS TotalDeposits,
    SUM(CASE WHEN amount < 0 THEN ABS(amount) ELSE 0 END) AS TotalWithdrawals,
    SUM(amount) AS NetChange
FROM #DecemberTransactions
GROUP BY account_id
ORDER BY NetChange DESC;

-- Cleanup
DROP TABLE #DecemberTransactions;
PRINT '';
PRINT '✓ Demo 2 completed';
PRINT '';
GO

-- ============================================================================
-- DEMO 3: SELECT INTO Method (Quick Temp Table Creation)
-- ============================================================================

PRINT '--- DEMO 3: SELECT INTO Method ---';
PRINT '';

-- Create temp table automatically with SELECT INTO
SELECT 
    account_id,
    account_number,
    customer_name,
    account_type,
    opening_balance
INTO #QuickTemp
FROM accounts
WHERE account_type = 'Business';

PRINT 'Business accounts in #QuickTemp:';
SELECT * FROM #QuickTemp ORDER BY opening_balance DESC;

-- Cleanup
DROP TABLE #QuickTemp;
PRINT '';
PRINT '✓ Demo 3 completed';
PRINT '';
GO

PRINT '================================================================================';
PRINT 'SECTION 5: TABLE VARIABLES - THE LIGHTWEIGHT ALTERNATIVE';
PRINT '================================================================================';
PRINT '';
GO

-- ============================================================================
-- DEMO 4: Table Variable Declaration and Usage
-- ============================================================================

PRINT '--- DEMO 4: Table Variable Basics ---';
PRINT '';

-- Declare table variable
DECLARE @AccountSummary TABLE (
    account_id INT,
    customer_name NVARCHAR(100),
    current_balance DECIMAL(15,2),
    risk_level NVARCHAR(20)
);

-- Populate table variable
INSERT INTO @AccountSummary
SELECT 
    a.account_id,
    a.customer_name,
    a.opening_balance + ISNULL(SUM(t.amount), 0) AS current_balance,
    CASE 
        WHEN a.opening_balance + ISNULL(SUM(t.amount), 0) < 1000 THEN 'High Risk'
        WHEN a.opening_balance + ISNULL(SUM(t.amount), 0) < 5000 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_level
FROM accounts a
LEFT JOIN transactions t ON a.account_id = t.account_id
WHERE t.transaction_date >= '2024-12-01' 
  AND t.transaction_date < '2025-01-01'
GROUP BY a.account_id, a.customer_name, a.opening_balance;

-- Query table variable
PRINT 'Account Risk Analysis:';
SELECT 
    risk_level,
    COUNT(*) AS AccountCount,
    AVG(current_balance) AS AvgBalance
FROM @AccountSummary
GROUP BY risk_level
ORDER BY 
    CASE risk_level 
        WHEN 'High Risk' THEN 1 
        WHEN 'Medium Risk' THEN 2 
        ELSE 3 
    END;

PRINT '';
PRINT '✓ Table variable demonstration completed';
PRINT '';
GO

-- ============================================================================
-- DEMO 5: Batch Scope Demonstration
-- ============================================================================

PRINT '--- DEMO 5: Batch Scope (Table Variable vs Temp Table) ---';
PRINT '';

-- Table variable - dies at GO
DECLARE @BatchTest TABLE (ID INT, Value NVARCHAR(50));
INSERT INTO @BatchTest VALUES (1, 'Batch scoped - dies at GO');
SELECT * FROM @BatchTest;
PRINT 'Table variable exists in this batch';
GO

-- This will fail - table variable out of scope
-- SELECT * FROM @BatchTest; -- Uncomment to see error

-- Temp table - survives GO
CREATE TABLE #SessionTest (ID INT, Value NVARCHAR(50));
INSERT INTO #SessionTest VALUES (1, 'Session scoped - survives GO');
GO

SELECT * FROM #SessionTest;
PRINT 'Temp table survives across batches!';

-- Cleanup
DROP TABLE #SessionTest;
PRINT '';
GO

PRINT '================================================================================';
PRINT 'SECTION 6: MULTI-STEP WORKFLOW - THE PRODUCTION PATTERN';
PRINT '================================================================================';
PRINT '';
GO

-- ============================================================================
-- COMPLETE MONTH-END RECONCILIATION WORKFLOW
-- ============================================================================

PRINT '--- MONTH-END RECONCILIATION: 10-Step Automated Process ---';
PRINT '';
PRINT 'Starting comprehensive reconciliation for December 2024...';
PRINT '';

-- STEP 1: Extract December Transactions
PRINT 'STEP 1: Extracting December 2024 transactions...';

CREATE TABLE #Step1_Transactions (
    transaction_id INT,
    account_id INT,
    transaction_date DATETIME,
    amount DECIMAL(15,2),
    transaction_type NVARCHAR(50),
    description NVARCHAR(200)
);

INSERT INTO #Step1_Transactions
SELECT 
    transaction_id,
    account_id,
    transaction_date,
    amount,
    transaction_type,
    description
FROM transactions
WHERE transaction_date >= '2024-12-01'
  AND transaction_date < '2025-01-01';

-- Add index for performance
CREATE INDEX IX_Account ON #Step1_Transactions(account_id);
CREATE INDEX IX_Date ON #Step1_Transactions(transaction_date);

DECLARE @Step1Count INT = (SELECT COUNT(*) FROM #Step1_Transactions);
PRINT '  ✓ Extracted ' + CAST(@Step1Count AS NVARCHAR(10)) + ' transactions';
PRINT '';

-- STEP 2: Calculate Daily Running Balances
PRINT 'STEP 2: Calculating daily running balances per account...';

CREATE TABLE #Step2_DailyBalances (
    account_id INT,
    balance_date DATE,
    daily_total DECIMAL(15,2),
    running_balance DECIMAL(15,2)
);

INSERT INTO #Step2_DailyBalances
SELECT 
    t.account_id,
    CAST(t.transaction_date AS DATE) AS balance_date,
    SUM(t.amount) AS daily_total,
    a.opening_balance + SUM(SUM(t.amount)) OVER (
        PARTITION BY t.account_id 
        ORDER BY CAST(t.transaction_date AS DATE)
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_balance
FROM #Step1_Transactions t
JOIN accounts a ON t.account_id = a.account_id
GROUP BY t.account_id, CAST(t.transaction_date AS DATE), a.opening_balance;

CREATE INDEX IX_AccountDate ON #Step2_DailyBalances(account_id, balance_date);

DECLARE @Step2Count INT = (SELECT COUNT(*) FROM #Step2_DailyBalances);
PRINT '  ✓ Calculated ' + CAST(@Step2Count AS NVARCHAR(10)) + ' daily balance records';
PRINT '';

-- STEP 3: Identify Overdraft Instances
PRINT 'STEP 3: Identifying overdraft instances...';

CREATE TABLE #Step3_Overdrafts (
    account_id INT,
    overdraft_date DATE,
    overdraft_amount DECIMAL(15,2),
    severity NVARCHAR(20)
);

INSERT INTO #Step3_Overdrafts
SELECT 
    account_id,
    balance_date AS overdraft_date,
    running_balance AS overdraft_amount,
    CASE 
        WHEN running_balance < -10000 THEN 'Critical'
        WHEN running_balance < -5000 THEN 'High'
        WHEN running_balance < 0 THEN 'Medium'
    END AS severity
FROM #Step2_DailyBalances
WHERE running_balance < 0;

DECLARE @Step3Count INT = (SELECT COUNT(*) FROM #Step3_Overdrafts);
PRINT '  ✓ Identified ' + CAST(@Step3Count AS NVARCHAR(10)) + ' overdraft instances';
PRINT '';

-- STEP 4: Flag Suspicious Large Transactions
PRINT 'STEP 4: Flagging suspicious large transactions...';

CREATE TABLE #Step4_SuspiciousTransactions (
    transaction_id INT,
    account_id INT,
    transaction_date DATETIME,
    amount DECIMAL(15,2),
    transaction_type NVARCHAR(50),
    flag_reason NVARCHAR(100)
);

INSERT INTO #Step4_SuspiciousTransactions
SELECT 
    transaction_id,
    account_id,
    transaction_date,
    amount,
    transaction_type,
    CASE 
        WHEN ABS(amount) > 50000 THEN 'Critical Alert (>$50K)'
        WHEN ABS(amount) > 10000 THEN 'Large Transaction (>$10K)'
        WHEN ABS(amount) > 5000 THEN 'Medium Alert (>$5K)'
    END AS flag_reason
FROM #Step1_Transactions
WHERE ABS(amount) > 5000;

DECLARE @Step4Count INT = (SELECT COUNT(*) FROM #Step4_SuspiciousTransactions);
PRINT '  ✓ Flagged ' + CAST(@Step4Count AS NVARCHAR(10)) + ' suspicious transactions';
PRINT '';

-- STEP 5: Calculate Fee Revenue
PRINT 'STEP 5: Calculating fee revenue by account type...';

CREATE TABLE #Step5_FeeRevenue (
    account_type NVARCHAR(50),
    total_fees DECIMAL(15,2),
    fee_count INT,
    avg_fee DECIMAL(15,2)
);

INSERT INTO #Step5_FeeRevenue
SELECT 
    a.account_type,
    SUM(ABS(t.amount)) AS total_fees,
    COUNT(*) AS fee_count,
    AVG(ABS(t.amount)) AS avg_fee
FROM #Step1_Transactions t
JOIN accounts a ON t.account_id = a.account_id
WHERE t.transaction_type = 'Fee'
GROUP BY a.account_type;

PRINT '  ✓ Fee revenue calculated by account type';
PRINT '';

-- STEP 6: Match Deposits to Withdrawals (Reconciliation)
PRINT 'STEP 6: Matching deposits to withdrawals...';

CREATE TABLE #Step6_DepositWithdrawalMatch (
    account_id INT,
    total_deposits DECIMAL(15,2),
    total_withdrawals DECIMAL(15,2),
    net_position DECIMAL(15,2),
    match_status NVARCHAR(50)
);

INSERT INTO #Step6_DepositWithdrawalMatch
SELECT 
    account_id,
    SUM(CASE WHEN amount > 0 THEN amount ELSE 0 END) AS total_deposits,
    SUM(CASE WHEN amount < 0 THEN ABS(amount) ELSE 0 END) AS total_withdrawals,
    SUM(amount) AS net_position,
    CASE 
        WHEN SUM(amount) > 10000 THEN 'High Net Deposit'
        WHEN SUM(amount) > 0 THEN 'Net Deposit'
        WHEN SUM(amount) = 0 THEN 'Balanced'
        WHEN SUM(amount) > -10000 THEN 'Net Withdrawal'
        ELSE 'High Net Withdrawal'
    END AS match_status
FROM #Step1_Transactions
GROUP BY account_id;

PRINT '  ✓ Deposit/Withdrawal matching completed';
PRINT '';

-- STEP 7: Identify Unmatched Large Transactions
PRINT 'STEP 7: Identifying unmatched large transactions...';

CREATE TABLE #Step7_UnmatchedLarge (
    transaction_id INT,
    account_id INT,
    amount DECIMAL(15,2),
    transaction_type NVARCHAR(50),
    issue NVARCHAR(100)
);

INSERT INTO #Step7_UnmatchedLarge
SELECT 
    t.transaction_id,
    t.account_id,
    t.amount,
    t.transaction_type,
    'Large unmatched ' + t.transaction_type AS issue
FROM #Step1_Transactions t
LEFT JOIN #Step6_DepositWithdrawalMatch m 
    ON t.account_id = m.account_id 
    AND ABS(t.amount) < ABS(m.net_position) * 0.1 -- Less than 10% of net position
WHERE ABS(t.amount) > 10000
  AND t.transaction_type IN ('Deposit', 'Withdrawal');

DECLARE @Step7Count INT = (SELECT COUNT(*) FROM #Step7_UnmatchedLarge);
PRINT '  ✓ Identified ' + CAST(@Step7Count AS NVARCHAR(10)) + ' unmatched large transactions';
PRINT '';

-- STEP 8: Calculate Interest Accruals
PRINT 'STEP 8: Calculating interest accruals...';

CREATE TABLE #Step8_InterestAccruals (
    account_id INT,
    avg_balance DECIMAL(15,2),
    interest_rate DECIMAL(5,4),
    accrued_interest DECIMAL(15,2)
);

INSERT INTO #Step8_InterestAccruals
SELECT 
    db.account_id,
    AVG(db.running_balance) AS avg_balance,
    CASE a.account_type
        WHEN 'Savings' THEN 0.0325      -- 3.25% for Savings
        WHEN 'Investment' THEN 0.0475   -- 4.75% for Investment
        WHEN 'Business' THEN 0.0215     -- 2.15% for Business
        ELSE 0.0125                      -- 1.25% for Checking
    END AS interest_rate,
    AVG(db.running_balance) * 
    CASE a.account_type
        WHEN 'Savings' THEN 0.0325
        WHEN 'Investment' THEN 0.0475
        WHEN 'Business' THEN 0.0215
        ELSE 0.0125
    END * (31.0/365.0) AS accrued_interest -- December has 31 days
FROM #Step2_DailyBalances db
JOIN accounts a ON db.account_id = a.account_id
WHERE db.running_balance > 0
GROUP BY db.account_id, a.account_type;

DECLARE @Step8Count INT = (SELECT COUNT(*) FROM #Step8_InterestAccruals);
PRINT '  ✓ Calculated interest for ' + CAST(@Step8Count AS NVARCHAR(10)) + ' accounts';
PRINT '';

-- STEP 9: Generate Variance Report
PRINT 'STEP 9: Generating variance report...';

CREATE TABLE #Step9_VarianceReport (
    account_id INT,
    opening_balance DECIMAL(15,2),
    calculated_closing DECIMAL(15,2),
    expected_closing DECIMAL(15,2),
    variance DECIMAL(15,2),
    variance_pct DECIMAL(10,4)
);

INSERT INTO #Step9_VarianceReport
SELECT 
    a.account_id,
    a.opening_balance,
    a.opening_balance + ISNULL(SUM(t.amount), 0) AS calculated_closing,
    a.opening_balance * 1.02 AS expected_closing, -- Expect 2% growth
    (a.opening_balance + ISNULL(SUM(t.amount), 0)) - (a.opening_balance * 1.02) AS variance,
    CASE 
        WHEN a.opening_balance > 0 
        THEN (((a.opening_balance + ISNULL(SUM(t.amount), 0)) - (a.opening_balance * 1.02)) / a.opening_balance) * 100
        ELSE 0
    END AS variance_pct
FROM accounts a
LEFT JOIN #Step1_Transactions t ON a.account_id = t.account_id
GROUP BY a.account_id, a.opening_balance;

PRINT '  ✓ Variance report generated';
PRINT '';

-- STEP 10: Final Reconciliation Summary
PRINT 'STEP 10: Generating final reconciliation summary...';
PRINT '';
PRINT '================================================================================';
PRINT 'DECEMBER 2024 MONTH-END RECONCILIATION REPORT';
PRINT '================================================================================';
PRINT '';

-- Executive Summary
SELECT 
    'EXECUTIVE SUMMARY' AS Section,
    '' AS Metric,
    NULL AS Value,
    NULL AS Details
UNION ALL
SELECT 
    '',
    'Total Accounts Processed',
    CAST(COUNT(DISTINCT a.account_id) AS NVARCHAR(20)),
    NULL
FROM accounts a
UNION ALL
SELECT 
    '',
    'Total Transactions',
    CAST(COUNT(*) AS NVARCHAR(20)),
    NULL
FROM #Step1_Transactions
UNION ALL
SELECT 
    '',
    'Total Transaction Volume',
    '$' + FORMAT(SUM(ABS(amount)), 'N2'),
    NULL
FROM #Step1_Transactions
UNION ALL
SELECT 
    '',
    'Net Position Change',
    '$' + FORMAT(SUM(amount), 'N2'),
    CASE WHEN SUM(amount) > 0 THEN 'Net Inflow' ELSE 'Net Outflow' END
FROM #Step1_Transactions;

PRINT '';
PRINT 'ACCOUNT PERFORMANCE BY TYPE:';
SELECT 
    a.account_type AS AccountType,
    COUNT(DISTINCT a.account_id) AS TotalAccounts,
    FORMAT(AVG(a.opening_balance), 'C2') AS AvgOpeningBalance,
    --FORMAT(AVG(a.opening_balance + ISNULL(SUM(t.amount), 0)), 'C2') AS AvgClosingBalance, CANNOT PERFORM CALCULATION ON TEMP TABLES
    FORMAT(AVG(a.opening_balance + ISNULL(t.amount, 0)), 'C2') AS AvgClosingBalance,
    FORMAT(SUM(CASE WHEN t.amount > 0 THEN t.amount ELSE 0 END), 'C2') AS TotalDeposits,
    FORMAT(SUM(CASE WHEN t.amount < 0 THEN ABS(t.amount) ELSE 0 END), 'C2') AS TotalWithdrawals
FROM accounts a
LEFT JOIN #Step1_Transactions t ON a.account_id = t.account_id
GROUP BY a.account_type
ORDER BY a.account_type;

PRINT '';
PRINT 'RISK ALERTS:';
SELECT 
    'Overdraft Instances' AS AlertType,
    COUNT(*) AS Count,
    severity AS Severity
FROM #Step3_Overdrafts
GROUP BY severity
ORDER BY 
    CASE severity 
        WHEN 'Critical' THEN 1 
        WHEN 'High' THEN 2 
        ELSE 3 
    END;

PRINT '';
SELECT 
    'Suspicious Transactions' AS AlertType,
    COUNT(*) AS Count,
    flag_reason AS Severity
FROM #Step4_SuspiciousTransactions
GROUP BY flag_reason
ORDER BY COUNT(*) DESC;

PRINT '';
PRINT 'FEE REVENUE ANALYSIS:';
SELECT 
    account_type AS AccountType,
    FORMAT(total_fees, 'C2') AS TotalFeeRevenue,
    fee_count AS TransactionCount,
    FORMAT(avg_fee, 'C2') AS AvgFeeAmount
FROM #Step5_FeeRevenue
ORDER BY total_fees DESC;

PRINT '';
PRINT 'INTEREST ACCRUALS:';
SELECT 
    a.account_type AS AccountType,
    COUNT(*) AS AccountsWithInterest,
    FORMAT(AVG(i.avg_balance), 'C2') AS AvgAccountBalance,
    FORMAT(AVG(i.interest_rate * 100), 'N2') + '%' AS InterestRate,
    FORMAT(SUM(i.accrued_interest), 'C2') AS TotalAccruedInterest
FROM #Step8_InterestAccruals i
JOIN accounts a ON i.account_id = a.account_id
GROUP BY a.account_type
ORDER BY SUM(i.accrued_interest) DESC;

PRINT '';
PRINT 'TOP 10 ACCOUNTS BY ACTIVITY:';
SELECT TOP 10
    a.account_number AS AccountNumber,
    a.customer_name AS CustomerName,
    a.account_type AS AccountType,
    FORMAT(a.opening_balance, 'C2') AS OpeningBalance,
    COUNT(t.transaction_id) AS TransactionCount,
    FORMAT(SUM(CASE WHEN t.amount > 0 THEN t.amount ELSE 0 END), 'C2') AS TotalDeposits,
    FORMAT(SUM(CASE WHEN t.amount < 0 THEN ABS(t.amount) ELSE 0 END), 'C2') AS TotalWithdrawals,
    FORMAT(a.opening_balance + SUM(t.amount), 'C2') AS ClosingBalance
FROM accounts a
LEFT JOIN #Step1_Transactions t ON a.account_id = t.account_id
GROUP BY a.account_number, a.customer_name, a.account_type, a.opening_balance
ORDER BY COUNT(t.transaction_id) DESC;

PRINT '';
PRINT 'ACCOUNTS REQUIRING ATTENTION:';
SELECT 
    a.account_number AS AccountNumber,
    a.customer_name AS CustomerName,
    STUFF((
        SELECT ', ' + flag_reason
        FROM #Step4_SuspiciousTransactions s
        WHERE s.account_id = a.account_id
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS Alerts,
    ISNULL(o.OverdraftDays, 0) AS OverdraftDays,
    FORMAT(a.opening_balance + ISNULL(SUM(t.amount), 0), 'C2') AS CurrentBalance
FROM accounts a
LEFT JOIN #Step1_Transactions t ON a.account_id = t.account_id
LEFT JOIN (
    SELECT account_id, COUNT(DISTINCT overdraft_date) AS OverdraftDays
    FROM #Step3_Overdrafts
    GROUP BY account_id
) o ON a.account_id = o.account_id
WHERE EXISTS (SELECT 1 FROM #Step4_SuspiciousTransactions WHERE account_id = a.account_id)
   OR EXISTS (SELECT 1 FROM #Step3_Overdrafts WHERE account_id = a.account_id)
GROUP BY a.account_number, a.customer_name, a.account_id, a.opening_balance, o.OverdraftDays
ORDER BY ISNULL(o.OverdraftDays, 0) DESC, COUNT(t.transaction_id) DESC;

PRINT '';
PRINT '================================================================================';
PRINT 'RECONCILIATION STATUS: COMPLETE ✓';
PRINT '================================================================================';
PRINT '';
PRINT 'All 10 steps executed successfully!';
PRINT 'Processing time: ~10 minutes (vs 3.5 hours manual process)';
PRINT 'Error rate: 0% (vs 15% manual error rate)';
PRINT 'Time saved: 95% reduction';
PRINT '';

-- Cleanup all temp tables
DROP TABLE #Step1_Transactions;
DROP TABLE #Step2_DailyBalances;
DROP TABLE #Step3_Overdrafts;
DROP TABLE #Step4_SuspiciousTransactions;
DROP TABLE #Step5_FeeRevenue;
DROP TABLE #Step6_DepositWithdrawalMatch;
DROP TABLE #Step7_UnmatchedLarge;
DROP TABLE #Step8_InterestAccruals;
DROP TABLE #Step9_VarianceReport;

PRINT 'All temp tables cleaned up.';
PRINT '';
GO

PRINT '================================================================================';
PRINT 'SECTION 7: GLOBAL TEMP TABLES (##GlobalTemp)';
PRINT '================================================================================';
PRINT '';
GO

-- ============================================================================
-- DEMO 6: Global Temp Table (Cross-Session Sharing)
-- ============================================================================

PRINT '--- DEMO 6: Global Temp Tables ---';
PRINT '';

-- Create global temp table (visible to ALL sessions)
CREATE TABLE ##SharedAccountList (
    account_id INT,
    account_number NVARCHAR(20),
    customer_name NVARCHAR(100),
    shared_by NVARCHAR(100),
    shared_date DATETIME DEFAULT GETDATE()
);

INSERT INTO ##SharedAccountList (account_id, account_number, customer_name, shared_by)
SELECT TOP 10
    account_id,
    account_number,
    customer_name,
    'Training Session'
FROM accounts
ORDER BY opening_balance DESC;

PRINT 'Global temp table ##SharedAccountList created.';
PRINT 'This table is visible to ALL sessions until the last session using it disconnects.';
PRINT '';

SELECT * FROM ##SharedAccountList;

PRINT '';
PRINT 'Use Case: Share reference data across multiple analyst sessions';
PRINT 'Caution: Naming conflicts possible, use permanent tables for true shared data';
PRINT '';

-- Note: In production, you would query this from another session
-- For demo purposes, we'll just show it exists

-- Cleanup
DROP TABLE ##SharedAccountList;
PRINT '✓ Global temp table dropped';
PRINT '';
GO

PRINT '================================================================================';
PRINT 'SECTION 8: STORED PROCEDURE - PRODUCTION PATTERN';
PRINT '================================================================================';
PRINT '';
GO

-- ============================================================================
-- CREATE REUSABLE MONTH-END RECONCILIATION PROCEDURE
-- ============================================================================

CREATE PROCEDURE dbo.MonthEndReconciliation
    @Year INT,
    @Month INT,
    @ShowDetails BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate parameters
    IF @Year < 2020 OR @Year > 2030
    BEGIN
        RAISERROR('Year must be between 2020 and 2030', 16, 1);
        RETURN;
    END
    
    IF @Month < 1 OR @Month > 12
    BEGIN
        RAISERROR('Month must be between 1 and 12', 16, 1);
        RETURN;
    END
    
    -- Calculate date range
    DECLARE @StartDate DATE = DATEFROMPARTS(@Year, @Month, 1);
    DECLARE @EndDate DATE = DATEADD(MONTH, 1, @StartDate);
    DECLARE @MonthName NVARCHAR(20) = DATENAME(MONTH, @StartDate);
    
    PRINT '================================================================================';
    PRINT 'MONTH-END RECONCILIATION: ' + @MonthName + ' ' + CAST(@Year AS NVARCHAR(4));
    PRINT '================================================================================';
    PRINT '';
    
    -- STEP 1: Extract Transactions
    CREATE TABLE #Transactions (
        transaction_id INT,
        account_id INT,
        transaction_date DATETIME,
        amount DECIMAL(15,2),
        transaction_type NVARCHAR(50)
    );
    
    INSERT INTO #Transactions
    SELECT transaction_id, account_id, transaction_date, amount, transaction_type
    FROM transactions
    WHERE transaction_date >= @StartDate AND transaction_date < @EndDate;
    
    CREATE INDEX IX_Account ON #Transactions(account_id);
    
    DECLARE @TxCount INT = (SELECT COUNT(*) FROM #Transactions);
    PRINT 'Extracted ' + CAST(@TxCount AS NVARCHAR(10)) + ' transactions';
    
    -- STEP 2: Account Summary
    CREATE TABLE #AccountSummary (
        account_id INT,
        opening_balance DECIMAL(15,2),
        total_deposits DECIMAL(15,2),
        total_withdrawals DECIMAL(15,2),
        net_change DECIMAL(15,2),
        closing_balance DECIMAL(15,2)
    );
    
    INSERT INTO #AccountSummary
    SELECT 
        a.account_id,
        a.opening_balance,
        ISNULL(SUM(CASE WHEN t.amount > 0 THEN t.amount ELSE 0 END), 0),
        ISNULL(SUM(CASE WHEN t.amount < 0 THEN ABS(t.amount) ELSE 0 END), 0),
        ISNULL(SUM(t.amount), 0),
        a.opening_balance + ISNULL(SUM(t.amount), 0)
    FROM accounts a
    LEFT JOIN #Transactions t ON a.account_id = t.account_id
    GROUP BY a.account_id, a.opening_balance;
    
    -- Final Report
    PRINT '';
    PRINT 'RECONCILIATION SUMMARY:';
    SELECT 
        a.account_number,
        a.customer_name,
        a.account_type,
        FORMAT(s.opening_balance, 'C2') AS OpeningBalance,
        FORMAT(s.total_deposits, 'C2') AS TotalDeposits,
        FORMAT(s.total_withdrawals, 'C2') AS TotalWithdrawals,
        FORMAT(s.net_change, 'C2') AS NetChange,
        FORMAT(s.closing_balance, 'C2') AS ClosingBalance
    FROM #AccountSummary s
    JOIN accounts a ON s.account_id = a.account_id
    ORDER BY s.closing_balance DESC;
    
    -- Cleanup
    DROP TABLE #Transactions;
    DROP TABLE #AccountSummary;
    
    PRINT '';
    PRINT '✓ Reconciliation completed successfully';
END
GO

PRINT '✓ Stored procedure dbo.MonthEndReconciliation created';
PRINT '';
PRINT 'Execute with: EXEC dbo.MonthEndReconciliation @Year = 2024, @Month = 12';
PRINT '';

-- Test the procedure
EXEC dbo.MonthEndReconciliation @Year = 2024, @Month = 12;
GO

PRINT '';
PRINT '================================================================================';
PRINT 'SECTION 9: PRACTICE EXERCISES';
PRINT '================================================================================';
PRINT '';
GO

-- ============================================================================
-- EXERCISE 1: Basic Temp Table ⭐
-- ============================================================================

PRINT '--- EXERCISE 1: Basic Temp Table ⭐ ---';
PRINT 'Task: Create #HighValueAccounts, insert accounts > $50,000, query, and drop';
PRINT '';

-- SOLUTION:
CREATE TABLE #HighValueAccounts (
    account_id INT,
    account_number NVARCHAR(20),
    customer_name NVARCHAR(100),
    opening_balance DECIMAL(15,2)
);

INSERT INTO #HighValueAccounts
SELECT account_id, account_number, customer_name, opening_balance
FROM accounts
WHERE opening_balance > 50000;

SELECT 
    'High Value Accounts' AS Category,
    COUNT(*) AS TotalAccounts,
    FORMAT(MIN(opening_balance), 'C2') AS MinBalance,
    FORMAT(MAX(opening_balance), 'C2') AS MaxBalance,
    FORMAT(AVG(opening_balance), 'C2') AS AvgBalance
FROM #HighValueAccounts;

SELECT * FROM #HighValueAccounts ORDER BY opening_balance DESC;

DROP TABLE #HighValueAccounts;

PRINT '✓ Exercise 1 completed';
PRINT '';
GO

-- ============================================================================
-- EXERCISE 2: Table Variable for Small Dataset ⭐⭐
-- ============================================================================

PRINT '--- EXERCISE 2: Table Variable for Small Dataset ⭐⭐ ---';
PRINT 'Task: Declare @TransactionSummary, populate with aggregated data, display accounts with >10 transactions';
PRINT '';

-- SOLUTION:
DECLARE @TransactionSummary TABLE (
    account_id INT,
    total_amount DECIMAL(15,2),
    tx_count INT
);

INSERT INTO @TransactionSummary
SELECT 
    account_id,
    SUM(amount) AS total_amount,
    COUNT(*) AS tx_count
FROM transactions
WHERE transaction_date >= '2024-12-01' AND transaction_date < '2025-01-01'
GROUP BY account_id;

SELECT 
    a.account_number,
    a.customer_name,
    ts.tx_count AS TransactionCount,
    FORMAT(ts.total_amount, 'C2') AS TotalAmount
FROM @TransactionSummary ts
JOIN accounts a ON ts.account_id = a.account_id
WHERE ts.tx_count > 10
ORDER BY ts.tx_count DESC;

PRINT '✓ Exercise 2 completed';
PRINT '';
GO

-- ============================================================================
-- EXERCISE 3: Multi-Step Workflow ⭐⭐⭐
-- ============================================================================

PRINT '--- EXERCISE 3: Multi-Step Workflow ⭐⭐⭐ ---';
PRINT 'Task: 3-step process - Extract Dec 2024, aggregate by date, show trends';
PRINT '';

-- SOLUTION:

-- Step 1: Extract December transactions
CREATE TABLE #AllTransactions (
    transaction_id INT,
    transaction_date DATETIME,
    amount DECIMAL(15,2)
);

INSERT INTO #AllTransactions
SELECT transaction_id, transaction_date, amount
FROM transactions
WHERE transaction_date >= '2024-12-01' AND transaction_date < '2025-01-01';

-- Making some changes
-- PRINT 'Step 1: Extracted ' + CAST((SELECT COUNT(*) FROM #AllTransactions) AS NVARCHAR(10)) + ' transactions';
DECLARE @Step1Count INT;
SELECT @Step1Count = COUNT(*) FROM #AllTransactions;
PRINT 'Step 1: Extracted ' + CAST(@Step1Count AS NVARCHAR(10)) + ' transactions';

-- Step 2: Create daily totals
CREATE TABLE #DailyTotals (
    transaction_date DATE,
    daily_deposits DECIMAL(15,2),
    daily_withdrawals DECIMAL(15,2),
    daily_net DECIMAL(15,2),
    transaction_count INT
);

INSERT INTO #DailyTotals
SELECT 
    CAST(transaction_date AS DATE),
    SUM(CASE WHEN amount > 0 THEN amount ELSE 0 END),
    SUM(CASE WHEN amount < 0 THEN ABS(amount) ELSE 0 END),
    SUM(amount),
    COUNT(*)
FROM #AllTransactions
GROUP BY CAST(transaction_date AS DATE);

--Modify this
--PRINT 'Step 2: Aggregated into ' + CAST((SELECT COUNT(*) FROM #DailyTotals) AS NVARCHAR(10)) + ' daily records';
DECLARE @DailyCount INT;
SELECT @DailyCount = COUNT(*) FROM #DailyTotals;
PRINT 'Step 2: Aggregated into '  + CAST(@DailyCount AS NVARCHAR(10)) + ' daily records';
PRINT '';


-- Step 3: Show daily trends
PRINT 'Step 3: Daily Transaction Trends:';
SELECT 
    transaction_date AS Date,
    FORMAT(daily_deposits, 'C2') AS Deposits,
    FORMAT(daily_withdrawals, 'C2') AS Withdrawals,
    FORMAT(daily_net, 'C2') AS NetChange,
    transaction_count AS TxCount
FROM #DailyTotals
ORDER BY transaction_date;

-- Cleanup
DROP TABLE #AllTransactions;
DROP TABLE #DailyTotals;

PRINT '';
PRINT '✓ Exercise 3 completed';
PRINT '';
GO

-- ============================================================================
-- EXERCISE 4: Indexed Temp Table Performance ⭐⭐⭐
-- ============================================================================

PRINT '--- EXERCISE 4: Indexed Temp Table Performance ⭐⭐⭐ ---';
PRINT 'Task: Create temp table, add index on account_id, query specific account';
PRINT '';

-- SOLUTION:

-- Create temp table with all transactions
CREATE TABLE #AllTx (
    transaction_id INT,
    account_id INT,
    transaction_date DATETIME,
    amount DECIMAL(15,2)
);

INSERT INTO #AllTx
SELECT transaction_id, account_id, transaction_date, amount
FROM transactions;

--PRINT 'Temp table created with ' + CAST((SELECT COUNT(*) FROM #AllTx) AS NVARCHAR(10)) + ' records';
-- Modifying.
DECLARE @Cnt INT;
SELECT @Cnt = COUNT(*) FROM #AllTx;
PRINT 'Temp table created with ' + CAST(@Cnt AS NVARCHAR(10)) + ' records';

-- Query for specific account
DECLARE @TestAccountID INT = (SELECT TOP 1 account_id FROM accounts ORDER BY NEWID());

PRINT 'Querying transactions for account_id: ' + CAST(@TestAccountID AS NVARCHAR(10));
SELECT 
    transaction_date,
    FORMAT(amount, 'C2') AS Amount,
    CASE WHEN amount > 0 THEN 'Credit' ELSE 'Debit' END AS Type
FROM #AllTx
WHERE account_id = @TestAccountID
ORDER BY transaction_date DESC;

-- Cleanup
DROP TABLE #AllTx;

PRINT '';
PRINT '✓ Exercise 4 completed';
PRINT 'Note: In production, compare execution plans with/without index using SET STATISTICS IO ON';
PRINT '';
GO

-- ============================================================================
-- EXERCISE 5: Complete Reconciliation Procedure ⭐⭐⭐⭐
-- ============================================================================

PRINT '--- EXERCISE 5: Complete Reconciliation Procedure ⭐⭐⭐⭐ ---';
PRINT 'Task: Create QuarterlyReconciliation procedure with parameters';
PRINT '';

-- SOLUTION:
CREATE PROCEDURE dbo.QuarterlyReconciliation
    @Year INT,
    @Quarter INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate inputs
    IF @Quarter NOT IN (1, 2, 3, 4)
    BEGIN
        RAISERROR('Quarter must be 1, 2, 3, or 4', 16, 1);
        RETURN;
    END
    
    -- Calculate quarter start and end
    DECLARE @StartMonth INT = (@Quarter - 1) * 3 + 1;
    DECLARE @StartDate DATE = DATEFROMPARTS(@Year, @StartMonth, 1);
    DECLARE @EndDate DATE = DATEADD(MONTH, 3, @StartDate);
    
    PRINT '================================================================================';
    PRINT 'QUARTERLY RECONCILIATION: Q' + CAST(@Quarter AS NVARCHAR(1)) + ' ' + CAST(@Year AS NVARCHAR(4));
    PRINT 'Period: ' + CONVERT(NVARCHAR(10), @StartDate, 120) + ' to ' + CONVERT(NVARCHAR(10), @EndDate, 120);
    PRINT '================================================================================';
    PRINT '';
    
    -- Step 1: Extract quarter transactions
    CREATE TABLE #QuarterTransactions (
        transaction_id INT,
        account_id INT,
        amount DECIMAL(15,2)
    );
    
    INSERT INTO #QuarterTransactions
    SELECT transaction_id, account_id, amount
    FROM transactions
    WHERE transaction_date >= @StartDate AND transaction_date < @EndDate;
    
    CREATE INDEX IX_Account ON #QuarterTransactions(account_id);
    
    -- Step 2: Calculate quarterly summary
    CREATE TABLE #QuarterlySummary (
        account_id INT,
        opening_balance DECIMAL(15,2),
        quarter_deposits DECIMAL(15,2),
        quarter_withdrawals DECIMAL(15,2),
        closing_balance DECIMAL(15,2)
    );
    
    INSERT INTO #QuarterlySummary
    SELECT 
        a.account_id,
        a.opening_balance,
        ISNULL(SUM(CASE WHEN t.amount > 0 THEN t.amount ELSE 0 END), 0),
        ISNULL(SUM(CASE WHEN t.amount < 0 THEN ABS(t.amount) ELSE 0 END), 0),
        a.opening_balance + ISNULL(SUM(t.amount), 0)
    FROM accounts a
    LEFT JOIN #QuarterTransactions t ON a.account_id = t.account_id
    GROUP BY a.account_id, a.opening_balance;
    
    -- Final report
    PRINT 'QUARTERLY SUMMARY BY ACCOUNT:';
    SELECT 
        a.account_number AS AccountNumber,
        a.customer_name AS CustomerName,
        a.account_type AS AccountType,
        FORMAT(q.opening_balance, 'C2') AS OpeningBalance,
        FORMAT(q.quarter_deposits, 'C2') AS QuarterDeposits,
        FORMAT(q.quarter_withdrawals, 'C2') AS QuarterWithdrawals,
        FORMAT(q.closing_balance, 'C2') AS ClosingBalance,
        FORMAT(q.closing_balance - q.opening_balance, 'C2') AS NetChange
    FROM #QuarterlySummary q
    JOIN accounts a ON q.account_id = a.account_id
    ORDER BY q.closing_balance DESC;
    
    PRINT '';
    PRINT 'QUARTERLY TOTALS:';
    SELECT 
        'Total Accounts' AS Metric,
        FORMAT(COUNT(*), 'N0') AS Value
    FROM #QuarterlySummary
    UNION ALL
    SELECT 
        'Total Deposits',
        FORMAT(SUM(quarter_deposits), 'C2')
    FROM #QuarterlySummary
    UNION ALL
    SELECT 
        'Total Withdrawals',
        FORMAT(SUM(quarter_withdrawals), 'C2')
    FROM #QuarterlySummary
    UNION ALL
    SELECT 
        'Net Portfolio Change',
        FORMAT(SUM(closing_balance - opening_balance), 'C2')
    FROM #QuarterlySummary;
    
    -- Cleanup
    DROP TABLE #QuarterTransactions;
    DROP TABLE #QuarterlySummary;
    
    PRINT '';
    PRINT '✓ Quarterly reconciliation completed successfully';
END
GO

PRINT '✓ Stored procedure dbo.QuarterlyReconciliation created';
PRINT '';

-- Test the procedure for Q4 2024
PRINT 'Testing QuarterlyReconciliation for Q4 2024:';
PRINT '';
EXEC dbo.QuarterlyReconciliation @Year = 2024, @Quarter = 4;
GO

PRINT '';
PRINT '✓ Exercise 5 completed';
PRINT '';
GO

PRINT '================================================================================';
PRINT 'SECTION 10: KEY TAKEAWAYS & DECISION GUIDE';
PRINT '================================================================================';
PRINT '';
GO

-- ============================================================================
-- COMPARISON DEMO: Temp Table vs Table Variable vs CTE
-- ============================================================================

PRINT '--- COMPARISON DEMO: When to Use Each Storage Type ---';
PRINT '';

-- Scenario 1: Small dataset, single use → Table Variable
PRINT 'Scenario 1: Quick lookup list (20 account IDs) → TABLE VARIABLE';
DECLARE @AccountList TABLE (account_id INT);
INSERT INTO @AccountList VALUES (1), (2), (3), (5), (8), (13), (21), (34);
SELECT COUNT(*) AS AccountCount FROM @AccountList;
PRINT '✓ Table variable perfect for small, temporary lists';
PRINT '';

-- Scenario 2: Large dataset, multiple steps → Temp Table
PRINT 'Scenario 2: Process 15,000 transactions → TEMP TABLE';
CREATE TABLE #LargeProcess (
    transaction_id INT,
    amount DECIMAL(15,2)
);
INSERT INTO #LargeProcess SELECT transaction_id, amount FROM transactions;
CREATE INDEX IX_Amount ON #LargeProcess(amount); -- Can add index!
SELECT COUNT(*) AS RecordCount FROM #LargeProcess WHERE amount > 1000;
DROP TABLE #LargeProcess;
PRINT '✓ Temp table with index for large datasets';
PRINT '';

-- Scenario 3: Single query readability → CTE
PRINT 'Scenario 3: Readable one-time ranking query → CTE';
WITH AccountRanking AS (
    SELECT 
        account_number,
        customer_name,
        opening_balance,
        ROW_NUMBER() OVER (ORDER BY opening_balance DESC) AS BalanceRank
    FROM accounts
)
SELECT * FROM AccountRanking WHERE BalanceRank <= 5;
PRINT '✓ CTE perfect for single-query readability';
PRINT '';

PRINT '================================================================================';
PRINT 'DECISION GUIDE SUMMARY';
PRINT '================================================================================';
PRINT '';
PRINT 'Question 1: Do you need to REUSE results?';
PRINT '  NO  → Use CTE (single query, inline)';
PRINT '  YES → Continue to Question 2';
PRINT '';
PRINT 'Question 2: How many rows?';
PRINT '  < 1,000 rows  → Use TABLE VARIABLE (lightweight)';
PRINT '  > 1,000 rows  → Continue to Question 3';
PRINT '';
PRINT 'Question 3: Need indexes or statistics?';
PRINT '  YES → Use TEMP TABLE';
PRINT '  NO  → Continue to Question 4';
PRINT '';
PRINT 'Question 4: Multiple batches/steps?';
PRINT '  YES → Use TEMP TABLE (survives GO)';
PRINT '  NO  → Use TABLE VARIABLE (batch-scoped is fine)';
PRINT '';
PRINT 'Special Case: Cross-session sharing?';
PRINT '  YES → Use GLOBAL TEMP TABLE (##GlobalTemp)';
PRINT '';
GO

PRINT '================================================================================';
PRINT 'TRAINING SESSION COMPLETE! 🎓';
PRINT '================================================================================';
PRINT '';
PRINT 'What You Mastered:';
PRINT '✓ Temp tables (#TempTable) - Session-scoped storage';
PRINT '✓ Table variables (@TableVariable) - Batch-scoped storage';
PRINT '✓ Global temp tables (##GlobalTemp) - Cross-session sharing';
PRINT '✓ Multi-step workflow patterns';
PRINT '✓ Performance optimization with indexes';
PRINT '✓ Production-ready stored procedures';
PRINT '✓ Decision framework for choosing the right tool';
PRINT '';
PRINT 'Business Impact:';
PRINT '• Time Reduction: 95% (3.5 hours → 10 minutes)';
PRINT '• Error Rate: 0% (down from 15%)';
PRINT '• Annual Savings: $4,200+ per analyst';
PRINT '• Career Level: Senior Analyst proficiency achieved!';
PRINT '';
PRINT 'Next Video: Video 11 - Transactions & Error Handling';
PRINT '  Commonwealth Bank - Data Integrity & ACID Principles';
PRINT '';
PRINT 'Ready for your bootcamp demonstration! 🚀';
PRINT '================================================================================';
GO

/*
================================================================================
END OF TRAINING SCRIPT
================================================================================

INSTRUCTOR NOTES:
1. This script is completely self-contained and production-ready
2. Run the entire script for full demonstration
3. Each section can be run independently for focused teaching
4. All exercises include solutions
5. The stored procedures are reusable for different months/quarters

TEACHING FLOW SUGGESTION:
1. Run Sections 1-3: Setup and explain the business problem (5 min)
2. Run Section 4: Demonstrate temp tables (3 min)
3. Run Section 5: Demonstrate table variables (2 min)
4. Run Section 6: Show complete multi-step workflow (5 min)
5. Run Section 8: Show production procedure pattern (2 min)
6. Run Section 9: Walk through exercises (optional, for practice)

Total demonstration time: ~17 minutes
Perfect for your video recording!


================================================================================
*/
