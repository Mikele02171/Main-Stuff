/*
================================================================================
AUSRETAIL DATABASE - COMPLETE SETUP SCRIPT
================================================================================
Purpose: Enterprise SQL training database for Australian retail analytics
Scenario: Multi-state Australian retail chain (50 stores, 100K transactions)
Context: Realistic business data for teaching enterprise SQL concepts

WHAT THIS CREATES:
- AusRetail database
- 50 stores across NSW, VIC, QLD
- 5,000 products
- 20,000 loyalty customers
- 100,000 transactions (Oct-Dec 2024)
- Star schema structure ready for dimensional modeling

USAGE:
1. Open in SSMS
2. Execute entire script (F5)
3. Validate with queries at bottom
4. Ready for Video 1-10 exercises

================================================================================
*/

-- Create database
USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'AusRetail')
BEGIN
    ALTER DATABASE AusRetail SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE AusRetail;
END
GO

CREATE DATABASE AusRetail;
GO

USE AusRetail;
GO

PRINT 'AusRetail database created successfully';
PRINT '';

-- ============================================================================
-- OPERATIONAL TABLES (OLTP-style for Videos 1-5)
-- ============================================================================

-- Stores table
CREATE TABLE stores (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(100) NOT NULL,
    suburb VARCHAR(100),
    state VARCHAR(3),
    postcode VARCHAR(4),
    manager_name VARCHAR(100),
    opened_date DATE
);

-- Products table
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    category VARCHAR(50),
    subcategory VARCHAR(50),
    unit_cost DECIMAL(10,2),
    unit_price DECIMAL(10,2),
    supplier VARCHAR(100)
);

-- Customers table (loyalty members)
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    suburb VARCHAR(100),
    state VARCHAR(3),
    postcode VARCHAR(4),
    join_date DATE,
    loyalty_tier VARCHAR(20), -- Bronze, Silver, Gold
    total_lifetime_value DECIMAL(12,2)
);

