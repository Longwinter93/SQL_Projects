--https://learnsql.com/blog/sql-window-functions-guide/
--https://www.sqlshack.com/an-overview-of-analytic-functions-in-sql-server/
--https://learn.microsoft.com/en-us/sql/t-sql/functions/analytic-functions-transact-sql?view=sql-server-ver16
--https://learnsql.com/blog/sql-window-functions-explanation/
--https://learn.microsoft.com/en-us/sql/t-sql/queries/select-window-transact-sql?view=sql-server-ver16
--https://www.sqlshack.com/use-window-functions-sql-server/ -- Value Window Functions
--https://www.mssqltips.com/sqlservertip/6738/sql-window-functions-in-sql-server/
--https://www.red-gate.com/simple-talk/databases/sql-server/t-sql-programming-sql-server/introduction-to-t-sql-window-functions/
--https://learnsql.com/blog/sql-window-functions-examples/
--https://learnsql.com/blog/lead-and-lag-functions-in-sql/
--https://learnsql.com/blog/sql-first-value-function/
--https://learnsql.com/blog/common-sql-window-functions-positional-functions/
--https://www.sqlshack.com/sql-lag-function-overview-and-examples/
--https://www.datacamp.com/tutorial/sql-lag
--https://www.sqltutorial.org/sql-window-functions/sql-lead/
--https://www.sqltutorial.org/sql-window-functions/sql-first_value/
--https://www.sqltutorial.org/sql-window-functions/sql-last_value/


CREATE DATABASE AnalyticFunctions;
GO

USE AnalyticFunctions;
GO

CREATE SCHEMA AnalyticTraining;
GO

DROP TABLE IF EXISTS employee_sales;
GO

CREATE TABLE employee_sales (
	employee_id INT,
	employee_name varchar(50),
	department varchar(50),
	sales_month datetime,
	sales_amount decimal(8,2)
);
GO

INSERT INTO employee_sales 
SELECT 1, 'Alice',   'Electronics', '2024-01-01', 5000
UNION ALL 
SELECT 2, 'Bob',     'Electronics', '2024-01-02', 5500
UNION ALL
SELECT 3, 'Carol',   'Clothing',    '2024-01-03', 4000
UNION ALL
SELECT 4, 'Dave',    'Clothing',    '2024-01-04', 4500
UNION ALL
SELECT 5, 'Alex',    'Clothing',    '2024-01-05', NULL
UNION ALL
SELECT 6, 'Lucas',    'Marketing',    '2024-01-06', 6500
UNION ALL
SELECT 1, 'Archie',   'Electronics', '2024-02-01', 6225
UNION ALL
SELECT 2, 'George',     'Electronics', '2024-02-02', 6900
UNION ALL
SELECT  3, 'Carol',   'Clothing',    '2024-02-03', 3800
UNION ALL
SELECT 4, 'Beatrice',    'Clothing',    '2024-02-04', 3700
UNION ALL
SELECT 5, 'Mark',    'Clothing',    '2024-02-05', NULL
UNION ALL
SELECT 1, 'Alfie',   'Electronics', '2024-03-01', 6000
UNION ALL
SELECT 2, 'Oliver',     'Electronics', '2024-03-02', 5225
UNION ALL
SELECT 3, 'Harry',   'Clothing',    '2024-03-03', 8225
UNION ALL
SELECT  4, 'Annabelle',    'Clothing',    '2024-03-04', 7300
UNION ALL
SELECT  5, 'Harper',    'Marketing',    '2024-03-05', NULL;
GO
--
SELECT *
FROM employee_sales;
GO
--
--Analytic functions calculate an aggregate value based on a group of rows.
--Unlike aggregate functions, however, analytic functions can return multiple rows for each group.
--Use analytic functions to compute moving averages, running totals, percentages or top-N results within a group.
--LEAD() function
--LEAD function allows to access data from the next row in the same result set without use of any SQL joins.
--We need to compare an individual row data with the subsequent row data
--If we have in dataset NULL values, we need to use ISNULL to replace it. If there are no null VALUES and and the offset is beyond the scope of the partition
--we need to specify the default value. Otherwise, NULL is returned
--You can see in below example, using LEAD function we found next order date.
--Compare values between years 
--https://learn.microsoft.com/en-us/sql/t-sql/functions/lead-transact-sql?view=sql-server-ver16
USE AdventureWorks2022;
GO

