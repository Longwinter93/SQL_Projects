--https://www.sqlshack.com/overview-of-sql-rank-functions/
--https://learn.microsoft.com/en-us/sql/t-sql/functions/ranking-functions-transact-sql?view=sql-server-ver16
--https://learnsql.com/blog/how-to-rank-rows-in-sql/
--RANK(), DENSE_RANK(), ROW_NUMBER(), 


CREATE DATABASE RankingFunctions;
GO 

USE RankingFunctions;

CREATE SCHEMA ComparisonRanking;
GO 
--
DROP TABLE IF EXISTS ExamResult;
GO

CREATE TABLE ExamResult
(StudentName VARCHAR(70), 
 Subject     VARCHAR(20), 
 PlaceOfExamCity VARCHAR(20), 
 Marks       INT,
 ExamDate date
);
GO
--
INSERT INTO ExamResult
VALUES
('Lily','Maths','Warsaw', 65,'2018-12-18'),('Lily', 'Science','Warsaw', 80,'2018-12-31'),
('Lily',  'English','Lodz', 70,'2019-01-23'),('Lily',  'Polish','Lodz', 70,'2019-01-25'),
('Isabella', 'Maths','Lodz', 50,'2019-06-07'),('Isabella', 'Science','New York City', 70,'2019-07-09'),
('Isabella', 'English','Amsterdam', 90,'2020-06-09'),('Isabella', 'Polish', 'Amsterdam',90,'2020-01-06'),
('Olivia', 'Maths','Amsterdam',55,'2021-09-06'),('Olivia', 'Science','Amsterdam', 60,'2021-09-25'),
('Olivia', 'English','Amsterdam', 89,'2023-06-02'),('Olivia', 'Polish','New York City', 89,'2023-06-08');
GO
--
SELECT *
FROM ExamResult;
GO


SELECT *, 
		ROW_NUMBER() OVER(ORDER BY Marks) AS RankingRowNumber,
		RANK() OVER (ORDER BY Marks) AS RankingRank,
		DENSE_RANK() OVER (ORDER BY Marks) AS RankingDenseRank,
		NTILE(2) OVER (ORDER BY Marks) AS RankingNTILE
FROM ExamResult


--ROW_NUMBER and RANK are similar. ROW_NUMBER numbers all rows sequentially (for example 1, 2, 3, 4, 5).
--RANK provides the same numeric value for ties (for example 1, 2, 2, 4, 5).
--RANK()
--If two or more rows tie for a rank, each tied row receives the same rank.
--For example, if the two top salespeople have the same SalesYTD value, they are both ranked one (1). 
--The salesperson with the next highest SalesYTD is ranked number three (3), because there are two rows that are ranked higher.
--Therefore, the RANK function does not always return consecutive integers.
--DENSE_RANK()
--If two or more rows have the same rank value in the same partition, each of those rows will receive the same rank.
--For example, if the two top salespeople have the same SalesYTD value, they will both have a rank value of one.
--The salesperson with the next highest SalesYTD will have a rank value of two.
--This exceeds the number of distinct rows that come before the row in question by one.
--Therefore, the numbers returned by the DENSE_RANK function do not have gaps, and always have consecutive rank values.

USE AdventureWorks2019;

SELECT p.FirstName, p.LastName  
    ,ROW_NUMBER() OVER (ORDER BY a.PostalCode) AS "Row Number"  
    ,RANK() OVER (ORDER BY a.PostalCode) AS Rank  
    ,DENSE_RANK() OVER (ORDER BY a.PostalCode) AS "Dense Rank"  
    ,NTILE(4) OVER (ORDER BY a.PostalCode) AS Quartile  
    ,s.SalesYTD  
    ,a.PostalCode  
FROM Sales.SalesPerson AS s   
    INNER JOIN Person.Person AS p   
        ON s.BusinessEntityID = p.BusinessEntityID  
    INNER JOIN Person.Address AS a   
        ON a.AddressID = p.BusinessEntityID  
WHERE TerritoryID IS NOT NULL AND SalesYTD <> 0;  
--
USE RankingFunctions;

SELECT *, 
		ROW_NUMBER() OVER(ORDER BY Marks DESC) AS RankingRowNumber,
		RANK() OVER (ORDER BY Marks DESC) AS RankingRank,
		DENSE_RANK() OVER (ORDER BY Marks DESC) AS RankingDenseRank,
		NTILE(2) OVER (ORDER BY Marks DESC) AS RankingNTILE
FROM ExamResult;
GO
--
SELECT *,
	ROW_NUMBER() OVER (PARTITION BY StudentName ORDER BY Marks) AS RankingPartByNameRowNumber,
	RANK() OVER (PARTITION BY StudentName ORDER BY Marks) AS RankingPartByNameRank,
	DENSE_RANK() OVER (PARTITION BY StudentName ORDER BY Marks) AS RankingPartByNameDenseRank,
	NTILE(2) OVER (PARTITION BY StudentName ORDER BY Marks) AS RankingPartByNameNTILE
