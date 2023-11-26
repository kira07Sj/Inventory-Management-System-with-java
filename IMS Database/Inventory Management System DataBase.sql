-- =============================================================================================
-- =============SCHOOL OF ELECTRICAL ENGINEERING AND COMPUTING===============================================
-- =============DEPARTMENT OF COMPUTER SCIENCE AND ENGINEERING===============================================================================--=============================================================================================
-- =============SECTION:2                             GROUP:4  ===============================================
-- ==============================DATABASE PROJECT===========================================================


-- -GROUP NAME............ID
-- -Kirubel Dagne....... ugr/25329/14
-- -Kirubel Girma ...... ugr/25460/14
-- -Jaefer Mohammed .... ugr/25447/14
-- -Elsabet Mulugeta ... ugr/25592/14
-- -Newal Hussen........ugr/25353/14








-- Inventory Management System Database
-- creating the IMS database
CREATE DATABASE IMS2

-- use the database we just created
USE IMS2

-- create table for products
CREATE TABLE Products
(
Product_ID VARCHAR(20) PRIMARY KEY not null,
Name VARCHAR(50) not null,
Description VARCHAR(100),
Category VARCHAR(50),
Price_per_unit REAL
);
-- ALTER TABLE Products
-- DROP COLUMN Quantity_in_Stock --BY MISTAKE

-- Creating a table suppliers
CREATE TABLE Suppliers
(
Supplier_ID VARCHAR(20) PRIMARY KEY NOT NULL,
Name VARCHAR(50) NOT NULL,
Phone_number VARCHAR(20),
Email VARCHAR(50),
Address VARCHAR(50)
);


-- **************************************************************
-- Creating a table for Warehouse
CREATE TABLE Warehouse
(
Warehouse_ID VARCHAR(20) PRIMARY KEY NOT NULL,
Warehouse_Name VARCHAR(50),
Location VARCHAR(50)
);


-- ****************************************************************
-- creating inventory Warehouse
CREATE TABLE Inventory_Warehouse
(
Inventory_ID VARCHAR(20) PRIMARY KEY,
Warehouse_ID VARCHAR(20) FOREIGN KEY REFERENCES Warehouse(Warehouse_ID),
Product_ID VARCHAR(20) FOREIGN KEY REFERENCES Products(Product_ID) ON UPDATE CASCADE,
Quantity_in_Stock INT
);




-- ********************************************************************
-- creating a Customer Table
CREATE TABLE Customer
(
Customer_ID VARCHAR(20) PRIMARY KEY,
Name VARCHAR(50) not null,
Phone_number VARCHAR(20),
Address VARCHAR(50)
);

-- **********************************************************************
-- Creating a Purchase Order table
CREATE TABLE Purchase_Orders
(
Order_ID VARCHAR(20) PRIMARY KEY,
Order_Date DateTime,
Supplier_ID VARCHAR(20) FOREIGN KEY REFERENCES Suppliers(Supplier_ID),
Product_ID VARCHAR(20) FOREIGN KEY REFERENCES Products(Product_ID) ON UPDATE CASCADE,
Quantity INT
);
select * from Purchase_Orders
-- ***********************************************************************
-- Crearing a Sales Order table
CREATE TABLE Sales_Orders
(
Order_ID VARCHAR(20) PRIMARY KEY,
Order_Date DateTime,
Customer_ID VARCHAR(20) FOREIGN KEY REFERENCES Customer(Customer_ID),
Product_ID VARCHAR(20) FOREIGN KEY REFERENCES Products(Product_ID) ON UPDATE CASCADE,
Quantity INT
);
-- =============================================================================================
-- ============= CREATE VIEW & PROCEDURE ===============================================
-- =============================================================================================
-- creating  view for Purchase order
CREATE VIEW Purchase_Order_List_View
AS
(
select pro.Order_ID,pro.Order_Date,s.Supplier_ID,s.Name AS 'Suppliers Name',s.Address,
p.Product_ID, p.Name AS 'Products Name',p.Category,p.Description, pro.Quantity

from Purchase_Orders pro

inner join Suppliers s ON pro.Supplier_ID = s.Supplier_ID
inner join Products p ON pro.Product_ID = p.Product_ID
)
-- ==========================================================================================

