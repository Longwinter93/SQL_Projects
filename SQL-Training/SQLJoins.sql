--https://learn.microsoft.com/en-us/sql/relational-databases/performance/joins?view=sql-server-ver16

USE AdventureWorksDW2019;
GO

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
FROM [testing].[TableA];
GO

--
SELECT *
FROM [testing].[TableB];
GO

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

--DIFFERENCE BETWEEN CONDITION IN A WHERE CLAUSE AND IN A JOIN
--https://learnsql.com/blog/introduction-using-aggregate-functions-joins/
--https://stackoverflow.com/questions/2559194/difference-between-and-and-where-in-joins
--https://stackoverflow.com/questions/354070/sql-join-what-is-the-difference-between-where-clause-and-on-clause
--

USE AdventureWorksDW2019;
GO
--WHERE clause: Records will be filtered after join has taken place
--ON clause: Records, from the right table, will be filtered before joining. This may end up as null in the result
CREATE TABLE table1 (Company NVARCHAR(100) NOT NULL, Field1 INT NOT NULL);
INSERT INTO table1 (Company, Field1) VALUES
('FooSoft', 100),
('BarSoft', 200);

--
CREATE TABLE table2 (Id INT NOT NULL, Name NVARCHAR(100) NOT NULL);
INSERT INTO table2 (Id, Name) VALUES
(2727, 'FooSoft'),
(2728, 'BarSoft');
--

SELECT *
FROM table1;
GO
--
SELECT *
FROM table2;
GO

--
SELECT *
FROM table1 as t1
LEFT JOIN table2 as t2
	on t1.Company = t2.Name
WHERE t2.Id IN (2728);
GO
--Filters out all non id 2728 records, it acts like inner join
--
SELECT *
FROM table1 as t1
INNER JOIN table2 as t2
	on t1.Company = t2.Name
	and t2.Id IN (2728);
GO
--
SELECT *
FROM table1 as t1
LEFT JOIN table2 as t2
	on t1.Company = t2.Name
	and t2.Id IN (2728);
GO
--Keep these records, even if they are not in 2728 records (it returns null values)
--
SELECT *
FROM table1 as t1
RIGHT JOIN table2 as t2
	on t1.Company = t2.Name
WHERE t2.Id IN (2728);
GO
--
SELECT *
FROM table1 as t1
RIGHT JOIN table2 as t2
	on t1.Company = t2.Name
	and t2.Id IN (2728);
GO

--
DROP TABLE IF EXISTS Documents;
GO
--
CREATE TABLE Documents 
(
	id int,
	name nvarchar(255)
);
GO
--
INSERT INTO Documents (id, name)
VALUES (1, 'Document1'), (2, 'Document2'), (3, 'Document3'), (4, 'Document4'), (5, 'Document5');
GO
--
DROP TABLE IF EXISTS Downloads;
GO
--
CREATE TABLE Downloads 
(
	id int,
	document_id int,
	username nvarchar(255)
);
GO
--
INSERT INTO Downloads (id, document_id, username) 
VALUES (1, 1, 'sandeep'),(2,1,'simi'), (3,2,'sandeep'), (4,2,'reya'), (5,3,'simi');

--Filters out values that do not meet conditions
SELECT *
FROM Documents as doc
LEFT OUTER JOIN Downloads as dwd
	ON doc.id = dwd.id 
WHERE username = 'sandeep';
GO
--Values that do not meet conditions are returned as null values
SELECT *
FROM Documents as doc 
LEFT OUTER JOIN Downloads as dwd 
	ON doc.id = dwd.id and dwd.username = 'sandeep';
GO
