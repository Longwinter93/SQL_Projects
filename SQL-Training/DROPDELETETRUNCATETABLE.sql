CREATE DATABASE DROPTABLETRUNCATE;
GO

USE DROPTABLETRUNCATE;
GO

CREATE SCHEMA TrainingOfRemoveObjectRows;
GO
-- DROP TABLE (DDL)
--https://learn.microsoft.com/en-us/sql/t-sql/statements/drop-table-transact-sql?view=sql-server-ver16
--Removes one or more table definitions and all data, indexes, triggers, constraints, and permission specifications for those tables
--When a table is dropped, rules or defaults on the table lose their binding,
--and any constraints or triggers associated with the table are automatically dropped.
--If you re-create a table, you must rebind the appropriate rules and defaults,
--re-create any triggers, and add all required constraints.

DROP TABLE IF EXISTS  TrainingOfRemoveObjectRows.Customer;


CREATE TABLE TrainingOfRemoveObjectRows.Customer (
    PersonID int IDENTITY(1,1) NOT NULL,
	FirstName varchar(255),
    LastName varchar(255),
    Address varchar(255),
    City varchar(255)
	CONSTRAINT PK_PersonID PRIMARY KEY CLUSTERED (PersonID)
);
GO

INSERT INTO TrainingOfRemoveObjectRows.Customer (FirstName, LastName, Address, City)
VALUES ( 'Marcel', 'Marcelowski','Tatrzanska 1', 'Warszawa'),	
		( 'Andrzej', 'Andrjowski','Olechowska 10', 'Lodz'), 
		( 'Ewelina', 'Nowak','Tatrzanska 1', 'Gdynia'), 
		( 'Malgorzata', 'Kowalska','Polna  1', 'Warszawa'), 
		( 'Ewa', 'Kowalczewska','Szkolna  1', 'Gdansk'), 
		( 'Maja', 'Wisniewski','Lipowa  1', 'Gdynia'), 
		( 'Zuzanna', 'Kowalczyk','Ogrodowa  1', 'Sopot'), 
		( 'Oliwia', 'Lesuk','Kwiatowa  1', 'Warszawa'), 
		( 'Pola', 'Jaje','Brzozowa  1', 'Walbrzych'), 
		( 'Alicja', 'Fidor','Dluga 1', 'Mielno'), 
		( 'Maria', 'Karolczuk','Krotka 1', 'Gdynia');
GO

SELECT *
FROM TrainingOfRemoveObjectRows.Customer;
GO

SELECT *
INTO #temptableCustomer
FROM TrainingOfRemoveObjectRows.Customer;
GO

SELECT * FROM #temptableCustomer;
GO

DROP TABLE IF EXISTS #temptableCustomer;
GO

--If you delete all rows in a table by using the DELETE statement or use the TRUNCATE TABLE statement,
--the table definition exists until it's dropped using DROP TABLE.

--DELETE TABLE 
--https://learn.microsoft.com/en-us/sql/t-sql/statements/delete-transact-sql?view=sql-server-ver16
--Removes one or more rows from a table or view in SQL Server.
--WHERE
--Specifies the conditions used to limit the number of rows that are deleted.
--If a WHERE clause is not supplied, DELETE removes all the rows from the table.
--The DELETE statement is always fully logged.


DELETE FROM TrainingOfRemoveObjectRows.Customer
WHERE City = 'Warszawa';
GO 

DELETE FROM TrainingOfRemoveObjectRows.Customer;
GO

--https://learn.microsoft.com/en-us/sql/t-sql/functions/ident-current-transact-sql?view=sql-server-ver16
SELECT IDENT_CURRENT('TrainingOfRemoveObjectRows.Customer') AS Current_Identity;
GO
--It keeps the identity

--TRUNCATE TABLE
--https://learn.microsoft.com/en-us/sql/t-sql/statements/truncate-table-transact-sql?view=sql-server-ver16 (REMARKS)

--Removes all rows from a table or specified partitions of a table, without logging the individual row deletions. 
--TRUNCATE TABLE is similar to the DELETE statement with no WHERE clause; 
--however, TRUNCATE TABLE is faster and uses fewer system and transaction log resources.
--TRUNCATE TABLE removes all rows from a table, but the table structure and its columns, constraints, indexes, and so on, remain. 
--To remove the table definition in addition to its data, use the DROP TABLE statement.
--If the table contains an identity column, the counter for that column is reset to the seed value defined for the column. 
--If no seed was defined, the default value 1 is used. To retain the identity counter, use DELETE instead.


SELECT *
FROM TrainingOfRemoveObjectRows.Customer;
GO 


TRUNCATE TABLE TrainingOfRemoveObjectRows.Customer;
GO
--
--https://learn.microsoft.com/en-us/sql/t-sql/functions/ident-current-transact-sql?view=sql-server-ver16
SELECT IDENT_CURRENT('TrainingOfRemoveObjectRows.Customer') AS Current_Identity;
GO
--It starts from 1