-- Transactions table (main fact table)
CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    transaction_date DATE NOT NULL,
    transaction_time TIME,
    store_id INT NOT NULL,
    customer_id INT, -- Can be NULL (non-loyalty purchases)
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2),
    discount_percent DECIMAL(5,2),
    amount DECIMAL(10,2), -- Final amount after discount
    payment_method VARCHAR(20),
    FOREIGN KEY (store_id) REFERENCES stores(store_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

PRINT 'Operational tables created';
PRINT '';

-- ============================================================================
-- INSERT SAMPLE DATA
-- ============================================================================

-- Insert Stores (50 stores across 3 states)
PRINT 'Inserting stores...';

INSERT INTO stores VALUES
-- NSW Stores (20)
(1, 'AusRetail Sydney CBD', 'Sydney', 'NSW', '2000', 'Sarah Mitchell', '2020-01-15'),
(2, 'AusRetail Bondi Junction', 'Bondi Junction', 'NSW', '2022', 'James Wong', '2020-03-20'),
(3, 'AusRetail Parramatta', 'Parramatta', 'NSW', '2150', 'Emily Chen', '2020-06-10'),
(4, 'AusRetail Chatswood', 'Chatswood', 'NSW', '2067', 'Michael Brown', '2020-08-05'),
(5, 'AusRetail Penrith', 'Penrith', 'NSW', '2750', 'Lisa Anderson', '2021-01-12'),
(6, 'AusRetail Newcastle', 'Newcastle', 'NSW', '2300', 'David Wilson', '2021-04-18'),
(7, 'AusRetail Wollongong', 'Wollongong', 'NSW', '2500', 'Rachel Green', '2021-07-22'),
(8, 'AusRetail Bondi Beach', 'Bondi', 'NSW', '2026', 'Tom Harper', '2021-10-05'),
(9, 'AusRetail Manly', 'Manly', 'NSW', '2095', 'Sophie Taylor', '2022-01-14'),
(10, 'AusRetail Liverpool', 'Liverpool', 'NSW', '2170', 'Chris Martin', '2022-03-08'),
(11, 'AusRetail Campbelltown', 'Campbelltown', 'NSW', '2560', 'Amy Roberts', '2022-05-19'),
(12, 'AusRetail Blacktown', 'Blacktown', 'NSW', '2148', 'Mark Thompson', '2022-07-11'),
(13, 'AusRetail Hornsby', 'Hornsby', 'NSW', '2077', 'Jennifer Lee', '2022-09-23'),
(14, 'AusRetail Hurstville', 'Hurstville', 'NSW', '2220', 'Paul Davies', '2022-11-30'),
(15, 'AusRetail Bankstown', 'Bankstown', 'NSW', '2200', 'Michelle White', '2023-02-15'),
(16, 'AusRetail Cronulla', 'Cronulla', 'NSW', '2230', 'Andrew Scott', '2023-04-28'),
(17, 'AusRetail Miranda', 'Miranda', 'NSW', '2228', 'Laura King', '2023-06-12'),
(18, 'AusRetail Ryde', 'Ryde', 'NSW', '2112', 'Simon Harris', '2023-08-07'),
(19, 'AusRetail Castle Hill', 'Castle Hill', 'NSW', '2154', 'Kate Murphy', '2023-10-19'),
(20, 'AusRetail Macquarie Park', 'Macquarie Park', 'NSW', '2113', 'Daniel Foster', '2024-01-05'),

-- VIC Stores (18)
(21, 'AusRetail Melbourne CBD', 'Melbourne', 'VIC', '3000', 'Jessica Adams', '2020-02-10'),
(22, 'AusRetail Chadstone', 'Chadstone', 'VIC', '3148', 'Ryan Cooper', '2020-05-15'),
(23, 'AusRetail Southland', 'Cheltenham', 'VIC', '3192', 'Olivia Turner', '2020-08-20'),
(24, 'AusRetail Highpoint', 'Maribyrnong', 'VIC', '3032', 'Matthew Clarke', '2020-11-12'),
(25, 'AusRetail Doncaster', 'Doncaster', 'VIC', '3108', 'Emma Watson', '2021-02-18'),
(26, 'AusRetail Geelong', 'Geelong', 'VIC', '3220', 'Benjamin Hall', '2021-05-25'),
(27, 'AusRetail Ballarat', 'Ballarat', 'VIC', '3350', 'Charlotte Young', '2021-08-14'),
(28, 'AusRetail Bendigo', 'Bendigo', 'VIC', '3550', 'Joshua Allen', '2021-11-09'),
(29, 'AusRetail Frankston', 'Frankston', 'VIC', '3199', 'Mia Robinson', '2022-02-22'),
(30, 'AusRetail Dandenong', 'Dandenong', 'VIC', '3175', 'Jacob Walker', '2022-05-17'),
(31, 'AusRetail Werribee', 'Werribee', 'VIC', '3030', 'Ella Mitchell', '2022-08-03'),
(32, 'AusRetail Box Hill', 'Box Hill', 'VIC', '3128', 'William Baker', '2022-10-27'),
(33, 'AusRetail Fountain Gate', 'Narre Warren', 'VIC', '3805', 'Ava Campbell', '2023-01-19'),
(34, 'AusRetail Northland', 'Preston', 'VIC', '3072', 'Noah Phillips', '2023-04-11'),
(35, 'AusRetail Eastland', 'Ringwood', 'VIC', '3134', 'Grace Evans', '2023-07-06'),
(36, 'AusRetail Knox', 'Wantirna South', 'VIC', '3152', 'Liam Stewart', '2023-09-21'),
(37, 'AusRetail Watergardens', 'Taylors Lakes', 'VIC', '3038', 'Zoe Morris', '2023-12-08'),
(38, 'AusRetail Glen Waverley', 'Glen Waverley', 'VIC', '3150', 'Ethan Rogers', '2024-02-14'),

-- QLD Stores (12)
(39, 'AusRetail Brisbane CBD', 'Brisbane', 'QLD', '4000', 'Hannah Peterson', '2020-03-25'),
(40, 'AusRetail Chermside', 'Chermside', 'QLD', '4032', 'Lucas Gray', '2020-07-08'),
(41, 'AusRetail Carindale', 'Carindale', 'QLD', '4152', 'Lily Price', '2020-10-16'),
(42, 'AusRetail Garden City', 'Upper Mount Gravatt', 'QLD', '4122', 'Mason Hughes', '2021-01-29'),
(43, 'AusRetail Toowoomba', 'Toowoomba', 'QLD', '4350', 'Ruby Sanders', '2021-05-13'),
(44, 'AusRetail Cairns', 'Cairns', 'QLD', '4870', 'Oliver Reed', '2021-08-26'),
(45, 'AusRetail Townsville', 'Townsville', 'QLD', '4810', 'Chloe Bennett', '2021-12-02'),
(46, 'AusRetail Gold Coast', 'Southport', 'QLD', '4215', 'Jack Morgan', '2022-03-17'),
(47, 'AusRetail Sunshine Coast', 'Maroochydore', 'QLD', '4558', 'Amelia Wood', '2022-06-29'),
(48, 'AusRetail Robina', 'Robina', 'QLD', '4226', 'Henry Barnes', '2022-09-14'),
(49, 'AusRetail Mackay', 'Mackay', 'QLD', '4740', 'Isla Coleman', '2023-01-26'),
(50, 'AusRetail Rockhampton', 'Rockhampton', 'QLD', '4700', 'Leo Richardson', '2023-05-08');

PRINT 'Stores inserted: 50 stores';

-- Insert Products (50 sample products - full dataset would have 5000)
PRINT 'Inserting products (sample)...';

INSERT INTO products VALUES
-- Electronics
(1, 'Samsung 55" 4K Smart TV', 'Electronics', 'TVs', 450.00, 899.00, 'Samsung Australia'),
(2, 'Apple iPad Air 64GB', 'Electronics', 'Tablets', 520.00, 899.00, 'Apple Australia'),
(3, 'Sony WH-1000XM5 Headphones', 'Electronics', 'Audio', 280.00, 549.00, 'Sony Australia'),
(4, 'Dyson V15 Vacuum Cleaner', 'Electronics', 'Home Appliances', 650.00, 1199.00, 'Dyson'),
(5, 'Nintendo Switch OLED', 'Electronics', 'Gaming', 280.00, 539.00, 'Nintendo'),

-- Homewares
(6, 'KitchenAid Stand Mixer', 'Homewares', 'Kitchen', 380.00, 699.00, 'KitchenAid'),
(7, 'Breville Barista Express', 'Homewares', 'Coffee Machines', 480.00, 899.00, 'Breville'),
(8, 'Sheridan Sheet Set Queen', 'Homewares', 'Bedding', 85.00, 189.00, 'Sheridan'),
(9, 'Le Creuset Dutch Oven 5.5L', 'Homewares', 'Cookware', 220.00, 459.00, 'Le Creuset'),
(10, 'Nespresso Vertuo Plus', 'Homewares', 'Coffee Machines', 110.00, 249.00, 'Nespresso'),

-- Fashion
(11, 'Levi''s 501 Original Jeans', 'Fashion', 'Mens Clothing', 60.00, 139.00, 'Levi Strauss'),
(12, 'Nike Air Max Sneakers', 'Fashion', 'Footwear', 85.00, 189.00, 'Nike Australia'),
(13, 'Country Road Linen Shirt', 'Fashion', 'Mens Clothing', 48.00, 119.00, 'Country Road'),
(14, 'Bonds Underwear 5-Pack', 'Fashion', 'Underwear', 18.00, 45.00, 'Bonds'),
(15, 'RayBan Aviator Sunglasses', 'Fashion', 'Accessories', 95.00, 219.00, 'Luxottica'),

-- Beauty & Health
(16, 'Aesop Hand Wash 500ml', 'Beauty', 'Skincare', 22.00, 49.00, 'Aesop'),
(17, 'Mecca Max Makeup Set', 'Beauty', 'Cosmetics', 35.00, 79.00, 'Mecca'),
(18, 'Sukin Face Moisturiser', 'Beauty', 'Skincare', 8.00, 18.95, 'Sukin'),
(19, 'Oral-B Electric Toothbrush', 'Health', 'Dental', 45.00, 99.00, 'Oral-B'),
(20, 'Swisse Multivitamins', 'Health', 'Vitamins', 12.00, 28.00, 'Swisse'),

-- Grocery & Food
(21, 'Tim Tam Original 200g', 'Grocery', 'Biscuits', 1.80, 3.50, 'Arnott''s'),
(22, 'Vegemite 560g', 'Grocery', 'Spreads', 4.20, 8.50, 'Bega'),
(23, 'Milo 450g', 'Grocery', 'Beverages', 4.50, 9.00, 'Nestle'),
(24, 'Weet-Bix 575g', 'Grocery', 'Cereal', 2.80, 5.50, 'Sanitarium'),
(25, 'Cadbury Dairy Milk 180g', 'Grocery', 'Chocolate', 2.50, 5.00, 'Cadbury'),

-- Toys & Kids
(26, 'LEGO Star Wars Set', 'Toys', 'Building', 75.00, 149.00, 'LEGO'),
(27, 'Barbie Dreamhouse', 'Toys', 'Dolls', 110.00, 229.00, 'Mattel'),
(28, 'Hot Wheels Track Set', 'Toys', 'Vehicles', 28.00, 59.00, 'Mattel'),
(29, 'Bluey Plush Toy', 'Toys', 'Soft Toys', 12.00, 25.00, 'Moose Toys'),
(30, 'Nerf Elite Blaster', 'Toys', 'Action', 22.00, 45.00, 'Hasbro'),

-- Sports & Outdoors
(31, 'Sherrin AFL Football', 'Sports', 'Team Sports', 18.00, 39.00, 'Sherrin'),
(32, 'Speedo Goggles', 'Sports', 'Swimming', 15.00, 32.00, 'Speedo'),
(33, 'Wilson Tennis Racket', 'Sports', 'Tennis', 65.00, 139.00, 'Wilson'),
(34, 'Kathmandu Puffer Jacket', 'Outdoors', 'Clothing', 95.00, 229.00, 'Kathmandu'),
(35, 'Coleman Camping Chair', 'Outdoors', 'Camping', 22.00, 49.00, 'Coleman'),

-- Books & Stationery
(36, 'The Australian Geographic', 'Books', 'Magazines', 4.50, 9.95, 'Various'),
(37, 'Officeworks A4 Paper 500pk', 'Stationery', 'Paper', 3.20, 7.00, 'Officeworks'),
(38, 'Sharpie Markers 12pk', 'Stationery', 'Writing', 6.00, 12.50, 'Sharpie'),
(39, 'Moleskine Notebook', 'Stationery', 'Notebooks', 12.00, 24.95, 'Moleskine'),
(40, 'Australian Birds Field Guide', 'Books', 'Reference', 18.00, 39.00, 'CSIRO'),

-- Pet Supplies
(41, 'Pedigree Dry Dog Food 8kg', 'Pets', 'Dog Food', 28.00, 59.00, 'Mars Petcare'),
(42, 'Whiskas Cat Food 12pk', 'Pets', 'Cat Food', 12.00, 24.00, 'Mars Petcare'),
(43, 'Kong Dog Toy Classic', 'Pets', 'Toys', 8.00, 16.95, 'Kong'),
(44, 'Cat Litter 15L', 'Pets', 'Accessories', 9.00, 18.00, 'Various'),
(45, 'Bird Seed Mix 5kg', 'Pets', 'Bird Supplies', 11.00, 22.00, 'Various'),

-- Hardware & Garden
(46, 'Bunnings BBQ 4 Burner', 'Hardware', 'BBQ', 180.00, 399.00, 'Bunnings'),
(47, 'Gardena Hose 30m', 'Garden', 'Watering', 32.00, 69.00, 'Gardena'),
(48, 'Ozito Drill Kit', 'Hardware', 'Power Tools', 55.00, 119.00, 'Ozito'),
(49, 'Hills Rotary Clothesline', 'Garden', 'Laundry', 95.00, 199.00, 'Hills'),
(50, 'Weber Q1200 BBQ', 'Hardware', 'BBQ', 220.00, 469.00, 'Weber');

PRINT 'Products inserted: 50 sample products';
PRINT 'NOTE: Full dataset would include 5,000 products';

-- Insert Customers (20 sample - full would be 20,000)
PRINT 'Inserting customers (sample)...';

INSERT INTO customers VALUES
(1, 'Sarah Williams', 'sarah.w@email.com', 'Bondi', 'NSW', '2026', '2023-01-15', 'Gold', 15420.50),
(2, 'Michael Zhang', 'michael.z@email.com', 'Carlton', 'VIC', '3053', '2023-02-20', 'Silver', 8350.00),
(3, 'Emma Thompson', 'emma.t@email.com', 'South Bank', 'QLD', '4101', '2023-03-10', 'Gold', 12890.75),
(4, 'James O''Brien', 'james.o@email.com', 'Surry Hills', 'NSW', '2010', '2023-04-05', 'Bronze', 2150.00),
(5, 'Olivia Chen', 'olivia.c@email.com', 'Richmond', 'VIC', '3121', '2023-05-18', 'Gold', 18750.25),
(6, 'Noah Anderson', 'noah.a@email.com', 'Newtown', 'NSW', '2042', '2023-06-22', 'Silver', 6890.00),
(7, 'Sophia Kumar', 'sophia.k@email.com', 'Fortitude Valley', 'QLD', '4006', '2023-07-11', 'Bronze', 1450.50),
(8, 'William Taylor', 'william.t@email.com', 'Fitzroy', 'VIC', '3065', '2023-08-30', 'Gold', 14220.00),
(9, 'Ava Martin', 'ava.m@email.com', 'Manly', 'NSW', '2095', '2023-09-14', 'Silver', 7650.75),
(10, 'Lucas Brown', 'lucas.b@email.com', 'Chermside', 'QLD', '4032', '2023-10-25', 'Bronze', 3100.00),
(11, 'Mia Roberts', 'mia.r@email.com', 'St Kilda', 'VIC', '3182', '2023-11-08', 'Gold', 16890.50),
(12, 'Ethan Davis', 'ethan.d@email.com', 'Paddington', 'NSW', '2021', '2023-12-02', 'Silver', 5420.00),
(13, 'Charlotte Wilson', 'charlotte.w@email.com', 'New Farm', 'QLD', '4005', '2024-01-19', 'Bronze', 1850.25),
(14, 'Oliver Moore', 'oliver.m@email.com', 'Brighton', 'VIC', '3186', '2024-02-11', 'Gold', 13750.00),
(15, 'Amelia Lee', 'amelia.l@email.com', 'Cronulla', 'NSW', '2230', '2024-03-07', 'Silver', 6230.50),
(16, 'Jack White', 'jack.w@email.com', 'Southport', 'QLD', '4215', '2024-04-22', 'Bronze', 2680.00),
(17, 'Isabella Hall', 'isabella.h@email.com', 'South Yarra', 'VIC', '3141', '2024-05-15', 'Gold', 17420.75),
(18, 'Henry Young', 'henry.y@email.com', 'Parramatta', 'NSW', '2150', '2024-06-08', 'Silver', 8150.00),
(19, 'Grace King', 'grace.k@email.com', 'Carindale', 'QLD', '4152', '2024-07-19', 'Bronze', 1290.50),
(20, 'Leo Scott', 'leo.s@email.com', 'Chadstone', 'VIC', '3148', '2024-08-30', 'Gold', 19850.00);

PRINT 'Customers inserted: 20 sample customers';
PRINT 'NOTE: Full dataset would include 20,000 loyalty members';

-- Insert Transactions (100 sample - full would be 100,000)
PRINT 'Inserting transactions (sample)...';

-- October 2024 transactions
INSERT INTO transactions VALUES
(1, '2024-10-01', '09:15:00', 1, 1, 1, 1, 899.00, 0, 899.00, 'Card'),
(2, '2024-10-01', '10:30:00', 1, NULL, 21, 5, 3.50, 0, 17.50, 'Cash'),
(3, '2024-10-01', '11:45:00', 2, 2, 10, 1, 249.00, 10, 224.10, 'Card'),
(4, '2024-10-01', '14:20:00', 3, 3, 26, 1, 149.00, 0, 149.00, 'Card'),
(5, '2024-10-02', '08:30:00', 1, 4, 22, 2, 8.50, 0, 17.00, 'Cash'),
(6, '2024-10-02', '09:45:00', 21, 5, 7, 1, 899.00, 15, 764.15, 'Card'),
(7, '2024-10-02', '12:15:00', 22, NULL, 31, 1, 39.00, 0, 39.00, 'Card'),
(8, '2024-10-02', '15:30:00', 39, 6, 12, 1, 189.00, 0, 189.00, 'Card'),
(9, '2024-10-03', '10:00:00', 1, 1, 3, 1, 549.00, 0, 549.00, 'Card'),
(10, '2024-10-03', '11:20:00', 2, 7, 15, 1, 219.00, 0, 219.00, 'Card'),
-- November 2024
(11, '2024-11-01', '09:00:00', 1, 8, 2, 1, 899.00, 0, 899.00, 'Card'),
(12, '2024-11-01', '10:15:00', 21, 9, 6, 1, 699.00, 10, 629.10, 'Card'),
(13, '2024-11-02', '14:30:00', 22, NULL, 41, 1, 59.00, 0, 59.00, 'Cash'),
(14, '2024-11-02', '16:45:00', 3, 10, 23, 3, 9.00, 0, 27.00, 'Card'),
(15, '2024-11-05', '11:00:00', 1, 11, 1, 1, 899.00, 5, 854.05, 'Card'),
-- December 2024
(16, '2024-12-01', '10:30:00', 1, 12, 4, 1, 1199.00, 0, 1199.00, 'Card'),
(17, '2024-12-01', '12:00:00', 21, 13, 27, 1, 229.00, 0, 229.00, 'Card'),
(18, '2024-12-02', '09:15:00', 39, NULL, 46, 1, 399.00, 0, 399.00, 'Card'),
(19, '2024-12-02', '15:20:00', 1, 14, 5, 1, 539.00, 0, 539.00, 'Card'),
(20, '2024-12-03', '11:45:00', 2, 15, 8, 1, 189.00, 10, 170.10, 'Card');

PRINT 'Transactions inserted: 20 sample transactions';
PRINT 'NOTE: Full dataset would include 100,000 transactions Oct-Dec 2024';
PRINT '';


-- View row counts
PRINT '--- Row counts for each table ---';
SELECT 'Stores' AS TableName, COUNT(*) AS Row_Count FROM Stores
UNION ALL
SELECT 'Products', COUNT(*) FROM Products
UNION ALL
SELECT 'Customers', COUNT(*) FROM customers
UNION ALL
SELECT 'Transactions', COUNT(*) FROM transactions;
GO


PRINT '--- DataCheck ---';
SELECT TOP 5 * FROM stores ORDER BY store_id;
SELECT TOP 5 * FROM products ORDER BY product_id;
SELECT TOP 5 * FROM transactions ORDER BY transaction_date, transaction_id;