--https://medium.com/@mariusz_kujawski/advanced-sql-for-data-professionals-875ab725730c


CREATE DATABASE AdvancedSQLForDataProfessionals;
USE AdvancedSQLForDataProfessionals;

-- WITH COMMON TABLE EXPRESSION
DROP TABLE IF EXISTS [dbo].[Employees];
GO
CREATE TABLE Employees
(
  EmployeeID int,
  FirstName nvarchar(255),
  LastName nvarchar(255),
  ManagerID int 
)


INSERT INTO Employees VALUES (1, 'Harper', 'Westbrook', NULL);
INSERT INTO Employees VALUES (2, 'Liam', 'Carrington', 1);
INSERT INTO Employees VALUES (3, 'Evelyn', 'Radcliffe', 1);
INSERT INTO Employees VALUES (4, 'Mason', 'Albright', 2);
INSERT INTO Employees VALUES (5, 'Isla', 'Whitman', 2);
INSERT INTO Employees VALUES (6, 'Noah', 'Sterling', 3);
INSERT INTO Employees VALUES (7, 'Ruby', 'Lennox', 3);
INSERT INTO Employees VALUES (8, 'Caleb', 'Winslow', 5);
INSERT INTO Employees VALUES (9, 'Avery', 'Sinclair', 6);
INSERT INTO Employees VALUES (10, 'Oliver', 'Beckett', 6);

SELECT * FROM Employees

--1. RECURSIVE 
--A recursive CTE can reference itself, a preceding CTE, or a subsequent CTE. 
--A non-recursive CTE can reference only preceding CTEs and can't reference itself. 
--Recursive CTEs run continuously until no new results are found, while non-recursive CTEs run once.
WITH cteReports (EmpID, FirstName, LastName, MgrID, EmpLevel)
	AS 
	(
	SELECT EmployeeID, FirstName, LastName, ManagerID, 1
	FROM Employees 
	WHERE ManagerID IS NULL 
	UNION ALL 
	SELECT e.EmployeeID, e.FirstName, e.LastName, e.ManagerID, r.EmpLevel + 1
	FROM Employees e 
		INNER JOIN cteReports r 
			on e.ManagerID = r.EmpID
	)
SELECT 
	FirstName + ' ' + LastName AS FullName,
	EmpLevel,
	(SELECT FirstName + ' ' + LastName FROM Employees 
		WHERE EmployeeID = cteReports.MgrID) AS Manager
FROM cteReports
ORDER BY EmpLevel, MgrID 

-- Date Dimension Table 

WITH dates (Date, year, month) as (
	SELECT
	CAST('2024-01-01' as date) as Date,
	datepart(year, cast('2024-01-01' as date)) as year,
	datepart(month,cast('2024-01-01' as date)) as month
	UNION ALL 
	SELECT dateadd(day,1,Date), 
	datepart(year,dateadd(day,1,Date)) as year, 
	datepart(month,dateadd(day,1,Date)) as month
	FROM dates 
	where Date <= '2024-02-28'
)
SELECT * 
FROM dates
option (maxrecursion 0); 

--2. Duplicate rows
with dane (id, name, age, date) as
(
select 1, 'John Smit', 19, '2020-01-01' 
UNION ALL 
select 2, 'Eva Nowak', 21, '2021-01-01'
UNION ALL 
select 3, 'Danny Clark', 24, '2021-01-01'
UNION ALL 
select 4, 'Alicia Kaiser', 25, '2021-01-01'
UNION ALL 
select 5, 'John Smit', 19, '2021-01-01'
UNION ALL 
select 6, 'Eva Nowak', 21, '2022-01-01'
)
SELECT *
FROM (
SELECT row_number() over (partition by name order by date) as rn, *
FROM dane) as dane 
WHERE dane.rn = 1

-- Removing Duplicated Rows with a Subquery

with dane (id, name, age, date) as
(
select 1, 'John Smit', 19, '2020-01-01' 
UNION ALL 
select 2, 'Eva Nowak', 21, '2021-01-01'
UNION ALL 
select 3, 'Danny Clark', 24, '2021-01-01'
UNION ALL 
select 4, 'Alicia Kaiser', 25, '2021-01-01'
UNION ALL 
select 5, 'John Smit', 19, '2021-01-01'
UNION ALL 
select 6, 'Eva Nowak', 21, '2022-01-01'
)
SELECT a.*
from dane as a
INNER JOIN (SELECT name, max(date) as date FROM dane GROUP BY name) as dane2
ON dane2.name = a.name AND dane2.date = a.date
 
