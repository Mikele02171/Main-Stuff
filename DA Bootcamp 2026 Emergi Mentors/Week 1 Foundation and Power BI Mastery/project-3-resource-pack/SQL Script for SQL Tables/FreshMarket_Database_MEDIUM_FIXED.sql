-- =============================================
-- FreshMarket ETL Pipeline - MEDIUM DATASET
-- Power BI Bootcamp - Video 1: ETL & Power Query
-- =============================================
-- Purpose: Create SQL Server database with MEDIUM-scale realistic data
-- Database: FreshMarket_DB
-- Compatible: SQL Server 2019+
-- Dataset Size: 50 Stores | 100 Products | 1,000 Customers | 50,000 Transactions
-- Execution Time: ~30-60 seconds
-- =============================================

USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'FreshMarket_DB')
BEGIN
    ALTER DATABASE FreshMarket_DB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE FreshMarket_DB;
END
GO

CREATE DATABASE FreshMarket_DB;
GO

USE FreshMarket_DB;
GO

PRINT 'Database FreshMarket_DB created successfully';
GO

-- =============================================
-- STEP 1: CREATE TABLES
-- =============================================

CREATE TABLE DimStore (
    StoreID INT PRIMARY KEY,
    StoreName NVARCHAR(100) NOT NULL,
    StoreType NVARCHAR(50) NOT NULL,
    Address NVARCHAR(200),
    Suburb NVARCHAR(100),
    State NVARCHAR(3) NOT NULL,
    Postcode NVARCHAR(4) NOT NULL,
    Region NVARCHAR(50),
    ManagerName NVARCHAR(100),
    ManagerEmail NVARCHAR(100),
    StorePhone NVARCHAR(20),
    OpeningDate DATE,
    SquareMeters INT,
    ParkingSpaces INT,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE()
);

CREATE TABLE DimProduct (
    ProductID INT PRIMARY KEY,
    ProductName NVARCHAR(200) NOT NULL,
    Category NVARCHAR(100) NOT NULL,
    SubCategory NVARCHAR(100),
    Brand NVARCHAR(100),
    Supplier NVARCHAR(100),
    SupplierABN NVARCHAR(11),
    UnitOfMeasure NVARCHAR(20),
    PackSize NVARCHAR(50),
    UnitCost DECIMAL(10,2),
    RetailPrice DECIMAL(10,2),
    MarginPercent DECIMAL(5,2),
    IsOrganic BIT DEFAULT 0,
    IsPrivateLabel BIT DEFAULT 0,
    Barcode NVARCHAR(13),
    ShelfLife INT,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE()
);

CREATE TABLE DimCustomer (
    CustomerID INT PRIMARY KEY,
    FirstName NVARCHAR(100),
    LastName NVARCHAR(100),
    Email NVARCHAR(200),
    Phone NVARCHAR(20),
    DateOfBirth DATE,
    Gender NVARCHAR(10),
    Suburb NVARCHAR(100),
    State NVARCHAR(3),
    Postcode NVARCHAR(4),
    LoyaltyTier NVARCHAR(20),
    LoyaltyJoinDate DATE,
    LoyaltyPoints INT DEFAULT 0,
    PreferredStore INT,
    IsEmailSubscriber BIT DEFAULT 0,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE()
);

CREATE TABLE DimChannel (
    ChannelID INT PRIMARY KEY,
    ChannelName NVARCHAR(50) NOT NULL,
    ChannelDescription NVARCHAR(200),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE()
);

CREATE TABLE DimDate (
    DateKey INT PRIMARY KEY,
    FullDate DATE NOT NULL,
    DayOfWeek INT,
    DayName NVARCHAR(10),
    DayOfMonth INT,
    DayOfYear INT,
    WeekOfYear INT,
    MonthNumber INT,
    MonthName NVARCHAR(10),
    MonthShort NVARCHAR(3),
    Quarter INT,
    QuarterName NVARCHAR(2),
    Year INT,
    FinancialYear INT,
    FinancialQuarter NVARCHAR(10),
    IsWeekend BIT,
    IsPublicHoliday BIT DEFAULT 0,
    HolidayName NVARCHAR(100),
    IsEOFY BIT DEFAULT 0
);

CREATE TABLE FactTransactions (
    TransactionID INT PRIMARY KEY IDENTITY(1,1),
    TransactionDate DATE NOT NULL,
    StoreID INT NOT NULL,
    CustomerID INT,
    ProductID INT NOT NULL,
    ChannelID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    Revenue DECIMAL(12,2) NOT NULL,
    GST DECIMAL(10,2),
    TotalAmount DECIMAL(12,2),
    Discount DECIMAL(10,2) DEFAULT 0,
    CostOfGoods DECIMAL(10,2),
    GrossProfit DECIMAL(10,2),
    LoyaltyPointsEarned INT DEFAULT 0,
    PaymentMethod NVARCHAR(50),
    TransactionTime TIME,
    CreatedDate DATETIME DEFAULT GETDATE()
);

CREATE INDEX IX_Transaction_Date ON FactTransactions(TransactionDate);
CREATE INDEX IX_Transaction_Store ON FactTransactions(StoreID);
CREATE INDEX IX_Transaction_Customer ON FactTransactions(CustomerID);
CREATE INDEX IX_Transaction_Product ON FactTransactions(ProductID);

PRINT 'All tables created successfully';
GO

-- =============================================
-- STEP 2: INSERT 50 STORES
-- =============================================

PRINT 'Inserting 50 stores across Australia...';

