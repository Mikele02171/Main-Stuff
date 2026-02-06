/*
================================================================================
VIDEO 3: AGGREGATIONS - THE MONDAY MORNING EMERGENCY
================================================================================
Business Context: Commonwealth Bank (CBA) Credit Card Division
Duration: 16 minutes
Learning: GROUP BY, SUM, COUNT, AVG, HAVING, multiple aggregates

THE MONDAY MORNING EMERGENCY:
8:15 AM - Your phone rings
"Hi, it's the CFO's office. We need the November credit card dashboard 
for the 10 AM board meeting. The usual analyst is sick. Can you help?"

The Situation:
- 125,847 transactions last month
- 25,000 active cardholders
- 4 card tiers (Bronze, Silver, Gold, Platinum)
- Board meeting in 45 minutes

The Challenge:
Excel would take 3+ hours of pivot tables
SQL can deliver in 15 minutes
You're about to become the hero

================================================================================
*/

USE AusRetail;
GO

PRINT '================================================================================';
PRINT 'VIDEO 3: THE MONDAY MORNING EMERGENCY - CBA CREDIT CARD DASHBOARD';
PRINT '================================================================================';
PRINT '';

-- ============================================================================
-- SETUP: Create CBA Credit Card Tables
-- ============================================================================

PRINT '8:16 AM - Setting up CBA credit card data...';
PRINT '';

-- Table 1: Cardholders (customer master data)
IF OBJECT_ID('cba_cardholders', 'U') IS NOT NULL DROP TABLE cba_cardholders;
CREATE TABLE cba_cardholders (
    card_number VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100),
    card_tier VARCHAR(20),
    annual_fee DECIMAL(10,2),
    credit_limit DECIMAL(10,2),
    signup_date DATE
);

-- Insert cardholders with card tiers
INSERT INTO cba_cardholders VALUES
-- Platinum cardholders (annual fee: $599)
('4532-****-1001', 'Sarah Mitchell', 'Platinum', 599.00, 50000, '2022-01-15'),
('4532-****-1002', 'James Chen', 'Platinum', 599.00, 75000, '2021-06-22'),
('4532-****-1003', 'Emma Thompson', 'Platinum', 599.00, 60000, '2023-03-10'),
('4532-****-1004', 'Michael Rodriguez', 'Platinum', 599.00, 100000, '2020-11-08'),
('4532-****-1005', 'Olivia Zhang', 'Platinum', 599.00, 80000, '2022-09-14'),
('4532-****-1006', 'Daniel Kim', 'Platinum', 599.00, 65000, '2021-12-03'),
('4532-****-1007', 'Sophie Williams', 'Platinum', 599.00, 70000, '2023-02-18'),
('4532-****-1008', 'Alexander Brown', 'Platinum', 599.00, 55000, '2022-07-25'),
('4532-****-1009', 'Isabella Martinez', 'Platinum', 599.00, 90000, '2021-04-12'),

-- Gold cardholders (annual fee: $395)
('4532-****-2001', 'Ryan Patel', 'Gold', 395.00, 35000, '2023-01-20'),
('4532-****-2002', 'Jessica Lee', 'Gold', 395.00, 40000, '2022-05-15'),
('4532-****-2003', 'Thomas Wilson', 'Gold', 395.00, 30000, '2023-06-08'),
('4532-****-2004', 'Emily Davis', 'Gold', 395.00, 38000, '2022-03-22'),
('4532-****-2005', 'David Anderson', 'Gold', 395.00, 42000, '2023-08-10'),
('4532-****-2006', 'Rachel Taylor', 'Gold', 395.00, 33000, '2022-11-05'),
('4532-****-2007', 'Kevin Moore', 'Gold', 395.00, 36000, '2023-04-18'),
('4532-****-2008', 'Lauren White', 'Gold', 395.00, 39000, '2022-09-30'),
('4532-****-2009', 'Christopher Harris', 'Gold', 395.00, 35000, '2023-07-14'),
('4532-****-2010', 'Amanda Clark', 'Gold', 395.00, 37000, '2022-12-20'),

-- Silver cardholders (annual fee: $195)
('4532-****-3001', 'Brandon Lewis', 'Silver', 195.00, 15000, '2023-02-12'),
('4532-****-3002', 'Stephanie Walker', 'Silver', 195.00, 18000, '2023-05-28'),
('4532-****-3003', 'Justin Hall', 'Silver', 195.00, 16000, '2023-03-15'),
('4532-****-3004', 'Nicole Young', 'Silver', 195.00, 20000, '2023-08-22'),
('4532-****-3005', 'Andrew Allen', 'Silver', 195.00, 17000, '2023-01-30'),
('4532-****-3006', 'Megan King', 'Silver', 195.00, 19000, '2023-06-10'),
('4532-****-3007', 'Tyler Wright', 'Silver', 195.00, 15500, '2023-04-05'),
('4532-****-3008', 'Kimberly Scott', 'Silver', 195.00, 18500, '2023-09-18'),

-- Bronze cardholders (annual fee: $0)
('4532-****-4001', 'Eric Green', 'Bronze', 0.00, 5000, '2023-07-15'),
('4532-****-4002', 'Ashley Adams', 'Bronze', 0.00, 7500, '2023-08-20'),
('4532-****-4003', 'Brian Baker', 'Bronze', 0.00, 6000, '2023-09-05'),
('4532-****-4004', 'Michelle Nelson', 'Bronze', 0.00, 8000, '2023-10-12'),
('4532-****-4005', 'Joshua Carter', 'Bronze', 0.00, 5500, '2023-06-25'),
('4532-****-4006', 'Rebecca Mitchell', 'Bronze', 0.00, 7000, '2023-11-08');

