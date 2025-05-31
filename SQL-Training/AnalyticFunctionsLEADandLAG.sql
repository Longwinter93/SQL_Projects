--https://learnsql.com/blog/sql-window-functions-guide/ (all functions)
--https://www.sqlshack.com/an-overview-of-analytic-functions-in-sql-server/ (all functions)
--https://learn.microsoft.com/en-us/sql/t-sql/functions/analytic-functions-transact-sql?view=sql-server-ver16 (all functions)
--https://learnsql.com/blog/sql-window-functions-explanation/ (FIRST AND LAST VALUE FUNCTIONS)
--https://www.red-gate.com/simple-talk/databases/sql-server/t-sql-programming-sql-server/introduction-to-t-sql-window-functions/ (all functions + framing)
--https://learnsql.com/blog/sql-first-value-function/ (FIRST_VALUE())
--https://learnsql.com/blog/common-sql-window-functions-positional-functions/ (FIRST,LAST, LAG, LEAD FUNCTIONS)
--https://www.sqlshack.com/sql-lag-function-overview-and-examples/
--https://www.sqlshack.com/overview-and-examples-of-sql-server-lead-function/
--https://www.sqltutorial.org/sql-window-functions/ (On the right Ranking Functions & Value Functions)
--https://www.sqlshack.com/use-window-functions-sql-server/ -- Value Window Functions (all functions)
--https://www.sqlservertutorial.net/sql-server-window-functions/ (All functions)
--https://www.mssqltips.com/tutorial/sql-server-t-sql-window-functions-tutorial/ -- (All functions)

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
--LEAD function allows to access data from the next row in the same result set without use of any SQL joins. It accesses a value stored in a row below.
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
	LEAD(sales_amount, 1)  OVER(ORDER BY sales_month ASC) AS NextSalesAmountIfNothingNULL, -- If null, it returns null, if there is an end of partition - also null
	LEAD(sales_amount, 1, 0)  OVER(ORDER BY sales_month ASC) AS NextSalesAmountIfNothing0,-- If null, it returns null, if there is an end of partition - it returns 0
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