INSERT INTO DimStore (StoreID, StoreName, StoreType, Address, Suburb, State, Postcode, Region, ManagerName, ManagerEmail, StorePhone, OpeningDate, SquareMeters, ParkingSpaces)
VALUES
-- NSW Stores (20)
(1, 'FreshMarket Sydney CBD', 'Metro', '123 George Street', 'Sydney', 'NSW', '2000', 'Sydney Metro', 'Sarah Johnson', 'sarah.johnson@freshmarket.com.au', '02 9000 0001', '2020-03-15', 1500, 0),
(2, 'FreshMarket Parramatta', 'Metro', '456 Church Street', 'Parramatta', 'NSW', '2150', 'Sydney Metro', 'Michael Chen', 'michael.chen@freshmarket.com.au', '02 9000 0002', '2019-07-20', 2000, 150),
(3, 'FreshMarket Bondi Junction', 'Metro', '789 Oxford Street', 'Bondi Junction', 'NSW', '2022', 'Sydney Metro', 'Emma Wilson', 'emma.wilson@freshmarket.com.au', '02 9000 0003', '2021-01-10', 1800, 80),
(4, 'FreshMarket Chatswood', 'Metro', '321 Victoria Avenue', 'Chatswood', 'NSW', '2067', 'Sydney Metro', 'David Lee', 'david.lee@freshmarket.com.au', '02 9000 0004', '2018-11-05', 2200, 200),
(5, 'FreshMarket Castle Hill', 'Metro', '654 Old Northern Road', 'Castle Hill', 'NSW', '2154', 'Sydney Metro', 'Jennifer Smith', 'jennifer.smith@freshmarket.com.au', '02 9000 0005', '2022-02-14', 2500, 250),
(6, 'FreshMarket Westfield', 'Metro', '159 Pitt Street', 'Sydney', 'NSW', '2000', 'Sydney Metro', 'Thomas Brown', 'thomas.brown@freshmarket.com.au', '02 9000 0006', '2021-05-22', 1700, 0),
(7, 'FreshMarket Hurstville', 'Metro', '753 Forest Road', 'Hurstville', 'NSW', '2220', 'Sydney Metro', 'Linda Garcia', 'linda.garcia@freshmarket.com.au', '02 9000 0007', '2020-09-18', 1900, 160),
(8, 'FreshMarket Bankstown', 'Metro', '357 Chapel Road', 'Bankstown', 'NSW', '2200', 'Sydney Metro', 'Kevin Wang', 'kevin.wang@freshmarket.com.au', '02 9000 0008', '2019-12-10', 2100, 180),
(9, 'FreshMarket Macquarie', 'Metro', '951 Waterloo Road', 'Macquarie Park', 'NSW', '2113', 'Sydney Metro', 'Rachel Kim', 'rachel.kim@freshmarket.com.au', '02 9000 0009', '2021-08-05', 2300, 220),
(10, 'FreshMarket Liverpool', 'Metro', '258 Macquarie Street', 'Liverpool', 'NSW', '2170', 'Western Sydney', 'Andrew Martinez', 'andrew.martinez@freshmarket.com.au', '02 9000 0010', '2020-04-12', 2000, 200),
(11, 'FreshMarket Penrith', 'Regional', '147 High Street', 'Penrith', 'NSW', '2750', 'Western Sydney', 'Lisa Anderson', 'lisa.anderson@freshmarket.com.au', '02 4700 0011', '2019-09-12', 2100, 220),
(12, 'FreshMarket Campbelltown', 'Regional', '369 Queen Street', 'Campbelltown', 'NSW', '2560', 'Western Sydney', 'Daniel Rodriguez', 'daniel.rodriguez@freshmarket.com.au', '02 4600 0012', '2021-11-28', 1950, 190),
(13, 'FreshMarket Newcastle', 'Regional', '741 Hunter Street', 'Newcastle', 'NSW', '2300', 'Hunter', 'James Brown', 'james.brown@freshmarket.com.au', '02 4900 0013', '2020-06-15', 2200, 210),
(14, 'FreshMarket Wollongong', 'Regional', '852 Crown Street', 'Wollongong', 'NSW', '2500', 'Illawarra', 'Amanda White', 'amanda.white@freshmarket.com.au', '02 4200 0014', '2021-03-08', 1900, 175),
(15, 'FreshMarket Central Coast', 'Regional', '963 The Entrance Road', 'Erina', 'NSW', '2250', 'Central Coast', 'Robert Taylor', 'robert.taylor@freshmarket.com.au', '02 4300 0015', '2019-10-20', 2050, 195),
(16, 'FreshMarket Dubbo', 'Regional', '456 Macquarie Street', 'Dubbo', 'NSW', '2830', 'Central West', 'Michelle Lee', 'michelle.lee@freshmarket.com.au', '02 6800 0016', '2022-01-15', 1700, 150),
(17, 'FreshMarket Wagga Wagga', 'Regional', '789 Baylis Street', 'Wagga Wagga', 'NSW', '2650', 'Riverina', 'Christopher Davis', 'chris.davis@freshmarket.com.au', '02 6900 0017', '2020-11-30', 1650, 145),
(18, 'FreshMarket Tamworth', 'Regional', '123 Peel Street', 'Tamworth', 'NSW', '2340', 'New England', 'Jessica Wilson', 'jessica.wilson@freshmarket.com.au', '02 6700 0018', '2021-07-22', 1600, 140),
(19, 'FreshMarket Orange', 'Regional', '321 Summer Street', 'Orange', 'NSW', '2800', 'Central West', 'Mark Thompson', 'mark.thompson@freshmarket.com.au', '02 6300 0019', '2022-04-10', 1550, 135),
(20, 'FreshMarket Albury', 'Regional', '654 Dean Street', 'Albury', 'NSW', '2640', 'Murray', 'Patricia Moore', 'patricia.moore@freshmarket.com.au', '02 6000 0020', '2019-08-05', 1700, 155),
-- VIC Stores (18)
(21, 'FreshMarket Melbourne CBD', 'Metro', '159 Collins Street', 'Melbourne', 'VIC', '3000', 'Melbourne Metro', 'Sophie Thompson', 'sophie.thompson@freshmarket.com.au', '03 9000 0021', '2019-05-10', 1600, 0),
(22, 'FreshMarket Chadstone', 'Metro', '357 Dandenong Road', 'Chadstone', 'VIC', '3148', 'Melbourne Metro', 'Oliver Garcia', 'oliver.garcia@freshmarket.com.au', '03 9000 0022', '2020-09-25', 2400, 280),
(23, 'FreshMarket Doncaster', 'Metro', '753 Doncaster Road', 'Doncaster', 'VIC', '3108', 'Melbourne Metro', 'Emily Robinson', 'emily.robinson@freshmarket.com.au', '03 9000 0023', '2021-03-08', 2200, 250),
(24, 'FreshMarket Southland', 'Metro', '951 Nepean Highway', 'Cheltenham', 'VIC', '3192', 'Melbourne Metro', 'William Clark', 'william.clark@freshmarket.com.au', '03 9000 0024', '2020-11-15', 2100, 240),
(25, 'FreshMarket Eastland', 'Metro', '258 Maroondah Highway', 'Ringwood', 'VIC', '3134', 'Melbourne Metro', 'Isabella Lewis', 'isabella.lewis@freshmarket.com.au', '03 9000 0025', '2019-07-28', 2000, 220),
(26, 'FreshMarket Northland', 'Metro', '456 Murray Road', 'Preston', 'VIC', '3072', 'Melbourne Metro', 'Henry Young', 'henry.young@freshmarket.com.au', '03 9000 0026', '2021-09-12', 1950, 200),
(27, 'FreshMarket Highpoint', 'Metro', '789 Rosamond Road', 'Maribyrnong', 'VIC', '3032', 'Melbourne Metro', 'Charlotte Walker', 'charlotte.walker@freshmarket.com.au', '03 9000 0027', '2020-02-20', 1900, 190),
(28, 'FreshMarket Box Hill', 'Metro', '147 Station Street', 'Box Hill', 'VIC', '3128', 'Melbourne Metro', 'Ethan King', 'ethan.king@freshmarket.com.au', '03 9000 0028', '2022-06-05', 1850, 180),
(29, 'FreshMarket Glen Waverley', 'Metro', '369 Kingsway', 'Glen Waverley', 'VIC', '3150', 'Melbourne Metro', 'Ava Wright', 'ava.wright@freshmarket.com.au', '03 9000 0029', '2019-12-18', 2050, 210),
(30, 'FreshMarket Fountain Gate', 'Metro', '741 Princes Highway', 'Narre Warren', 'VIC', '3805', 'Melbourne Metro', 'Lucas Scott', 'lucas.scott@freshmarket.com.au', '03 9000 0030', '2021-04-25', 2150, 230),
(31, 'FreshMarket Frankston', 'Regional', '852 Nepean Highway', 'Frankston', 'VIC', '3199', 'Mornington Peninsula', 'Mia Harris', 'mia.harris@freshmarket.com.au', '03 9000 0031', '2020-08-10', 1800, 170),
(32, 'FreshMarket Geelong', 'Regional', '963 Ryrie Street', 'Geelong', 'VIC', '3220', 'Geelong', 'Noah Green', 'noah.green@freshmarket.com.au', '03 5200 0032', '2019-03-20', 2100, 215),
(33, 'FreshMarket Bendigo', 'Regional', '159 Mitchell Street', 'Bendigo', 'VIC', '3550', 'Bendigo', 'Olivia Adams', 'olivia.adams@freshmarket.com.au', '03 5400 0033', '2021-10-08', 1750, 160),
(34, 'FreshMarket Ballarat', 'Regional', '357 Sturt Street', 'Ballarat', 'VIC', '3350', 'Ballarat', 'Benjamin Baker', 'benjamin.baker@freshmarket.com.au', '03 5300 0034', '2020-05-15', 1700, 155),
(35, 'FreshMarket Shepparton', 'Regional', '753 Wyndham Street', 'Shepparton', 'VIC', '3630', 'Goulburn Valley', 'Sophia Carter', 'sophia.carter@freshmarket.com.au', '03 5800 0035', '2022-02-28', 1650, 150),
(36, 'FreshMarket Mildura', 'Regional', '951 Deakin Avenue', 'Mildura', 'VIC', '3500', 'Sunraysia', 'Jack Mitchell', 'jack.mitchell@freshmarket.com.au', '03 5000 0036', '2019-11-12', 1600, 145),
(37, 'FreshMarket Wodonga', 'Regional', '258 High Street', 'Wodonga', 'VIC', '3690', 'North East', 'Amelia Perez', 'amelia.perez@freshmarket.com.au', '02 6000 0037', '2021-06-20', 1550, 140),
(38, 'FreshMarket Warrnambool', 'Regional', '456 Liebig Street', 'Warrnambool', 'VIC', '3280', 'Great South Coast', 'Mason Roberts', 'mason.roberts@freshmarket.com.au', '03 5500 0038', '2020-09-05', 1500, 135),
-- QLD Stores (12)
(39, 'FreshMarket Brisbane CBD', 'Metro', '789 Queen Street', 'Brisbane', 'QLD', '4000', 'Brisbane Metro', 'Harper Turner', 'harper.turner@freshmarket.com.au', '07 3000 0039', '2020-02-20', 1700, 0),
(40, 'FreshMarket Chermside', 'Metro', '147 Gympie Road', 'Chermside', 'QLD', '4032', 'Brisbane Metro', 'Evelyn Phillips', 'evelyn.phillips@freshmarket.com.au', '07 3000 0040', '2021-06-10', 2300, 260),
(41, 'FreshMarket Carindale', 'Metro', '369 Creek Road', 'Carindale', 'QLD', '4152', 'Brisbane Metro', 'Alexander Campbell', 'alex.campbell@freshmarket.com.au', '07 3000 0041', '2019-09-15', 2100, 230),
(42, 'FreshMarket Garden City', 'Metro', '741 Logan Road', 'Upper Mount Gravatt', 'QLD', '4122', 'Brisbane Metro', 'Abigail Parker', 'abigail.parker@freshmarket.com.au', '07 3000 0042', '2020-12-08', 2000, 215),
(43, 'FreshMarket Indooroopilly', 'Metro', '852 Moggill Road', 'Indooroopilly', 'QLD', '4068', 'Brisbane Metro', 'Sebastian Evans', 'sebastian.evans@freshmarket.com.au', '07 3000 0043', '2021-11-20', 1950, 200),
(44, 'FreshMarket Toombul', 'Metro', '963 Sandgate Road', 'Nundah', 'QLD', '4012', 'Brisbane Metro', 'Victoria Edwards', 'victoria.edwards@freshmarket.com.au', '07 3000 0044', '2019-04-18', 1850, 185),
(45, 'FreshMarket Robina', 'Metro', '159 Robina Town Centre Drive', 'Robina', 'QLD', '4226', 'Gold Coast', 'Jackson Collins', 'jackson.collins@freshmarket.com.au', '07 5500 0045', '2020-07-25', 2050, 220),
(46, 'FreshMarket Gold Coast', 'Regional', '357 Surfers Paradise Boulevard', 'Surfers Paradise', 'QLD', '4217', 'Gold Coast', 'Madison Stewart', 'madison.stewart@freshmarket.com.au', '07 5500 0046', '2019-10-15', 2200, 240),
(47, 'FreshMarket Sunshine Coast', 'Regional', '753 Horton Parade', 'Maroochydore', 'QLD', '4558', 'Sunshine Coast', 'Aiden Sanchez', 'aiden.sanchez@freshmarket.com.au', '07 5400 0047', '2022-03-28', 1950, 190),
(48, 'FreshMarket Townsville', 'Regional', '951 Flinders Street', 'Townsville', 'QLD', '4810', 'North Queensland', 'Scarlett Morris', 'scarlett.morris@freshmarket.com.au', '07 4700 0048', '2021-08-05', 1800, 170),
(49, 'FreshMarket Cairns', 'Regional', '258 Lake Street', 'Cairns', 'QLD', '4870', 'Far North Queensland', 'Logan Rogers', 'logan.rogers@freshmarket.com.au', '07 4000 0049', '2020-01-12', 1750, 160),
(50, 'FreshMarket Toowoomba', 'Regional', '456 Margaret Street', 'Toowoomba', 'QLD', '4350', 'Darling Downs', 'Aria Reed', 'aria.reed@freshmarket.com.au', '07 4600 0050', '2021-05-30', 1700, 155);

