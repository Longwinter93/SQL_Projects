CREATE DATABASE [MyDatabase];

USE [MyDatabase];
--1. Passing table name and object type to OBJECT_ID - a NULL is returned if there is no object id and DROP TABLE is ignored 
-- OBJECT_ID()
IF OBJECT_ID(N'dbo.MyTable0', N'U') IS NOT NULL 
DROP TABLE [dbo].[MyTable0]
--2. Checking to see if table exists in sys.tables
SELECT *
FROM sys.tables 
WHERE SCHEMA_NAME(schema_id) LIKE 'dbo' AND name like 'MyTable0'
--3. Checking to see if table exists in sys.tables - ignore DROP TABLE if it does not
IF EXISTS(SELECT *
FROM sys.tables 
WHERE SCHEMA_NAME(schema_id) LIKE 'dbo' AND name like 'MyTable0') 
DROP TABLE [dbo].[MyTable0]
--4. Checking to see if table exists in INFORMATION_SCHEMA.TABLES
SELECT * 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME ='MyTable0' AND TABLE_SCHEMA ='dbo'
--5. Checking to see if table exists in INFORMATION_SCHEMA.TABLES - ignore DROP TABLE if it does not
IF EXISTS(SELECT * 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME ='MyTable0' AND TABLE_SCHEMA ='dbo')
DROP TABLE [dbo].[MyTable0];
GO 
--6. Attempting to run DROP TABLE only if it exists 
DROP TABLE IF EXISTS [dbo].[MyTable0]
GO
--7. Dropping Table when Referential Integrity is in place
USE [MyDatabase]
GO
--Creating Customers Table
CREATE TABLE [dbo].[customers]
(
    [customer_id] [int] IDENTITY(1, 1) NOT NULL
  , [first_name] [varchar](255) NOT NULL
  , [last_name] [varchar](255) NOT NULL
  , [phone] [varchar](25) NULL
  , [email] [varchar](255) NOT NULL
  , [street] [varchar](255) NULL
  , [city] [varchar](50) NULL
  , [state] [varchar](25) NULL
  , [zip_code] [varchar](5) NULL
  ,
  PRIMARY KEY CLUSTERED ([customer_id] ASC)
);
GO

-- Populating Customers Table
INSERT INTO [dbo].[customers] ([first_name],[last_name],[phone],[email],[street],[city],[state],[zip_code])
VALUES ('John', 'Doe', '123-456-7890', 'john@doe.com', '100 Main St', 'AnyTown', 'MA', '12345'),
       ('Jane', 'Doe', '123-456-7890', 'jane@doe.com', '100 Main St', 'AnyTown', 'MA', '12345'),
       ('Bob', 'Smith', '123-456-8901','bob@smith.com', '100 Elm St', 'AnyTown', 'MA', '12345');
GO
 
 
-- Creating Orders Table
CREATE TABLE [dbo].[orders]
(
    [order_id] [int] IDENTITY(1, 1) NOT NULL
  , [customer_id] [int] NULL
PRIMARY KEY CLUSTERED ([order_id] ASC)
);
 
-- Adding foreign key referencing [dbo].[customers] table
ALTER TABLE [dbo].[orders]
ADD
FOREIGN KEY ([customer_id]) REFERENCES [dbo].[customers] ([customer_id]);
GO
-- Populating Orders Table
INSERT INTO [dbo].[orders] ([customer_id])
VALUES (3),
       (2);
GO
-- Creating order_items table
CREATE TABLE [dbo].[order_items]
(
    [order_id] [int] NOT NULL
  , [item_id] [int] NOT NULL
  , [product_id] [int] NOT NULL
  , [quantity] [int] NOT NULL
  , [list_price] [decimal](10, 2) NOT NULL
  , [discount] [decimal](4, 2) NOT NULL
  ,
  PRIMARY KEY CLUSTERED
  (
      [order_id] ASC
    , [item_id] ASC
  )
);
GO
-- Adding foreign key referencing [dbo].[orders] table
ALTER TABLE [dbo].[order_items]
ADD
FOREIGN KEY ([order_id]) REFERENCES [dbo].[orders] ([order_id]);
GO
 
--Populating order_items tables
INSERT INTO [dbo].[order_items]
VALUES (1,10,100,25,999.99,0),
       (2,11,  5,99,800.00,0);
GO
--
DROP TABLE IF EXISTS [dbo].[order_items]; -- removes dependency on [dbo].[orders]
DROP TABLE IF EXISTS [dbo].[orders];      -- removes dependency on [dbo].[customers]
DROP TABLE IF EXISTS [dbo].[customers];   
GO
SELECT * FROM [dbo].[order_items]
--Alternatively, we can query sys.foreign_keys, filtering on the tables to drop for the foreign key names.
SELECT * FROM sys.foreign_keys

SELECT OBJECT_SCHEMA_NAME(parent_object_id) AS [Schema],
		OBJECT_NAME(parent_object_id) AS [Table],
		name AS [Name]
FROM sys.foreign_keys 
WHERE OBJECT_NAME(parent_object_id) IN ('customers','orders','order_items'); --tables we want to drop
GO 
--Then run an ALTER TABLE [schema].[table] DROP CONSTRIANT to drop the constraints.
--Without the constraints we can drop the tables in any order we like.
ALTER TABLE [dbo].[orders]      DROP CONSTRAINT FK__orders__customer__1209AD79;
ALTER TABLE [dbo].[order_items] DROP CONSTRAINT FK__order_ite__order__14E61A24;
GO
 
DROP TABLE IF EXISTS [dbo].[customers];   
DROP TABLE IF EXISTS [dbo].[orders];      
DROP TABLE IF EXISTS [dbo].[order_items];
GO