--3. Finding New Records or Records that Don’t Exist
DROP TABLE IF EXISTS TargetEmployees;
GO
CREATE TABLE TargetEmployees
(
  EmployeeID int,
  FirstName nvarchar(255),
  LastName nvarchar(255),
  ManagerID int 
);

INSERT INTO TargetEmployees VALUES (1, 'Harper', 'Westbrook', NULL);
INSERT INTO TargetEmployees VALUES (2, 'Liam', 'Carrington', 1);
INSERT INTO TargetEmployees VALUES (3, 'Evelyn', 'Radcliffe', 1);
INSERT INTO TargetEmployees VALUES (4, 'Mason', 'Albright', 2);
INSERT INTO TargetEmployees VALUES (5, 'Isla', 'Whitman', 2);
INSERT INTO TargetEmployees VALUES (6, 'Noah', 'Sterling', 3);
INSERT INTO TargetEmployees VALUES (7, 'Ruby', 'Lennox', 3);
INSERT INTO TargetEmployees VALUES (8, 'Caleb', 'Winslow', 5);
INSERT INTO TargetEmployees VALUES (9, 'Avery', 'Sinclair', 6);
INSERT INTO TargetEmployees VALUES (10, 'Oliver', 'Beckett', 6);

SELECT * FROM TargetEmployees
--
DROP TABLE IF EXISTS Sourceraw_Employees;
CREATE TABLE Sourceraw_Employees
(
  EmployeeID int,
  FirstName nvarchar(255),
  LastName nvarchar(255),
  ManagerID int 
);

INSERT INTO Sourceraw_Employees VALUES (1, 'Harper', 'Westbrook', NULL);
INSERT INTO Sourceraw_Employees VALUES (2, 'Liam', 'Carrington', 1);
INSERT INTO Sourceraw_Employees VALUES (3, 'Evelyn', 'Radcliffe', 1);
INSERT INTO Sourceraw_Employees VALUES (4, 'Mason', 'Albright', 2);
INSERT INTO Sourceraw_Employees VALUES (5, 'Isla', 'Whitman', 2);
INSERT INTO Sourceraw_Employees VALUES (6, 'Noah', 'Sterling', 3);
INSERT INTO Sourceraw_Employees VALUES (7, 'Ruby', 'Lennox', 3);
INSERT INTO Sourceraw_Employees VALUES (8, 'Caleb', 'Winslow', 5);
INSERT INTO Sourceraw_Employees VALUES (9, 'Avery', 'Sinclair', 6);
INSERT INTO Sourceraw_Employees VALUES (10, 'Oliver', 'Beckett', 6);
INSERT INTO Sourceraw_Employees VALUES (11, 'Avery', 'Sinclair', 6);
INSERT INTO Sourceraw_Employees VALUES (12, 'Oliver', 'Beckett', 6);

SELECT * FROM Sourceraw_Employees

--4. Verifying if there are new records in on the source table:

SELECT *
FROM Sourceraw_Employees as a
WHERE NOT EXISTS (
SELECT 1
FROM TargetEmployees as b
WHERE a.EmployeeID = B.EmployeeID)

--
SELECT *
FROM Sourceraw_Employees  as a
LEFT JOIN TargetEmployees as b ON a.EmployeeID = B.EmployeeID 
WHERE B.EmployeeID IS NULL 

--5. Checking for Existing Values in Other Tables (Active Clients)
--You might be asked to create a report that shows only active clients. 
--To identify these clients, you can check if a specific CustomerID exists in another table.
DROP TABLE IF EXISTS  Customers
CREATE TABLE Customers
(
  CustomerID int,
  FirstName nvarchar(255),
  LastName nvarchar(255)
);

INSERT INTO Customers VALUES (1, 'Harper', 'Westbrook');
INSERT INTO Customers VALUES (2, 'Liam', 'Carrington');
INSERT INTO Customers VALUES (3, 'Evelyn', 'Radcliffe');
INSERT INTO Customers VALUES (4, 'Mason', 'Albright');
INSERT INTO Customers VALUES (5, 'Isla', 'Whitman');
INSERT INTO Customers VALUES (6, 'Noah', 'Sterling');
INSERT INTO Customers VALUES (7, 'Ruby', 'Lennox');
INSERT INTO Customers VALUES (8, 'Caleb', 'Winslow');
INSERT INTO Customers VALUES (9, 'Avery', 'Sinclair');
INSERT INTO Customers VALUES (10, 'Oliver', 'Beckett');
INSERT INTO Customers VALUES (11, 'Avery', 'Sinclair');
INSERT INTO Customers VALUES (12, 'Oliver', 'Beckett');

SELECT * FROM Customers 


DROP TABLE IF EXISTS orders 
CREATE TABLE orders
(
  OrderID int,
  CustomerID int,
  Quantity int,
  Price decimal(10,2),
  ProductID int
);