PRINT 'Inserted 50 stores successfully';
GO

-- =============================================
-- STEP 3: INSERT 100 PRODUCTS
-- =============================================

PRINT 'Inserting 100 products...';

INSERT INTO DimProduct (ProductID, ProductName, Category, SubCategory, Brand, Supplier, SupplierABN, UnitOfMeasure, PackSize, UnitCost, RetailPrice, MarginPercent, IsOrganic, IsPrivateLabel, Barcode, ShelfLife)
VALUES
-- Fresh Produce (25 products)
(101, 'Organic Bananas', 'Fresh Produce', 'Fruit', 'FreshMarket Organic', 'Queensland Fresh', '12345678901', 'kg', '1kg', 1.80, 3.99, 54.89, 1, 1, '9300001000101', 7),
(102, 'Red Delicious Apples', 'Fresh Produce', 'Fruit', 'Australian Orchard', 'Victorian Farms', '23456789012', 'kg', '1kg', 2.00, 4.49, 55.46, 0, 0, '9300001000102', 14),
(103, 'Baby Spinach', 'Fresh Produce', 'Vegetables', 'Garden Fresh', 'Sydney Greens', '34567890123', 'unit', '120g', 1.20, 3.50, 65.71, 0, 0, '9300001000103', 5),
(104, 'Cherry Tomatoes', 'Fresh Produce', 'Vegetables', 'Premium Harvest', 'Queensland Fresh', '12345678901', 'unit', '250g', 2.50, 5.99, 58.26, 0, 0, '9300001000104', 7),
(105, 'Avocados', 'Fresh Produce', 'Fruit', 'Hass Select', 'Victorian Farms', '23456789012', 'unit', 'each', 1.50, 2.99, 49.83, 0, 0, '9300001000105', 5),
(106, 'Strawberries', 'Fresh Produce', 'Fruit', 'Berry Bliss', 'Queensland Fresh', '12345678901', 'unit', '250g', 2.00, 4.99, 59.92, 0, 0, '9300001000106', 3),
(107, 'Blueberries', 'Fresh Produce', 'Fruit', 'Berry Premium', 'Victorian Farms', '23456789012', 'unit', '125g', 2.50, 5.99, 58.26, 0, 0, '9300001000107', 5),
(108, 'Broccoli', 'Fresh Produce', 'Vegetables', 'Green Valley', 'Victorian Farms', '23456789012', 'unit', 'each', 1.20, 2.99, 59.87, 0, 0, '9300001000108', 7),
(109, 'Carrots', 'Fresh Produce', 'Vegetables', 'Fresh Farms', 'Queensland Fresh', '12345678901', 'kg', '1kg', 1.00, 2.49, 59.84, 0, 0, '9300001000109', 14),
(110, 'Potatoes', 'Fresh Produce', 'Vegetables', 'Australian Grown', 'Victorian Farms', '23456789012', 'kg', '2kg', 2.00, 4.99, 59.92, 0, 0, '9300001000110', 30),
(111, 'Oranges Valencia', 'Fresh Produce', 'Fruit', 'Citrus Australia', 'Queensland Fresh', '12345678901', 'kg', '1kg', 1.80, 3.99, 54.89, 0, 0, '9300001000111', 10),
(112, 'Mandarins', 'Fresh Produce', 'Fruit', 'Citrus King', 'Queensland Fresh', '12345678901', 'kg', '1kg', 2.20, 4.99, 55.91, 0, 0, '9300001000112', 10),
(113, 'Lemons', 'Fresh Produce', 'Fruit', 'Citrus Fresh', 'Victorian Farms', '23456789012', 'kg', '500g', 1.50, 2.99, 49.83, 0, 0, '9300001000113', 14),
(114, 'Grapes Green', 'Fresh Produce', 'Fruit', 'Vineyard Select', 'Victorian Farms', '23456789012', 'kg', '500g', 3.00, 5.99, 49.92, 0, 0, '9300001000114', 7),
(115, 'Watermelon', 'Fresh Produce', 'Fruit', 'Fresh Farms', 'Queensland Fresh', '12345678901', 'unit', 'each', 4.00, 7.99, 49.94, 0, 0, '9300001000115', 10),
(116, 'Pumpkin', 'Fresh Produce', 'Vegetables', 'Aussie Veggies', 'Victorian Farms', '23456789012', 'kg', '1kg', 1.50, 3.49, 57.02, 0, 0, '9300001000116', 30),
(117, 'Capsicum Red', 'Fresh Produce', 'Vegetables', 'Garden Fresh', 'Queensland Fresh', '12345678901', 'kg', '1kg', 3.50, 6.99, 49.93, 0, 0, '9300001000117', 7),
(118, 'Capsicum Green', 'Fresh Produce', 'Vegetables', 'Garden Fresh', 'Queensland Fresh', '12345678901', 'kg', '1kg', 3.00, 5.99, 49.92, 0, 0, '9300001000118', 7),
(119, 'Mushrooms', 'Fresh Produce', 'Vegetables', 'Mushroom Farm', 'Victorian Farms', '23456789012', 'unit', '200g', 2.00, 4.49, 55.46, 0, 0, '9300001000119', 5),
(120, 'Lettuce Iceberg', 'Fresh Produce', 'Salad', 'Salad Masters', 'Sydney Greens', '34567890123', 'unit', 'each', 1.00, 2.49, 59.84, 0, 0, '9300001000120', 7),
(121, 'Cucumber', 'Fresh Produce', 'Vegetables', 'Fresh Greens', 'Queensland Fresh', '12345678901', 'unit', 'each', 0.80, 1.99, 59.80, 0, 0, '9300001000121', 7),
(122, 'Zucchini', 'Fresh Produce', 'Vegetables', 'Garden Valley', 'Victorian Farms', '23456789012', 'kg', '1kg', 2.00, 4.49, 55.46, 0, 0, '9300001000122', 7),
(123, 'Celery', 'Fresh Produce', 'Vegetables', 'Fresh Farms', 'Sydney Greens', '34567890123', 'unit', 'bunch', 1.20, 2.99, 59.87, 0, 0, '9300001000123', 10),
(124, 'Corn Cob', 'Fresh Produce', 'Vegetables', 'Golden Corn', 'Queensland Fresh', '12345678901', 'unit', '2 pack', 1.50, 3.49, 57.02, 0, 0, '9300001000124', 5),
(125, 'Sweet Potato', 'Fresh Produce', 'Vegetables', 'Root Veggies', 'Queensland Fresh', '12345678901', 'kg', '1kg', 2.20, 4.99, 55.91, 0, 0, '9300001000125', 21),
-- Dairy (20 products)
(201, 'Full Cream Milk', 'Dairy', 'Milk', 'Dairy Farmers', 'National Dairy', '45678901234', 'L', '2L', 2.20, 4.50, 51.11, 0, 0, '9300001000201', 10),
(202, 'Skim Milk', 'Dairy', 'Milk', 'Dairy Farmers', 'National Dairy', '45678901234', 'L', '2L', 2.10, 4.30, 51.16, 0, 0, '9300001000202', 10),
(203, 'Greek Yoghurt', 'Dairy', 'Yoghurt', 'Chobani', 'Dairy Imports', '56789012345', 'unit', '500g', 3.00, 6.99, 57.08, 0, 0, '9300001000203', 21),
(204, 'Natural Yoghurt', 'Dairy', 'Yoghurt', 'Jalna', 'National Dairy', '45678901234', 'unit', '1kg', 3.50, 7.49, 53.27, 0, 0, '9300001000204', 21),
(205, 'Cheddar Cheese Block', 'Dairy', 'Cheese', 'Mainland', 'National Dairy', '45678901234', 'unit', '500g', 4.50, 9.99, 54.95, 0, 0, '9300001000205', 60),
(206, 'Tasty Cheese Block', 'Dairy', 'Cheese', 'Bega', 'National Dairy', '45678901234', 'unit', '500g', 4.80, 10.49, 54.24, 0, 0, '9300001000206', 60),
(207, 'Mozzarella Cheese', 'Dairy', 'Cheese', 'Perfect Italiano', 'Dairy Co-op', '67890123456', 'unit', '250g', 2.80, 5.99, 53.26, 0, 0, '9300001000207', 45),
(208, 'Cream Cheese', 'Dairy', 'Cheese', 'Philadelphia', 'Dairy Imports', '56789012345', 'unit', '250g', 2.50, 5.49, 54.46, 0, 0, '9300001000208', 30),
(209, 'Butter Unsalted', 'Dairy', 'Butter', 'Western Star', 'Dairy Co-op', '67890123456', 'unit', '500g', 3.80, 7.49, 49.27, 0, 0, '9300001000209', 90),
(210, 'Butter Salted', 'Dairy', 'Butter', 'Western Star', 'Dairy Co-op', '67890123456', 'unit', '500g', 3.80, 7.49, 49.27, 0, 0, '9300001000210', 90),
(211, 'Thickened Cream', 'Dairy', 'Cream', 'Pauls', 'National Dairy', '45678901234', 'unit', '300mL', 2.00, 4.49, 55.46, 0, 0, '9300001000211', 14),
(212, 'Sour Cream', 'Dairy', 'Cream', 'Dairy Blend', 'National Dairy', '45678901234', 'unit', '200mL', 1.50, 3.49, 57.02, 0, 0, '9300001000212', 21),
(213, 'Cottage Cheese', 'Dairy', 'Cheese', 'Bulla', 'National Dairy', '45678901234', 'unit', '200g', 2.00, 4.49, 55.46, 0, 0, '9300001000213', 21),
(214, 'Feta Cheese', 'Dairy', 'Cheese', 'Dodoni', 'Dairy Imports', '56789012345', 'unit', '200g', 3.00, 6.49, 53.77, 0, 0, '9300001000214', 45),
(215, 'Parmesan Grated', 'Dairy', 'Cheese', 'Perfect Italiano', 'Dairy Co-op', '67890123456', 'unit', '125g', 2.50, 5.49, 54.46, 0, 0, '9300001000215', 60),
(216, 'Ricotta Cheese', 'Dairy', 'Cheese', 'Perfect Italiano', 'Dairy Co-op', '67890123456', 'unit', '250g', 2.00, 4.49, 55.46, 0, 0, '9300001000216', 21),
(217, 'Almond Milk', 'Dairy', 'Milk Alternatives', 'Almond Breeze', 'Alternative Dairy', '78901234567', 'unit', '1L', 2.50, 4.99, 49.90, 0, 0, '9300001000217', 60),
(218, 'Oat Milk', 'Dairy', 'Milk Alternatives', 'Oatly', 'Alternative Dairy', '78901234567', 'unit', '1L', 3.00, 5.99, 49.92, 0, 0, '9300001000218', 60),
(219, 'Custard', 'Dairy', 'Dessert', 'Pauls', 'National Dairy', '45678901234', 'unit', '1kg', 2.50, 5.49, 54.46, 0, 0, '9300001000219', 21),
(220, 'Ice Cream Vanilla', 'Dairy', 'Ice Cream', 'Streets', 'National Dairy', '45678901234', 'unit', '2L', 4.00, 8.99, 55.51, 0, 0, '9300001000220', 180),
-- Meat (15 products)
(301, 'Chicken Breast Fillet', 'Meat', 'Poultry', 'Lilydale', 'Australian Poultry', '78901234567', 'kg', '1kg', 8.00, 14.99, 46.63, 0, 0, '9300001000301', 3),
(302, 'Chicken Thigh Fillet', 'Meat', 'Poultry', 'Lilydale', 'Australian Poultry', '78901234567', 'kg', '1kg', 7.00, 12.99, 46.11, 0, 0, '9300001000302', 3),
(303, 'Beef Mince Premium', 'Meat', 'Beef', 'Coles Finest', 'Meat Wholesalers', '89012345678', 'kg', '500g', 5.50, 10.99, 49.95, 0, 0, '9300001000303', 3),
(304, 'Beef Steak Scotch Fillet', 'Meat', 'Beef', 'Premium Butcher', 'Meat Wholesalers', '89012345678', 'kg', '1kg', 15.00, 29.99, 49.98, 0, 0, '9300001000304', 3),
(305, 'Pork Sausages', 'Meat', 'Pork', 'Hahn', 'Butcher Supply Co', '90123456789', 'kg', '1kg', 6.00, 11.99, 49.96, 0, 0, '9300001000305', 5),
(306, 'Pork Chops', 'Meat', 'Pork', 'Australian Pork', 'Butcher Supply Co', '90123456789', 'kg', '1kg', 8.00, 15.99, 49.97, 0, 0, '9300001000306', 5),
(307, 'Lamb Chops', 'Meat', 'Lamb', 'Australian Lamb Co', 'Meat Wholesalers', '89012345678', 'kg', '1kg', 12.00, 22.99, 47.80, 0, 0, '9300001000307', 5),
(308, 'Lamb Leg Roast', 'Meat', 'Lamb', 'Australian Lamb Co', 'Meat Wholesalers', '89012345678', 'kg', '1.5kg', 15.00, 28.99, 48.26, 0, 0, '9300001000308', 5),
(309, 'Salmon Fillet', 'Meat', 'Seafood', 'Tassal', 'Seafood Suppliers', '01234567890', 'kg', '500g', 12.00, 22.99, 47.80, 0, 0, '9300001000309', 2),
(310, 'Prawns Raw', 'Meat', 'Seafood', 'Ocean Fresh', 'Seafood Suppliers', '01234567890', 'kg', '500g', 15.00, 28.99, 48.26, 0, 0, '9300001000310', 2),
(311, 'Bacon Rashers', 'Meat', 'Pork', 'Don Smallgoods', 'Butcher Supply Co', '90123456789', 'unit', '250g', 3.00, 6.99, 57.08, 0, 0, '9300001000311', 14),
(312, 'Ham Shaved', 'Meat', 'Deli', 'Primo', 'Meat Wholesalers', '89012345678', 'unit', '200g', 3.50, 7.49, 53.27, 0, 0, '9300001000312', 10),
(313, 'Salami', 'Meat', 'Deli', 'Primo', 'Meat Wholesalers', '89012345678', 'unit', '100g', 2.50, 5.49, 54.46, 0, 0, '9300001000313', 21),
(314, 'BBQ Chicken', 'Meat', 'Deli', 'Store Made', 'Australian Poultry', '78901234567', 'unit', 'each', 5.00, 9.99, 49.95, 0, 0, '9300001000314', 2),
(315, 'Fish Fillets Battered', 'Meat', 'Seafood', 'Birds Eye', 'Seafood Suppliers', '01234567890', 'unit', '425g', 4.00, 8.49, 52.89, 0, 0, '9300001000315', 180),
-- Bakery (10 products)
(401, 'White Bread Loaf', 'Bakery', 'Bread', 'Tip Top', 'Bread Suppliers', '01234567890', 'unit', '700g', 1.50, 3.49, 57.02, 0, 0, '9300001000401', 7),
(402, 'Multigrain Bread', 'Bakery', 'Bread', 'Helgas', 'Bread Suppliers', '01234567890', 'unit', '750g', 2.00, 4.49, 55.46, 0, 0, '9300001000402', 7),
(403, 'Sourdough Loaf', 'Bakery', 'Bread', 'Bakers Delight', 'Artisan Bakery', '11223344556', 'unit', '600g', 2.50, 5.49, 54.46, 0, 0, '9300001000403', 5),
(404, 'Croissants', 'Bakery', 'Pastries', 'Bakers Delight', 'Artisan Bakery', '11223344556', 'unit', '4 pack', 3.00, 6.99, 57.08, 0, 0, '9300001000404', 3),
(405, 'Muffins Blueberry', 'Bakery', 'Cakes', 'Store Baked', 'Artisan Bakery', '11223344556', 'unit', '4 pack', 2.50, 5.99, 58.26, 0, 0, '9300001000405', 5),
(406, 'Donuts Glazed', 'Bakery', 'Pastries', 'Store Baked', 'Artisan Bakery', '11223344556', 'unit', '6 pack', 3.00, 6.49, 53.77, 0, 0, '9300001000406', 3),
(407, 'Bagels Plain', 'Bakery', 'Bread', 'Fresh Bakery', 'Bread Suppliers', '01234567890', 'unit', '6 pack', 2.00, 4.49, 55.46, 0, 0, '9300001000407', 7),
(408, 'Bread Rolls', 'Bakery', 'Bread', 'Tip Top', 'Bread Suppliers', '01234567890', 'unit', '6 pack', 1.80, 3.99, 54.89, 0, 0, '9300001000408', 7),
(409, 'Lamington', 'Bakery', 'Cakes', 'Australian Classic', 'Artisan Bakery', '11223344556', 'unit', '6 pack', 3.50, 7.49, 53.27, 0, 0, '9300001000409', 5),
(410, 'Vanilla Slice', 'Bakery', 'Pastries', 'Store Baked', 'Artisan Bakery', '11223344556', 'unit', 'each', 2.00, 4.49, 55.46, 0, 0, '9300001000410', 3),
-- Packaged Goods (30 products)
(501, 'Corn Flakes', 'Packaged Goods', 'Cereal', 'Kelloggs', 'Cereal Imports', '11223344556', 'unit', '500g', 2.80, 5.99, 53.26, 0, 0, '9300001000501', 180),
(502, 'Weet-Bix', 'Packaged Goods', 'Cereal', 'Sanitarium', 'Cereal Suppliers', '22334455667', 'unit', '575g', 3.00, 6.49, 53.77, 0, 0, '9300001000502', 180),
(503, 'Muesli', 'Packaged Goods', 'Cereal', 'Uncle Tobys', 'Cereal Suppliers', '22334455667', 'unit', '700g', 3.50, 7.49, 53.27, 0, 0, '9300001000503', 180),
(504, 'Pasta Penne', 'Packaged Goods', 'Pasta', 'San Remo', 'Italian Foods', '33445566778', 'unit', '500g', 1.20, 2.49, 51.81, 0, 0, '9300001000504', 730),
(505, 'Pasta Spaghetti', 'Packaged Goods', 'Pasta', 'San Remo', 'Italian Foods', '33445566778', 'unit', '500g', 1.20, 2.49, 51.81, 0, 0, '9300001000505', 730),
(506, 'Rice White', 'Packaged Goods', 'Rice', 'SunRice', 'Rice Suppliers', '44556677889', 'unit', '1kg', 2.00, 4.49, 55.46, 0, 0, '9300001000506', 365),
(507, 'Rice Basmati', 'Packaged Goods', 'Rice', 'SunRice', 'Rice Suppliers', '44556677889', 'unit', '1kg', 2.50, 5.49, 54.46, 0, 0, '9300001000507', 365),
(508, 'Olive Oil Extra Virgin', 'Packaged Goods', 'Oils', 'Cobram Estate', 'Victorian Farms', '23456789012', 'unit', '750mL', 6.50, 12.99, 49.96, 0, 0, '9300001000508', 365),
(509, 'Vegetable Oil', 'Packaged Goods', 'Oils', 'Meadow Lea', 'Oil Suppliers', '55667788990', 'unit', '1L', 3.00, 6.49, 53.77, 0, 0, '9300001000509', 365),
(510, 'Tomato Sauce', 'Packaged Goods', 'Condiments', 'Masterfoods', 'Condiment Co', '66778899001', 'unit', '500mL', 1.80, 3.99, 54.89, 0, 0, '9300001000510', 365);