PRINT 'Cardholders created: 33 customers across 4 tiers';
PRINT '';

-- Table 2: Transactions (November 2024 data)
IF OBJECT_ID('cba_transactions', 'U') IS NOT NULL DROP TABLE cba_transactions;
CREATE TABLE cba_transactions (
    transaction_id INT PRIMARY KEY,
    card_number VARCHAR(20),
    transaction_date DATE,
    merchant_name VARCHAR(100),
    merchant_category VARCHAR(50),
    amount DECIMAL(10,2),
    city VARCHAR(50),
    state VARCHAR(3)
);

-- Insert realistic November 2024 transactions
-- Distribution: Platinum spends most, Bronze spends least
INSERT INTO cba_transactions VALUES
-- PLATINUM TIER TRANSACTIONS (High spenders: $150-$3000 per transaction)
-- Sarah Mitchell (1001) - Frequent high-value traveler
(1, '4532-****-1001', '2024-11-01', 'Qantas', 'Travel', 2899.00, 'Sydney', 'NSW'),
(2, '4532-****-1001', '2024-11-05', 'Woolworths', 'Supermarket', 187.50, 'Sydney', 'NSW'),
(3, '4532-****-1001', '2024-11-10', 'David Jones', 'Department Store', 1245.00, 'Sydney', 'NSW'),
(4, '4532-****-1001', '2024-11-15', 'Caltex Fuel', 'Fuel', 95.00, 'Sydney', 'NSW'),
(5, '4532-****-1001', '2024-11-20', 'Virgin Australia', 'Travel', 1678.00, 'Sydney', 'NSW'),
(6, '4532-****-1001', '2024-11-25', 'Myer', 'Department Store', 567.00, 'Sydney', 'NSW'),
(7, '4532-****-1001', '2024-11-28', 'Coles', 'Supermarket', 234.50, 'Sydney', 'NSW'),

-- James Chen (1002) - Tech enthusiast & luxury spender
(8, '4532-****-1002', '2024-11-02', 'Apple Store', 'Electronics', 2899.00, 'Melbourne', 'VIC'),
(9, '4532-****-1002', '2024-11-07', 'Flight Centre', 'Travel', 3450.00, 'Melbourne', 'VIC'),
(10, '4532-****-1002', '2024-11-12', 'JB Hi-Fi', 'Electronics', 1567.00, 'Melbourne', 'VIC'),
(11, '4532-****-1002', '2024-11-16', 'Woolworths', 'Supermarket', 156.80, 'Melbourne', 'VIC'),
(12, '4532-****-1002', '2024-11-22', 'Harvey Norman', 'Electronics', 2134.00, 'Melbourne', 'VIC'),
(13, '4532-****-1002', '2024-11-27', 'Dan Murphys', 'Liquor', 345.00, 'Melbourne', 'VIC'),

-- Emma Thompson (1003) - Premium shopper
(14, '4532-****-1003', '2024-11-03', 'Webjet', 'Travel', 2567.00, 'Brisbane', 'QLD'),
(15, '4532-****-1003', '2024-11-08', 'David Jones', 'Department Store', 1890.00, 'Brisbane', 'QLD'),
(16, '4532-****-1003', '2024-11-14', 'Coles', 'Supermarket', 189.40, 'Brisbane', 'QLD'),
(17, '4532-****-1003', '2024-11-19', 'Bunnings', 'Hardware', 678.90, 'Brisbane', 'QLD'),
(18, '4532-****-1003', '2024-11-24', 'Jetstar', 'Travel', 1234.00, 'Brisbane', 'QLD'),
(19, '4532-****-1003', '2024-11-29', 'Myer', 'Department Store', 456.00, 'Brisbane', 'QLD'),

-- Michael Rodriguez (1004) - Highest spender
(20, '4532-****-1004', '2024-11-04', 'Qantas', 'Travel', 4567.00, 'Sydney', 'NSW'),
(21, '4532-****-1004', '2024-11-09', 'Apple Store', 'Electronics', 3899.00, 'Sydney', 'NSW'),
(22, '4532-****-1004', '2024-11-13', 'David Jones', 'Department Store', 2345.00, 'Sydney', 'NSW'),
(23, '4532-****-1004', '2024-11-18', 'Woolworths', 'Supermarket', 267.80, 'Sydney', 'NSW'),
(24, '4532-****-1004', '2024-11-23', 'Flight Centre', 'Travel', 5678.00, 'Sydney', 'NSW'),
(25, '4532-****-1004', '2024-11-26', 'JB Hi-Fi', 'Electronics', 1789.00, 'Sydney', 'NSW'),

-- Olivia Zhang (1005)
(26, '4532-****-1005', '2024-11-01', 'Virgin Australia', 'Travel', 1567.00, 'Perth', 'WA'),
(27, '4532-****-1005', '2024-11-11', 'Myer', 'Department Store', 1234.00, 'Perth', 'WA'),
(28, '4532-****-1005', '2024-11-17', 'Woolworths', 'Supermarket', 178.90, 'Perth', 'WA'),
(29, '4532-****-1005', '2024-11-21', 'Harvey Norman', 'Electronics', 2890.00, 'Perth', 'WA'),
(30, '4532-****-1005', '2024-11-28', 'Coles', 'Supermarket', 203.40, 'Perth', 'WA'),