SELECT BusinessEntityID,
    YEAR(QuotaDate) AS SalesYear,
    SalesQuota AS CurrentQuota,
	LEAD(SalesQuota, 1, 0) OVER(ORDER BY YEAR(QuotaDate) ASC) AS NextQuota,
	LEAD(SalesQuota, 1, 5) OVER(ORDER BY YEAR(QuotaDate) ASC) AS NextQuota5IfNothing,
	LEAD(SalesQuota, 2, 0) OVER(ORDER BY YEAR(QuotaDate) ASC) AS NextNextQuota
FROM Sales.SalesPersonQuotaHistory
WHERE BusinessEntityID = 275 
--
USE AnalyticFunctions;
GO
--There are NULL values in datasets and no subsequent row is available - it returns NULL (last row in a NextSalesAmountIfNothingNULL column)
SELECT employee_name, 
	sales_month,
	sales_amount,
	LEAD(sales_amount, 1)  OVER(ORDER BY sales_month ASC) AS NextSalesAmountIfNothingNULL,
	LEAD(sales_amount, 1, 0)  OVER(ORDER BY sales_month ASC) AS NextSalesAmountIfNothing0,
	ISNULL(LEAD(sales_amount, 1, 0)  OVER(ORDER BY sales_month ASC),0) AS NextSalesAmountIfNothing0IfNull0
FROM employee_sales;
GO

-- Compare Values within PARTITIONS
USE AdventureWorks2022;
GO

SELECT TerritoryName, BusinessEntityID, SalesYTD,
       LEAD (SalesYTD, 1, 0) OVER (PARTITION BY TerritoryName ORDER BY SalesYTD DESC) AS NextRepSales
FROM Sales.vSalesPerson
WHERE TerritoryName IN (N'Northwest', N'Canada')
ORDER BY TerritoryName;
GO
--Specify arbitraty expressions
USE AnalyticFunctions;
GO

DROP TABLE IF EXISTS T;
GO

CREATE TABLE T (a INT, b INT, c INT);
GO

INSERT INTO T VALUES (1, 1, -3), (2, 2, 4), (3, 1, NULL), (4, 3, 1), (5, 2, NULL), (6, 1, 5);
GO

SELECT 
	a,
	b,
	c,
	LEAD(c,1,1) IGNORE NULLS OVER (ORDER BY a ASC) as IgnoreNull,
	LEAD(c,1,1) RESPECT NULLS OVER (ORDER BY a ASC) as RespectNull
FROM T;
GO
--
SELECT 
	a,
	b,
	c,
    LEAD(2 * c, b * (SELECT MIN(b) FROM T), -c / 2.0) IGNORE NULLS OVER (ORDER BY a) AS i
FROM T;
GO
--USE IGNORE NULL to find non-NULL values
DROP TABLE IF EXISTS #test_ignore_nulls;
GO

CREATE TABLE #test_ignore_nulls (column_a int, column_b int);
GO

INSERT INTO #test_ignore_nulls VALUES
    (1, 8),
    (2, 9),
    (3, NULL),
    (4, 10),
    (5, NULL),
    (6, NULL),
    (7, 11);

SELECT column_a, column_b,
      [Previous value for column_b] = LAG(column_b) IGNORE NULLS OVER (ORDER BY column_a),
      [Next value for column_b] = LEAD(column_b) IGNORE NULLS OVER (ORDER BY column_a)
FROM #test_ignore_nulls
ORDER BY column_a;
--cleanup
DROP TABLE #test_ignore_nulls;
--USE RESPECT NULLS TO KEEP NULL VALUES 
DROP TABLE IF EXISTS #test_ignore_nulls;
GO