PRINT 'Inserted 100 products successfully';
GO

-- =============================================
-- STEP 4: INSERT 1,000 CUSTOMERS
-- =============================================

PRINT 'Inserting 1,000 customers...';

DECLARE @CustID INT = 1001;
DECLARE @MaxCust INT = 2000;

-- Helper data
DECLARE @FirstNames TABLE (FName NVARCHAR(50));
INSERT INTO @FirstNames VALUES ('Liam'),('Noah'),('Oliver'),('William'),('James'),('Benjamin'),('Lucas'),('Henry'),('Alexander'),('Jack'),
('Olivia'),('Charlotte'),('Amelia'),('Ava'),('Mia'),('Isla'),('Sophia'),('Grace'),('Zoe'),('Emily'),
('Ethan'),('Mason'),('Logan'),('Jackson'),('Aiden'),('Sebastian'),('Matthew'),('Daniel'),('Thomas'),('Samuel');

DECLARE @LastNames TABLE (LName NVARCHAR(50));
INSERT INTO @LastNames VALUES ('Smith'),('Johnson'),('Williams'),('Brown'),('Jones'),('Garcia'),('Miller'),('Davis'),('Rodriguez'),('Martinez'),
('Wilson'),('Anderson'),('Taylor'),('Thomas'),('Moore'),('Jackson'),('Martin'),('Lee'),('Thompson'),('White'),
('Harris'),('Clark'),('Lewis'),('Robinson'),('Walker'),('Young'),('Allen'),('King'),('Wright'),('Scott');

