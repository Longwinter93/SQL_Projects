--https://learn.microsoft.com/pl-pl/sql/t-sql/functions/aggregate-functions-transact-sql?view=sql-server-ver16
--https://learnsql.com/blog/aggregate-functions-in-sql/
--https://learnsql.com/blog/aggregate-functions/
--https://learnsql.com/blog/window-functions-vs-aggregate-functions/
--https://www.sqlshack.com/sql-partition-by-clause-overview/

CREATE DATABASE AggregateFunctionsTraining;
GO

CREATE SCHEMA Aggregated;
GO

USE AggregateFunctionsTraining;
GO

DROP TABLE IF EXISTS Aggregated.Sales;
GO

CREATE TABLE Aggregated.Sales (
	ID int,
	CompanyName nvarchar(255),
	Department nvarchar(255),
	Sales decimal(10,2),
	DateOfBusiness datetime
);
GO

INSERT INTO Aggregated.Sales
VALUES (1, 'Good Company', 'Marketing', 1000, '2016-02-15'),
(1, 'Good Company', 'Human Resources', 1200, '2016-02-20'),
(1, 'Good Company', 'Research and Development', 3000, '2016-03-15'),
(1, 'Good Company', 'Research and Development', 3000, '2016-04-12'),
(1, 'Good Company', 'Finance', 1500, '2016-12-21'),
(2, 'Great Company', 'Marketing', 2520, '2017-01-12'),
(2, 'Great Company', 'Human Resources', 3550, '2017-02-05'),
(2, 'Great Company', 'Research and Development', 4250, '2017-11-15'),
(2, 'Great Company', 'Customer Service', 6250, '2017-11-23'),
(2, 'Great Company', 'Finance', 5850, '2017-12-31'),
(3, 'Excellent Company', 'Marketing', 7580, '2018-03-05'),
(3, 'Excellent Company', 'Human Resources', 850, '2018-04-15'),
(3, 'Excellent Company', 'Research and Development', 6500, '2018-05-25'),
(3, 'Excellent Company', 'Finance', 6850, '2018-08-18'),
(3, 'Excellent Company', 'IT', 7850, '2018-09-20'),
(3, 'Excellent Company', NULL, 8000, '2018-10-22'),
(3, 'Excellent Company', 'Operations Management', 8500, '2018-11-25'),
(3, 'Excellent Company', 'Operations Management', 9500, '2018-12-14'),
(4, 'Superb Company', 'Marketing', NULL, '2019-03-17'),
(4, 'Superb Company', 'Human Resources', 10000, '2019-04-01'),
(4, 'Superb Company', 'Research and Development', NULL, '2019-04-11'),
(4, 'Superb Company', 'Finance', 11522, '2019-06-21'),
(4, 'Superb Company', NULL, 15000, '2019-07-25'),
(4, 'Superb Company', 'Business Administration', 15000, '2019-08-19'),
(5, 'Magnificient Company', 'Marketing', 12500, '2020-06-11'),
(5, NULL, 'Human Resources', 15000, '2020-08-14'),
(5, NULL, 'Research and Development', 10000, '2020-09-09'),
(5, 'Magnificient Company', 'Finance', 12500, '2020-11-14'),
(5, 'Magnificient Company', 'Finance', 14252, '2020-12-16');
GO

SELECT * FROM Aggregated.Sales;
GO


--An aggregate function performs a calculation on a set of values, and returns a single value.
--Except for COUNT(*), aggregate functions ignore null values.
--Aggregate functions are often used with the GROUP BY clause of the SELECT statement.

--All aggregate functions are deterministic.
--In other words, aggregate functions return the same value each time that they are called, when called with a specific set of input values

--SUM()
--https://learn.microsoft.com/pl-pl/sql/t-sql/functions/sum-transact-sql?view=sql-server-ver16
--Returns the sum of all the values, or only the DISTINCT values, in the expression. 
--SUM can be used with numeric columns only. Null values are ignored.
--SUM is a deterministic function when used without the OVER and ORDER BY clauses. 
--It's nondeterministic when specified with the OVER and ORDER BY clauses
USE AggregateFunctionsTraining;