INSERT INTO orders VALUES (1,1, 10, 5.2, 1);
INSERT INTO orders VALUES (2,2, 5, 5.2, 1);
INSERT INTO orders VALUES (3,3, 2, 5.2, 1);
INSERT INTO orders VALUES (4,4, 4, 5.2, 1);
INSERT INTO orders VALUES (5,5, 11, 5.2, 1);
INSERT INTO orders VALUES (6,6, 1, 5.2, 1);
INSERT INTO orders VALUES (7,7, 1, 5.2, 1);

SELECT * FROM orders 

--Active Clients:
SELECT * 
FROM Customers as c
WHERE EXISTS (
SELECT 1
FROM orders as o
WHERE c.CustomerID = o.CustomerID
)

--Unactive clients:

SELECT *
FROM Customers as c 
WHERE NOT EXISTS (
SELECT 1 
FROM orders as o 
WHERE c.CustomerID = o.CustomerID )

--6. Filling Gaps in Data Using SQL
--https://www.mssqltips.com/sqlservertip/7379/last-non-null-value-set-of-sql-server-records/
-- IGNORE NULLs option in window functions could be used. for example:
--first_value(price)  ignore nulls  over(order by cal.date) price
with  calendar  as (
    Select cast('2006-01-01' as date) as Date

    union all 

    Select dateadd(day,1, date)
    from calendar
    where Date <= '2006-01-31' -- Put the end date here 
)
, currency (date, price, currency) as (
select cast('2006-01-02' as date) ,3.2582, 'USD'
UNION select cast('2006-01-03' as date) ,3.2488  , 'USD'
UNION select cast('2006-01-04' as date) ,3.1858  , 'USD'
UNION select cast('2006-01-05' as date) ,3.1416  , 'USD'
UNION select cast('2006-01-06' as date) ,3.1507  , 'USD'
--missing data
UNION select cast('2006-01-09' as date) ,3.1228  , 'USD'
UNION select cast('2006-01-10' as date) ,3.128   , 'USD'
UNION select cast('2006-01-11' as date) ,3.1353  , 'USD'
UNION select cast('2006-01-12' as date) ,3.1229  , 'USD'
UNION select cast('2006-01-13' as date) ,3.1542  , 'USD'
--missing data
UNION select cast('2006-01-16' as date) ,3.1321  , 'USD'
UNION select cast('2006-01-17' as date) ,3.1521  , 'USD'
UNION select cast('2006-01-18' as date) ,3.1887  , 'USD'
UNION select cast('2006-01-19' as date) ,3.1772  , 'USD'
UNION select cast('2006-01-20' as date) ,3.1868  , 'USD'
--missing data
UNION select cast('2006-01-23' as date) ,3.1397  , 'USD'
UNION select cast('2006-01-24' as date) ,3.1333  , 'USD'
UNION select cast('2006-01-25' as date) ,3.095   , 'USD'
UNION select cast('2006-01-26' as date) ,3.1253  , 'USD'
UNION select cast('2006-01-27' as date) ,3.1379  , 'USD'
--missing data
UNION select cast('2006-01-30' as date) ,3.1559  , 'USD'
UNION select cast('2006-01-31' as date) ,3.163   , 'USD'
)
SELECT *
FROM currency -- lack of data on the weekend for example -> 07,08,14,15



 with  calendar  as (
    Select cast('2006-01-01' as date) as Date

    union all 

    Select dateadd(day,1, date)
    from calendar
    where Date <= '2006-01-31' -- Put the end date here 
)
, currency (date, price, currency) as (
select cast('2006-01-02' as date) ,3.2582, 'USD'
UNION select cast('2006-01-03' as date) ,3.2488  , 'USD'
UNION select cast('2006-01-04' as date) ,3.1858  , 'USD'
UNION select cast('2006-01-05' as date) ,3.1416  , 'USD'
UNION select cast('2006-01-06' as date) ,3.1507  , 'USD'
--missing data
UNION select cast('2006-01-09' as date) ,3.1228  , 'USD'
UNION select cast('2006-01-10' as date) ,3.128   , 'USD'
UNION select cast('2006-01-11' as date) ,3.1353  , 'USD'
UNION select cast('2006-01-12' as date) ,3.1229  , 'USD'
UNION select cast('2006-01-13' as date) ,3.1542  , 'USD'
--missing data
UNION select cast('2006-01-16' as date) ,3.1321  , 'USD'
UNION select cast('2006-01-17' as date) ,3.1521  , 'USD'
UNION select cast('2006-01-18' as date) ,3.1887  , 'USD'
UNION select cast('2006-01-19' as date) ,3.1772  , 'USD'
UNION select cast('2006-01-20' as date) ,3.1868  , 'USD'
--missing data
UNION select cast('2006-01-23' as date) ,3.1397  , 'USD'
UNION select cast('2006-01-24' as date) ,3.1333  , 'USD'
UNION select cast('2006-01-25' as date) ,3.095   , 'USD'
UNION select cast('2006-01-26' as date) ,3.1253  , 'USD'
UNION select cast('2006-01-27' as date) ,3.1379  , 'USD'
--missing data
UNION select cast('2006-01-30' as date) ,3.1559  , 'USD'
UNION select cast('2006-01-31' as date) ,3.163   , 'USD'
), groupingNull AS (
SELECT 
	cal.Date,
	cur.price,
	cur.currency,
	count(cur.price) over (order by cal.date) as _grp
FROM calendar  as cal
LEFT JOIN currency  as cur ON cal.date = cur.date)
SELECT Date, 
first_value(price) OVER (PARTITION BY _grp order by Date) as price2,
first_value(currency) OVER (PARTITION BY _grp order by Date) as currency2
FROM groupingNull 
--
DROP TABLE IF EXISTS #SampleData;
 