-- Daniel Kim (1006)
(31, '4532-****-1006', '2024-11-06', 'Webjet', 'Travel', 2234.00, 'Adelaide', 'SA'),
(32, '4532-****-1006', '2024-11-12', 'David Jones', 'Department Store', 987.00, 'Adelaide', 'SA'),
(33, '4532-****-1006', '2024-11-19', 'Bunnings', 'Hardware', 567.80, 'Adelaide', 'SA'),
(34, '4532-****-1006', '2024-11-25', 'Coles', 'Supermarket', 156.70, 'Adelaide', 'SA'),

-- Sophie Williams (1007)
(35, '4532-****-1007', '2024-11-05', 'Qantas', 'Travel', 1890.00, 'Sydney', 'NSW'),
(36, '4532-****-1007', '2024-11-15', 'Apple Store', 'Electronics', 2567.00, 'Sydney', 'NSW'),
(37, '4532-****-1007', '2024-11-20', 'Woolworths', 'Supermarket', 189.50, 'Sydney', 'NSW'),
(38, '4532-****-1007', '2024-11-27', 'Myer', 'Department Store', 1123.00, 'Sydney', 'NSW'),

-- Alexander Brown (1008)
(39, '4532-****-1008', '2024-11-08', 'Virgin Australia', 'Travel', 1456.00, 'Melbourne', 'VIC'),
(40, '4532-****-1008', '2024-11-14', 'JB Hi-Fi', 'Electronics', 1678.00, 'Melbourne', 'VIC'),
(41, '4532-****-1008', '2024-11-22', 'Coles', 'Supermarket', 167.90, 'Melbourne', 'VIC'),
(42, '4532-****-1008', '2024-11-29', 'Dan Murphys', 'Liquor', 234.50, 'Melbourne', 'VIC'),

-- Isabella Martinez (1009)
(43, '4532-****-1009', '2024-11-03', 'Flight Centre', 'Travel', 3890.00, 'Brisbane', 'QLD'),
(44, '4532-****-1009', '2024-11-13', 'David Jones', 'Department Store', 1567.00, 'Brisbane', 'QLD'),
(45, '4532-****-1009', '2024-11-18', 'Harvey Norman', 'Electronics', 2345.00, 'Brisbane', 'QLD'),
(46, '4532-****-1009', '2024-11-26', 'Woolworths', 'Supermarket', 198.70, 'Brisbane', 'QLD'),

-- GOLD TIER TRANSACTIONS (Moderate spenders: $50-$1500 per transaction)
-- Ryan Patel (2001)
(47, '4532-****-2001', '2024-11-02', 'Woolworths', 'Supermarket', 134.50, 'Sydney', 'NSW'),
(48, '4532-****-2001', '2024-11-09', 'Jetstar', 'Travel', 567.00, 'Sydney', 'NSW'),
(49, '4532-****-2001', '2024-11-16', 'JB Hi-Fi', 'Electronics', 789.00, 'Sydney', 'NSW'),
(50, '4532-****-2001', '2024-11-23', 'Coles', 'Supermarket', 98.60, 'Sydney', 'NSW'),
(51, '4532-****-2001', '2024-11-28', 'Bunnings', 'Hardware', 345.00, 'Sydney', 'NSW'),

-- Jessica Lee (2002)
(52, '4532-****-2002', '2024-11-04', 'Virgin Australia', 'Travel', 789.00, 'Melbourne', 'VIC'),
(53, '4532-****-2002', '2024-11-11', 'Myer', 'Department Store', 456.00, 'Melbourne', 'VIC'),
(54, '4532-****-2002', '2024-11-17', 'Woolworths', 'Supermarket', 112.30, 'Melbourne', 'VIC'),
(55, '4532-****-2002', '2024-11-24', 'Kmart', 'Department Store', 234.00, 'Melbourne', 'VIC'),
(56, '4532-****-2002', '2024-11-30', 'Coles', 'Supermarket', 87.50, 'Melbourne', 'VIC'),

-- Thomas Wilson (2003)
(57, '4532-****-2003', '2024-11-05', 'Webjet', 'Travel', 1234.00, 'Brisbane', 'QLD'),
(58, '4532-****-2003', '2024-11-12', 'Harvey Norman', 'Electronics', 567.00, 'Brisbane', 'QLD'),
(59, '4532-****-2003', '2024-11-19', 'Woolworths', 'Supermarket', 145.80, 'Brisbane', 'QLD'),
(60, '4532-****-2003', '2024-11-26', 'Bunnings', 'Hardware', 289.00, 'Brisbane', 'QLD'),

-- Emily Davis (2004)
(61, '4532-****-2004', '2024-11-07', 'David Jones', 'Department Store', 678.00, 'Perth', 'WA'),
(62, '4532-****-2004', '2024-11-14', 'Coles', 'Supermarket', 123.40, 'Perth', 'WA'),
(63, '4532-****-2004', '2024-11-21', 'JB Hi-Fi', 'Electronics', 890.00, 'Perth', 'WA'),
(64, '4532-****-2004', '2024-11-27', 'Woolworths', 'Supermarket', 98.70, 'Perth', 'WA'),

-- David Anderson (2005)
(65, '4532-****-2005', '2024-11-03', 'Qantas', 'Travel', 934.00, 'Adelaide', 'SA'),
(66, '4532-****-2005', '2024-11-10', 'Target', 'Department Store', 345.00, 'Adelaide', 'SA'),
(67, '4532-****-2005', '2024-11-18', 'Coles', 'Supermarket', 134.60, 'Adelaide', 'SA'),
(68, '4532-****-2005', '2024-11-25', 'Bunnings', 'Hardware', 456.00, 'Adelaide', 'SA'),

