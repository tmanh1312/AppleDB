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