CREATE TABLE #test_ignore_nulls (column_a int, column_b int);
GO

INSERT INTO #test_ignore_nulls VALUES
    (1, 8),
    (2, 9),
    (3, NULL),
    (4, 10),
    (5, NULL),
    (6, NULL),
    (7, 11);

SELECT column_a, column_b,
      [Previous value for column_b] = LAG(column_b) RESPECT NULLS OVER (ORDER BY column_a),
      [Next value for column_b] = LEAD(column_b) RESPECT NULLS OVER (ORDER BY column_a)
FROM #test_ignore_nulls
ORDER BY column_a;

--Identical output
SELECT column_a, column_b,
      [Previous value for column_b] = LAG(column_b)  OVER (ORDER BY column_a),
      [Next value for column_b] = LEAD(column_b)  OVER (ORDER BY column_a)
FROM #test_ignore_nulls
ORDER BY column_a;

--cleanup
DROP TABLE #test_ignore_nulls;
GO


--Look at NULL values in ORDER BY! it does not work !!! -- try to look at  case when and partition by like:
--CASE WHEN Column IS NOT NULL THEN ROW_NUMBER() OVER (PARTITION BY Column ORDER BY blah) ELSE NULL END
--If you order by column with null values it could distort the order of it in particular with IGNORE NULL and so on
--Look how ORDER BY hebehaves in LEAD, LAG with IGNORE NULL. 
--Using ChatGPT
--Which columns should be used to sort data, which columns avoid? for example duplicate values or null values
-- USING IN ORDER BY -> OVER (ORDER BY COALESCE(columns, 'aa')) 
-- Doing with these functions and with normal for example max with subquery

--We should avoid using columns with duplicates and null values to ORDER BY because it distorts order
--We take next value
SELECT *,
	LEAD(sales_amount, 1, 1) IGNORE NULLS OVER (ORDER BY sales_month ASC) as NextSalesAmountIgnoreNull,
	LEAD(sales_amount, 1, 1) RESPECT NULLS OVER (ORDER BY sales_month ASC) NextSalesAmountRespectNull
FROM employee_sales
ORDER BY sales_month ASC;
GO

--Carry last non-null values -> Using without LEAD IGNROE NULLS
--To create a new column to sort our data, thus we use COUNT (a sales column) with PARTITION BY (a department column)
--to have the same value if there is NULL values to group our data. We can see that a GroupingRows column increments if a value is inside
--If it is a NULL, it have the same value -> 2,2 (duplicated)
--Then, we need to make a new dataset and use MAX() and  PARTITION BY  on department and GroupingRows columns
--to obtain maximum value from this new partition and ignore nulls
--We are able to obtain next non-null values
WITH Test1 AS (
	SELECT *, 
		LEAD(sales_amount, 1, 1) OVER(ORDER BY sales_month ASC) NextSalesValueIncludeNull
	FROM employee_sales
), Test2 AS (--grouping rows to increment values if there is no null. Otherwise the value is duplicated
	SELECT *, COUNT(sales_amount) OVER (PARTITION BY department ORDER BY sales_month ASC) as GroupingRows
	FROM Test1
)
----We use this dataset for creating a new partition to have the same value in a groupingrow column if there is null value in NextSalesValueIncludeNull
SELECT *
FROM Test2
--Then we use department and groupingrows columns to make a new partition (unique)
--Then we use MAX() to take maximum values from this new partition to take maximum values from a NextSalesValueIncludeNull column 
--and ignore null values in this.
--FINAL RESULT