DECLARE @Suburbs TABLE (Suburb NVARCHAR(50), State NVARCHAR(3), Postcode NVARCHAR(4));
INSERT INTO @Suburbs VALUES 
('Sydney','NSW','2000'),('Parramatta','NSW','2150'),('Bondi','NSW','2022'),('Newcastle','NSW','2300'),('Wollongong','NSW','2500'),
('Melbourne','VIC','3000'),('Chadstone','VIC','3148'),('Geelong','VIC','3220'),('Bendigo','VIC','3550'),('Ballarat','VIC','3350'),
('Brisbane','QLD','4000'),('Gold Coast','QLD','4217'),('Townsville','QLD','4810'),('Cairns','QLD','4870'),('Toowoomba','QLD','4350');

WHILE @CustID <= @MaxCust
BEGIN
    INSERT INTO DimCustomer (CustomerID, FirstName, LastName, Email, Phone, DateOfBirth, Gender, Suburb, State, Postcode, 
                             LoyaltyTier, LoyaltyJoinDate, LoyaltyPoints, PreferredStore, IsEmailSubscriber)
    SELECT 
        @CustID,
        (SELECT TOP 1 FName FROM @FirstNames ORDER BY NEWID()),
        (SELECT TOP 1 LName FROM @LastNames ORDER BY NEWID()),
        LOWER((SELECT TOP 1 FName FROM @FirstNames ORDER BY NEWID())) + '.' + 
        LOWER((SELECT TOP 1 LName FROM @LastNames ORDER BY NEWID())) + 
        CAST(ABS(CHECKSUM(NEWID())) % 1000 AS VARCHAR(4)) + '@email.com',
        '04' + CAST(10000000 + ABS(CHECKSUM(NEWID())) % 90000000 AS VARCHAR(8)),
        DATEADD(YEAR, -(ABS(CHECKSUM(NEWID())) % 50 + 18), GETDATE()),
        CASE ABS(CHECKSUM(NEWID())) % 3 WHEN 0 THEN 'Male' WHEN 1 THEN 'Female' ELSE 'Other' END,
        Suburb, State, Postcode,
        CASE ABS(CHECKSUM(NEWID())) % 10 WHEN 0 THEN 'Gold' WHEN 1 THEN 'Silver' WHEN 2 THEN 'Silver' ELSE 'Bronze' END,
        DATEADD(DAY, -(ABS(CHECKSUM(NEWID())) % 1095), GETDATE()),
        ABS(CHECKSUM(NEWID())) % 5000,
        (ABS(CHECKSUM(NEWID())) % 50) + 1,
        CASE WHEN ABS(CHECKSUM(NEWID())) % 2 = 0 THEN 1 ELSE 0 END
    FROM (SELECT TOP 1 Suburb, State, Postcode FROM @Suburbs ORDER BY NEWID()) AS S;
    
    SET @CustID = @CustID + 1;