WITH CTE_SampleData AS
(
    SELECT DateKey = 20210101, EmployeeCode = 'A', ContractType = 'Permanent', DaysWorked = 20
    UNION ALL
    SELECT DateKey = 20210201, EmployeeCode = 'A', ContractType = 'Permanent', DaysWorked = 18
    UNION ALL
    SELECT DateKey = 20210301, EmployeeCode = 'A', ContractType = NULL, DaysWorked = 1
    UNION ALL
    SELECT DateKey = 20210101, EmployeeCode = 'B', ContractType = 'Temporary', DaysWorked = 20
    UNION ALL
    SELECT DateKey = 20210201, EmployeeCode = 'B', ContractType = 'Temporary', DaysWorked = 18
    UNION ALL
    SELECT DateKey = 20210301, EmployeeCode = 'B', ContractType = NULL, DaysWorked = 0
    UNION ALL
    SELECT DateKey = 20210401, EmployeeCode = 'B', ContractType = NULL, DaysWorked = 0
    UNION ALL
    SELECT DateKey = 20210501, EmployeeCode = 'B', ContractType = 'Permanent', DaysWorked = 19
)
SELECT *
INTO #SampleData
FROM CTE_SampleData;

with cte_grp AS (
SELECT *,
	grp = MAX(IIF(ContractType IS NOT NULL,DateKey,NULL)) OVER (PARTITION BY EmployeeCode ORDER BY DateKey)
FROM #SampleData
)
SELECT *
,LastKnownContractType = MAX(ContractType) OVER (PARTITION BY EmployeeCode, grp ORDER BY DateKey)
FROM cte_grp 
ORDER BY EmployeeCode, DateKey 



--7. Finding Employees with the Highest Salary

with Employees  (EmployeeID, Name, Salary) as (
select 1, 'John', 5000 
UNION ALL 
select  2, 'Jane', 7000
UNION ALL 
select  3, 'Bob', 4500
UNION ALL 
select  4, 'Alice', 9000
UNION ALL
select  5, 'Mike', 9000
UNION ALL
select  6, 'Sara', 8000
UNION ALL
select  7, 'Tom', 6000
UNION ALL
select  8, 'Lucy', 5500
UNION ALL 
select  9, 'Mary', 5820
UNION ALL 
select  10, 'Tom', 7890
)
SELECT * 
FROM Employees as e 
INNER JOIN (SELECT DISTINCT TOP(4) Salary, EmployeeID FROM Employees ORDER BY Salary DESC) as S 
ON E.EmployeeID =  S.EmployeeID
--
with Employees (EmployeeID, Name, Salary)  as (
select 1, 'John', 5000 
UNION ALL 
select  2, 'Jane', 7000
UNION ALL 
select  3, 'Bob', 4500
UNION ALL 
select  4, 'Alice', 9000
UNION ALL
select  5, 'Mike', 9000
UNION ALL
select  6, 'Sara', 8000
UNION ALL
select  7, 'Tom', 6000
UNION ALL
select  8, 'Lucy', 5500
UNION ALL 
select  9, 'Mary', 5820
UNION ALL 
select  10, 'Tom', 7890
), CTERa (EmployeeID, Name, Salary,RowNumber, RankSalary)  AS (
SELECT * , 
ROW_NUMBER() OVER (ORDER BY Salary DESC) as RowNumber,
DENSE_RANK() OVER (ORDER BY Salary DESC) as RankSalary
FROM Employees)
SELECT *
FROM CTERa
WHERE RankSalary <= 3

