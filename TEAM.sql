-- Drop all previous tables if they exist
DROP TABLE Vendor_Bottle;
DROP TABLE OrderLine;
DROP TABLE Composition;
DROP TABLE Bottle_Line;
DROP TABLE Bottle_Shipment;
DROP TABLE Bottle_Order;
DROP TABLE Glass_Vendor;
DROP TABLE Bottle;
DROP TABLE Customer_Order;
DROP TABLE Customer;
DROP TABLE Product;
DROP TABLE Wine;
DROP TABLE Grape_Variety;
DROP TABLE Harvest;
DROP TABLE Vineyard;
DROP TABLE Supervisor;
DROP TABLE Employee;

-- Employee Table
CREATE TABLE Employee (
    EmployeeID NUMBER(10) PRIMARY KEY,
    Name VARCHAR2(100) NOT NULL,
    Position VARCHAR2(50) DEFAULT 'Worker' NOT NULL,
    SSN VARCHAR2(20) NOT NULL,
    Address VARCHAR2(255) NOT NULL,
    Phone VARCHAR2(20) NOT NULL,
    CONSTRAINT chk_employee_phone CHECK (LENGTH(Phone) >= 7)
);


-- Supervisor Table
CREATE TABLE Supervisor (
    SupervisorID NUMBER(10) PRIMARY KEY,
    EmployeeID NUMBER(10) NOT NULL,
    CONSTRAINT fk_supervisor_employee FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);

CREATE TABLE Vineyard (
    VineyardID NUMBER(10) PRIMARY KEY,
    Name VARCHAR2(100) NOT NULL,
    Location VARCHAR2(255) NOT NULL,
    VineyardSize VARCHAR2(50) NOT NULL,
    Managed_by NUMBER(10) DEFAULT 1 NOT NULL, -- Assuming 1 is the default supervisor ID
    CONSTRAINT fk_vineyard_supervisor FOREIGN KEY (Managed_by) REFERENCES Supervisor(SupervisorID)
);



-- Harvest Table
CREATE TABLE Harvest (
    HarvestID NUMBER(10) PRIMARY KEY,
    VineyardID NUMBER(10) NOT NULL,
    Grape_Variety VARCHAR2(100) NOT NULL,
    Weight NUMBER(10, 2) NOT NULL,
    Ripeness VARCHAR2(20) NOT NULL,
    VintageYear NUMBER(4) NOT NULL,
    CONSTRAINT fk_harvest_vineyard FOREIGN KEY (VineyardID) REFERENCES Vineyard(VineyardID)
);

-- Grape Variety Table
CREATE TABLE Grape_Variety (
    VarietyID NUMBER(10) PRIMARY KEY,
    Juice_Conversion_Ratio NUMBER(10, 2) NOT NULL,
    Wine_Storage_Requirement VARCHAR2(100) NOT NULL,
    Wine_Aging_Requirement VARCHAR2(100) NOT NULL
);

-- Wine Table
CREATE TABLE Wine (
    WineID NUMBER(10) PRIMARY KEY,
    Name VARCHAR2(100) NOT NULL,
    Vintage_Year NUMBER(4) NOT NULL,
    Category VARCHAR2(50) NOT NULL,
    Percent_Alcohol NUMBER(5, 2) NOT NULL,
    Made_by NUMBER(10) DEFAULT 1 NOT NULL, -- Assuming 1 is the default grape variety ID
    CONSTRAINT fk_wine_grape_variety FOREIGN KEY (Made_by) REFERENCES Grape_Variety(VarietyID)
);

-- Product Table
CREATE TABLE Product (
    ProductID NUMBER(10) PRIMARY KEY,
    WineID NUMBER(10) DEFAULT 1 NOT NULL, -- Assuming 1 is the default wine ID
    Bottle_Type VARCHAR2(50) NOT NULL,
    Case_Quantity NUMBER(10) NOT NULL,
    Price NUMBER(10, 2) NOT NULL
);

-- Customer Table
CREATE TABLE Customer (
    CustomerID NUMBER(10) PRIMARY KEY,
    First_Name VARCHAR2(50) NOT NULL,
    Last_Name VARCHAR2(50) NOT NULL,
    DoB NUMBER(8) NOT NULL,
    Company_Name VARCHAR2(100),
    Tax_ID_Num VARCHAR2(20),
    Customer_Address VARCHAR2(255),
    Customer_Phone VARCHAR2(20),
    Customer_Type VARCHAR2(50) DEFAULT 'Regular' NOT NULL, -- Assuming 'Regular' is the default customer type
    CONSTRAINT chk_customer_dob CHECK (LENGTH(DoB) = 8)
);

