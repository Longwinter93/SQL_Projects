--https://learn.microsoft.com/en-us/sql/t-sql/queries/select-over-clause-transact-sql?view=sql-server-ver16
--https://learnsql.com/blog/sql-over-clause/
--https://www.sqlservercentral.com/articles/understanding-the-over-clause

--The OVER clause determines the partitioning and ordering of a rowset before the associated window function is applied. 
--That is, the OVER clause defines a window or user-specified set of rows within a query result set. 
--A window function then computes a value for each row in the window.
--You can use the OVER clause with functions to compute aggregated values such as moving averages, cumulative aggregates, running totals, or top N per group results.
--The definition of the set of records where the function will be calculated is critical. 
--This set of records is called the window frame
USE RankingFunctions;
--If you don't specify any argument, the window functions are applied on the entire result set.
SELECT *, MIN(Marks) OVER () AS [min], MAX(Marks) OVER() as [max]
FROM dbo.ExamResult;
GO
--WINDOW FRAME:
--PARTITION BY
--Divides the query result set into partitions. 
--The window function is applied to each partition separately and computation restarts for each partition.
SELECT *, MIN(Marks) OVER (PARTITION BY Subject), MAX(Marks) OVER (PARTITION BY Subject)
FROM dbo.ExamResult;
GO
--
--ORDER BY 
--Defines the logical order of the rows within each partition of the result set. 
--That is, it specifies the logical order in which the window function calculation is performed.
SELECT *, MIN(Marks) OVER (PARTITION BY Subject ORDER BY Marks) as MinimumMarks,
MAX(Marks) OVER (PARTITION BY Subject ORDER BY Marks DESC) as MaximumMarks,
MAX(Marks) OVER (PARTITION BY Subject ORDER BY Marks) as EachRow
FROM dbo.ExamResult;
GO

--Specifies that the values in the specified column should be sorted in ascending or descending order.
--ASC is the default sort order. Null values are treated as the lowest possible values.

--ROWS or RANGE
--Further limits the rows within the partition by specifying start and end points within the partition.
--It specifies a range of rows with respect to the current row either by logical association or physical association. 
--Physical association is achieved by using the ROWS clause.
--It limits the rows from a start point and endpoint in the particular window,
--to use the ROWS and RANGE clause we need to ORDER BY clause as well.
--The RANGE and ROWS clauses are similar 
--but the only difference is ROWS clause considers duplicates as well whereas the RANGE class doesn't consider duplicates.
--ROWS BETWEEN for row ranges
--RANGE BETWEEN for value ranges