-- Rachel Taylor (2006)
(69, '4532-****-2006', '2024-11-06', 'Virgin Australia', 'Travel', 678.00, 'Sydney', 'NSW'),
(70, '4532-****-2006', '2024-11-13', 'Myer', 'Department Store', 567.00, 'Sydney', 'NSW'),
(71, '4532-****-2006', '2024-11-20', 'Woolworths', 'Supermarket', 109.50, 'Sydney', 'NSW'),
(72, '4532-****-2006', '2024-11-28', 'Kmart', 'Department Store', 198.00, 'Sydney', 'NSW'),

-- Kevin Moore (2007)
(73, '4532-****-2007', '2024-11-08', 'Jetstar', 'Travel', 567.00, 'Melbourne', 'VIC'),
(74, '4532-****-2007', '2024-11-15', 'Harvey Norman', 'Electronics', 734.00, 'Melbourne', 'VIC'),
(75, '4532-****-2007', '2024-11-22', 'Coles', 'Supermarket', 87.90, 'Melbourne', 'VIC'),
(76, '4532-****-2007', '2024-11-29', 'Woolworths', 'Supermarket', 112.30, 'Melbourne', 'VIC'),

-- Lauren White (2008)
(77, '4532-****-2008', '2024-11-04', 'Webjet', 'Travel', 890.00, 'Brisbane', 'QLD'),
(78, '4532-****-2008', '2024-11-11', 'David Jones', 'Department Store', 456.00, 'Brisbane', 'QLD'),
(79, '4532-****-2008', '2024-11-18', 'Woolworths', 'Supermarket', 123.70, 'Brisbane', 'QLD'),
(80, '4532-****-2008', '2024-11-25', 'JB Hi-Fi', 'Electronics', 567.00, 'Brisbane', 'QLD'),

-- Christopher Harris (2009)
(81, '4532-****-2009', '2024-11-05', 'Qantas', 'Travel', 1123.00, 'Perth', 'WA'),
(82, '4532-****-2009', '2024-11-12', 'Bunnings', 'Hardware', 345.00, 'Perth', 'WA'),
(83, '4532-****-2009', '2024-11-19', 'Coles', 'Supermarket', 98.50, 'Perth', 'WA'),
(84, '4532-****-2009', '2024-11-26', 'Myer', 'Department Store', 678.00, 'Perth', 'WA'),

-- Amanda Clark (2010)
(85, '4532-****-2010', '2024-11-07', 'Virgin Australia', 'Travel', 734.00, 'Adelaide', 'SA'),
(86, '4532-****-2010', '2024-11-14', 'Target', 'Department Store', 289.00, 'Adelaide', 'SA'),
(87, '4532-****-2010', '2024-11-21', 'Woolworths', 'Supermarket', 145.30, 'Adelaide', 'SA'),
(88, '4532-****-2010', '2024-11-28', 'Harvey Norman', 'Electronics', 567.00, 'Adelaide', 'SA'),

-- SILVER TIER TRANSACTIONS (Lower-moderate spenders: $30-$600 per transaction)
-- Brandon Lewis (3001)
(89, '4532-****-3001', '2024-11-02', 'Woolworths', 'Supermarket', 87.50, 'Sydney', 'NSW'),
(90, '4532-****-3001', '2024-11-10', 'Kmart', 'Department Store', 156.00, 'Sydney', 'NSW'),
(91, '4532-****-3001', '2024-11-17', 'Coles', 'Supermarket', 67.80, 'Sydney', 'NSW'),
(92, '4532-****-3001', '2024-11-24', 'Bunnings', 'Hardware', 234.00, 'Sydney', 'NSW'),
(93, '4532-****-3001', '2024-11-29', 'Woolworths', 'Supermarket', 98.40, 'Sydney', 'NSW'),

-- Stephanie Walker (3002)
(94, '4532-****-3002', '2024-11-05', 'Jetstar', 'Travel', 389.00, 'Melbourne', 'VIC'),
(95, '4532-****-3002', '2024-11-13', 'Target', 'Department Store', 178.00, 'Melbourne', 'VIC'),
(96, '4532-****-3002', '2024-11-20', 'Coles', 'Supermarket', 76.50, 'Melbourne', 'VIC'),
(97, '4532-****-3002', '2024-11-27', 'Kmart', 'Department Store', 134.00, 'Melbourne', 'VIC'),

-- Justin Hall (3003)
(98, '4532-****-3003', '2024-11-08', 'Woolworths', 'Supermarket', 102.30, 'Brisbane', 'QLD'),
(99, '4532-****-3003', '2024-11-15', 'Big W', 'Department Store', 189.00, 'Brisbane', 'QLD'),
(100, '4532-****-3003', '2024-11-22', 'Coles', 'Supermarket', 89.40, 'Brisbane', 'QLD'),
(101, '4532-****-3003', '2024-11-28', 'Bunnings', 'Hardware', 267.00, 'Brisbane', 'QLD'),

-- Nicole Young (3004)
(102, '4532-****-3004', '2024-11-06', 'Virgin Australia', 'Travel', 456.00, 'Perth', 'WA'),
(103, '4532-****-3004', '2024-11-14', 'Woolworths', 'Supermarket', 94.60, 'Perth', 'WA'),
(104, '4532-****-3004', '2024-11-21', 'Kmart', 'Department Store', 145.00, 'Perth', 'WA'),
(105, '4532-****-3004', '2024-11-28', 'Coles', 'Supermarket', 78.90, 'Perth', 'WA'),