-- Customer Order Table
CREATE TABLE Customer_Order (
    CustomerOrderID NUMBER(10) PRIMARY KEY,
    Order_Date DATE NOT NULL,
    ProductID NUMBER(10) NOT NULL,
    Quantity NUMBER(10) NOT NULL,
    CONSTRAINT fk_customer_order_product FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);



-- Glass Vendor Table
CREATE TABLE Glass_Vendor (
    VendorID NUMBER(10) PRIMARY KEY,
    Name VARCHAR2(100) NOT NULL,
    Address VARCHAR2(255) NOT NULL,
    Phone VARCHAR2(20) NOT NULL,
    Principal_Contact VARCHAR2(100) NOT NULL
);

-- Bottle Table
CREATE TABLE Bottle (
    BottleID NUMBER(10) PRIMARY KEY,
    BottleCode VARCHAR2(50) NOT NULL,
    Capacity NUMBER(10, 2) NOT NULL,
    Shape VARCHAR2(50) NOT NULL,
    Glass_Color VARCHAR2(50) NOT NULL,
    Cost_Per_Bottle NUMBER(10, 2) NOT NULL,
    VendorID NUMBER(10) DEFAULT 1 NOT NULL -- Assuming 1 is the default vendor ID
);


-- Bottle Order Table
CREATE TABLE Bottle_Order (
    BottleOrderID NUMBER(10) PRIMARY KEY,
    VendorID NUMBER(10) NOT NULL,
    Total_Quantity NUMBER(10) NOT NULL,
    Date_Ordered DATE NOT NULL,
    Order_Cost NUMBER(10, 2) NOT NULL,
    CONSTRAINT fk_bottle_order_vendor FOREIGN KEY (VendorID) REFERENCES Glass_Vendor(VendorID)
);

-- Bottle Shipment Table
CREATE TABLE Bottle_Shipment (
    ShipmentID NUMBER(10) PRIMARY KEY,
    BottleOrderID NUMBER(10) NOT NULL,
    Quantity_Received NUMBER(10) NOT NULL,
    Date_Ordered DATE NOT NULL,
    Date_Received DATE NOT NULL,
    Order_Cost NUMBER(10, 2) NOT NULL,
    Price_Charged NUMBER(10, 2) NOT NULL,
    CONSTRAINT fk_bottle_shipment_order FOREIGN KEY (BottleOrderID) REFERENCES Bottle_Order(BottleOrderID)
);

-- Bottle Line Table
CREATE TABLE Bottle_Line (
    BottleLineID NUMBER(10) PRIMARY KEY,
    BottleID NUMBER(10) NOT NULL,
    BottleOrderID NUMBER(10) NOT NULL,
    Line_Quantity NUMBER(10) NOT NULL,
    Line_Cost NUMBER(10, 2) NOT NULL,
    CONSTRAINT fk_bottle_line_bottle FOREIGN KEY (BottleID) REFERENCES Bottle(BottleID),
    CONSTRAINT fk_bottle_line_order FOREIGN KEY (BottleOrderID) REFERENCES Bottle_Order(BottleOrderID)
);

-- Composition Table
CREATE TABLE Composition (
    CompositionID NUMBER(10) PRIMARY KEY,
    VarietyName VARCHAR2(100) NOT NULL,
    WineID NUMBER(10) DEFAULT 1 NOT NULL, -- Assuming 1 is the default wine ID
    BlendPercentage NUMBER(5, 2) NOT NULL
);

-- OrderLine Table
CREATE TABLE OrderLine (
    OrderLineID NUMBER(10) PRIMARY KEY,
    OrderID NUMBER(10) NOT NULL,
    ProductID NUMBER(10) NOT NULL,
    CONSTRAINT fk_order_line_order FOREIGN KEY (OrderID) REFERENCES Customer_Order(CustomerOrderID),
    CONSTRAINT fk_order_line_product FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);

-- Vendor Bottle Table
CREATE TABLE Vendor_Bottle (
    VendorBottleID NUMBER(10) PRIMARY KEY,
    VendorID NUMBER(10) NOT NULL,
    BottleID NUMBER(10) NOT NULL,
    CONSTRAINT fk_vendor_bottle_vendor FOREIGN KEY (VendorID) REFERENCES Glass_Vendor(VendorID),
    CONSTRAINT fk_vendor_bottle_bottle FOREIGN KEY (BottleID) REFERENCES Bottle(BottleID)
);