--The ROWS or RANGE clause determines the subset of rows within the partition that are to be applied to the function. 
--DEFAULT RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
SELECT object_id,
       COUNT(*) OVER (ORDER BY object_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS [preceding],
       COUNT(*) OVER (ORDER BY object_id ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING) AS [central],
       COUNT(*) OVER (ORDER BY object_id ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS [following]
FROM sys.objects
ORDER BY object_id ASC;

SELECT COUNT(*) FROM sys.objects

--
USE AdventureWorks2019;
GO

SELECT ROW_NUMBER() OVER (PARTITION BY PostalCode ORDER BY SalesYTD DESC) AS "Row Number",
       p.LastName,
       s.SalesYTD,
       a.PostalCode
FROM Sales.SalesPerson AS s
     INNER JOIN Person.Person AS p
         ON s.BusinessEntityID = p.BusinessEntityID
     INNER JOIN Person.Address AS a
         ON a.AddressID = p.BusinessEntityID
WHERE TerritoryID IS NOT NULL
      AND SalesYTD <> 0
ORDER BY PostalCode;
GO
--
USE AdventureWorks2019;
GO

SELECT SalesOrderID,
       ProductID,
       OrderQty,
       SUM(OrderQty) OVER (PARTITION BY SalesOrderID) AS Total,
       AVG(OrderQty) OVER (PARTITION BY SalesOrderID) AS "Avg",
       COUNT(OrderQty) OVER (PARTITION BY SalesOrderID) AS "Count",
       MIN(OrderQty) OVER (PARTITION BY SalesOrderID) AS "Min",
       MAX(OrderQty) OVER (PARTITION BY SalesOrderID) AS "Max"
FROM Sales.SalesOrderDetail
WHERE SalesOrderID IN (43659, 43664);
GO

--Produce a moving average and cumulative total
--A cumulative total / running total refers to the sum of all data points up to a certain point in time
--Cumulative moving average returns the moving average of all data up to the current data point
USE AdventureWorks2019;
GO

SELECT BusinessEntityID,
       TerritoryID,
       DATEPART(yy, ModifiedDate) AS SalesYear,
       CONVERT (VARCHAR (20), SalesYTD, 1) AS SalesYTD,
       CONVERT (VARCHAR (20), AVG(SalesYTD) OVER (PARTITION BY TerritoryID ORDER BY DATEPART(yy, ModifiedDate)), 1) AS MovingAvg,
       CONVERT (VARCHAR (20), SUM(SalesYTD) OVER (PARTITION BY TerritoryID ORDER BY DATEPART(yy, ModifiedDate)), 1) AS CumulativeTotal
FROM Sales.SalesPerson
WHERE TerritoryID IS NULL
      OR TerritoryID < 5
ORDER BY TerritoryID, SalesYear;
GO
--
SELECT BusinessEntityID,
       TerritoryID,
       DATEPART(yy, ModifiedDate) AS SalesYear,
       CONVERT (VARCHAR (20), SalesYTD, 1) AS SalesYTD,
       CONVERT (VARCHAR (20), AVG(SalesYTD) OVER (ORDER BY DATEPART(yy, ModifiedDate)), 1) AS MovingAvg,
       CONVERT (VARCHAR (20), SUM(SalesYTD) OVER (ORDER BY DATEPART(yy, ModifiedDate)), 1) AS CumulativeTotal
FROM Sales.SalesPerson
WHERE TerritoryID IS NULL
      OR TerritoryID < 5
ORDER BY SalesYear;
--D. Specify the ROWS clause
SELECT BusinessEntityID,
       TerritoryID,
       CONVERT (VARCHAR (20), SalesYTD, 1) AS SalesYTD,
       DATEPART(yy, ModifiedDate) AS SalesYear,
       CONVERT (VARCHAR (20), SUM(SalesYTD) OVER (PARTITION BY TerritoryID ORDER BY DATEPART(yy, ModifiedDate)), 1) AS NormalCumulativeTotal,
       CONVERT (VARCHAR (20), SUM(SalesYTD) OVER (PARTITION BY TerritoryID ORDER BY DATEPART(yy, ModifiedDate) ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING), 1) AS OneFollowingCumulativeTotal
FROM Sales.SalesPerson
WHERE TerritoryID IS NULL
      OR TerritoryID < 5;
GO
--
SELECT BusinessEntityID,
       TerritoryID,
       CONVERT (VARCHAR (20), SalesYTD, 1) AS SalesYTD,
       DATEPART(yy, ModifiedDate) AS SalesYear,
       CONVERT (VARCHAR (20), SUM(SalesYTD) OVER (PARTITION BY TerritoryID ORDER BY DATEPART(yy, ModifiedDate) ROWS UNBOUNDED PRECEDING), 1) AS CumulativeTotal
FROM Sales.SalesPerson
WHERE TerritoryID IS NULL
      OR TerritoryID < 5;
GO
--Produce a moving average and cumulative total
--A cumulative total refers to the sum of all data points up to a certain point in time
--Cumulative moving average returns the moving average of all data up to the current data point
USE RankingFunctions;

SELECT *,
CONVERT (VARCHAR (20), AVG(Marks) OVER (PARTITION BY Subject ORDER BY Subject), 1) AS MovingAvg,
CONVERT (VARCHAR (20), SUM(Marks) OVER (PARTITION BY Subject ORDER BY Subject), 1) AS CumulativeTotal
FROM dbo.ExamResult;
GO
--
SELECT *,
CONVERT (VARCHAR (20), AVG(Marks) OVER (ORDER BY Subject), 1) AS MovingAvg,
CONVERT (VARCHAR (20), SUM(Marks) OVER (ORDER BY Subject), 1) AS CumulativeTotal
FROM dbo.ExamResult;
GO

--D. Specify the ROWS clause
SELECT *,
CONVERT (VARCHAR (20), AVG(Marks) OVER (PARTITION BY Subject ORDER BY Subject), 1) AS MovingAvg,
CONVERT (VARCHAR (20), SUM(Marks) OVER (PARTITION BY Subject ORDER BY Subject), 1) AS NormalCumulativeTotal,
CONVERT (VARCHAR (20), SUM(Marks) OVER (PARTITION BY Subject ORDER BY Subject ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING), 1) AS OneFollowingCumulativeTotal,
CONVERT (VARCHAR (20), SUM(Marks) OVER (PARTITION BY Subject ORDER BY Subject ROWS BETWEEN 1 PRECEDING AND CURRENT ROW), 1) AS OnePrecedingCumulativeTotal
FROM dbo.ExamResult;
GO
--
SELECT *,
CONVERT (VARCHAR (20), AVG(Marks) OVER (PARTITION BY Subject ORDER BY Subject), 1) AS MovingAvg,
CONVERT (VARCHAR (20), SUM(Marks) OVER (PARTITION BY Subject ORDER BY Subject), 1) AS NormalCumulativeTotal,
  CONVERT (VARCHAR (20), SUM(Marks) OVER (PARTITION BY Subject ORDER BY Subject ROWS UNBOUNDED PRECEDING), 1) AS FirstRowPartitionCumulativeTotal,
SUM(Marks) OVER (ORDER BY Subject ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS [preceding],
SUM(Marks) OVER (ORDER BY Subject  ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS [following]
FROM dbo.ExamResult;
GO

--https://www.sqlservercentral.com/articles/understanding-the-over-clause

SELECT  COUNT(*)
FROM    [msdb].sys.indexes;
--
SELECT  object_id, index_id, COUNT(*) OVER ()
FROM    [msdb].sys.indexes;
--
SELECT  object_id, index_id, COUNT(*) OVER (PARTITION BY object_id)
FROM    [msdb].sys.indexes;

--Demonstrating the ORDER BY and ROWS or RANGE clauses

DECLARE @Test TABLE (
    Account     INTEGER,
    TranDate    DATE,
    TranAmount  NUMERIC(5,2));
INSERT INTO @Test (Account, TranDate, TranAmount)
VALUES  (1, '2015-01-01', 50.00),
        (1, '2015-01-15', 25.00),
        (1, '2015-02-01', 50.00),
        (1, '2015-02-15', 25.00),
        (2, '2015-01-01', 50.00),
        (2, '2015-01-15', 25.00),
        (2, '2015-02-01', 50.00),
        (2, '2015-02-15', 25.00);
SELECT  Account, TranDate, TranAmount,
        COUNT(*) OVER (PARTITION BY Account
                       ORDER BY TranDate
                       ROWS UNBOUNDED PRECEDING) AS RowNbr,
        COUNT(*) OVER (PARTITION BY TranDate) AS DateCount,
        COUNT(*) OVER (PARTITION BY Account
                       ORDER BY TranDate
                       ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) AS Last2Count
FROM    @Test
ORDER BY Account, TranDate;

-- ROW & RANGE
--Look at rows 4,5 and 12,13
SELECT  FName,
        Salary,
        SumByRows  = SUM(Salary) OVER (ORDER BY Salary
                                        ROWS UNBOUNDED PRECEDING),
        SumByRange = SUM(Salary) OVER (ORDER BY Salary
                                       RANGE UNBOUNDED PRECEDING)
FROM    (VALUES (1, 'George',       800),
                (2, 'Sam',          950),
                (3, 'Diane',       1100),
                (4, 'Nicholas',    1250),
                (5, 'Samuel',      1250),
                (6, 'Patricia',    1300),
                (7, 'Brian',       1500),
                (8, 'Thomas',      1600),
                (9, 'Fran',        2450),
                (10,'Debbie',      2850),
                (11,'Mark',        2975),
                (12,'James',       3000),
                (13,'Cynthia',     3000),
                (14,'Christopher', 5000)
        ) dt(RowID, FName, Salary);

--However, the RANGE clause works off of the value of the Salary column, 
--so it sums up all rows with the same or lower salary. 
--This results in the SumByRange value being the same value for all rows with the same Salary.
--ROWs 4,5 (duplicates) in column Salary  are the same (1250), therefore ROWs 4,5 in SumByRange are the same 5350
--ROWs 12,13 (duplicates) in column Salary  are the same (3000), therefore ROWs 12,13 in SumByRange are the same 24025


--RANGE and ROW CLAUSE
--https://learnsql.com/blog/difference-between-rows-range-window-functions/
--https://learnsql.com/blog/sql-window-functions-rows-clause/
--https://learnsql.com/blog/range-clause/ 
--The ROW clause does it by specifying a fixed number of rows that precede or follow the current row.
--The RANGE clause, on the other hand, limits the rows logically; 
--it specifies the range of values in relation to the value of the current row.