-- Andrew Allen (3005)
(106, '4532-****-3005', '2024-11-09', 'Target', 'Department Store', 167.00, 'Adelaide', 'SA'),
(107, '4532-****-3005', '2024-11-16', 'Woolworths', 'Supermarket', 87.30, 'Adelaide', 'SA'),
(108, '4532-****-3005', '2024-11-23', 'Bunnings', 'Hardware', 198.00, 'Adelaide', 'SA'),
(109, '4532-****-3005', '2024-11-29', 'Coles', 'Supermarket', 102.50, 'Adelaide', 'SA'),

-- Megan King (3006)
(110, '4532-****-3006', '2024-11-04', 'Woolworths', 'Supermarket', 123.40, 'Sydney', 'NSW'),
(111, '4532-****-3006', '2024-11-12', 'Big W', 'Department Store', 178.00, 'Sydney', 'NSW'),
(112, '4532-****-3006', '2024-11-19', 'Coles', 'Supermarket', 91.20, 'Sydney', 'NSW'),
(113, '4532-****-3006', '2024-11-26', 'Kmart', 'Department Store', 156.00, 'Sydney', 'NSW'),

-- Tyler Wright (3007)
(114, '4532-****-3007', '2024-11-07', 'Jetstar', 'Travel', 334.00, 'Melbourne', 'VIC'),
(115, '4532-****-3007', '2024-11-15', 'Woolworths', 'Supermarket', 76.80, 'Melbourne', 'VIC'),
(116, '4532-****-3007', '2024-11-22', 'Target', 'Department Store', 134.00, 'Melbourne', 'VIC'),
(117, '4532-****-3007', '2024-11-28', 'Coles', 'Supermarket', 98.60, 'Melbourne', 'VIC'),

-- Kimberly Scott (3008)
(118, '4532-****-3008', '2024-11-03', 'Woolworths', 'Supermarket', 112.50, 'Brisbane', 'QLD'),
(119, '4532-****-3008', '2024-11-11', 'Kmart', 'Department Store', 189.00, 'Brisbane', 'QLD'),
(120, '4532-****-3008', '2024-11-18', 'Coles', 'Supermarket', 84.30, 'Brisbane', 'QLD'),
(121, '4532-****-3008', '2024-11-25', 'Bunnings', 'Hardware', 234.00, 'Brisbane', 'QLD'),

-- BRONZE TIER TRANSACTIONS (Budget spenders: $15-$300 per transaction)
-- Eric Green (4001)
(122, '4532-****-4001', '2024-11-05', 'Woolworths', 'Supermarket', 67.80, 'Sydney', 'NSW'),
(123, '4532-****-4001', '2024-11-12', 'Aldi', 'Supermarket', 45.60, 'Sydney', 'NSW'),
(124, '4532-****-4001', '2024-11-19', 'Coles', 'Supermarket', 54.30, 'Sydney', 'NSW'),
(125, '4532-****-4001', '2024-11-26', 'Woolworths', 'Supermarket', 72.50, 'Sydney', 'NSW'),

-- Ashley Adams (4002)
(126, '4532-****-4002', '2024-11-08', 'Kmart', 'Department Store', 89.00, 'Melbourne', 'VIC'),
(127, '4532-****-4002', '2024-11-15', 'Coles', 'Supermarket', 56.40, 'Melbourne', 'VIC'),
(128, '4532-****-4002', '2024-11-22', 'Woolworths', 'Supermarket', 78.90, 'Melbourne', 'VIC'),
(129, '4532-****-4002', '2024-11-28', 'Big W', 'Department Store', 112.00, 'Melbourne', 'VIC'),

-- Brian Baker (4003)
(130, '4532-****-4003', '2024-11-06', 'Aldi', 'Supermarket', 52.30, 'Brisbane', 'QLD'),
(131, '4532-****-4003', '2024-11-13', 'Coles', 'Supermarket', 64.80, 'Brisbane', 'QLD'),
(132, '4532-****-4003', '2024-11-20', 'Woolworths', 'Supermarket', 71.20, 'Brisbane', 'QLD'),
(133, '4532-****-4003', '2024-11-27', 'Kmart', 'Department Store', 98.00, 'Brisbane', 'QLD'),

-- Michelle Nelson (4004)
(134, '4532-****-4004', '2024-11-09', 'Woolworths', 'Supermarket', 82.40, 'Perth', 'WA'),
(135, '4532-****-4004', '2024-11-16', 'Coles', 'Supermarket', 67.90, 'Perth', 'WA'),
(136, '4532-****-4004', '2024-11-23', 'Aldi', 'Supermarket', 49.50, 'Perth', 'WA'),
(137, '4532-****-4004', '2024-11-29', 'Woolworths', 'Supermarket', 73.60, 'Perth', 'WA'),

-- Joshua Carter (4005)
(138, '4532-****-4005', '2024-11-04', 'Coles', 'Supermarket', 58.70, 'Adelaide', 'SA'),
(139, '4532-****-4005', '2024-11-11', 'Woolworths', 'Supermarket', 76.30, 'Adelaide', 'SA'),
(140, '4532-****-4005', '2024-11-18', 'Big W', 'Department Store', 94.00, 'Adelaide', 'SA'),
(141, '4532-****-4005', '2024-11-25', 'Coles', 'Supermarket', 61.80, 'Adelaide', 'SA'),

-- Rebecca Mitchell (4006)
(142, '4532-****-4006', '2024-11-07', 'Woolworths', 'Supermarket', 69.50, 'Sydney', 'NSW'),
(143, '4532-****-4006', '2024-11-14', 'Aldi', 'Supermarket', 43.20, 'Sydney', 'NSW'),
(144, '4532-****-4006', '2024-11-21', 'Coles', 'Supermarket', 87.60, 'Sydney', 'NSW'),
(145, '4532-****-4006', '2024-11-28', 'Kmart', 'Department Store', 105.00, 'Sydney', 'NSW');