GO
CREATE PROCEDURE PurchaseOrdersBySupplier
@SupplierID VARCHAR(20)
AS
BEGIN
SET NOCOUNT ON;
SELECT *
FROM Purchase_Order_List_View
WHERE Supplier_ID = @SupplierID;
END;

-- -EXAMPLE
EXEC PurchaseOrdersBySupplier @SupplierID = 'S003';
-- ==========================================================================================
-- ==========================================================================================


-- Creating View for Sales Order 
CREATE VIEW Sales_Order_List_View
AS
(
select S.Order_ID,S.Order_Date,C.Customer_ID,C.Name AS 'Customer Name',C.Address,
p.Product_ID, p.Name AS 'Products Name',p.Category,p.Description, S.Quantity
from Sales_Orders S

inner join Products p ON S.Product_ID = p.Product_ID
inner join Customer C ON S.Customer_ID = C.Customer_ID

);
-- =====================================================================================
GO
CREATE PROCEDURE SaleOrdersByCustomer
@CustomerID VARCHAR(20)
AS
BEGIN
SET NOCOUNT ON;
SELECT *
FROM Sales_Order_List_View
WHERE Customer_ID = @CustomerID;
END;

-- =====================================================================================
SELECT * FROM Sales_Order_List_View
EXEC SaleOrdersByCustomer @CustomerID = 'S101';
-- =====================================================================================
-- create views for Inventory warehouse
CREATE VIEW Inventory_Warehouse_Display
AS
select Inventory_Warehouse.Inventory_ID, Warehouse.*, Products.*,Inventory_Warehouse.Quantity_in_Stock
from Inventory_Warehouse
inner join Warehouse on Inventory_Warehouse.Warehouse_ID = Warehouse.Warehouse_ID
inner join Products on Inventory_Warehouse.Product_ID = Products.Product_ID 
-- =====================================================================================
SELECT * FROM Inventory_Warehouse
-- =====================================================================================
-- =====================================================================================
-- -PROCEDURE FOR Inventorywarehouse 
GO

CREATE PROCEDURE InventoryWarehouseStats
    @ProductID VARCHAR(20)
AS
BEGIN
SET NOCOUNT ON;

SELECT IWD.Inventory_ID, W.Warehouse_ID, W.Warehouse_Name, P.Product_ID, P.Name AS Product_Name,
IWD.Quantity_in_Stock
FROM Inventory_Warehouse_Display AS IWD
INNER JOIN Warehouse AS W ON IWD.Warehouse_ID = W.Warehouse_ID
INNER JOIN Products AS P ON IWD.Product_ID = P.Product_ID
WHERE IWD.Product_ID = @ProductID
GROUP BY IWD.Inventory_ID, W.Warehouse_ID, W.Warehouse_Name, P.Product_ID, P.Name,IWD.Quantity_in_Stock;
END;

-- =======================================================================================================
SELECT * FROM Inventory_Warehouse_Display
EXEC InventoryWarehouseStats @ProductID = '101';
-- =======================================================================================================
-- creating a view for Transaction history