--8. Using the MAX Function with a Subquery
with Employees  (EmployeeID, Name, Salary) as (
select 1, 'John', 5000 
UNION ALL 
select  2, 'Jane', 7000
UNION ALL 
select  3, 'Bob', 4500
UNION ALL 
select  4, 'Alice', 9000
UNION ALL
select  5, 'Mike', 9000
UNION ALL 
select  6, 'Sara', 8000
UNION ALL 
select  7, 'Tom', 6000
UNION ALL 
select  8, 'Lucy', 5500
UNION ALL 
select  9, 'Mary', 5820
UNION ALL 
select  10, 'Tom', 7890
)
SELECT *
FROM Employees as e
INNER JOIN (SELECT MAX(Salary) as Salary FROM Employees) as S 
ON e.Salary = S.Salary

--
with Employees  (EmployeeID, Name, Salary) as (
select 1, 'John', 5000 
UNION ALL 
select  2, 'Jane', 7000
UNION ALL 
select  3, 'Bob', 4500
UNION ALL 
select  4, 'Alice', 9000
UNION ALL
select  5, 'Mike', 9000
UNION ALL 
select  6, 'Sara', 8000
UNION ALL 
select  7, 'Tom', 6000
UNION ALL 
select  8, 'Lucy', 5500
UNION ALL 
select  9, 'Mary', 5820
UNION ALL 
select  10, 'Tom', 7890
)
SELECT *
FROM Employees 
WHERE Salary = (SELECT MAX(Salary) as Salary FROM Employees)

--9. UNPIVOT  it will be useful for data modeling purposes to move values from columns to rows.
with data (productID, I2024, II2024, III2024, IV2024) 
AS 
(
select 1,100,123,234,4323
UNION ALL
select 2,123,445,33,2212
UNION ALL
select 3,1222,1223,1232,43232
UNION ALL
select 4,111,223,234,213
UNION ALL
select 5,22332,2323,2334,4342
)
SELECT *
FROM data

--
with data (productID, I2024, II2024, III2024, IV2024) 
AS 
(
select 1,100,123,234,4323
UNION ALL
select 2,123,445,33,2212
UNION ALL
select 3,1222,1223,1232,43232
UNION ALL
select 4,111,223,234,213
UNION ALL
select 5,22332,2323,2334,4342
)
SELECT *
FROM data 
UNPIVOT (
	sales for quarter IN (I2024, II2024, III2024, IV2024)
) as unpvt;


--
with data (productID, I2024, II2024, III2024, IV2024) 
AS 
(
select 1,100,123,234,4323
UNION ALL
select 2,123,445,33,2212
UNION ALL
select 3,1222,1223,1232,43232
UNION ALL
select 4,111,223,234,213
UNION ALL
select 5,22332,2323,2334,4342
)
SELECT productID, I2024 as value ,'I2024' as quarter
FROM data
UNION ALL 
SELECT productID, II2024 as value, 'II2024' as quarter 
FROM data
UNION ALL 
SELECT productID, III2024 as value, 'III2024' as quarter 
FROM data
UNION ALL 
SELECT productID, IV2024 as value, 'IV2024' as quarter 
FROM data

--PIVOT
--It is used to transform data so that row values are presented as columns.
DROP TABLE IF EXISTS Region
CREATE TABLE Region
(
  Year int,
  Quarter int,
  Region nvarchar(255),
  value int
);


INSERT INTO Region	VALUES (2018, 1, 'east', 100);
INSERT INTO Region	VALUES   (2018, 2, 'east',  20);
INSERT INTO Region	VALUES  (2018, 3, 'east',  40);
INSERT INTO Region	VALUES   (2018, 4, 'east',  40);
INSERT INTO Region	VALUES   (2019, 1, 'east', 120);
INSERT INTO Region	VALUES   (2019, 2, 'east', 110);
INSERT INTO Region	VALUES   (2019, 3, 'east',  80);
INSERT INTO Region	VALUES   (2019, 4, 'east',  60);
INSERT INTO Region	VALUES   (2018, 1, 'west', 105);
INSERT INTO Region	VALUES  (2018, 2, 'west',  25);
INSERT INTO Region	VALUES     (2018, 3, 'west',  45);
INSERT INTO Region	VALUES   (2018, 4, 'west',  45);
INSERT INTO Region	VALUES   (2019, 1, 'west', 125);
INSERT INTO Region	VALUES   (2019, 2, 'west', 115);
INSERT INTO Region	VALUES  (2019, 3, 'west',  85);
INSERT INTO Region	VALUES   (2019, 4, 'west',  65);

SELECT * FROM Region 