END

PRINT 'Inserted 1,000 customers successfully';
GO

-- =============================================
-- STEP 5: INSERT CHANNELS
-- =============================================

INSERT INTO DimChannel (ChannelID, ChannelName, ChannelDescription)
VALUES
(1, 'In-Store', 'Traditional brick-and-mortar store purchases'),
(2, 'Online Delivery', 'Home delivery via website or mobile app'),
(3, 'Click & Collect', 'Online order with in-store pickup');

PRINT 'Inserted 3 channels successfully';
GO

-- =============================================
-- STEP 6: INSERT DATE DIMENSION (2023-2025)
-- =============================================

PRINT 'Inserting date dimension (2023-2025)...';

DECLARE @StartDate DATE = '2023-01-01';
DECLARE @EndDate DATE = '2025-12-31';
DECLARE @CurrentDate DATE = @StartDate;

WHILE @CurrentDate <= @EndDate
BEGIN
    DECLARE @Year INT = YEAR(@CurrentDate);
    DECLARE @Month INT = MONTH(@CurrentDate);
    DECLARE @Day INT = DAY(@CurrentDate);
    DECLARE @DayOfWeek INT = DATEPART(WEEKDAY, @CurrentDate);
    DECLARE @FY INT = CASE WHEN @Month >= 7 THEN @Year + 1 ELSE @Year END;
    DECLARE @IsWeekend BIT = CASE WHEN @DayOfWeek IN (1, 7) THEN 1 ELSE 0 END;
    DECLARE @IsEOFY BIT = CASE WHEN @Month = 6 AND @Day = 30 THEN 1 ELSE 0 END;

    INSERT INTO DimDate (
        DateKey, FullDate, DayOfWeek, DayName, DayOfMonth, DayOfYear,
        WeekOfYear, MonthNumber, MonthName, MonthShort, Quarter, QuarterName,
        Year, FinancialYear, FinancialQuarter, IsWeekend, IsPublicHoliday, IsEOFY
    )
    VALUES (
        CAST(FORMAT(@CurrentDate, 'yyyyMMdd') AS INT),
        @CurrentDate,
        @DayOfWeek,
        DATENAME(WEEKDAY, @CurrentDate),
        @Day,
        DATEPART(DAYOFYEAR, @CurrentDate),
        DATEPART(WEEK, @CurrentDate),
        @Month,
        DATENAME(MONTH, @CurrentDate),
        LEFT(DATENAME(MONTH, @CurrentDate), 3),
        DATEPART(QUARTER, @CurrentDate),
        'Q' + CAST(DATEPART(QUARTER, @CurrentDate) AS VARCHAR(1)),
        @Year,
        @FY,
        'FY' + CAST(@FY AS VARCHAR(4)) + '-Q' + CAST(
            CASE 
                WHEN @Month IN (7, 8, 9) THEN 1
                WHEN @Month IN (10, 11, 12) THEN 2
                WHEN @Month IN (1, 2, 3) THEN 3
                ELSE 4
            END AS VARCHAR(1)
        ),
        @IsWeekend,
        0,
        @IsEOFY
    );

    SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