WITH FirstDataSet  AS (
	SELECT *, LEAD(sales_amount) OVER(ORDER BY sales_month ASC) NextSalesAmountRespectNull
	FROM employee_sales
), SecondDataSetGroupingDataUsingPartition AS (
	SELECT *, --Grouping data - if null values - duplicated values, otherwise it increments
		COUNT(sales_amount) OVER(PARTITION BY department ORDER BY sales_month ASC) GroupingRows
	FROM FirstDataSet
), ThirdDataSetGroupDataTakingMaxValuesFromPartitionWhenNull AS (
SELECT *,--grouping values to take maximum values from this partition (ignore null)
	MAX(NextSalesAmountRespectNull) OVER(PARTITION BY department, GroupingRows) as NextSalesAmountIgnoreNull
FROM SecondDataSetGroupingDataUsingPartition)
SELECT employee_id, employee_name, department, sales_month, sales_amount, NextSalesAmountIgnoreNull, NextSalesAmountRespectNull
FROM ThirdDataSetGroupDataTakingMaxValuesFromPartitionWhenNull
ORDER BY sales_month ASC
--We need to analyse thoroughly all datasets and each step and see relations to have these unique values
--
--
USE AnalyticFunctions;
GO
--
SELECT 
	employee_name,
	department,
	sales_month,
	sales_amount,
	LEAD(sales_amount, 1, 0) OVER(PARTITION BY department ORDER BY sales_amount DESC) as NextSalesAmountIfNothing0,
	ISNULL(LEAD(sales_amount, 1, 0) OVER(PARTITION BY department ORDER BY sales_amount DESC),99) as NextSalesAmountIfNothing0IfNull99
FROM employee_sales;
GO
--Analyzing data for a daily basis in 2024
SELECT 
	sales_month,
	YEAR(sales_month) AS YearOfSales,
	MONTH(sales_month) AS MonthOfSales,
	DAY(sales_month) AS DayOfSales,
	sales_amount,
	LEAD(sales_amount,1, 0) OVER(PARTITION BY MONTH(sales_month) ORDER BY MONTH(sales_month) ASC, DAY(sales_month) ASC) NextSalesInYear
FROM employee_sales;
GO
--DESCENDING ORDER 
SELECT 
	sales_month,
	YEAR(sales_month) AS YearOfSales,
	MONTH(sales_month) AS MonthOfSales,
	DAY(sales_month) AS DayOfSales,
	sales_amount,
	LEAD(sales_amount,1, 0) OVER(PARTITION BY MONTH(sales_month) ORDER BY MONTH(sales_month) DESC, DAY(sales_month) DESC) NextSalesInYear
FROM employee_sales;
GO


--Comparing values -- calculating difference in sales over subsequent period
USE AdventureWorksDW2022;
GO
--
SELECT CalendarYear AS Year,
    CalendarQuarter AS Quarter,
    SalesAmountQuota AS SalesQuota,
    LEAD(SalesAmountQuota, 1, 0) OVER (ORDER BY CalendarYear, CalendarQuarter) AS NextQuota,
    SalesAmountQuota - LEAD(SalesAmountQuota, 1, 0) OVER (ORDER BY CalendarYear, CalendarQuarter) AS Diff
FROM dbo.FactSalesQuota
WHERE EmployeeKey = 272 
ORDER BY CalendarYear, CalendarQuarter;
--
USE AnalyticFunctions;
GO
--
SELECT 
	employee_name,
	department,
	sales_month,
	sales_amount as sales_amount,
	LEAD(sales_amount, 1, 0) OVER(ORDER BY sales_amount DESC) as NextSalesAmount,
	sales_amount - LEAD(sales_amount, 1, 0) OVER(ORDER BY sales_amount DESC) as Diff
FROM [dbo].[employee_sales];
GO
--IF NULL Then 0 
SELECT 
	employee_name,
	department,
	sales_month,
	ISNULL(sales_amount,0) as sales_amount,
	ISNULL(LEAD(sales_amount, 1, 0) OVER(ORDER BY sales_amount DESC),0) as NextSalesAmount,
	ISNULL(sales_amount,0) - ISNULL(LEAD(sales_amount, 1, 0) OVER(ORDER BY sales_amount DESC),0) as Diff
FROM [dbo].[employee_sales];
GO
--https://www.sqlshack.com/use-window-functions-sql-server/
--Finding next sales_date, two next day of sales_day
SELECT employee_name,
		department,
		sales_month,
		LEAD(sales_month,1,0) OVER(ORDER BY sales_month ASC) AS  NextSales,
		LEAD(sales_month,2,0) OVER(ORDER BY sales_month ASC) AS TwoNextSalesDay
