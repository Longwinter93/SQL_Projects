--Other materials:
--which analytic functions can be used with rows or range (Gemini)
--https://www.sqlservercentral.com/articles/the-new-analytic-functions-in-sql-server-2012, https://data-xtractor.com/blog/query-builder/lag-function/
--can LAG LEAD analytic functions can be used with rows or range in SQL Server?

--https://www.mssqltips.com/sqlservertip/6738/sql-window-functions-in-sql-server/ (ARTICLES ABOUT PERFORMANCE)
----https://learnsql.com/blog/sql-window-functions-examples/ (aggregated functions, max() and rank())
--Other things to analyze:
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


