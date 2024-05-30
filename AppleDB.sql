CREATE DATABASE Apple_test
USE Apple_testm
GO
-- DROP DATABASE Apple_test

CREATE TABLE Employee
(EmployeeID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
EmployeeFname varchar(50) NOT NULL,
EmployeeLname varchar(50) NOT NULL,
EmployeeEmail varchar(75) NULL,
EmployeePhone varchar(15) NULL,
EmployeeHireDate DATE NOT NULL,
EmployeeDOB DATE NOT NULL)

CREATE TABLE EmployeeType
(EmployeeTypeID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
EmployeeTypeName varchar(50) NOT NULL,
EmployeeTypeDescr varchar(500) NULL)

CREATE TABLE DiscountType
(DiscountTypeID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
DiscountTypeName varchar(50) NOT NULL,
DiscountTypeDescr varchar(500) NULL)

CREATE TABLE OrderType
(OrderTypeID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
OrderTypeName varchar(50) NOT NULL,
OrderTypeDescr varchar(500) NULL)

CREATE TABLE ProductType
(ProductTypeID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
ProductTypeName varchar(50) NOT NULL,
ProductTypeDescr varchar(500) NULL)

CREATE TABLE Supplier
(SupplierID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
SupplierName varchar(50) NOT NULL,
StreetAddress varchar(50) NULL,
City varchar(50) NULL,
StateName varchar(50) NULL,
Country varchar(50) NOT NULL)

CREATE TABLE Product
(ProductID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
ProductTypeID INT FOREIGN KEY REFERENCES ProductType(ProductTypeID) NOT NULL,
ProductName varchar(50) NOT NULL,
ProductDescr varchar(500) NULL,
Price NUMERIC(9,2) NOT NULL)

CREATE TABLE PriceHistory
(PriceHistoryID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
ProductID INT FOREIGN KEY REFERENCES Product(ProductID),
Price NUMERIC(9,2) NOT NULL,
BeginDate DATE NOT NULL,
EndDate DATE NULL)

CREATE TABLE SupplierProduct
(SupProdID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
SupplierID INT FOREIGN KEY REFERENCES Supplier(SupplierID) NOT NULL,
ProductID INT FOREIGN KEY REFERENCES Product(ProductID) NOT NULL)

CREATE TABLE Discount
(DiscountID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
DiscountName varchar(50) NOT NULL,
DiscountTypeID INT FOREIGN KEY REFERENCES DiscountType(DiscountTypeID) NOT NULL,
DiscountUnit varchar(50) NOT NULL, -- 'percentage' or 'dollar'
DiscountValue NUMERIC(9,2) NOT NULL)

CREATE TABLE Store
(StoreID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
StoreName varchar(50) NOT NULL,
StreetAddress varchar(50) NULL,
City varchar(50) NULL,
StateName varchar(25) NULL,
Country varchar(50) NOT NULL)

CREATE TABLE Shipper
(ShipperID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
ShipperName varchar(50) NOT NULL,
ShipperDescr varchar(500) NULL)

CREATE TABLE Shipment
(ShipmentID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
ShipmentName varchar(50) NOT NULL,
OrderQuantity INT NOT NULL,
ShipperID INT FOREIGN KEY REFERENCES Shipper(ShipperID) NOT NULL,
ShipDate DATE NOT NULL)

CREATE TABLE Orders
(OrderID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
StoreID INT FOREIGN KEY REFERENCES Store(StoreID) NOT NULL,
OrderTypeID INT FOREIGN KEY REFERENCES OrderType(OrderTypeID) NOT NULL,
OrderTotal NUMERIC(9,2) NOT NULL,       -- order total
DateCreated DATE NOT NULL,
SupplierID INT FOREIGN KEY REFERENCES Supplier(SupplierID) NOT NULL,
--JobID INT FOREIGN KEY REFERENCES Job(JobID) NOT NULL,
ShipmentID INT FOREIGN KEY REFERENCES Shipment(ShipmentID) NOT NULL)

CREATE TABLE OrderProduct
(OrdProdID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
OrderTotal NUMERIC(9,2) NOT NULL,       -- order total
OrderID INT FOREIGN KEY REFERENCES Orders(OrderID) NOT NULL,
ProductID INT FOREIGN KEY REFERENCES Product(ProductID) NOT NULL,
ProdQuantity INT NOT NULL,
DiscountID INT FOREIGN KEY REFERENCES Discount(DiscountID) NULL)
GO

-- 1. Stored procedure to insert into DiscountType
CREATE OR ALTER PROCEDURE uspInsertDiscountType
    @DT_Name VARCHAR(50)