FROM ExamResult
--ORDER BY StudentName, Subject


--ROW_NUMBER() - It assigns the sequential rank rumber to each unique record
--RANK() - It assigns the rank number to each row in a partition. It skips the number for similar values
--DENSE_RANK() - It assigns the rank number to each row in a partition. It does not skip the number for similar values.
--NTILE(n) - It divides the number of rows as per specified partition and assigns unique value in the partition

--RANK()
--https://learn.microsoft.com/en-us/sql/t-sql/functions/rank-transact-sql?view=sql-server-ver16
USE AdventureWorks2019;  
GO  

SELECT i.ProductID, p.Name, i.LocationID, i.Quantity  
    ,RANK() OVER   
    (PARTITION BY i.LocationID ORDER BY i.Quantity DESC) AS Rank  
FROM Production.ProductInventory AS i   
INNER JOIN Production.Product AS p   
    ON i.ProductID = p.ProductID  
WHERE i.LocationID BETWEEN 3 AND 4  
ORDER BY i.LocationID;  
GO  

--
USE AdventureWorks2019;
GO

SELECT TOP(10) BusinessEntityID, Rate,   
       RANK() OVER (ORDER BY Rate DESC) AS RankBySalary  
FROM HumanResources.EmployeePayHistory AS eph1  
WHERE RateChangeDate = (SELECT MAX(RateChangeDate)   
                        FROM HumanResources.EmployeePayHistory AS eph2  
                        WHERE eph1.BusinessEntityID = eph2.BusinessEntityID)  
ORDER BY BusinessEntityID;  
GO 

USE RankingFunctions;

SELECT *, RANK() OVER (ORDER BY Marks) as Ranking
FROM ExamResult
--ORDER BY StudentName, Subject;
GO 

--DENSE_RANK()
--https://learn.microsoft.com/en-us/sql/t-sql/functions/dense-rank-transact-sql?view=sql-server-ver16

USE AdventureWorks2019;  
GO  

SELECT i.ProductID, p.Name, i.LocationID, i.Quantity  
    ,DENSE_RANK() OVER   
    (PARTITION BY i.LocationID ORDER BY i.Quantity DESC) AS Rank  
FROM Production.ProductInventory AS i   
INNER JOIN Production.Product AS p   
    ON i.ProductID = p.ProductID  
WHERE i.LocationID BETWEEN 3 AND 4  
ORDER BY i.LocationID;  
GO  
--
USE AdventureWorks2019;  
GO  
SELECT TOP(10) BusinessEntityID, Rate,   
       DENSE_RANK() OVER (ORDER BY Rate DESC) AS RankBySalary  
FROM HumanResources.EmployeePayHistory;  

--

USE RankingFunctions;

SELECT *, DENSE_RANK() OVER (ORDER BY Marks) as Ranking
FROM ExamResult

-- ROW_NUMBER()
--https://learn.microsoft.com/en-us/sql/t-sql/functions/row-number-transact-sql?view=sql-server-ver16
USE AdventureWorks2019;   
GO  

SELECT ROW_NUMBER() OVER(ORDER BY SalesYTD DESC) AS Row,   
    FirstName, LastName, ROUND(SalesYTD,2,1) AS "Sales YTD"   
FROM Sales.vSalesPerson  
WHERE TerritoryName IS NOT NULL AND SalesYTD <> 0;  

---

USE RankingFunctions;

SELECT *, ROW_NUMBER() OVER(ORDER BY Marks) AS Ranking 
FROM ExamResult;
--
USE AdventureWorks2019;  
GO  

WITH OrderedOrders AS  
(  
    SELECT SalesOrderID, OrderDate,  
    ROW_NUMBER() OVER (ORDER BY OrderDate) AS RowNumber  
    FROM Sales.SalesOrderHeader   
)   
SELECT SalesOrderID, OrderDate, RowNumber    
FROM OrderedOrders   
WHERE RowNumber BETWEEN 50 AND 60;  
--
USE AdventureWorks2019;  
GO  

SELECT FirstName, LastName, TerritoryName, ROUND(SalesYTD,2,1) AS SalesYTD,  
ROW_NUMBER() OVER(PARTITION BY TerritoryName ORDER BY SalesYTD DESC) 
  AS Row  
FROM Sales.vSalesPerson  
WHERE TerritoryName IS NOT NULL AND SalesYTD <> 0  
ORDER BY TerritoryName;  
GO

--
--NTILE 
--https://learn.microsoft.com/en-us/sql/t-sql/functions/ntile-transact-sql?view=sql-server-ver16
USE AdventureWorks2019;   
GO  

SELECT p.FirstName, p.LastName  
    ,NTILE(4) OVER(ORDER BY SalesYTD DESC) AS Quartile  
    ,CONVERT(NVARCHAR(20),s.SalesYTD,1) AS SalesYTD  
    , a.PostalCode  