CREATE VIEW Transaction_History
AS 
(
select 'Purchase' as 'Transaction Type',p.Order_ID AS 'Transaction ID', p.Order_Date as 'Transaction Date',
p.Product_ID as 'Product_ID',pr.Name,pr.Description,pr.Category, 
p.Quantity AS 'Quantity' ,pr.Price_per_unit, 'Supplier' AS 'Client Type',sp.Name AS 'Person Name', sp.Address
from Purchase_Orders p
inner join Products pr ON p.Product_ID = pr.Product_ID
inner join Suppliers sp ON p.Supplier_ID = sp.Supplier_ID

Union All

select 'Sale' as 'Transaction Type',s.Order_ID AS 'Transaction ID',s.Order_Date as 'Transaction Date', 
s.Product_ID as 'Product_ID' ,pr.Name,pr.Description,pr.Category, 
s.Quantity AS 'Quantity' ,pr.Price_per_unit,'Customer' AS 'Client Type', Cs.Name AS 'Person Name', CS.Address
from Sales_Orders s
inner join Products pr ON s.Product_ID = pr.Product_ID
inner join Customer Cs ON s.Customer_ID = Cs.Customer_ID
);

-- ========================================================================================================
SELECT * FROM Transaction_History 
ORDER BY Price_per_unit DESC
--
SELECT * FROM Transaction_History WHERE QUANTITY=(SELECT MAX(Quantity))



-- ==================================================================================
-- inserting sample Values for Products Table
insert into Products values('101', 'Lenovo ThinkPad', '15-inch, Core i7, 16GB RAM','Electronics','55999.99')
insert into Products values('102', 'Sumsang Galaxy S12', 'Android, 128GB Storage','Electronics','18599.99')
insert into Products values('103', 'Wireless Mouse', 'Ergonomic design, Bluetooth','Electronics','499.99')
insert into Products values('104', 'Leather Wallet', 'Genuine leather, brown','Fashion','359.99')
insert into Products values('105', 'Men Dress Shirt', ' White, long-sleeve, slim fit','Fashion','799.99')
insert into Products values('106', ' Women Running Shoes', 'Size 8, pink','Fashion','999.99')
insert into Products values('107', 'LED Desk Lamp', 'Adjustable brightness, white','Home & Living','299.99')
insert into Products values('108', 'Stainless Steel Water Bottle', '32 oz, double-walled','Home & Living','379.99')
insert into Products values('109', 'Coffee Maker', '12-cup, programmable','Home & Living','2499.99')
insert into Products values('110', 'Hardcover Notebook', 'Lined pages, A5 size','Office Supplies','199.99')
insert into Products values('111', 'Ballpoint Pens (Pack of 10)', 'Assorted colors','Office Supplies','149.99')
insert into Products values('112', 'Wireless Headphones', 'Over-ear, noise-canceling, Bluetooth','Electronics','1499.99')
insert into Products values('113', 'Yoga Mat', 'Non-slip, extra thick','Fitness & Sports','749.99')
insert into Products values('114', 'Dumbbell Set (Pair)', '10 lbs each','Fitness & Sports','649.99')
insert into Products values('115', 'Men Running Shorts', 'Size M, black','Fashion','299.99')
insert into Products values('116', 'Wall Clock', 'Quartz movement, silver','Home & Living','349.99')
insert into Products values('117', 'Umbrella', 'Compact, automatic open/close','Fashion','299.99')
insert into Products values('118', 'Blu-ray Player', '4K Ultra HD, Wi-Fi','Electronics','899.99')
insert into Products values('119', 'Stainless Steel Cookware Set', '10-piece set','Home & Living','3499.99')
insert into Products values('120', 'Portable Bluetooth Speaker', 'Waterproof, 20W','Electronics','299.99')
insert into Products values('121', 'Women Sunglasses', 'Cat-eye style, UV protection','Fashion','249.99')
insert into Products values('122', 'Backpack', 'Laptop compartment, gray','Fashion','799.99')
insert into Products values('123', 'Kitchen Blender', '800W, 10-speed','Home & Living','1299.99')
insert into Products values('124', 'Digital Camera', '24MP, DSLR','Electronics','22499.99')
insert into Products values('125', 'Men Leather Belt', 'Brown, reversible','Fashion','249.99')
insert into Products values('126', 'Resistance Bands (Set of 5)', 'Various resistances','itness & Sports','199.99')
insert into Products values('127', 'LG OLED CX Series Smart TV (55-inch)', 'Premium OLED TV with Dolby Vision IQ and NVIDIA G-SYNC support ','Electronics','28499.99')
insert into Products values('128', 'Apple AirPods Pro', 'True wireless earbuds with active noise cancellation.','Electronics','1499.99')
insert into Products values('129', 'Sony PlayStation 5', 'Next-gen gaming console with high-performance graphics','Electronics','45499.99')
insert into Products values('130', 'Dell XPS 13 Laptop', 'Ultra-portable laptop with InfinityEdge display and Intel Core i7 processor.','Electronics','58599.99')
-- =====================================================================================