SELECT Year, Region,
SUM(CASE WHEN Quarter = 1 THEN value end) as q1,
SUM(CASE WHEN Quarter = 2 THEN value end) as q2,
SUM(CASE WHEN Quarter = 3 THEN value end) as q3,
SUM(CASE WHEN Quarter = 4 THEN value end) as q4
FROM Region 
GROUP BY Year, Region 

SELECT Year, Region,[1] as q1,[2] as q2,[3] as q3,[4] as q4
FROM (
SELECT Year, Quarter, Region, Value 
FROM Region
) as SourceTable 
PIVOT (
	SUM(Value) FOR Quarter IN ([1],[2],[3],[4])
) AS PivotTable

--10. Compare Row-to-Row: LAG Function

with currency (date, price, currency) as (
select cast('2006-01-02' as date) ,3.2582, 'USD'
UNION select cast('2006-01-03' as date) ,3.2488  , 'USD'
UNION select cast('2006-01-04' as date) ,3.1858  , 'USD'
UNION select cast('2006-01-05' as date) ,3.1416  , 'USD'
UNION select cast('2006-01-06' as date) ,3.1507  , 'USD'
UNION select cast('2006-01-09' as date) ,3.1228  , 'USD'
UNION select cast('2006-01-10' as date) ,3.128   , 'USD'
UNION select cast('2006-01-11' as date) ,3.1353  , 'USD'
UNION select cast('2006-01-12' as date) ,3.1229  , 'USD'
UNION select cast('2006-01-13' as date) ,3.1542  , 'USD'
)
SELECT 
	date,
	price,
	currency,
	LAG(price) OVER (order by date)  as previous_day_price,
	(price - LAG(price) OVER (order by date)) / LAG(price) OVER (order by date) change
FROM currency; 

--11. The LEAD Function
with currency (date, price, currency) as (
select cast('2006-01-02' as date) ,3.2582, 'USD'
UNION select cast('2006-01-03' as date) ,3.2488  , 'USD'
UNION select cast('2006-01-04' as date) ,3.1858  , 'USD'
UNION select cast('2006-01-05' as date) ,3.1416  , 'USD'
UNION select cast('2006-01-06' as date) ,3.1507  , 'USD'
UNION select cast('2006-01-09' as date) ,3.1228  , 'USD'
UNION select cast('2006-01-10' as date) ,3.128   , 'USD'
UNION select cast('2006-01-11' as date) ,3.1353  , 'USD'
UNION select cast('2006-01-12' as date) ,3.1229  , 'USD'
UNION select cast('2006-01-13' as date) ,3.1542  , 'USD'
)
SELECT 
	date,
	price,
	currency,
	LEAD(price) OVER (ORDER BY date) as NextPrice 
FROM currency 

--12. NTILE
with Employees  (EmployeeID, Name, Salary) as (
select 1, 'John', 5000 
UNION ALL select  2, 'Jane', 7000
UNION ALL select  3, 'Bob', 4500
UNION ALL select  4, 'Alice', 9000
UNION ALL select  5, 'Mike', 12000
UNION ALL select  6, 'Sara', 8000
UNION ALL select  7, 'Tom', 6000
UNION ALL select  8, 'Lucy', 5500
UNION ALL select  9, 'Mary', 5820
UNION ALL select  10, 'Tom', 7890
)
SELECT 
	EmployeeID,
	Name,
	Salary,
	NTILE(10) OVER (ORDER BY Salary) as SalaryQuartile
FROM Employees 

--13. MERGE INTO
DROP TABLE IF EXISTS EmployeesMerge
CREATE TABLE EmployeesMerge
(
  EmployeeID int,
  FirstName nvarchar(255),
  LastName nvarchar(255),
  ManagerID int 
);

DROP TABLE IF EXISTS raw_EmployeesMerge
CREATE TABLE raw_EmployeesMerge
(
  EmployeeID int,
  FirstName nvarchar(255),
  LastName nvarchar(255),
  ManagerID int 
);

INSERT INTO EmployeesMerge VALUES (1, 'Harper', 'Westbrook', NULL);
INSERT INTO EmployeesMerge VALUES (2, 'Liam', 'Carrington', 1);
INSERT INTO EmployeesMerge VALUES (3, 'Evelyn', 'Radcliffe', 1);
INSERT INTO EmployeesMerge VALUES (4, 'Mason', 'Albright', 2);
INSERT INTO EmployeesMerge VALUES (5, 'Isla', 'Whitman', 2);
INSERT INTO EmployeesMerge VALUES (6, 'Noah', 'Sterling', 3);
INSERT INTO EmployeesMerge VALUES (7, 'Ruby', 'Lennox', 3);
INSERT INTO EmployeesMerge VALUES (8, 'Caleb', 'Winslow', 5);
INSERT INTO EmployeesMerge VALUES (9, 'Avery', 'Sinclair', 6);
INSERT INTO EmployeesMerge VALUES (10, 'Oliver', 'Beckett', 6);