FROM Sales.SalesPerson AS s   
INNER JOIN Person.Person AS p   
    ON s.BusinessEntityID = p.BusinessEntityID  
INNER JOIN Person.Address AS a   
    ON a.AddressID = p.BusinessEntityID  
WHERE TerritoryID IS NOT NULL   
    AND SalesYTD <> 0;  
GO  
--
USE AdventureWorks2019;  
GO  

DECLARE @NTILE_Var INT = 4;  
  
SELECT p.FirstName, p.LastName  
    ,NTILE(@NTILE_Var) OVER(PARTITION BY PostalCode ORDER BY SalesYTD DESC) AS Quartile  
    ,CONVERT(NVARCHAR(20),s.SalesYTD,1) AS SalesYTD  
    ,a.PostalCode  
FROM Sales.SalesPerson AS s   
INNER JOIN Person.Person AS p   
    ON s.BusinessEntityID = p.BusinessEntityID  
INNER JOIN Person.Address AS a   
    ON a.AddressID = p.BusinessEntityID  
WHERE TerritoryID IS NOT NULL   
    AND SalesYTD <> 0;  
GO  

--
USE RankingFunctions;

DECLARE @NTILE_VAR INT = 3

SELECT *, NTILE(@NTILE_VAR) OVER(PARTITION BY Subject ORDER BY Marks DESC) AS Quartile
FROM ExamResult
--
DECLARE @NTILE_VAR INT = 3

SELECT *, NTILE(@NTILE_VAR) OVER(ORDER BY Marks DESC) AS Quartile
FROM ExamResult

-- For example, ranking functions can't accept ROWS or RANGE, therefore this window frame isn't applied even though ORDER BY is present and ROWS or RANGE is not.
--https://learnsql.com/blog/how-to-rank-rows-in-sql/
SELECT *, RANK() OVER(ORDER BY Marks DESC, StudentName ASC) AS RankingMarksStudentName
FROM ExamResult
-- MAKE ROW_NUMBER DETERMINISTIC:
SELECT *, ROW_NUMBER() OVER(ORDER BY Marks DESC, StudentName ASC) AS RankingMarksStudentName
FROM ExamResult

-- DIFFERENCE DENSE_RANK() RANK()
--TOP5
SELECT *
FROM (
	SELECT 
	StudentName,
	Marks,
	RANK() OVER (ORDER BY Marks DESC) as Ranking
	FROM ExamResult) as a
WHERE a.Ranking < 5;
GO
--
SELECT *
FROM (
	SELECT 
	StudentName, 
	Marks,
	DENSE_RANK() OVER (ORDER BY Marks DESC) as Ranking
	FROM ExamResult) as a 
WHERE a.Ranking < 5;
GO
-- Ranking by DATE 
--The important thing to remember is that ASC (ascending) in case of dates means that the oldest will be placed first.
--In the DESC (descending) order, the newest date will be placed first.
SELECT *, RANK() OVER (ORDER BY ExamDate ASC) as Ranking
FROM ExamResult 
--
--Ranking by Month
SELECT *, RANK() OVER(ORDER BY YEAR(ExamDate) ASC, MONTH(ExamDate)) as Ranking
FROM ExamResult

-- RANKING With Group BY
-- Using rankings with aggregate functions
--Your database computes the aggregate functions first and then creates a ranking based on the computed values. 
--Take a look at this example with AVG():
SELECT 
	StudentName,
	SUM(Marks) AS SumOfMarks,
	RANK () OVER(ORDER BY SUM(Marks) DESC) AS Ranking
FROM ExamResult
GROUP BY StudentName 
--
SELECT 
	StudentName,
	AVG(Marks) AS SumOfMarks,
	RANK () OVER(ORDER BY AVG(Marks) DESC) AS Ranking
FROM ExamResult
GROUP BY StudentName 

--You can simply use aggregate functions inside ranking functions.
--The important thing to remember is to use the GROUP BY clause.
--As mentioned above, the aggregate functions are computed first. 
--This means that with GROUP BY, you can only use aggregate functions or the expressions you’re grouping by inside the ranking function.

--Ranking with COUNT(*)

SELECT 
	RANK() OVER(ORDER BY COUNT(*) DESC) as Ranking,
	PlaceOfExamCity,
	COUNT(*) as Quantity
FROM ExamResult
GROUP BY PlaceOfExamCity;
GO 

--RANK OVER PARTITION BY one column
SELECT *,
	RANK() OVER (PARTITION BY PlaceOfExamCity ORDER BY Marks DESC) as Ranking 
FROM ExamResult;
GO
--RANK OVER PARTITION BY mutiple columns
--In the above query, we’re using PARTITION BY with two columns: PlaceOfExamCity and StudentName. 
--This means that within each distinct pair of city and first name, we will have separate rankings. 
SELECT *,
RANK() OVER(PARTITION BY PlaceOfExamCity, StudentName ORDER BY ExamDate ASC) as Ranking
FROM ExamResult;
GO