AS
BEGIN
    BEGIN TRANSACTION T1

    INSERT INTO DiscountType (DiscountTypeName)
    VALUES (@DT_Name)

    IF @@ERROR <> 0
    BEGIN
        ROLLBACK TRANSACTION T1
        PRINT 'Something wrong in transaction' 
    END
    ELSE
        COMMIT TRANSACTION T1
END
GO

-- 1. Stored procedure to get DiscountTypeID
CREATE OR ALTER PROCEDURE uspGetDiscountTypeID
    @DT_Name_g VARCHAR(50),
    @DT_ID_g INT OUTPUT
AS
BEGIN
    SET @DT_ID_g = (SELECT DiscountTypeID
                  FROM DiscountType
                  WHERE DiscountTypeName = @DT_Name_g)
END
GO

-- 1. Stored procedure to insert into Discount
CREATE OR ALTER PROCEDURE uspInsertDiscount
    @D_Name VARCHAR (50),
    @DT_Name VARCHAR(50),
    @D_Unit VARCHAR(50),
    @D_Value NUMERIC(9,2)
AS
BEGIN
    DECLARE @DT_ID INT 
    -- Retrieve DiscountTypeID using the GetDiscountTypeID procedure
    EXEC uspGetDiscountTypeID 
        @DT_Name_g = @DT_Name, 
        @DT_ID_g = @DT_ID OUTPUT 
    
    IF @DT_ID IS NULL
        BEGIN
            PRINT 'DiscountTypeID cannot be null'
        END

    BEGIN TRANSACTION T1
        INSERT INTO Discount (DiscountName, DiscountTypeID, DiscountUnit, DiscountValue)
        VALUES (@D_Name, @DT_ID, @D_Unit, @D_Value)

    IF @@ERROR <> 0
        BEGIN
            ROLLBACK TRANSACTION T1
            PRINT 'Something wrong in transaction'
        END
    ELSE
        COMMIT TRANSACTION T1
END
GO
/*
INSERT INTO DiscountType (DiscountTypeName, DiscountTypeDescr)
VALUES 
  ('Seasonal', 'Seasonal discounts offered during specific periods'),
  ('Promotional', 'Special discounts for promotional events'),
  ('Employee', 'Discounts for employees')

EXEC uspInsertDiscount @D_Name = 'Summer sale', @DT_Name = 'Seasonal', @D_Unit = 'Percentage', @D_Value = '15.00'
EXEC uspInsertDiscount @D_Name = 'Black Friday', @DT_Name = 'Seasonal', @D_Unit = 'Percentage', @D_Value = '50.00'
EXEC uspInsertDiscount @D_Name = 'Employee Discount', @DT_Name = 'Employee', @D_Unit = 'Dollar', @D_Value = '5.00'
EXEC uspInsertDiscount @D_Name = 'First Purchase', @DT_Name = 'Promotional', @D_Unit = 'Dollar', @D_Value = '20.00'
GO
*/

-- 2. Create a function that makes stores in Oregon cannot have Black Friday discount for Samsung products
CREATE FUNCTION fn_oregonBlackFridaySamsung()
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = 0 
    IF EXISTS (
        SELECT *
        FROM Store S
        JOIN Orders O ON S.StoreID = O.StoreID
        JOIN OrderProduct OP ON O.OrderID = OP.OrderID
        JOIN Discount D ON OP.DiscountID = D.DiscountID
        JOIN DiscountType DT ON D.DiscountTypeID = DT.DiscountTypeID
        JOIN Product P ON OP.ProductID = P.ProductID
        JOIN SupplierProduct SUPP ON P.ProductID = SUPP.ProductID
        JOIN Supplier SUP ON SUPP.SupplierID = SUP.SupplierID
        WHERE S.[StateName] = 'Oregon'
          AND DT.DiscountTypeName = 'Black Friday'
          AND SUP.SupplierName = 'Samsung'
    )
    BEGIN
        SET @RET = 1
    END
    RETURN @RET
END
GO

-- Add a check constraint to ensure stores in Oregon cannot have Black Friday discount for Samsung products
ALTER TABLE Orders
ADD CONSTRAINT ck_oregonBlackFridaySamsung
CHECK (dbo.fn_oregonBlackFridaySamsung() = 0) 
GO

