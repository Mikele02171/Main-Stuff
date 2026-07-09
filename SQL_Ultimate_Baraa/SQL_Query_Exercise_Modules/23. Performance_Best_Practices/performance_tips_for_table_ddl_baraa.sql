-- ========================================================================================
-- Tip 20: Avoid Data Types VARCHAR and TEXT
-- ========================================================================================

/* CREATE TABLE CustomersInfo (
CustomerID INT,
FirstName VARCHAR(MAX),
LastName TEXT,
Country VARCHAR(255),
TotalPurchases FLOAT,
Score VARCHAR(255),
BirthDate VARCHAR(255),
EmployeeID INT,
CONSTRAINT FK_CustomersInfo_Employee FOREIGN KEY (EmployeeID)
REFERENCES Sales.Employees(EmployeeID)
) */



-- ========================================================================================
-- Tip 21: Avoid (MAX) unnecessarily large lengths in data types
-- ========================================================================================

/* CREATE TABLE CustomersInfo (
CustomerID INT,
FirstName VARCHAR(MAX),
LastName VARCHAR(50),
Country VARCHAR(255),
TotalPurchases FLOAT,
Score INT,
BirthDate DATE,
EmployeeID INT,
CONSTRAINT FK_CustomersInfo_Employee FOREIGN KEY (EmployeeID)
REFERENCES Sales.Employees(EmployeeID)
) */

-- ========================================================================================
-- Tip 22: Use the NOT NULL constraint where applicable
-- ========================================================================================

/* CREATE TABLE CustomersInfo (
CustomerID INT,
FirstName VARCHAR(50),
LastName VARCHAR(50),
Country VARCHAR(50),
TotalPurchases FLOAT,
Score INT,
BirthDate DATE,
EmployeeID INT,
CONSTRAINT FK_CustomersInfo_Employee FOREIGN KEY (EmployeeID)
REFERENCES Sales.Employees(EmployeeID)
) */

-- ========================================================================================
-- Tip 23: Ensure all your tables have a Clustered Primary Key
-- ========================================================================================

/* CREATE TABLE CustomersInfo (
CustomerID INT,
FirstName VARCHAR(50) NOT NULL,
LastName VARCHAR(50) NOT NULL,
Country VARCHAR(50) NOT NULL,
TotalPurchases FLOAT,
Score INT,
BirthDate DATE,
EmployeeID INT,
CONSTRAINT FK_CustomersInfo_Employee FOREIGN KEY (EmployeeID)
REFERENCES Sales.Employees(EmployeeID)
)  */

-- ========================================================================================
-- Tip 24: Create a non-clustered index for foreign keys that are used frequently
-- ========================================================================================

/* CREATE TABLE CustomersInfo (
CustomerID INT PRIMARY KEY CLUSTERED,
FirstName VARCHAR(50) NOT NULL,
LastName VARCHAR(50) NOT NULL,
Country VARCHAR(50) NOT NULL,
TotalPurchases FLOAT,
Score INT,
BirthDate DATE,
EmployeeID INT,
CONSTRAINT FK_CustomersInfo_Employee FOREIGN KEY (EmployeeID)
REFERENCES Sales.Employees(EmployeeID)
)   */

CREATE TABLE CustomersInfo (
CustomerID INT PRIMARY KEY CLUSTERED,
FirstName VARCHAR(50) NOT NULL,
LastName VARCHAR(50) NOT NULL,
Country VARCHAR(50) NOT NULL,
TotalPurchases FLOAT,
Score INT,
BirthDate DATE,
EmployeeID INT,
CONSTRAINT FK_CustomersInfo_Employee FOREIGN KEY (EmployeeID)
REFERENCES Sales.Employees(EmployeeID)
) 

CREATE NONCLUSTERED INDEX IX_CustomersInfo_EmployeeID
ON CustomersInfo(EmployeeID)