FROM [dbo].[employee_sales]
ORDER BY sales_month ASC;
GO
--Finding next sales_date, two next sales_date based on department
SELECT 
	employee_name, 
	department,
	sales_month,
	LEAD(sales_month,1,0) OVER(PARTITION BY department ORDER BY sales_month ASC) as NextDateOfSalesByDepartment,
	LEAD(sales_month,2,0) OVER(PARTITION BY department ORDER BY sales_month ASC) as NextTwoDateOfSalesByDepartment
FROM [dbo].[employee_sales];
GO
--Finding next name
--https://www.sqlshack.com/an-overview-of-analytic-functions-in-sql-server/
SELECT  
	employee_name,
	LEAD(employee_name, 1,'Name') OVER(ORDER BY employee_name ASC) as FirstOffset,
	LEAD(employee_name, 2,'Name') OVER(ORDER BY employee_name ASC) as SecondOffset
FROM [dbo].[employee_sales];
GO
--
SELECT  
	employee_name,
	department,
	LEAD(employee_name,1,'Name') OVER(PARTITION BY department ORDER BY employee_name ASC) as NextName
FROM [dbo].[employee_sales];
GO

--
DROP TABLE IF EXISTS EventLog;
GO
--
CREATE TABLE EventLog (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    EventName NVARCHAR(100),
    EventDateTime DATETIME
);
GO 
--
INSERT INTO EventLog (EventName, EventDateTime)
VALUES
-- May 4th events
('UserLogin', '2025-05-04 07:55:00'),
('FileDownload', '2025-05-04 08:10:00'),
('UserLogout', '2025-05-04 12:00:00'),

-- May 5th events
('UserLogin', '2025-05-05 09:00:00'),
('FileUpload', '2025-05-05 09:30:00'),
('SystemUpdate', '2025-05-05 15:45:00'),
('UserLogout', '2025-05-05 16:10:00'),

-- May 6th events
('UserLogin', '2025-05-06 08:20:00'),
('ReportGenerated', '2025-05-06 10:05:00'),
('EmailSent', '2025-05-06 10:06:00'),
('UserLogout', '2025-05-06 17:00:00');
GO
--https://learnsql.com/blog/sql-window-functions-examples/
SELECT *
FROM EventLog;
GO
--Calculate Time to Next Event in Minutes
--Time from Date:
SELECT
	EventDateTime,
	CAST(EventDateTime as time) as EventTime1,
	CONVERT(char(5), EventDateTime, 108) AS EventTime2
FROM EventLog;
GO 
--Calculate Time to Next Event in Minutes, Calculating Elapsed Time from the start
SELECT 
	EventName,
	EventDateTime,
	LEAD(EventDateTime,1,0) OVER(ORDER BY EventDateTime ASC) AS NextEventDateTime,
	DATEDIFF(minute, EventDateTime, LEAD(EventDateTime,1,0) OVER(ORDER BY EventDateTime ASC)) as TimeToNextEvent,
	DATEDIFF(minute, MIN(EventDateTime) OVER (ORDER BY EventDateTime ASC), EventDateTime) AS ElapsedTimeEventFromTheStart
FROM EventLog;
GO 
--Calculating Time To Next Event and Elapsed time from the first value in a day
SELECT 
	EventName,
	EventDateTime,
	LEAD(EventDateTime,1,0) OVER(PARTITION BY DAY(EventDateTime) ORDER BY EventDateTime ASC) AS NextEventDateTime,
	DATEDIFF(minute, EventDateTime, LEAD(EventDateTime,1,0) OVER(PARTITION BY DAY(EventDateTime) ORDER BY EventDateTime ASC)) as TimeToNextEvent,
	DATEDIFF(minute, MIN(EventDateTime) OVER (PARTITION BY DAY(EventDateTime) ORDER BY EventDateTime ASC), EventDateTime) AS ElapsedTimeEventFromTheStart
FROM EventLog;
GO 
--https://www.sqlshack.com/overview-and-examples-of-sql-server-lead-function/

