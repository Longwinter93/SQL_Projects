--https://learn.microsoft.com/en-us/sql/relational-databases/performance/joins?view=sql-server-ver16

USE AdventureWorksDW2019;

CREATE SCHEMA testing;
GO
DROP TABLE IF EXISTS [testing].[TableA];
GO 

CREATE TABLE [testing].[TableA]
(
EmployeeIDA INT NOT NULL,
AmountA DECIMAL(12,2),
ClassA nvarchar(255)
);
GO 

DROP TABLE IF EXISTS [testing].[TableB];
GO 

CREATE TABLE [testing].[TableB]
(
EmployeeIDB INT NOT NULL,
AmountB DECIMAL(12,2),
ClassB nvarchar(255)
);
GO 


INSERT INTO [testing].[TableA] 
VALUES (1, 100, 'A'), (2,150,'B'), (3, 200, 'C'), (4, 250,'D'), (5,300,'C'), (6,350,'E'), (7,400,'F'), (8,450,'X'), (9,500,'Y')

INSERT INTO [testing].[TableB]
VALUES (1,110,'Aa'), (2,160,'Be'), (3,210,'Ce'), (4, 260,'De'), (5,310,'Ee')

--
SELECT *
FROM [testing].[TableA]
--
SELECT *
FROM [testing].[TableB]

SELECT A.*, B.* 
FROM [testing].[TableA] as A 
INNER JOIN [testing].[TableB] AS B 
ON A.EmployeeIDA = B.EmployeeIDB
--
INSERT INTO [Testing].[TableA]
VALUES (1, 555,'E')
--
SELECT A.*, B.* 
FROM [testing].[TableA] as A 
INNER JOIN [testing].[TableB] AS B 
ON A.EmployeeIDA = B.EmployeeIDB

--
INSERT INTO [Testing].[TableA]
VALUES (1, 666,'G'), (1, 777,'H')
--
INSERT INTO [Testing].[TableB]
VALUES (2, 777,'S'), (2, 888,'J')
--
INSERT INTO [Testing].[TableA]
VALUES (2, 777,'S'), (2, 888,'J')
--
SELECT *
FROM [testing].[TableA]
--
SELECT *
FROM [testing].[TableB]
--
SELECT A.*, B.* 
FROM [testing].[TableA] as A 
INNER JOIN [testing].[TableB] AS B 
ON A.EmployeeIDA = B.EmployeeIDB

--
INSERT INTO [Testing].[TableB]
VALUES (8, 555,'Z')
--
SELECT *
FROM [testing].[TableA]
--
SELECT *
FROM [testing].[TableB]
--
SELECT A.*, B.* 
FROM [testing].[TableA] as A 
INNER JOIN [testing].[TableB] AS B 
ON A.EmployeeIDA = B.EmployeeIDB
--
SELECT *
FROM [testing].[TableA]
--
SELECT *
FROM [testing].[TableB]
--
SELECT A.*, B.* 
FROM [testing].[TableA] as A 
LEFT JOIN [testing].[TableB] AS B 
ON A.EmployeeIDA = B.EmployeeIDB
--
SELECT A.*, B.* 
FROM [testing].[TableA] as A 
RIGHT JOIN [testing].[TableB] AS B 
ON A.EmployeeIDA = B.EmployeeIDB
--
SELECT A.*, B.* 
FROM [testing].[TableA] as A 
FULL OUTER JOIN [testing].[TableB] AS B 
ON A.EmployeeIDA = B.EmployeeIDB

--CROSS JOIN - CARTESIAN JOIN 

SELECT *
FROM [testing].[TableA] as A 
CROSS JOIN [testing].[TableB] AS B 
--
SELECT *
FROM [testing].[TableA], [testing].[TableB] 
--
SELECT B.*, A.* 
FROM [testing].[TableA] as A 
CROSS JOIN [testing].[TableB] AS B 
--
SELECT *
FROM [testing].[TableB] as B 
CROSS JOIN [testing].[TableA] AS A
--
SELECT *
FROM [testing].[TableB], [testing].[TableA] 
--
SELECT A.*,B.* 
FROM [testing].[TableB] as B 
CROSS JOIN [testing].[TableA] AS A
--Results are the same