-- --inserting Sample Values for Warehouse Table
insert into Warehouse values('WH001', 'Addis Ababa Warehouse', 'Addis Ababa, Ethiopia')
insert into Warehouse values('WH002', 'Dire Dawa Warehouse', 'Dire Dawa, Ethiopia')
insert into Warehouse values('WH003', 'Bahir Da Warehouse', 'Bahir Da, Ethiopia')
insert into Warehouse values('WH004', 'Mekelle Warehouse', 'Mekelle, Ethiopia')
insert into Warehouse values('WH005', 'Hawassa Warehouse', 'Hawassa, Ethiopia')
insert into Warehouse values('WH006', 'Jimma Warehouse', 'Jimma, Ethiopia')
insert into Warehouse values('WH007', ' Gondar Warehouse', ' Gondar, Ethiopia')
insert into Warehouse values('WH008', 'Adama  Warehouse', 'Adama , Ethiopia')
insert into Warehouse values('WH009', 'Addis Alem Warehouse', 'Addis Alem, Ethiopia')
insert into Warehouse values('WH010', 'Debre Birhan Warehouse', 'Debre Birhan, Ethiopia')
-- =====================================================================================


-- ===================================================================================
-- inserting Sample Values for Customer Table
insert into Customer values ('S100','Ayele Mola', '0945342891', 'Addis Abeba' )
insert into Customer values ('S101','Keneni Wendemu', '0934482911', 'Adama' )
insert into Customer values ('S102','Wintana Abera', '0987652348', 'Adama')
insert into Customer values ('S103','Yared Tamiru', '0998605657', 'Adama' )
insert into Customer values ('S104','Firaol Anteneh', '0966009861', 'Gonder')
insert into Customer values ('S105','Eden Gebremedhin', '0922818697', 'Addis Abeba' )
insert into Customer values ('S106','Yonas Tades', '0997986006', 'USA ' )
insert into Customer values ('S107','Dawit Tilahun', '0937461398', 'Gonder' )
insert into Customer values ('S108','Teshome Wendirad', '0900987613', 'Wolayta')
insert into Customer values ('S109','Biniyam Selamu', '0972494371', 'Kenya' )
insert into Customer values ('S110','Abreham kero', '0967498734', 'Addis Abeba' )
insert into Customer values ('S111','Abigiya Zenabu', '0939818402', 'Harar')
insert into Customer values ('S112','Yohami Abenet', '0974218813', 'Harar' )
insert into Customer values ('S113','Yoriyanos Solomen', '098412743', 'Sodere' )
insert into Customer values ('S114','Naod Gulema', '0934782334', 'Adama' )
insert into Customer values ('S115','Betelem Zeryihun', '0979324253', 'USA')
insert into Customer values ('S116','Nahom Ananiya', '0975825273', 'Kenya')
insert into Customer values ('S117','Alazar Mengestu', '0945342891', 'Hosana' )
insert into Customer values ('S118','Wonimu Muse', '0964734858', 'Harar')
insert into Customer values ('S119','Samuel Tola', '0967276312', 'Wolayta')
insert into Customer values ('S120','Belayneh Mulatu', '0987347812', 'Gonder' )
--======================================================================================