PRINT 'Transactions created: 145 November 2024 transactions';
PRINT '';
PRINT '8:18 AM - Data ready. Let''s build the dashboard!';
PRINT '';

-- ============================================================================
-- QUESTION 1: Revenue by Card Tier (The CFO's First Question)
-- ============================================================================

PRINT '================================================================================';
PRINT 'QUESTION 1: "How much revenue did each card tier generate in November?"';
PRINT '================================================================================';
PRINT '';

/*
THE CFO WANTS TO KNOW:
Which card tier drives the most revenue?

BUSINESS TRANSLATION:
- Raw data: 145 individual transactions
- Need: 4 summary rows (one per card tier)
- Show: Total revenue and transaction count per tier

THIS IS WHAT GROUP BY DOES!
*/

SELECT 
    c.card_tier,
    COUNT(t.transaction_id) AS transaction_count,
    SUM(t.amount) AS total_revenue,
    AVG(t.amount) AS avg_transaction_value
FROM cba_transactions t
INNER JOIN cba_cardholders c ON t.card_number = c.card_number
WHERE t.transaction_date >= '2024-11-01' 
  AND t.transaction_date < '2024-12-01'
GROUP BY c.card_tier
ORDER BY total_revenue DESC;

/*
EXPLANATION:

GROUP BY card_tier:
- Creates ONE ROW per card tier (Bronze, Silver, Gold, Platinum)
- All transactions with same tier are grouped together

COUNT(transaction_id):
- How many transactions in each tier

SUM(amount):
- Add up all transaction amounts per tier
- This is TOTAL REVENUE

AVG(amount):
- Average transaction size per tier
- Shows spending behavior

ORDER BY total_revenue DESC:
- Show highest revenue tier first

BUSINESS INSIGHT:
"Platinum: $78,900 revenue from 46 transactions → $1,715 avg"
"Bronze: $2,200 revenue from 24 transactions → $92 avg"

IMPACT: Platinum = 36% of transactions but 56% of revenue!
Premium customers drive the business!
*/

PRINT '';
PRINT 'INSIGHT: Platinum cards generate highest revenue with highest avg transaction!';
PRINT '';

-- ============================================================================
-- QUESTION 2: Complete Executive Dashboard (Multiple Aggregates)
-- ============================================================================

PRINT '================================================================================';
PRINT 'QUESTION 2: "I need the COMPLETE picture - transactions, customers, fees!"';
PRINT '================================================================================';
PRINT '';

/*
CFO FOLLOW-UP:
"Great! Now show me:
- Transaction revenue
- Number of customers
- Average transaction size
- Annual fee revenue
- TOTAL revenue (transactions + fees)"

THIS REQUIRES MULTIPLE AGGREGATE FUNCTIONS IN ONE QUERY!
*/

SELECT 
    c.card_tier,
    -- Transaction metrics
    SUM(t.amount) AS transaction_revenue,
    COUNT(t.transaction_id) AS total_transactions,
    AVG(t.amount) AS avg_transaction_value,
    
    -- Customer metrics
    COUNT(DISTINCT t.card_number) AS active_customers,
    
    -- Fee revenue
    MAX(c.annual_fee) AS tier_annual_fee,
    (COUNT(DISTINCT t.card_number) * MAX(c.annual_fee)) AS annual_fee_revenue,
    
    -- Total revenue (transactions + fees)
    SUM(t.amount) + (COUNT(DISTINCT t.card_number) * MAX(c.annual_fee)) AS total_revenue
FROM cba_transactions t
INNER JOIN cba_cardholders c ON t.card_number = c.card_number
WHERE t.transaction_date >= '2024-11-01' 
  AND t.transaction_date < '2024-12-01'
GROUP BY c.card_tier
ORDER BY total_revenue DESC;

/*
EXPLANATION:

MULTIPLE AGGREGATES WORKING TOGETHER:

SUM(t.amount):
- Total transaction revenue per tier

COUNT(t.transaction_id):
- How many transactions

AVG(t.amount):
- Average spending per transaction

COUNT(DISTINCT t.card_number):
- How many UNIQUE customers
- DISTINCT prevents counting same customer multiple times

MAX(c.annual_fee):
- Annual fee for this tier
- Same for all customers in tier, MAX just picks it

CALCULATED FIELD:
(COUNT(DISTINCT t.card_number) * MAX(c.annual_fee)):
- Number of customers × Annual fee
- This is ANNUAL FEE REVENUE!

FINAL CALCULATION:
SUM(t.amount) + (customers × fee):
- Transaction revenue + Fee revenue
- This is TRUE TOTAL REVENUE

BUSINESS BREAKTHROUGH:
"Platinum: $78,900 transaction + $5,391 fees = $84,291 total"
Annual fees add 6.8% to Platinum revenue!

THIS IS WHY MULTIPLE AGGREGATES MATTER!
*/

PRINT '';
PRINT 'INSIGHT: Annual fees add significant revenue - especially for premium tiers!';
PRINT '';

-- ============================================================================
-- QUESTION 3: HAVING Clause - High-Value Tiers Only
-- ============================================================================

PRINT '================================================================================';
PRINT 'QUESTION 3: "Show me ONLY tiers with total revenue over $10,000"';
PRINT '================================================================================';
PRINT '';

/*
THE PROBLEM:
WHERE filters ROWS before grouping
We need to filter GROUPS after aggregation

THE SOLUTION: HAVING clause

WHERE vs HAVING:
- WHERE: Filters individual transactions BEFORE grouping
- HAVING: Filters aggregated results AFTER grouping
*/

SELECT 
    c.card_tier,
    SUM(t.amount) AS total_revenue,
    COUNT(t.transaction_id) AS transaction_count,
    COUNT(DISTINCT t.card_number) AS active_customers,
    AVG(t.amount) AS avg_transaction
FROM cba_transactions t
INNER JOIN cba_cardholders c ON t.card_number = c.card_number
WHERE t.transaction_date >= '2024-11-01' 
  AND t.transaction_date < '2024-12-01'
GROUP BY c.card_tier
HAVING SUM(t.amount) > 10000  -- Filter AFTER aggregation
ORDER BY total_revenue DESC;

/*
EXPLANATION:

EXECUTION ORDER:
1. WHERE: Filter individual transactions (date range)
2. GROUP BY: Group filtered data by tier
3. Calculate: SUM, COUNT, AVG for each group
4. HAVING: Filter groups based on aggregated values
5. ORDER BY: Sort final results

WHEN TO USE EACH:

WHERE Examples:
- WHERE transaction_date >= '2024-11-01' (filter rows)
- WHERE amount > 500 (individual transaction filter)

HAVING Examples:
- HAVING SUM(amount) > 10000 (filter groups)
- HAVING COUNT(*) > 100 (groups with many transactions)
- HAVING AVG(amount) > 200 (high-value tiers)

YOU CAN USE BOTH:
WHERE amount > 50             -- Pre-filter: Only transactions over $50
GROUP BY card_tier
HAVING SUM(amount) > 10000    -- Post-filter: Only tiers over $10K total

BUSINESS IMPACT:
Only shows Platinum and Gold tiers (high-revenue segments)
CFO can focus on what matters most!
*/

PRINT '';
PRINT 'INSIGHT: HAVING filters aggregated groups, WHERE filters individual rows!';
PRINT '';

-- ============================================================================
-- QUESTION 4: Top Spending Customers (Real Business Value)
-- ============================================================================

PRINT '================================================================================';
PRINT 'QUESTION 4: "Who are our top 10 spenders? I want to send them gifts!"';
PRINT '================================================================================';
PRINT '';

/*
BUSINESS CONTEXT:
- Identify VIP customers
- Personalized retention strategy
- Premium service targeting
*/

SELECT TOP 10
    t.card_number,
    c.customer_name,
    c.card_tier,
    COUNT(t.transaction_id) AS transaction_count,
    SUM(t.amount) AS total_spent,
    AVG(t.amount) AS avg_transaction
FROM cba_transactions t
INNER JOIN cba_cardholders c ON t.card_number = c.card_number
WHERE t.transaction_date >= '2024-11-01' 
  AND t.transaction_date < '2024-12-01'
GROUP BY t.card_number, c.customer_name, c.card_tier
ORDER BY total_spent DESC;

/*
EXPLANATION:

TOP 10:
- SQL Server syntax for limiting results
- Other databases: LIMIT 10 (MySQL, PostgreSQL)

GROUP BY Multiple Columns:
- GROUP BY card_number, customer_name, card_tier
- Creates one row per unique combination
- Needed because we're showing customer details

BUSINESS IMPACT:
"Michael Rodriguez: $18,545 total → Send exclusive Platinum gift"
"James Chen: $10,551 total → Offer concierge service upgrade"

ACTIONABLE INSIGHTS:
- Send personalized thank you gifts
- Offer exclusive event invitations
- Provide dedicated account manager
*/

PRINT '';
PRINT 'INSIGHT: Top 10 customers identified for VIP treatment!';
PRINT '';

-- ============================================================================
-- QUESTION 5: Customer Segmentation with CASE
-- ============================================================================

PRINT '================================================================================';
PRINT 'QUESTION 5: "Segment ALL customers by spending: Low/Medium/High"';
PRINT '================================================================================';
PRINT '';

/*
BUSINESS NEED:
Create dynamic spending categories for targeted marketing

Low Spenders: < $500 total
Medium Spenders: $500-$2000
High Spenders: $2000+
*/

SELECT 
    t.card_number,
    c.customer_name,
    c.card_tier,
    SUM(t.amount) AS total_spent,
    COUNT(t.transaction_id) AS transaction_count,
    CASE 
        WHEN SUM(t.amount) < 500 THEN 'Low Value'
        WHEN SUM(t.amount) >= 500 AND SUM(t.amount) < 2000 THEN 'Medium Value'
        WHEN SUM(t.amount) >= 2000 THEN 'High Value'
    END AS spending_segment
FROM cba_transactions t
INNER JOIN cba_cardholders c ON t.card_number = c.card_number
WHERE t.transaction_date >= '2024-11-01' 
  AND t.transaction_date < '2024-12-01'
GROUP BY t.card_number, c.customer_name, c.card_tier
ORDER BY total_spent DESC;

/*
EXPLANATION:

CASE with Aggregates:
- CASE evaluated AFTER aggregation
- Can use SUM(amount) in WHEN conditions
- Creates dynamic categories

BUSINESS SEGMENTATION:

High Value ($2000+):
- Targeted message: "Exclusive Platinum benefits"
- Offer: Concierge service, travel insurance

Medium Value ($500-$2000):
- Targeted message: "Upgrade to next tier"
- Offer: 50% off annual fee for Gold

Low Value (< $500):
- Targeted message: "Earn 2x points this month"
- Offer: Cashback promotion to increase spending

MARKETING AUTOMATION:
Each segment gets different email campaign
Personalized offers based on spending behavior
*/

PRINT '';
PRINT 'INSIGHT: Dynamic segmentation enables targeted marketing campaigns!';
PRINT '';

-- ============================================================================
-- QUESTION 6: Merchant Category Analysis
-- ============================================================================

PRINT '================================================================================';
PRINT 'QUESTION 6: "Which merchant categories drive the most revenue?"';
PRINT '================================================================================';
PRINT '';

/*
BUSINESS CONTEXT:
- Identify partnership opportunities
- Understand spending patterns
- Optimize rewards programs
*/

SELECT 
    merchant_category,
    COUNT(transaction_id) AS transaction_count,
    SUM(amount) AS total_revenue,
    AVG(amount) AS avg_transaction,
    ROUND(SUM(amount) * 100.0 / (SELECT SUM(amount) FROM cba_transactions 
                                   WHERE transaction_date >= '2024-11-01' 
                                     AND transaction_date < '2024-12-01'), 2) AS pct_of_total
FROM cba_transactions
WHERE transaction_date >= '2024-11-01' 
  AND transaction_date < '2024-12-01'
GROUP BY merchant_category
ORDER BY total_revenue DESC;

/*
EXPLANATION:

ROUND Function:
- ROUND(value, 2): Round to 2 decimal places
- Clean percentage display

Percentage Calculation:
- Category revenue / Total revenue × 100
- Subquery: (SELECT SUM(amount) FROM ...) = total revenue
- Multiply by 100.0 (not 100) for decimal division

BUSINESS INSIGHTS:
"Travel: $45,600 (35% of spend) → Partner with airlines for 3x points"
"Electronics: $28,900 (22% of spend) → JB Hi-Fi partnership opportunity"
"Supermarket: $12,300 (9% of spend) → Daily spend category, high frequency"

STRATEGIC ACTIONS:
- Negotiate better merchant fees with top categories
- Create category-specific rewards (3x points on travel)
- Co-branded card opportunities (Qantas CBA card)
*/

PRINT '';
PRINT 'INSIGHT: Travel dominates premium tier spending - partnership opportunity!';
PRINT '';

-- ============================================================================
-- THE 8:45 AM VICTORY
-- ============================================================================

PRINT '';
PRINT '================================================================================';
PRINT '8:45 AM - DASHBOARD COMPLETE! 30 MINUTES TO SPARE!';
PRINT '================================================================================';
PRINT '';
PRINT 'What You Just Delivered to the CFO:';
PRINT '- Revenue by card tier';
PRINT '- Complete financial metrics (transactions + fees)';
PRINT '- High-value tier analysis';
PRINT '- Top 10 VIP customers';
PRINT '- Customer spending segmentation';
PRINT '- Merchant category insights';
PRINT '';
PRINT 'Board Meeting Outcome:';
PRINT '- CFO presents with confidence';
PRINT '- Premium card strategy validated';
PRINT '- $5,391 annual fee revenue identified';
PRINT '- VIP customer program approved';
PRINT '';
PRINT 'Your Career Impact:';
PRINT '- You are now "the SQL person"';
PRINT '- Future dashboard requests come to you';
PRINT '- Promotion discussion starts next quarter';
PRINT '================================================================================';
PRINT '';

-- ============================================================================
-- KEY TAKEAWAYS
-- ============================================================================

/*
SQL CONCEPTS YOU MASTERED:

1. GROUP BY
   - Summarize data by categories
   - Creates one row per unique group
   - Foundation of all business reporting

2. MULTIPLE AGGREGATES
   - SUM, COUNT, AVG, MIN, MAX in one query
   - COUNT DISTINCT for unique values
   - Complex calculations combining aggregates

3. HAVING vs WHERE
   - WHERE: Filter rows BEFORE grouping
   - HAVING: Filter groups AFTER aggregation
   - Use both together for powerful filtering

4. CASE with GROUP BY
   - Dynamic categorization
   - Evaluated AFTER aggregation
   - Enables business segmentation

5. JOINS with GROUP BY
   - Combine data from multiple tables
   - Group on joined results
   - Real-world reporting requires this

BUSINESS VALUE DELIVERED:

✓ Executive dashboards (monthly metrics)
✓ Revenue analysis (by tier, category, customer)
✓ Customer segmentation (high/medium/low value)
✓ VIP identification (top spenders)
✓ Category insights (merchant partnerships)
✓ Financial planning (transaction + fee revenue)

REAL-WORLD APPLICATIONS:

Every business dashboard uses GROUP BY:
- Sales: Revenue by region, product, salesperson
- Marketing: Campaign ROI by channel, segment
- Finance: Expenses by department, category, month
- Operations: Order volume by warehouse, shift, day

YOU'RE READY FOR:

✓ Building executive dashboards
✓ Monthly/quarterly reporting
✓ Customer segmentation projects
✓ Revenue analysis
✓ Business intelligence roles

NEXT VIDEO PREVIEW:

Video 4: Time Intelligence - YoY, MoM, Rolling Averages
Woolworths Grocery Sales Trend Analysis
Learn: DATEPART, LAG, trend analysis, growth rates
Duration: 17 minutes

PRACTICE EXERCISES:

1. Calculate revenue by STATE (GROUP BY state)
2. Find customers with >5 transactions (HAVING COUNT > 5)
3. Segment customers by credit limit tier (CASE on credit_limit)
4. Show only tiers with avg transaction > $500 (HAVING AVG)
5. Calculate month-over-month revenue (DATE functions)

================================================================================
VIDEO 3 COMPLETE - YOU'RE NOW A GROUP BY MASTER!
================================================================================
*/

GO