END

PRINT 'Date dimension inserted - 1095 days (2023-2025)';
GO

-- =============================================
-- STEP 7: INSERT 50,000 TRANSACTIONS (OPTIMIZED)
-- =============================================

PRINT 'Inserting 50,000 transactions (this will take ~30 seconds)...';
PRINT 'Progress: Starting bulk insert...';

SET NOCOUNT ON;

-- Create temp table for batch insert
CREATE TABLE #TempTransactions (
    TransactionDate DATE,
    StoreID INT,
    CustomerID INT,
    ProductID INT,
    ChannelID INT,
    Quantity INT,
    UnitPrice DECIMAL(10,2),
    Revenue DECIMAL(12,2),
    GST DECIMAL(10,2),
    TotalAmount DECIMAL(12,2),
    Discount DECIMAL(10,2),
    CostOfGoods DECIMAL(10,2),
    GrossProfit DECIMAL(10,2),
    LoyaltyPointsEarned INT,
    PaymentMethod NVARCHAR(50),
    TransactionTime TIME
);

-- Insert in single batch using CROSS JOIN for speed
INSERT INTO #TempTransactions
SELECT TOP 50000
    DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 730, '2023-01-01') AS TransactionDate,
    (ABS(CHECKSUM(NEWID())) % 50) + 1 AS StoreID,
    CASE WHEN ABS(CHECKSUM(NEWID())) % 4 > 0 
         THEN (ABS(CHECKSUM(NEWID())) % 1000) + 1001 
         ELSE NULL END AS CustomerID,
    CASE 
        WHEN ABS(CHECKSUM(NEWID())) % 100 < 25 THEN (ABS(CHECKSUM(NEWID())) % 25) + 101  -- Fresh Produce
        WHEN ABS(CHECKSUM(NEWID())) % 100 < 45 THEN (ABS(CHECKSUM(NEWID())) % 20) + 201  -- Dairy
        WHEN ABS(CHECKSUM(NEWID())) % 100 < 60 THEN (ABS(CHECKSUM(NEWID())) % 15) + 301  -- Meat
        WHEN ABS(CHECKSUM(NEWID())) % 100 < 70 THEN (ABS(CHECKSUM(NEWID())) % 10) + 401  -- Bakery
        ELSE (ABS(CHECKSUM(NEWID())) % 10) + 501  -- Packaged
    END AS ProductID,
    (ABS(CHECKSUM(NEWID())) % 3) + 1 AS ChannelID,
    (ABS(CHECKSUM(NEWID())) % 5) + 1 AS Quantity,
    0 AS UnitPrice,
    0 AS Revenue,
    0 AS GST,
    0 AS TotalAmount,
    0 AS Discount,
    0 AS CostOfGoods,
    0 AS GrossProfit,
    0 AS LoyaltyPointsEarned,
    CASE ABS(CHECKSUM(NEWID())) % 5 
        WHEN 0 THEN 'Card'
        WHEN 1 THEN 'Cash'
        WHEN 2 THEN 'Digital Wallet'
        WHEN 3 THEN 'BNPL'
        ELSE 'Gift Card'
    END AS PaymentMethod,
    CAST(DATEADD(SECOND, ABS(CHECKSUM(NEWID())) % 43200 + 28800, 0) AS TIME) AS TransactionTime
FROM sys.objects o1
CROSS JOIN sys.objects o2;

PRINT 'Progress: 50,000 rows generated, calculating prices...';

-- Update with product prices and calculations
UPDATE t
SET 
    t.UnitPrice = p.RetailPrice,
    t.Revenue = t.Quantity * p.RetailPrice,
    t.GST = ROUND(t.Quantity * p.RetailPrice * 0.10, 2),
    t.TotalAmount = t.Quantity * p.RetailPrice + ROUND(t.Quantity * p.RetailPrice * 0.10, 2),
    t.Discount = CASE WHEN ABS(CHECKSUM(NEWID())) % 10 < 2 
                      THEN ROUND(t.Quantity * p.RetailPrice * 0.05, 2) 
                      ELSE 0 END,
    t.CostOfGoods = t.Quantity * p.UnitCost,
    t.GrossProfit = (t.Quantity * p.RetailPrice) - (t.Quantity * p.UnitCost),
    t.LoyaltyPointsEarned = CASE WHEN t.CustomerID IS NOT NULL 
                                  THEN CAST((t.Quantity * p.RetailPrice) / 10 AS INT) 
                                  ELSE 0 END