WITH cte_aggregated AS (
	SELECT department,
		SUM(sales_amount) AS SalesByDepartment
	FROM [dbo].[employee_sales]
	GROUP BY department
)  
SELECT 
	department,
	SalesByDepartment,
	LEAD(SalesByDepartment,1,0) OVER(ORDER BY SalesByDepartment) AS NextSalesByDepartment
FROM cte_aggregated;
GO
--LEAD FUNCTION WITH EXPRESSIONS - look at documentation to understand all arguments in LEAD()
--Look at Electronics Department to get the gist of it 
SELECT *,
	LEAD(sales_amount, 1, 0) OVER(PARTITION BY department ORDER BY sales_amount DESC) as NextSalesByDepartment,
	LEAD(2*sales_amount, 1, 0) OVER(PARTITION BY department ORDER BY sales_amount DESC) as NextDoubleSalesByDepartment,
	DAY(sales_month) DayOfSales,
	LEAD(2*sales_amount, DAY(sales_month), 0) OVER(PARTITION BY department ORDER BY sales_amount DESC) as NextDoubleSalesByDepartmentDayWithDayOffset,
	LEAD(2*sales_amount, DAY(sales_month), MONTH(sales_month)) OVER(PARTITION BY department ORDER BY sales_amount DESC) as NextDoubleSalesByDepartmentDayWithDayOffsetAndMonthDefault	
FROM [dbo].[employee_sales]
GO
--

SELECT MAX(DAY(sales_month))
FROM [dbo].[employee_sales];
GO
----https://www.mssqltips.com/tutorial/sql-server-t-sql-window-functions-tutorial/ -- FROM INTRODUCTION!
--https://www.sqlservertutorial.net/sql-server-window-functions/
--https://www.sqltutorial.org/sql-window-functions/ (VALUE WINDOW FUNCTIONS, RANKING WINDOW FUNCTIONS)





--https://learn.microsoft.com/en-us/azure/azure-sql-edge/imputing-missing-values
--https://learn.microsoft.com/en-us/azure/azure-sql-edge/date-bucket-tsql


--https://www.mssqltips.com/sqlservertip/7379/last-non-null-value-set-of-sql-server-records/
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

SELECT *, MAX(ContractType) OVER(PARTITION BY GroupingValues) AS LastKnownContractType
FROM (SELECT *, COUNT(ContractType) OVER (PARTITION BY DateKey,EmployeeCode ORDER BY EmployeeCode ASC) as GroupingValues
FROM #SampleData) as GroupingData;
GO

SELECT *, COUNT(ContractType) OVER(PARTITION BY DateKey, EmployeeCode ORDER BY EmployeeCode) AS GroupingData
FROM #SampleData

WITH A AS (
	SELECT *, COUNT(sales_amount) OVER (PARTITION BY sales_month, sales_amount) a 
	FROM employee_sales)
SELECT *, MAX(sales_amount) OVER (PARTITION BY sales_month, a) as Try
FROM A


WITH DatasetA AS (
	SELECT *,
		COUNT(sales_amount) OVER (ORDER BY sales_month ASC) as grouper
	FROM employee_sales
)
SELECT *,MAX(sales_amount) OVER (PARTITION BY department, grouper) as forward_filled
FROM DatasetA;
GO

--
--https://www.andrewvillazon.com/forward-fill-values-t-sql/
--CTE
WITH DatasetA AS (
	SELECT *,
		COUNT(sales_amount) OVER (PARTITION BY department ORDER BY sales_month ASC) as grouper
	FROM employee_sales
)
SELECT *,MAX(sales_amount) OVER (PARTITION BY department, grouper) as forward_filled
FROM DatasetA;
GO
-- Subquery
SELECT *, 
	MAX(sales_amount) OVER(PARTITION BY department,grouper) as NextSalesAmount
FROM (SELECT *, 
	COUNT(sales_amount) OVER(PARTITION BY department ORDER BY sales_month ASC) as grouper
FROM employee_sales) as groupingdataset
GO