-- inserting Sample Values for Suppliers Table
insert into Suppliers values('S001', 'Abebe Destaw','0923874315', 'AbebeDest87@gmail.com', 'Oromia')
insert into Suppliers values('S002', 'Belay Kay','0924391201', 'BelayKay45@gmail.com', 'Oromia')
insert into Suppliers values('S003', 'Ayele Gulbete','0968924671', 'AyeleGulbete65@gmail.com', 'Amahar')
insert into Suppliers values('S004', 'Gelete Burka','0978450810', 'GeleteBurka34@gmail.com', 'Oromia')
insert into Suppliers values('S005', 'Habtamu Dereje','090143952', 'HabtamuDereje46@gmail.com', 'Harer')
insert into Suppliers values('S006', 'Kebed Mandefro','093510240', 'KebedMandefro24@gmail.com', 'Addis Abeba')
insert into Suppliers values('S007', 'Jemal Mohammed','097101431', 'JemalMohammed325@gmail.com', 'Addis Abeba')
-- ======================================================================================



-- inserting sample Values for Inventory warehouse
insert into Inventory_Warehouse values('Iv001','WH001','101','60')
insert into Inventory_Warehouse values('Iv002','WH001','103','70')
insert into Inventory_Warehouse values('Iv003','WH002','104','100')
insert into Inventory_Warehouse values('Iv004','WH002','105','66')
insert into Inventory_Warehouse values('Iv005','WH005','102','45')
insert into Inventory_Warehouse values('Iv006','WH003','106','77')
insert into Inventory_Warehouse values('Iv007','WH006','108','47')
insert into Inventory_Warehouse values('Iv008','WH002','107','43')
insert into Inventory_Warehouse values('Iv009','WH007','110','435')
insert into Inventory_Warehouse values('Iv010','WH008','112','59')
insert into Inventory_Warehouse values('Iv011','WH010','109','99')
insert into Inventory_Warehouse values('Iv012','WH009','111','26')
insert into Inventory_Warehouse values('Iv013','WH009','113','99')
insert into Inventory_Warehouse values('Iv014','WH004','118','54')
insert into Inventory_Warehouse values('Iv015','WH010','114','59')
insert into Inventory_Warehouse values('Iv016','WH006','119','79')
insert into Inventory_Warehouse values('Iv017','WH006','115','388')
insert into Inventory_Warehouse values('Iv018','WH009','120','1000')
insert into Inventory_Warehouse values('Iv019','WH001','116','939')
insert into Inventory_Warehouse values('Iv020','WH003','123','323')
insert into Inventory_Warehouse values('Iv021','WH005','117','322')
insert into Inventory_Warehouse values('Iv022','WH002','121','323')
insert into Inventory_Warehouse values('Iv023','WH010','129','44')
insert into Inventory_Warehouse values('Iv024','WH004','122','323')
insert into Inventory_Warehouse values('Iv025','WH006','125','323')
insert into Inventory_Warehouse values('Iv026','WH009','127','323')
insert into Inventory_Warehouse values('Iv027','WH010','126','444')
insert into Inventory_Warehouse values('Iv028','WH007','128','994')
insert into Inventory_Warehouse values('Iv029','WH001','124','432')
-- =============================================================================

-- --EXAMPLE OF SUBQUERY T
SELECT IWD.Product_ID, P.Name AS Product_Name, IWD.Quantity_in_Stock
FROM Inventory_Warehouse AS IWD
INNER JOIN Products AS P ON IWD.Product_ID = P.Product_ID
WHERE IWD.Quantity_in_Stock > (SELECT AVG(Quantity_in_Stock) FROM Inventory_Warehouse)
ORDER BY IWD.Quantity_in_Stock DESC ---DESCENDING

---=============================================================================

SELECT * FROM Inventory_Warehouse