--NULL & DUPLICATES -> PARTITION BY - ORDER BY!
--We should avoid using columns with duplicates and null values in ORDER BY clause
--because it distorts the order in a query (unexpected results!) and in particular in a WINDOW function!
--Using columns with NULL values and duplicates in the ORDER BY clause of a query with window functions can lead to unexpected results.
--Using NULL and duplicate values in columns specified in the PARTITION BY clause of window functions can indeed affect the results of your query.
--We can use expressions in PARTITION BY (CASE WHEN etc..) and ORDER BY (COALESCE().
--We should use these (EXPRESSIONS) to avoid having NULL or duplicates values in columns using in PARTITION BY & COLUMNS
--The best way of using these is to eliminate null values or duplicates.
--To eliminate duplicates, for example we might use two columns that will be unique in PARTITION BY, for example PARTITION BY col1, col2
--combied col1 and col2 are unique for selected dataset (partition), it leads to a corrected result.
--Of course, there are lot of possibilities of dealing with these ones.
--https://docs.aws.amazon.com/clean-rooms/latest/sql-reference/c_Window_functions.html#r_Examples_order_by_WF

--We take next value
USE AnalyticFunctions;
GO

SELECT *,
	LEAD(sales_amount, 1, 1) IGNORE NULLS OVER (ORDER BY sales_month ASC) as NextSalesAmountIgnoreNull,
	LEAD(sales_amount, 1, 1) RESPECT NULLS OVER (ORDER BY sales_month ASC) NextSalesAmountRespectNull
FROM employee_sales
ORDER BY sales_month ASC;
GO

--Carry last non-null values -> Using without LEAD IGNROE NULLS
--We use LEAD function to take a subsequent row from a current row
--To create a new column to sort & group our data, thus we use COUNT (a sales column) with PARTITION BY (a department column)
--to have the same value if there is NULL values to group our data in a GroupingRows column. 
--In a GroupingRows column, a value in rows increment if a value is inside
--If it is a NULL, it have the same value -> 2,2 (duplicated)
--To group this result, we need to use two columns (sales_amount & NextSalesValueIncludeNull), because they respond each other.
--Finally, we can see in selected rows belong to specified GroupingRows (for example Dave -> 2 (a GroupingRows Column), Beatrice -> 4 (a Grouping rows column)
--We simply group these rows!
--Then, we need to make a new dataset and use MAX() and  PARTITION BY  on department and GroupingRows columns
--to obtain maximum value from this new partition and ignore nulls
--As a result, we are able to obtain next non-null values
USE AnalyticFunctions;
GO

WITH Test1 AS (
	SELECT *, --Look at Dave row - it has a NULL value
		LEAD(sales_amount, 1, 1) OVER(ORDER BY sales_month ASC) NextSalesValueIncludeNull
	FROM employee_sales
), Test2 AS (--grouping rows to increment values if there is no null. Otherwise the value is duplicated
			
	SELECT *, COUNT(sales_amount) OVER (PARTITION BY department ORDER BY sales_month ASC) as GroupingRows
	FROM Test1 --Dave should have 6500 value after grouping and using MAX()
)
--We group selected rows that belong to selected group (for example Dove belongs to 2 in a GroupingRows)
--We use this dataset for creating a new partition to have the same value in a groupingrow column if there is null value in NextSalesValueIncludeNull
SELECT *
FROM Test2;
GO
--We need to include sales_amount and NextSalesValueIncludeNull to group these columns by GroupingRowsColumn
--It seems that we use this dataset to group rows!
--Then, we need to make a new partition and taking MAX value from NextSalesValueIncludeNull based on a new partition (department and GroupingRows columns)
--Next, we use department and groupingrows columns to make a new partition (unique)
--Finally, we use MAX() to take maximum values from this new partition to take maximum values from a NextSalesValueIncludeNull column 
--and ignore null values in this partition.
--FINAL RESULT

WITH FirstDataSet  AS (
	SELECT *, 
		LEAD(sales_amount) OVER(ORDER BY sales_month ASC) NextSalesAmountRespectNull
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
ORDER BY sales_month ASC;
GO
--We need to analyse thoroughly all datasets and each step and see relations to have these unique values! For Example Dove, Beatrice !
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
--https://www.sqlshack.com/use-window-functions-sql-server/ -- LEAD() Function
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
--https://www.sqlshack.com/an-overview-of-analytic-functions-in-sql-server/ LEAD() function
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
--Finding next date
SELECT 
	sales_month,
	sales_amount,
	LEAD(sales_month, 1, '1990-12-31') OVER(ORDER BY sales_amount ASC) as NextDate,
	LEAD(sales_month, 2, '1990-12-31') OVER(ORDER BY sales_amount ASC) as NextNextDate
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
--https://learnsql.com/blog/sql-window-functions-examples/ -- LEAD() functions
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
--https://www.sqlshack.com/overview-and-examples-of-sql-server-lead-function/ -- LEAD() function

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
--https://www.sqlservertutorial.net/sql-server-window-functions/sql-server-lead-function/
USE AnalyticFunctions;
GO
--

WITH cte_net_sales_2025 AS (
	SELECT 
		MONTH(sales_month) as month,
		SUM(sales_amount) as net_sales
	FROM employee_sales
	GROUP BY MONTH(sales_month)

)
SELECT 
	month,
	net_sales,
	LEAD(net_sales, 1) OVER (ORDER BY month ASC) as next_month_sales
FROM cte_net_sales_2025;
GO
--

--LAG() function
--Accesses data from a previous row in the same result set.
--LAG provides access to a row at a given physical offset that comes before the current row. 
--Use this analytic function in a SELECT statement to compare values in the current row with values in a previous row.
USE AdventureWorks2022;  
GO  

--Comparing values between years
SELECT BusinessEntityID, 
		YEAR(QuotaDate) AS SalesYear,
		SalesQuota AS CurrentQuota,   
		LAG(SalesQuota, 1,0) OVER (ORDER BY YEAR(QuotaDate)) AS PreviousQuota  
FROM Sales.SalesPersonQuotaHistory  
WHERE BusinessEntityID = 275  -- AND YEAR(QuotaDate) IN ('2005','2006');


USE AnalyticFunctions;
GO
--
SELECT 
	employee_id,
	employee_name,
	department,
	sales_month,
	MONTH(sales_month) as Months,
	sales_amount, 
	LAG(sales_amount, 1, 1) OVER(ORDER BY MONTH(sales_month) ASC) as PreviousSalesAmount
FROM employee_sales;
GO
--Comparing values within partitions
USE AdventureWorks2022;  
GO  

SELECT TerritoryName, BusinessEntityID, SalesYTD,   
       LAG (SalesYTD, 1, 0) OVER (PARTITION BY TerritoryName ORDER BY SalesYTD DESC) AS PrevRepSales  
FROM Sales.vSalesPerson  
WHERE TerritoryName IN (N'Northwest', N'Canada')   
ORDER BY TerritoryName;  
--
USE AnalyticFunctions;
GO
--
SELECT 
	employee_id,
	employee_name,
	department,
	sales_month,
	MONTH(sales_month) as Months,
	sales_amount,
	LAG(sales_amount, 1, 1) OVER(PARTITION BY department ORDER BY DAY(sales_month) DESC) PreviousSalesAmountByDepartment
FROM employee_sales;
--ORDER BY employee_name ASC;
GO
--Specifying arbitrary expressions
DROP TABLE IF EXISTS T;
GO

CREATE TABLE T (a INT, b INT, c INT);   
GO  
INSERT INTO T VALUES (1, 1, -3), (2, 2, 4), (3, 1, NULL), (4, 3, 1), (5, 2, NULL), (6, 1, 5);   
  
SELECT b, c,   
    LAG(2*c, b*(SELECT MIN(b) FROM T), -c/2.0) IGNORE NULLS OVER (ORDER BY a) AS i  
FROM T; 
--USE IGNORE NULLS to find non-NULL values
DROP TABLE IF EXISTS #test_ignore_nulls;
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
ORDER BY column_a ASC;
--cleanup
DROP TABLE #test_ignore_nulls;
--
--
USE AnalyticFunctions;
GO
--
SELECT 
	employee_id,
	employee_name,
	department,
	sales_month,
	sales_amount,
	LAG(sales_amount, 1, 1) OVER (ORDER BY DAY(sales_month) DESC) AS PreviousSalesAmount,
	LAG(sales_amount, 1, 1) IGNORE NULLS OVER (ORDER BY DAY(sales_month) DESC ) AS PreviousSalesAmountIgnoreNullValues
FROM employee_sales;
GO
--
SELECT
	employee_id,
	employee_name,
	department,
	sales_month,
	sales_amount,
	LAG(sales_amount, 1, 1) OVER(ORDER BY department ASC) as PreviousSalesAmount,
	LAG(sales_amount, 1, 1) IGNORE NULLS OVER (ORDER BY department ASC) as PreviousSalesAmountIgnoreNull
FROM employee_sales;
--ORDER BY employee_name DESC; --if we use it, it changes the order of records because ORDER BY is after SELECT in Order of Execution
GO
--USE RESPECT NULLS to keep NULL Values
DROP TABLE IF EXISTS #test_ignore_nulls;
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
--

USE AnalyticFunctions;
GO
--
SELECT 
	employee_id,
	employee_name,
	department,
	sales_month,
	sales_amount,
	LAG(sales_amount, 1, 1) RESPECT NULLS OVER(ORDER BY MONTH(sales_month) DESC) AS PreviousSalesAmountRespectNulls,
	LAG(sales_amount, 1, 1) OVER(ORDER BY MONTH(sales_month) DESC) AS PreviousSalesAmountRespectNulls
FROM employee_sales;
GO
--
USE AdventureWorksDW2022;
GO
  
SELECT CalendarYear, CalendarQuarter, SalesAmountQuota AS SalesQuota,  
       LAG(SalesAmountQuota,1,0) OVER (ORDER BY CalendarYear, CalendarQuarter) AS PrevQuota,  
       SalesAmountQuota - LAG(SalesAmountQuota,1,0) OVER (ORDER BY CalendarYear, CalendarQuarter) AS Diff  
FROM dbo.FactSalesQuota  
WHERE EmployeeKey = 272 --AND CalendarYear IN (2001, 2002)  
ORDER BY CalendarYear, CalendarQuarter; 
GO
--
USE AnalyticFunctions;
GO

SELECT 
	employee_id,
	employee_name,
	department,
	sales_month,
	sales_amount,
	LAG(sales_amount, 1, 1) IGNORE NULLS OVER(PARTITION BY department ORDER BY MONTH(sales_month) DESC) as PreviousSalesIgnoreNulls,
	LAG(sales_amount, 2, 1) IGNORE NULLS OVER(PARTITION BY department ORDER BY MONTH(sales_month) DESC) as PreviousSalesIgnoreNullsOffset2
FROM [dbo].[employee_sales];
GO
--
USE AnalyticFunctions;
GO
--
SELECT
	employee_id,
	employee_name,
	department,
	sales_month,
	sales_amount,
	LAG(sales_amount, 1, 1) OVER(ORDER BY sales_month DESC) as PreviousSalesAmount,
	LAG(sales_amount, 1, 1) IGNORE NULLS OVER(ORDER BY sales_month DESC) as PreviousSalesAmountIgnoreNulls,
	LAG(sales_amount, 1, 1) RESPECT NULLS OVER(ORDER BY sales_month DESC) as PreviousSalesAmountRespectNulls
FROM [dbo].[employee_sales];
GO
--
SELECT
	employee_id,
	employee_name,
	department,
	sales_month,
	sales_amount,
	LAG(sales_amount, 1, 1) OVER(ORDER BY sales_month DESC) as PreviousSalesAmount,
	sales_amount - LAG(sales_amount, 1, 1) OVER(ORDER BY sales_month DESC) as Diff
FROM [dbo].[employee_sales];
GO

--https://www.datacamp.com/tutorial/sql-lag
USE AnalyticFunctions;
GO
--
SELECT 
	sales_month, 
	sales_amount,
	LAG(sales_amount) OVER(ORDER BY DAY(sales_month) ASC,MONTH(sales_month) ASC) as onedaybefore
FROM[dbo].[employee_sales]
GO;
--
SELECT 
	sales_month, 
	sales_amount,
	department, 
	LAG(sales_amount) OVER(PARTITION BY department ORDER BY DAY(sales_month) ASC,MONTH(sales_month) ASC) as onedaybefore
FROM[dbo].[employee_sales]
GO;


--https://www.sqlshack.com/an-overview-of-analytic-functions-in-sql-server/ -- LAG()
USE AnalyticFunctions;
GO
--Next Name
SELECT 
	employee_name,
	sales_amount,
	LAG(employee_name, 1, 'Name') OVER(ORDER BY sales_amount ASC) FirstOffset,
	LAG(employee_name, 2, 'Name') OVER(ORDER BY sales_amount ASC) SecondOffset
FROM [dbo].[employee_sales]
GO;
--Next Date
SELECT 
	sales_month,
	sales_amount,
	LAG(sales_month, 1, '1990-12-31') OVER(ORDER BY sales_amount ASC) as FirstOffset,
	LAG(sales_month, 2, '1990-12-31') OVER(ORDER BY sales_amount ASC) as SecondOffset
FROM [dbo].[employee_sales]
GO;
--https://www.sqlservertutorial.net/sql-server-window-functions/sql-server-lag-function/ LAG()

WITH cte_sales_2024 AS (
	SELECT 
		MONTH(sales_month) as Month,
		SUM(sales_amount) sales
	FROM [dbo].[employee_sales]
	GROUP BY MONTH(sales_month)
)
SELECT 
	Month,
	sales,
	LAG(sales, 1) OVER(ORDER BY Month ASC) as previous_month_sales
FROM cte_sales_2024
--
WITH cte_sales_2024_diff_percentage_1 AS (
	SELECT 
		MONTH(sales_month) as Month,
		SUM(sales_amount) sales
	FROM [dbo].[employee_sales]
	GROUP BY MONTH(sales_month)
), cte_sales_2024_diff_percentage_2 AS (
SELECT 
	Month,
	sales,
	LAG(sales, 1) OVER(ORDER BY Month ASC) as previous_month_sales
FROM cte_sales_2024_diff_percentage_1)
SELECT 
	Month,
	sales,
	previous_month_sales,
	FORMAT((sales - previous_month_sales) / previous_month_sales, 'P') as vs_previous_month
FROM cte_sales_2024_diff_percentage_2;

--LEAD() AND LAG() functions do not have ROW or RANGE clause - window frame