--DROP TABLE EmployeesMerge;
SELECT * FROM EmployeesMerge;

INSERT INTO raw_EmployeesMerge VALUES (1, 'Harper', 'Westbrook', NULL);
INSERT INTO raw_EmployeesMerge VALUES (2, 'Liam', 'Carrington', 1);
INSERT INTO raw_EmployeesMerge VALUES (3, 'Evelyn', 'Radcliffe', 1);
INSERT INTO raw_EmployeesMerge VALUES (4, 'Mason', 'Albright', 2);
INSERT INTO raw_EmployeesMerge VALUES (5, 'Isla', 'Whitman', 2);
INSERT INTO raw_EmployeesMerge VALUES (6, 'Noah', 'Sterling', 3);
INSERT INTO raw_EmployeesMerge VALUES (7, 'Ruby', 'Lennox', 3);
INSERT INTO raw_EmployeesMerge VALUES (8, 'Caleb', 'Winslow', 5);
INSERT INTO raw_EmployeesMerge VALUES (9, 'Avery', 'Sinclair', 6);
INSERT INTO raw_EmployeesMerge VALUES (10, 'Oliver', 'Beckett', 6);
INSERT INTO raw_EmployeesMerge VALUES (11, 'Avery', 'Sinclair', 6);
INSERT INTO raw_EmployeesMerge VALUES (12, 'Oliver', 'Beckett', 6);
INSERT INTO raw_EmployeesMerge VALUES (13, 'Lukasz', 'Dlkgug', 7);

SELECT * FROM raw_EmployeesMerge;
--INSERT USING Merge
MERGE EmployeesMerge AS T
USING raw_EmployeesMerge AS S 
ON T.EmployeeID = S.EmployeeID
WHEN NOT MATCHED BY TARGET THEN INSERT (EmployeeID, FirstName, LastName, ManagerID) VALUES (S.EmployeeID, S.FirstName, S.LastName, S.ManagerID);
--UPDATE 
DROP TABLE EmployeesMerge;
DROP TABLE raw_EmployeesMerge;
--INSERTING ALL VALUES FROM THE SCRATCH
SELECT * FROM raw_EmployeesMerge;
SELECT * FROM EmployeesMerge;
--UPDATING
MERGE EmployeesMerge AS T
USING raw_EmployeesMerge AS S 
ON T.EmployeeID = S.EmployeeID
WHEN MATCHED AND T.EmployeeID <> S.EmployeeID OR T.FirstName <> S.FirstName OR T.LastName <> S.LastName OR  T.ManagerID <> S.ManagerID
THEN UPDATE SET T.EmployeeID = S.EmployeeID , T.FirstName = S.FirstName , T.LastName = S.LastName ,  T.ManagerID = S.ManagerID
WHEN NOT MATCHED BY TARGET THEN INSERT (EmployeeID, FirstName, LastName, ManagerID) VALUES (S.EmployeeID, S.FirstName, S.LastName, S.ManagerID);

--
UPDATE raw_EmployeesMerge
SET LastName ='Dlugozima'
WHERE ManagerID = 7

--Using Merge to update tables


--14. Checking if Tables are The Same
DROP TABLE IF EXISTS EmployeesExcept
CREATE TABLE EmployeesExcept
(
  EmployeeID int,
  FirstName nvarchar(255),
  LastName nvarchar(255),
  ManagerID int 
);

DROP TABLE IF EXISTS raw_EmployeesExcept
CREATE TABLE raw_EmployeesExcept
(
  EmployeeID int,
  FirstName nvarchar(255),
  LastName nvarchar(255),
  ManagerID int 
);

INSERT INTO EmployeesExcept VALUES (1, 'Harper', 'Westbrook', NULL);
INSERT INTO EmployeesExcept VALUES (2, 'Liam', 'Carrington', 1);
INSERT INTO EmployeesExcept VALUES (3, 'Evelyn', 'Radcliffe', 1);
INSERT INTO EmployeesExcept VALUES (4, 'Mason', 'Albright', 2);
INSERT INTO EmployeesExcept VALUES (5, 'Isla', 'Whitman', 2);
INSERT INTO EmployeesExcept VALUES (6, 'Noah', 'Sterling', 3);
INSERT INTO EmployeesExcept VALUES (7, 'Ruby', 'Lennox', 3);
INSERT INTO EmployeesExcept VALUES (8, 'Caleb', 'Winslow', 5);
INSERT INTO EmployeesExcept VALUES (9, 'Avery', 'Sinclair', 6);
INSERT INTO EmployeesExcept VALUES (10, 'Oliver', 'Beckett', 6);