-- 2. Create a function that makes iPhones cannot be on sale for Black Friday in all stores in the United States
CREATE FUNCTION fn_blackFridayIphone()
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = 0 
    IF EXISTS (
        SELECT *
        FROM Orders O
        JOIN OrderProduct OP ON O.OrderID = OP.OrderID
        JOIN Product P ON OP.ProductID = P.ProductID
        JOIN Discount D ON OP.DiscountID = D.DiscountID
        JOIN DiscountType DT ON D.DiscountTypeID = DT.DiscountTypeID
        JOIN Store S ON O.StoreID = S.StoreID
        JOIN ProductType PT ON P.ProductTypeID = PT.ProductTypeID
        WHERE PT.ProductTypeName = 'iPhone'
          AND DT.DiscountTypeName = 'Black Friday'
          AND S.Country = 'United States'
    )
    BEGIN
        SET @RET = 1
    END
    RETURN @RET
END
GO

-- Add a check constraint to ensure no iPhones are on sale for Black Friday in all stores in the United States
ALTER TABLE Orders
ADD CONSTRAINT ck_blackFridayIphone
CHECK (dbo.fn_blackFridayIphone() = 0) 
GO

-- 3. Computed column: calculate the average discount amount in dollar for each store by state across the U.S. since January 2020
CREATE FUNCTION fn_averageDisc(@State VARCHAR(50))
RETURNS NUMERIC(16,2)
AS
BEGIN
    DECLARE @RET NUMERIC(16,2) = (
        SELECT SUM(D.DiscountValue) / COUNT(DISTINCT OP.OrderID)
        FROM Discount D
        JOIN OrderProduct OP ON D.DiscountID = OP.DiscountID
        JOIN Orders O ON OP.OrderID = O.OrderID
        JOIN Store S ON O.StoreID = S.StoreID
        WHERE S.StateName = @State
          AND D.DiscountUnit = 'Dollar'
          AND O.DateCreated > '2020-01-01'
    )
    RETURN @RET
END
GO

-- Add a computed column for average discount amount in dollar
ALTER TABLE Store
ADD AverageDiscountAmountDollar AS dbo.fn_averageDisc(StateName)
GO

-- 3. Computed column: the total number of orders for each discount type this year
CREATE FUNCTION fn_totalOrdersByDiscountType(@DiscountTypeID INT)
RETURNS INT
AS
BEGIN
    DECLARE @TotalOrders INT = (
        SELECT COUNT(O.OrderID)
        FROM Orders O
        JOIN OrderProduct OP ON O.OrderID = OP.OrderID
        JOIN Discount D ON OP.DiscountID = D.DiscountID
        WHERE D.DiscountTypeID = @DiscountTypeID
          AND YEAR(O.DateCreated) = YEAR(GetDate())
    )
    RETURN @TotalOrders
END
GO

-- Add a computed column for the total number of orders for each discount type in this year
ALTER TABLE DiscountType
ADD TotalOrders2023 AS dbo.fn_totalOrdersByDiscountType(DiscountTypeID)
GO

-- 4. View: show the top 5 discount types with the most number of orders, partitioned by store state
CREATE VIEW vw_TopDiscountTypesByOrders AS
SELECT
    D.DiscountTypeID,
    DT.DiscountTypeName,
    S.StateName AS StoreState,
    RANK() OVER (PARTITION BY S.StateName ORDER BY COUNT(O.OrderID) DESC) AS Rank,
    COUNT(O.OrderID) AS TotalOrders
FROM Orders O
    JOIN OrderProduct OP ON O.OrderID = OP.OrderID
    JOIN Discount D ON OP.DiscountID = D.DiscountID
    JOIN DiscountType DT ON D.DiscountTypeID = DT.DiscountTypeID
    JOIN Store S ON O.StoreID = S.StoreID
GROUP BY D.DiscountTypeID, DT.DiscountTypeName, S.StateName
GO

SELECT * FROM vw_TopDiscountTypesByOrders
WHERE Rank <=5
GO 

-- 4. View: show the top 10 stores who placed the highest number of Macbook orders during "Back to School"
CREATE VIEW vw_TopStoresMacOrders AS
SELECT
    S.StoreID,
    S.StoreName,
    DENSE_RANK() OVER (ORDER BY COUNT(O.OrderID) DESC) AS DenseRank,
    COUNT(O.OrderID) AS TotalMacOrders
FROM Store S
    JOIN Orders O ON O.StoreID = S.StoreID
    JOIN OrderProduct OP ON O.OrderID = OP.OrderID
    JOIN Product P ON OP.ProductID = P.ProductID
    JOIN Discount D ON OP.DiscountID = D.DiscountID
WHERE P.ProductName = '%Macbook%' -- Modify the product name as needed
    AND D.DiscountName = 'Back to School'
GROUP BY S.StoreID, S.StoreName
GO

SELECT * FROM vw_TopStoresMacOrders
WHERE DenseRank <=10
GO 