insert into Purchase_Orders values ('P001',GETDATE(),'S003','101',10)
insert into Purchase_Orders values ('P002',GETDATE(),'S004','128',10)
insert into Purchase_Orders values ('P003',GETDATE(),'S001','110',10)
insert into Purchase_Orders values ('P004',GETDATE(),'S005','120',10)
insert into Purchase_Orders values ('P005',GETDATE(),'S002','115',10)
insert into Purchase_Orders values ('P006',GETDATE(),'S002','114',20)
insert into Purchase_Orders values ('P007',GETDATE(),'S001','104',15)
--=============================================================================
SELECT * FROM Sales_Orders
SELECT * FROM AUDIT_HISTORY
SELECT * FROM Inventory_Warehouse

--=============================================================================
insert into Sales_Orders values ('S001',GETDATE(),'S101','108',21)
insert into Sales_Orders values ('S002',GETDATE(),'S105','128',33)
insert into Sales_Orders values ('S003',GETDATE(),'S107','125',21)
insert into Sales_Orders values ('S004',GETDATE(),'S104','113',42)
insert into Sales_Orders values ('S005',GETDATE(),'S104','103',2)

--============================================================================
SELECT * FROM Inventory_Warehouse
SELECT * FROM Customer



--=============================================================================
select * from Customer
select * from Suppliers
select * from Warehouse
select * from Products
--=============================================================================
--=============================================================================
select * from Inventory_Warehouse_Display 

select * from Transaction_History

select * from Purchase_Order_List_View

SELECT * FROM AUDIT_HISTORY

select * from Sales_Order_List_View

--=============================================================================================
--============= CREATION OF TRIGGER ===============================================
--=============================================================================================

-- Create table AUDIT_HISTORY
CREATE TABLE AUDIT_HISTORY (
TRANSACTION_ID VARCHAR(30),
Transaction_Type VARCHAR(10) NOT NULL CHECK(Transaction_Type IN ('PURCHASED', 'SOLD')),
Made_By VARCHAR(20),
QUANTITY INT,
Product_Name VARCHAR(50),
Product_ID VARCHAR(20),
Transaction_Date DATETIME
);

--=============================================================================
SELECT * FROM AUDIT_HISTORY;

SELECT * FROM AUDIT_HISTORY WHERE Transaction_Type = 'PURCHASED'
SELECT * FROM AUDIT_HISTORY WHERE Transaction_Type = 'SOLD'
--=============================================================================

-- Create trigger FOR AUDIT_HISTORY
--TRIGGER ON PURCHASE ORDER
CREATE TRIGGER trg_AuditHistory
ON Purchase_Orders
AFTER INSERT
AS
BEGIN
SET NOCOUNT ON;
INSERT INTO AUDIT_HISTORY (TRANSACTION_ID, Transaction_Type,Made_By, QUANTITY, Product_ID, Product_Name, Transaction_Date)
SELECT I.ORDER_ID, 'PURCHASED', S.NAME, I.Quantity, I.PRODUCT_ID, P.NAME, GETDATE()
FROM inserted I
JOIN Products P ON P.Product_ID = I.Product_ID
JOIN Suppliers S ON I.Supplier_ID = S.Supplier_ID;
END;

--=============================================================================
--TRIGGER ON SALE ORDER
CREATE TRIGGER trg_AUDIT_HISTORY_Sale
ON Sales_Orders
AFTER INSERT
AS
BEGIN
SET NOCOUNT ON;
INSERT INTO AUDIT_HISTORY (TRANSACTION_ID, Transaction_Type,Made_By, QUANTITY, Product_ID, Product_Name, Transaction_Date)
SELECT I.Order_ID, 'SOLD',C.Name, I.Quantity, I.Product_ID, P.Name, GETDATE()
FROM inserted I
JOIN Products P ON P.Product_ID = I.Product_ID
JOIN Customer C ON I.Customer_ID = C.Customer_ID
END;
--=============================================================================