FROM #TempTransactions t
INNER JOIN DimProduct p ON t.ProductID = p.ProductID;

PRINT 'Progress: Prices calculated, inserting into final table...';

-- Insert into final table
INSERT INTO FactTransactions (
    TransactionDate, StoreID, CustomerID, ProductID, ChannelID, Quantity,
    UnitPrice, Revenue, GST, TotalAmount, Discount, CostOfGoods, GrossProfit,
    LoyaltyPointsEarned, PaymentMethod, TransactionTime
)
SELECT 
    TransactionDate, StoreID, CustomerID, ProductID, ChannelID, Quantity,
    UnitPrice, Revenue, GST, TotalAmount, Discount, CostOfGoods, GrossProfit,
    LoyaltyPointsEarned, PaymentMethod, TransactionTime
FROM #TempTransactions;

DROP TABLE #TempTransactions;

SET NOCOUNT OFF;

PRINT '50,000 transactions inserted successfully';
GO

-- =============================================
-- STEP 8: ADD FOREIGN KEY CONSTRAINTS
-- =============================================

PRINT 'Adding foreign key constraints...';

ALTER TABLE FactTransactions 
ADD CONSTRAINT FK_Transaction_Store FOREIGN KEY (StoreID) REFERENCES DimStore(StoreID);

ALTER TABLE FactTransactions 
ADD CONSTRAINT FK_Transaction_Customer FOREIGN KEY (CustomerID) REFERENCES DimCustomer(CustomerID);

ALTER TABLE FactTransactions 
ADD CONSTRAINT FK_Transaction_Product FOREIGN KEY (ProductID) REFERENCES DimProduct(ProductID);

ALTER TABLE FactTransactions 
ADD CONSTRAINT FK_Transaction_Channel FOREIGN KEY (ChannelID) REFERENCES DimChannel(ChannelID);

PRINT 'Foreign keys added successfully';
GO

-- =============================================
-- STEP 9: CREATE VIEWS FOR POWER BI
-- =============================================

CREATE VIEW vw_SalesByStore
AS
SELECT 
    s.StoreID, s.StoreName, s.State, s.StoreType, s.Region,
    COUNT(t.TransactionID) AS TotalTransactions,
    SUM(t.Revenue) AS TotalRevenue,
    SUM(t.GST) AS TotalGST,
    SUM(t.GrossProfit) AS TotalProfit,
    AVG(t.Revenue) AS AverageTransactionValue
FROM DimStore s
LEFT JOIN FactTransactions t ON s.StoreID = t.StoreID
GROUP BY s.StoreID, s.StoreName, s.State, s.StoreType, s.Region;
GO

CREATE VIEW vw_ProductPerformance
AS
SELECT 
    p.ProductID, p.ProductName, p.Category, p.SubCategory, p.Brand,
    COUNT(t.TransactionID) AS TransactionCount,
    SUM(t.Quantity) AS TotalQuantitySold,
    SUM(t.Revenue) AS TotalRevenue,
    SUM(t.GrossProfit) AS TotalProfit,
    AVG(p.MarginPercent) AS AvgMarginPercent
FROM DimProduct p
LEFT JOIN FactTransactions t ON p.ProductID = t.ProductID
GROUP BY p.ProductID, p.ProductName, p.Category, p.SubCategory, p.Brand, p.MarginPercent;
GO

CREATE VIEW vw_DailySalesTrend
AS
SELECT 
    d.FullDate, d.FinancialYear, d.MonthName, d.DayName, d.IsWeekend,
    COUNT(t.TransactionID) AS TransactionCount,
    SUM(t.Revenue) AS DailyRevenue,
    SUM(t.GST) AS DailyGST,
    SUM(t.GrossProfit) AS DailyProfit
FROM DimDate d
LEFT JOIN FactTransactions t ON d.FullDate = t.TransactionDate
GROUP BY d.FullDate, d.FinancialYear, d.MonthName, d.DayName, d.IsWeekend;
GO

CREATE VIEW vw_CustomerAnalysis
AS
SELECT 
    c.CustomerID, c.FirstName, c.LastName, c.LoyaltyTier, c.State,
    COUNT(t.TransactionID) AS TotalPurchases,
    SUM(t.Revenue) AS TotalSpent,
    AVG(t.Revenue) AS AvgTransactionValue,
    MAX(t.TransactionDate) AS LastPurchaseDate,
    c.LoyaltyPoints
FROM DimCustomer c
LEFT JOIN FactTransactions t ON c.CustomerID = t.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName, c.LoyaltyTier, c.State, c.LoyaltyPoints;
GO

PRINT 'Views created successfully';
GO

-- =============================================
-- STEP 10: VALIDATION & SUMMARY
-- =============================================

PRINT '';
PRINT '==============================================';
PRINT 'DATABASE SETUP COMPLETE - MEDIUM DATASET';
PRINT '==============================================';
PRINT '';
PRINT 'Row Counts:';
PRINT '-----------';

SELECT 'DimStore' AS TableName, COUNT(*) AS RowCount FROM DimStore
UNION ALL
SELECT 'DimProduct', COUNT(*) FROM DimProduct
UNION ALL
SELECT 'DimCustomer', COUNT(*) FROM DimCustomer
UNION ALL
SELECT 'DimChannel', COUNT(*) FROM DimChannel
UNION ALL
SELECT 'DimDate', COUNT(*) FROM DimDate
UNION ALL
SELECT 'FactTransactions', COUNT(*) FROM FactTransactions;

PRINT '';
PRINT 'Revenue Summary:';
PRINT '----------------';

SELECT 
    FORMAT(SUM(Revenue), 'C', 'en-AU') AS TotalRevenue,
    FORMAT(SUM(GST), 'C', 'en-AU') AS TotalGST,
    FORMAT(SUM(GrossProfit), 'C', 'en-AU') AS TotalProfit,
    FORMAT(AVG(Revenue), 'C', 'en-AU') AS AvgTransactionValue,
    MIN(TransactionDate) AS EarliestTransaction,
    MAX(TransactionDate) AS LatestTransaction
FROM FactTransactions;

PRINT '';
PRINT '==============================================';
PRINT 'POWER BI CONNECTION DETAILS';
PRINT '==============================================';
PRINT 'Server: localhost (or your SQL Server instance name)';
PRINT 'Database: FreshMarket_DB';
PRINT 'Authentication: Windows Authentication';
PRINT '';
PRINT 'Tables to Import:';
PRINT '- DimStore (50 stores)';
PRINT '- DimProduct (100 products)';
PRINT '- DimCustomer (1,000 customers)';
PRINT '- DimChannel (3 channels)';
PRINT '- DimDate (1,095 days)';
PRINT '- FactTransactions (50,000 transactions)';
PRINT '';
PRINT 'Power BI Ready Views:';
PRINT '- vw_SalesByStore';
PRINT '- vw_ProductPerformance';
PRINT '- vw_DailySalesTrend';
PRINT '- vw_CustomerAnalysis';
PRINT '';
PRINT 'Execution Time: ~30-60 seconds';
PRINT 'Database Size: ~20-30 MB';
PRINT 'Perfect for Power BI bootcamp training!';
PRINT '==============================================';
GO

-- End of Medium Dataset Script