INSERT INTO raw_EmployeesExcept VALUES (1, 'Harper', 'Westbrook', NULL);
INSERT INTO raw_EmployeesExcept VALUES (2, 'Liam', 'Carrington', 1);
INSERT INTO raw_EmployeesExcept VALUES (3, 'Evelyn', 'Radcliffe', 1);
INSERT INTO raw_EmployeesExcept VALUES (4, 'Mason', 'Albright', 2);
INSERT INTO raw_EmployeesExcept VALUES (5, 'Isla', 'Whitman', 2);
INSERT INTO raw_EmployeesExcept VALUES (6, 'Noah', 'Sterling', 3);
INSERT INTO raw_EmployeesExcept VALUES (7, 'Ruby', 'Lennox', null);
INSERT INTO raw_EmployeesExcept VALUES (8, 'Caleb', 'Winslow', 5);
INSERT INTO raw_EmployeesExcept VALUES (9, 'Avery', 'Sinclair', 6);
INSERT INTO raw_EmployeesExcept VALUES (10, 'Oliver', 'Beckett', 6);
--Check
SELECT * FROM EmployeesExcept 
EXCEPT
SELECT * FROM raw_EmployeesExcept

--15. Avoid ambiguity when naming calculated fields
DROP TABLE IF EXISTS products
CREATE TABLE products (
    product VARCHAR(50) NOT NULL,
    revenue INT NOT NULL
)

INSERT INTO products (product, revenue)
VALUES 
    ('Shark', 100),
    ('Robot', 150),
    ('Alien', 90);
---- The window function will rank the 'Robot' product as 1 when it should be 3.
SELECT 
	product,
	revenue,
	CASE WHEN product = 'Robot' THEN 0 Else revenue END AS revenue,
	RANK() OVER (ORDER BY revenue DESC)
FROM products

--
SELECT 
	product,
	revenue,
	CASE WHEN product = 'Robot' THEN 0 ELSE revenue END AS Revenue,
	RANK() OVER (ORDER BY CASE WHEN product ='Robot' THEN 0 ELSE revenue END DESC) AS revenue
FROM products

--16. NOT IN; EXISTS; LEFT JOIN
--https://lasha-dolenjashvili.medium.com/sqls-exists-and-not-exists-a-comprehensive-guide-41e45902a79d

USE WideWorldImportersDW;

SELECT * 
FROM [Dimension].[Stock Item]

SELECT * 
FROM [Fact].[Order] WHERE [Stock Item Key] IN (228, 229)

SELECT *
FROM [Dimension].[Stock Item] as S
WHERE NOT EXISTS (SELECT 1 FROM [Fact].[Order] as O WHERE S.[Stock Item Key] = O.[Stock Item Key])

SELECT * 
FROM [Dimension].[Stock Item] AS S 
WHERE [Stock Item Key] NOT IN (SELECT DISTINCT  [Stock Item Key] FROM [Fact].[Order])


---
USE AdvancedSQLForDataProfessionals;
--DROP TABLE ProductTables
DROP TABLE IF EXISTS ProductTables
CREATE TABLE ProductTables 
(
  ProductID int,
  ProductName nvarchar(255)
)

DROP TABLE IF EXISTS OrderTables
CREATE TABLE OrderTables 
(
  OrderID int,
  ProductID nvarchar(255)
)

INSERT INTO ProductTables VALUES (1,'Apple')
INSERT INTO ProductTables VALUES (2,'Banana')
INSERT INTO ProductTables VALUES (3,'Orange')
INSERT INTO ProductTables VALUES (4,'Pear')
INSERT INTO ProductTables VALUES (5,'Grape')
--
INSERT INTO OrderTables VALUES (101,1)
INSERT INTO OrderTables VALUES (102,2)
INSERT INTO OrderTables VALUES (103,NULL)
INSERT INTO OrderTables VALUES (104,NULL)
INSERT INTO OrderTables VALUES (105,4)

SELECT * FROM ProductTables
SELECT * FROM OrderTables
--No row returned due to NULL values
SELECT * 
FROM ProductTables
WHERE ProductID NOT IN (SELECT DISTINCT ProductID FROM OrderTables)
--Rows returned 
SELECT *
FROM ProductTables as P
WHERE NOT EXISTS (SELECT ProductID FROM OrderTables as O 
					WHERE P.ProductID = O.ProductID)
--
SELECT *
FROM ProductTables as P
LEFT JOIN OrderTables as O ON p.ProductID = O.ProductID 
WHERE o.ProductID IS NULL; 