-- Create trigger to update inventory warehouse quantity on purchase order
CREATE TRIGGER trg_UpdateInventory_Purchase
ON Purchase_Orders
AFTER INSERT
AS
BEGIN
SET NOCOUNT ON;
UPDATE Inventory_Warehouse
SET Quantity_in_Stock = Quantity_in_Stock + I.Quantity
FROM inserted I
WHERE Inventory_Warehouse.Product_ID = I.Product_ID;
END;

-- Create trigger to update inventory warehouse quantity on sales order
CREATE TRIGGER trg_UpdateInventory_Sale
ON Sales_Orders
AFTER INSERT
AS
BEGIN
SET NOCOUNT ON;
UPDATE Inventory_Warehouse
SET Quantity_in_Stock = Quantity_in_Stock - I.Quantity
FROM inserted I
WHERE Inventory_Warehouse.Product_ID = I.Product_ID;
END;

--=============================================================================================
--============= SECURITY ===============================================
--=============================================================================================
---Create LOGIN AND THEN CREATE USER TO ASSIGN IT TO THE LOGIN
EXEC sp_addlogin 'Manager_', 'Password123', 'IMS2'----@login_name,@password for login,@name_of_database
EXEC sp_adduser 'Manager_', 'manager1';           ----@login_name,@user_name

EXEC sp_addlogin 'Employee_', 'employee123', 'IMS2'----@login_name,@password for login,@name_of_database
EXEC sp_adduser 'Employee_', 'employee1';		   ----@login_name,@user_name

EXEC sp_addlogin 'Customer_', 'customer123', 'IMS2'----@login_name,@password for login,@name_of_database
EXEC sp_adduser 'Customer_', 'customer1';		   ----@login_name,@user_name

EXEC sp_addlogin 'Supplier_', 'supplier123', 'IMS2';----@login_name,@password for login,@name_of_database
EXEC sp_adduser 'Supplier_', 'supplier1';		   ----@login_name,@user_name

----THE LAST LOGIN IS FOR ADMINSTARTIVE LEVEL 
EXEC sp_addlogin 'Admin_', 'Admin123', 'IMS2';----@login_name,@password for login,@name_of_database
EXEC sp_adduser 'Admin_', 'Admin1';	

----ADMINISTRATIVE LEVEL TO ADMIN
ALTER ROLE [db_owner] ADD MEMBER Admin1;
-- GRANT AND REVOKE PERMISSION TO MANAGER
GRANT SELECT, INSERT, ALTER, UPDATE,DELETE TO manager1 WITH GRANT OPTION;
REVOKE DELETE ON AUDIT_HISTORY TO manager1

---GRANT AND REVOKE PERMISSION TO EMPLOYEE
GRANT SELECT ON Audit_History TO employee1;
GRANT SELECT,INSERT ON Purchase_Orders TO employee1;
GRANT SELECT,INSERT ON Sales_OrdERs TO employee1;
GRANT SELECT,UPDATE ON Customer TO employee1;
GRANT SELECT,UPDATE ON Suppliers TO employee1;
GRANT SELECT,INSERT,UPDATE ON Inventory_Warehouse TO employee1;
GRANT SELECT,INSERT,UPDATE ON Products TO employee1;
REVOKE SELECT ON Transaction_History to employee1;
---GRANT PERMISSION TO Customer
GRANT SELECT,UPDATE ON Customer TO customer1;
GRANT SELECT,INSERT ON Sales_Orders TO customer1;
GRANT SELECT ON Sales_Order_List_View to customer1;
---GRANT PERMISSION TO Supplier
GRANT SELECT,UPDATE ON Suppliers TO supplier1;
GRANT SELECT,INSERT ON Purchase_Orders TO supplier1;
GRANT SELECT ON Purchase_Order_List_View to supplier1;




--=============================================================================================
--=============THE END===============================================
--=============================================================================================--=============================================================================================
--=============TO INSTRUCTOR: GETINET YILMA  ===============================================
--=============================================================================================