SELECT CompanyName, SUM(Sales) as SumOfSales
FROM Aggregated.Sales
GROUP BY CompanyName 
ORDER BY CompanyName 

--
USE AdventureWorks2019;

SELECT *
FROM Production.Product
WHERE Color IS NOT NULL
    AND ListPrice != 0.00
    AND Name LIKE 'Mountain%'
ORDER BY Color;
GO

SELECT Color, SUM(ListPrice), SUM(StandardCost)
FROM Production.Product
WHERE Color IS NOT NULL
    AND ListPrice != 0.00
    AND Name LIKE 'Mountain%'
GROUP BY Color
ORDER BY Color;
GO

-- USING the OVER CLAUSE
--If we have duplicate rows in a Department column (Research And Development), CumulativeTotal is the same (4-5 rows).
--To avoid it, we need use ROWS/RANGE 
USE AggregateFunctionsTraining;
GO

SELECT *, 
SUM(Sales) OVER (PARTITION BY CompanyName ORDER BY Department ASC) AS CumulativeTotal,
SUM(Sales) OVER (PARTITION BY CompanyName ORDER BY Department ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS CumulativeTotalUnique
FROM Aggregated.Sales
ORDER BY ID ASC;
GO
--
USE AdventureWorks2019;
GO

SELECT BusinessEntityID, TerritoryID
   ,DATEPART(yy,ModifiedDate) AS SalesYear
   ,CONVERT(VARCHAR(20),SalesYTD,1) AS  SalesYTD
   ,CONVERT(VARCHAR(20),SUM(SalesYTD) OVER (PARTITION BY TerritoryID
                                            ORDER BY DATEPART(yy,ModifiedDate)
                                            ),1) AS CumulativeTotal
   ,CONVERT(VARCHAR(20),SUM(SalesYTD) OVER (PARTITION BY TerritoryID
                                            ORDER BY DATEPART(yy,ModifiedDate) ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                                            ),1) AS CumulativeTotalUnique
FROM Sales.SalesPerson
WHERE TerritoryID IS NULL OR TerritoryID < 5
ORDER BY TerritoryID,SalesYear;

--
USE AggregateFunctionsTraining;
GO
--SUM
SELECT CompanyName, SUM(Sales) as Sales
FROM Aggregated.Sales
GROUP BY CompanyName
ORDER BY CompanyName ASC;
GO
--SUM
SELECT *, SUM(Sales) OVER (PARTITION BY CompanyName) AS SumOfSales
FROM Aggregated.Sales 
ORDER BY CompanyName ASC;
GO
--CumulativeTotal for all CompanyName. CumulativeTotal for one Company, then it calculates based on previous company
SELECT *,
SUM(Sales) OVER (ORDER BY CompanyName DESC) as CumulativeTotalForAllCompanyName
FROM Aggregated.Sales
--ORDER BY ID ASC;
GO

--CumulativeTotal for Year
USE AdventureWorks2019;
GO

SELECT BusinessEntityID, TerritoryID
   ,DATEPART(yy,ModifiedDate) AS SalesYear
   ,CONVERT(VARCHAR(20),SalesYTD,1) AS  SalesYTD
   ,CONVERT(VARCHAR(20),SUM(SalesYTD) OVER (ORDER BY DATEPART(yy,ModifiedDate)
                                            ),1) AS CumulativeTotal
FROM Sales.SalesPerson
WHERE TerritoryID IS NULL OR TerritoryID < 5
ORDER BY SalesYear;
GO

--AVG
--https://learn.microsoft.com/pl-pl/sql/t-sql/functions/avg-transact-sql?view=sql-server-ver16
--https://learn.microsoft.com/pl-pl/sql/t-sql/functions/aggregate-functions-transact-sql?view=sql-server-ver16
--This function returns the average of the values in a group. It ignores null values.
--AVG () computes the average of a set of values by dividing the sum of those values by the count of non-null values
USE AdventureWorks2019;
GO

SELECT AVG(VacationHours)AS 'Average vacation hours',
    SUM(SickLeaveHours) AS 'Total sick leave hours'
FROM HumanResources.Employee
WHERE JobTitle LIKE 'Vice President%';
GO
--
USE AggregateFunctionsTraining;
GO

SELECT SUM(Sales) SumOfSales, AVG(Sales) AvgOfSales
FROM Aggregated.Sales;
GO

-- WITH GROUP BY Statement
USE AdventureWorks2019;
GO

SELECT TerritoryID, AVG(Bonus)as 'Average bonus', SUM(SalesYTD) as 'YTD sales'
FROM Sales.SalesPerson
GROUP BY TerritoryID;
GO
--
USE AggregateFunctionsTraining;
GO

SELECT CompanyName, SUM(Sales) SumOFSalesByCompanyName, AVG(Sales) AvgOfSalesByCompanyName
FROM Aggregated.Sales
GROUP BY CompanyName;
GO

-- USING DISTINCT VALUES -- AVG WITHOUT DISTINCT - including ay duplicate values
USE AggregateFunctionsTraining;
GO

SELECT AVG(DISTINCT Sales) AS DistinctAVG, AVG(Sales) AS NoDistinctAvg
FROM Aggregated.Sales;
GO
--OVER() CLAUSE 
USE AggregateFunctionsTraining;
GO

SELECT *, 
	AVG(Sales) OVER(PARTITION BY CompanyName ORDER BY Department ASC) AS MovingAverageWithDuplicates,
	AVG(Sales) OVER(PARTITION BY CompanyName ORDER BY Department ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS MovingAverageWithoutDuplicates
FROM Aggregated.Sales;
GO
--
USE AdventureWorks2019;
GO

SELECT BusinessEntityID, TerritoryID
   ,DATEPART(yy,ModifiedDate) AS SalesYear
   ,CONVERT(VARCHAR(20),SalesYTD,1) AS  SalesYTD
   ,CONVERT(VARCHAR(20),AVG(SalesYTD) OVER (PARTITION BY TerritoryID
                                            ORDER BY DATEPART(yy,ModifiedDate)
                                           ),1) AS MovingAvg
	,CONVERT(VARCHAR(20),AVG(SalesYTD) OVER (PARTITION BY TerritoryID
                                            ORDER BY DATEPART(yy,ModifiedDate) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                                           ),1) AS MovingAvgWithoutDuplicates
FROM Sales.SalesPerson
WHERE TerritoryID IS NULL OR TerritoryID < 5
ORDER BY TerritoryID,SalesYear;
--
USE AggregateFunctionsTraining;
GO

SELECT *, 
	AVG(Sales) OVER(ORDER BY CompanyName ASC) AS MovingAverageWithDuplicates
FROM Aggregated.Sales;
GO
--
USE AdventureWorks2019;
GO

SELECT BusinessEntityID, TerritoryID
   ,DATEPART(yy,ModifiedDate) AS SalesYear
   ,CONVERT(VARCHAR(20),SalesYTD,1) AS  SalesYTD
   ,CONVERT(VARCHAR(20),AVG(SalesYTD) OVER (ORDER BY DATEPART(yy,ModifiedDate)
                                            ),1) AS MovingAvg
FROM Sales.SalesPerson
WHERE TerritoryID IS NULL OR TerritoryID < 5
ORDER BY SalesYear;
--
USE AggregateFunctionsTraining;
GO

SELECT CompanyName, AVG(Sales) AS AverageOfSales
FROM Aggregated.Sales
GROUP BY CompanyName;
GO

SELECT *, AVG(Sales) OVER(PARTITION BY CompanyName) AS AverageOfSales
FROM Aggregated.Sales; 
GO

SELECT *, AVG(Sales) OVER (ORDER BY CompanyName ASC) AS AvgMoving
FROM Aggregated.Sales 

--MAX for date and characters
--Returns the maximum value in the expression.
--MAX ignores any null values.
--MAX returns NULL when there is no row to select.
--For character columns, MAX finds the highest value in the collating sequence.
--MAX can be used with numeric, character, uniqueidentifier, and datetime columns, but not with bit columns.
USE AdventureWorks2019;
GO

SELECT MAX(TaxRate)  
FROM Sales.SalesTaxRate;  
GO  

SELECT TaxRate
FROM Sales.SalesTaxRate 
ORDER BY TaxRate DESC;
GO   

SELECT MAX(name) 
FROM sys.databases WHERE database_id < 5;
GO

SELECT name
FROM sys.databases WHERE database_id < 5;
GO

SELECT DISTINCT Name  
       , MAX(Rate) OVER (PARTITION BY edh.DepartmentID) AS MaxSalary  
FROM HumanResources.EmployeePayHistory AS eph  
JOIN HumanResources.EmployeeDepartmentHistory AS edh  
     ON eph.BusinessEntityID = edh.BusinessEntityID  
JOIN HumanResources.Department AS d  
 ON d.DepartmentID = edh.DepartmentID  
WHERE edh.EndDate IS NULL  
ORDER BY Name; 
--

USE AggregateFunctionsTraining;
GO

SELECT *
FROM Aggregated.Sales;
GO


SELECT 
	MAX(ID) MaxOfId,
	MAX(CompanyName) LastCompanyAlphabetic,
	MAX(Department) LastDepartment,
	MAX(Sales) MaxOfSales, 
	MAX(DateOfBusiness) OldestDate
FROM Aggregated.Sales;
GO
--
SELECT CompanyName, MAX(Sales) MaxOfSales, MAX(DateOfBusiness) OldestDateOfBusiness
FROM Aggregated.Sales
GROUP BY CompanyName;
GO
--Look at PARTTION BY
SELECT *, 
	MAX(Sales) OVER(PARTITION BY CompanyName) AS MaxOfEachCompany,
	MAX(DateOfBusiness) OVER(PARTITION BY CompanyName) AS MaxOfDateOfBusiness
FROM  Aggregated.Sales;
GO
--Without any rows and distinct
SELECT  
	CompanyName, 
	MAX(Sales) OVER(PARTITION BY CompanyName) AS MaxOfEachCompany,
	MAX(DateOfBusiness) OVER(PARTITION BY CompanyName) AS MaxOfDateOfBusiness 
FROM Aggregated.Sales;
GO
--Without any additional rows
SELECT DISTINCT 
	CompanyName, 
	MAX(Sales) OVER(PARTITION BY CompanyName) AS MaxOfEachCompany,
	MAX(DateOfBusiness) OVER(PARTITION BY CompanyName) AS MaxOfDateOfBusiness 
FROM Aggregated.Sales;
GO

--MIN for date and characters
USE AdventureWorks2019;
GO

SELECT MIN(TaxRate)
FROM Sales.SalesTaxRate;
GO
--
SELECT TaxRate
FROM Sales.SalesTaxRate
ORDER BY TaxRate ASC;
GO
--
SELECT DISTINCT Name  
       , MIN(Rate) OVER (PARTITION BY edh.DepartmentID) AS MinSalary  
       , MAX(Rate) OVER (PARTITION BY edh.DepartmentID) AS MaxSalary  
       , AVG(Rate) OVER (PARTITION BY edh.DepartmentID) AS AvgSalary  
       ,COUNT(edh.BusinessEntityID) OVER (PARTITION BY edh.DepartmentID) AS EmployeesPerDept  
FROM HumanResources.EmployeePayHistory AS eph  
JOIN HumanResources.EmployeeDepartmentHistory AS edh  
     ON eph.BusinessEntityID = edh.BusinessEntityID  
JOIN HumanResources.Department AS d  
 ON d.DepartmentID = edh.DepartmentID  
WHERE edh.EndDate IS NULL  
ORDER BY Name;  
--

USE AggregateFunctionsTraining;
GO

SELECT *
FROM Aggregated.Sales; 
GO

SELECT 
	MIN(ID) MinID,
	MIN(CompanyName) MinCompanyName,
	MIN(Department) MinDepartment,
	MIN(Sales) MinSales,
	MIN(DateOfBusiness) MinDateOfBusiness
FROM Aggregated.Sales;
GO
--
SELECT 
	CompanyName,
	MIN(Sales) MinSales,
	MIN(DateOfBusiness) MinDateOfBusiness
FROM Aggregated.Sales
GROUP BY CompanyName;
GO
--

SELECT 
	*,
	MIN(Sales) OVER(PARTITION BY CompanyName) as MinOfEachCompany,
	MIN(DateOfBusiness) OVER(PARTITION BY CompanyName) AS MaxOfDateBusiness
FROM Aggregated.Sales;
GO
--Without any rows and distinct
SELECT 
	CompanyName,
	MIN(Sales) OVER(PARTITION BY CompanyName) as MinOfEachCompany,
	MIN(DateOfBusiness) OVER(PARTITION BY CompanyName) AS MaxOfDateBusiness
FROM Aggregated.Sales;
GO
--Without any additional rows
SELECT DISTINCT 
	CompanyName,
	MIN(Sales) OVER(PARTITION BY CompanyName) as MinSalesEachCompany,
	MIN(DateOfBusiness) OVER(PARTITION BY CompanyName) AS MinOfDateBusiness
FROM Aggregated.Sales;
GO

--COUNT -- deal with null
--This function returns the number of items found in a group. COUNT always returns an int data type value.
--COUNT(*) without GROUP BY returns the cardinality (number of rows) in the resultset.
--This includes rows comprised of all-NULL values and duplicates.
--COUNT(*) with GROUP BY returns the number of rows in each group. This includes NULL values and duplicates.
--COUNT(ALL <expression>) evaluates expression for each row in a group, and returns the number of nonnull values.
--COUNT(DISTINCT *expression*) evaluates expression for each row in a group, and returns the number of unique, nonnull values.

--https://www.sqlshack.com/working-with-sql-null-values/
--https://www.datacamp.com/tutorial/count-sql-function
--https://www.mssqltips.com/sqlservertip/7449/select-count-from-sql-server-examples-statistics/
--https://www.techonthenet.com/sql_server/functions/count.php
USE AdventureWorks2019;
GO
--
SELECT *
FROM HumanResources.Employee;
GO

--
SELECT COUNT(DISTINCT JobTitle) as CountDistinct, COUNT(JobTitle) as CountNormal
FROM HumanResources.Employee;
GO
--
SELECT COUNT(*)
FROM HumanResources.Employee;
GO
--
SELECT COUNT(*), AVG(Bonus)
FROM Sales.SalesPerson
WHERE SalesQuota > 25000;
GO
--
SELECT DISTINCT Name
    , COUNT(edh.BusinessEntityID) OVER (PARTITION BY edh.DepartmentID) AS EmployeesPerDept
FROM HumanResources.EmployeePayHistory AS eph
JOIN HumanResources.EmployeeDepartmentHistory AS edh
    ON eph.BusinessEntityID = edh.BusinessEntityID
JOIN HumanResources.Department AS d
ON d.DepartmentID = edh.DepartmentID
WHERE edh.EndDate IS NULL
ORDER BY Name;
--
--It returns the department of the company, each of which has more than 15 employees
USE AdventureWorksDW2019;
GO

SELECT 
	DepartmentName,
	COUNT(EmployeeKey) EmployeesInDept
FROM dbo.DimEmployee 
GROUP BY DepartmentName
HAVING COUNT(EmployeeKey) > 15;
GO
--Returning the number of produtcts contained in each of specficied sales orders 

SELECT DISTINCT 
	COUNT(ProductKey) OVER(PARTITION BY SalesOrderNumber) AS ProductCount,
	SalesOrderNumber 
FROM dbo.FactInternetSales
WHERE SalesOrderNumber IN ('SO53115','SO55981')
ORDER BY ProductCount DESC;
GO
--Without Distinct
SELECT  
	COUNT(ProductKey) OVER(PARTITION BY SalesOrderNumber) AS ProductCount,
	SalesOrderNumber 
FROM dbo.FactInternetSales
WHERE SalesOrderNumber IN ('SO53115','SO55981')
ORDER BY ProductCount DESC;
GO
--
USE AggregateFunctionsTraining;
GO

SELECT *
FROM Aggregated.Sales;
GO
--
SELECT COUNT(*) CountingValues
FROM Aggregated.Sales;
GO
--
SELECT COUNT(ALL CompanyName) CountAll, COUNT(DISTINCT CompanyName) AS CountDistinct
FROM Aggregated.Sales;
GO
--
SELECT 
	COUNT(*) TotalQuantityOfItems,
	SUM(Sales)  SumOfSales
FROM Aggregated.Sales;
GO
--

SELECT 
	CompanyName, 
	Department,
	COUNT(Department) OVER (PARTITION BY CompanyName) AS DepartmentPerCompanyNameWithoutNullValues,
	COUNT(*) OVER (PARTITION BY CompanyName) AS DepartmentPerCompanyNameWithNullValues,
	COUNT(ALL Department) OVER (PARTITION BY CompanyName) AS DepartmentPerCompanyNameWithoutNullValues
	--COUNT(DISTINCT Department) OVER (PARTITION BY CompanyName) AS DepartmentPerCompanyNameWithoutNullValuesAndDuplicate,
FROM Aggregated.Sales;
GO
--count distinct with partition by sql
--https://stackoverflow.com/questions/11202878/partition-function-count-over-possible-using-distinct
--https://dba.stackexchange.com/questions/239788/sql-counting-distinct-over-partition
--https://stackoverflow.com/questions/11202878/partition-function-count-over-possible-using-distinct
--https://stackoverflow.com/questions/57625457/count-over-partition-by-with-one-condition-dont-count-the-null-values

SELECT 
	CompanyName, 
	Department,
	--COUNT(DISTINCT Department) OVER (PARTITION BY CompanyName) AS DepartmentPerCompanyNameWithoutNullValuesAndDuplicate,
	dense_rank() over (partition by CompanyName order by Department) 
	+ dense_rank() over (partition by CompanyName order by Department desc) - 1
	- MAX(CASE WHEN DEPARTMENT IS NULL THEN 1 ELSE 0 END) OVER (PARTITION BY CompanyName) AS DepartmentPerCompanyNameWithoutNullValuesAndDuplicate
FROM Aggregated.Sales;
GO
--

SELECT 
	CompanyName, 
	Department,
	dense_rank() over (partition by CompanyName order by Department) as firstpart,
	dense_rank() over (partition by CompanyName order by Department desc) - 1 as secondpart,
	MAX(CASE WHEN DEPARTMENT IS NULL THEN 1 ELSE 0 END) OVER (PARTITION BY CompanyName) thirdpart
FROM Aggregated.Sales;
GO
--https://learnsql.com/blog/aggregate-functions-in-sql/
--COUNTING THE NUMBER OF DEPARTMENTS BY Company
--
SELECT *
FROM Aggregated.Sales;
GO
--
SELECT CompanyName, COUNT(Department) as NumberOfDepartments, COUNT(DISTINCT Department) AS DistinctNumberOfDep
FROM  Aggregated.Sales
GROUP BY CompanyName;
GO
--CASE STATEMENT
SELECT *
FROM Aggregated.Sales
WHERE Sales > 10000;
GO
--
SELECT COUNT(CASE WHEN Sales > 10000 THEN Sales END) AS NumberOfRichDepartment
FROM Aggregated.Sales; 
--
SELECT SUM(CASE WHEN Sales > 10000 THEN Sales END) AS SumSalesOfRichDepartment
FROM Aggregated.Sales;
--
SELECT *
FROM Aggregated.Sales
WHERE Sales < 10000;
GO
--
SELECT ROUND(AVG(CASE WHEN Sales < 10000 THEN Sales END),2) as AverageOfPoorDepartment
FROM Aggregated.Sales;
GO
--
SELECT MAX(CASE WHEN Sales < 10000 THEN Sales END) AS MaxOfPoorDepartment
FROM Aggregated.Sales;
GO
--
SELECT *
FROM Aggregated.Sales
WHERE Department = 'Research and Development';
GO
--
SELECT MIN(CASE WHEN Sales < 10000 AND Department LIKE '%Rese%' THEN Sales END) as MinOfRD
FROM Aggregated.Sales;
GO
--
SELECT 
	CompanyName,
	SUM(Sales)
FROM Aggregated.Sales
GROUP BY CompanyName
HAVING SUM(Sales)> 50000;
GO
--
SELECT 
	CompanyName,
	SUM(Sales)
FROM Aggregated.Sales
WHERE CompanyName LIKE '%Exc%'
GROUP BY CompanyName
HAVING SUM(Sales)> 50000;
GO
--
--https://learnsql.com/blog/window-functions-vs-aggregate-functions/
--https://www.sqlshack.com/sql-partition-by-clause-overview/
--https://learnsql.com/blog/aggregate-functions/