/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [Row ID]
      ,[Order ID]
      ,[Order Date]
      ,[Ship Date]
      ,[Ship Mode]
      ,[Customer ID]
      ,[Customer Name]
      ,[Segment]
      ,[City]
      ,[State]
      ,[Country]
      ,[Postal Code]
      ,[Market]
      ,[Region]
      ,[Product ID]
      ,[Category]
      ,[Sub-Category]
      ,[Product Name]
      ,[Sales]
      ,[Quantity]
      ,[Discount]
      ,[Profit]
      ,[Shipping Cost]
      ,[Order Priority]
  FROM [Project4].[dbo].[SuperStore]




SELECT *
FROM [Project4].[dbo].[SuperStore]



ALTER TABLE [Project4].[dbo].[SuperStore]
DROP COLUMN 
--1.DATA WRANGLING: CLEANING, EXPLORATION AND MODIFICATION OF DATA
--1.a) REMOVED UNUSED COLUMN
ALTER TABLE [Project4].[dbo].[SuperStore]
DROP COLUMN [Row ID]

ALTER TABLE [Project4].[dbo].[SuperStore]
DROP COLUMN [Order Date]

ALTER TABLE [Project4].[dbo].[SuperStore]
DROP COLUMN [Ship Date]

ALTER TABLE [Project4].[dbo].[SuperStore]
DROP COLUMN [Postal Code]


--1.b) Add new columns for modified Postal Code and Date
--1.c) Add new columns
ALTER TABLE [Project4].[dbo].[SuperStore]
ADD PostalCode varchar(30)

ALTER TABLE [Project4].[dbo].[SuperStore]
ADD OrderDate date

ALTER TABLE [Project4].[dbo].[SuperStore]
ADD ShipDate date

ALTER TABLE [Project4].[dbo].[SuperStore]
ADD YearOfOrderDate int

ALTER TABLE [Project4].[dbo].[SuperStore]
ADD YearOfShipDate int


--1.d) UPDATE NEW COLUMNS

UPDATE [Project4].[dbo].[SuperStore]
SET [PostalCode] = COALESCE(CAST([Postal Code] as varchar(30)), 'No Available') 

UPDATE [Project4].[dbo].[SuperStore]
SET [OrderDate] = CONVERT(date,[Order Date])

UPDATE [Project4].[dbo].[SuperStore]
SET [ShipDate] = CONVERT(date, [Ship Date])

UPDATE [Project4].[dbo].[SuperStore]
SET [YearOfOrderDate] = year([OrderDate])

UPDATE [Project4].[dbo].[SuperStore]
SET [YearOfShipDate] = year([ShipDate])

--2. Spliting Order ID, Customer ID, Customer Name and Producit ID into parts
SELECT [Order ID],[Customer ID],[Customer Name], [Product ID]
FROM [Project4].[dbo].[SuperStore]

--2.a) Cleaning Data. Spliting Customer Name into First Name and Second Name

SELECT CAST([Customer Name] AS VARCHAR(30)) as [Customer Name], 
		CAST(TRIM(LEFT([Customer Name],CHARINDEX(' ', [Customer Name]))) AS VARCHAR(30)) as [Customer First Name],
		CAST(TRIM(RIGHT([Customer Name], LEN([Customer Name]) - CHARINDEX(' ', [Customer Name]))) AS VARCHAR(30)) as [Customer Second Name],
		CAST(LTRIM(RTRIM((CHARINDEX(' ', [Customer Name])))) AS INT) as [Quantity of Letters], 
		CAST(LTRIM(RTRIM((CHARINDEX(' ',REVERSE([Customer Name]))))) AS INT)	 as [Quantity of Letters]
FROM  [Project4].[dbo].[SuperStore]

-- 2.b) Spliting Customer name into First Name and Second name using STRING SPLIT, CROSS APPLY AND Pivot
CREATE VIEW CustomerInformation AS 
	SELECT DISTINCT [Customer ID], VALUE
	FROM [Project4].[dbo].[SuperStore]
	CROSS APPLY
	STRING_SPLIT([Customer Name], ' ')

-- 2.c) Creating Row Number to assign a sequential integer to my customers in order to create Pivot
WITH CreatingRowNumber AS (	
SELECT *, ROW_NUMBER() OVER(PARTITION BY [Customer ID] ORDER BY [Customer ID]) as RowNumber
FROM CustomerInformation
)
SELECT UPPER([1]) as [First Name], UPPER([2]) as [Last Name]
FROM CreatingRowNumber
PIVOT
(MAX(VALUE)
FOR RowNumber in ([1], [2])) as PvT



--2.d) Spliting Customer ID into parts
SELECT CAST([Customer ID] AS VARCHAR(30)) as [Customer ID], 
	CAST(TRIM(SUBSTRING([Customer ID],1, CHARINDEX('-', [Customer ID]) -1)) AS VARCHAR(30)) as [First Part],
	CAST(TRIM(RIGHT([Customer ID],LEN([Customer ID]) - CHARINDEX('-',[Customer ID]))) AS INT) as [Second Part]
FROM [Project4].[dbo].[SuperStore]


--2.e) Spliting Order ID into parts
SELECT CAST([Order ID] AS VARCHAR(30)) as [Order ID],
	CAST(TRIM(LEFT([Order ID],CHARINDEX('-',[Order ID])-1)) AS VARCHAR(30)) as [First Part], 
	CAST(TRIM(SUBSTRING([Order ID], CHARINDEX('-',[Order ID])+1, LEN([Order ID]) - CHARINDEX('-', REVERSE([Order ID])) - CHARINDEX('-', [Order Id]))) AS INT) as [Second Part],
	CAST(TRIM(RIGHT([Order ID],CHARINDEX('-', REVERSE([Order ID]))-1)) AS INT) as [Third Part],
	CAST(LTRIM(RTRIM((LEN([Order ID])))) AS INT) as [Quantity of Letters],
	CAST(LTRIM(RTRIM((CHARINDEX('-', REVERSE([Order ID]))))) AS INT) as [Quantity of Letters],
	CAST(LTRIM(RTRIM(CHARINDEX('-', [Order Id]))) AS INT) as [Quantity of Letters],
	CAST(LTRIM(RTRIM(LEN([Order ID]) - CHARINDEX('-', REVERSE([Order ID])) - CHARINDEX('-', [Order Id]))) AS INT) as [Quantity of Letters]
FROM [Project4].[dbo].[SuperStore]


--2.f)Spliting Product ID into parts
SELECT CAST([Product ID] AS VARCHAR(30)) as [Product ID],
	CAST(TRIM(LEFT([Product ID], CHARINDEX('-',[Product ID])-1)) AS VARCHAR(30)) as [First Part],
	CAST(TRIM(SUBSTRING([Product ID], CHARINDEX('-', [Product ID])+1, LEN([Product ID]) - CHARINDEX('-',[Product ID])-CHARINDEX('-',REVERSE([Product ID])))) AS VARCHAR(30)) as [Second Part],
	CAST(TRIM(RIGHT([Product ID],CHARINDEX('-', REVERSE([Product ID]))-1)) AS INT) as [Third Part],
	CAST(LTRIM(RTRIM((LEN([Product ID])))) AS INT) as [Quantity of Letters],
	CAST(LTRIM(RTRIM((CHARINDEX('-',[Product ID])))) AS INT) as [Quantity of Letters],
	CAST(LTRIM(RTRIM(CHARINDEX('-',REVERSE([Order ID])))) AS INT) as [Quantity of Letters]
FROM  [Project4].[dbo].[SuperStore]

-- 3.a) Statistical descriptions 
SELECT [YearOfOrderDate] as [Year],SUM(Sales) as Sales,ROUND(STDEV([Sales]),2) as [Standard Deviation of Sales], VAR([Sales]) AS [Variance of Sales],
ROUND(AVG([Sales]),2) as [Average Sales], MAX([Sales]) as [Maximum Sales], MIN([Sales]) as [Minimum Sales],
SUM([Profit]) as Profit, ROUND(STDEV([Profit]),2) as [Standard Deviation of Profit],  VAR([Profit]) as [Variance of Profit],
ROUND(AVG([Profit]),2) AS [Average Profit],MAX([Profit]) as [Maximum Profit], MIN([Profit]) as [Minimum Profit]
FROM  [Project4].[dbo].[SuperStore]
GROUP BY [YearOfOrderDate]
ORDER BY [YearOfOrderDate] ASC
-- 3.b) The Median of Sales by year 
SELECT DISTINCT [YearOfOrderDate] as [Year], PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY [Sales]) OVER (PARTITION BY [YearOfOrderDate]) as [MedianCont],
PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY [Sales]) OVER (PARTITION BY [YearOfOrderDate]) as [MedianDisc]
FROM [Project4].[dbo].[SuperStore]
ORDER BY [YearOfOrderDate] DESC
-- 3.c) The Median of Profit by year 
SELECT DISTINCT [YearOfOrderDate], PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY [Profit]) OVER (PARTITION BY [YearOfOrderDate]) as [MedianCont],
PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY [Profit]) OVER (PARTITION BY [YearOfOrderDate]) as [MedianDisc]
FROM [Project4].[dbo].[SuperStore]
ORDER BY [YearOfOrderDate] DESC

--4. DATA EXPLORATION
--4.a)The quantity of Customers 
SELECT COUNT( distinct [Customer Name]) as [Quantity of Customers]
FROM  [Project4].[dbo].[SuperStore]

--4.b) Sales of Customer by Segment.
--4.c) Creaate Function in order to return data of a table type - 
--4.d) Look at top 25 % of Customer by Sales
DROP TABLE IF EXISTS #CustomerOfSales
CREATE TABLE #CustomerOfSales (
	[Customer Name] varchar(max),
	[Sales] int
)

INSERT INTO #CustomerOfSales
	SELECT DISTINCT [Customer Name], SUM([Sales]) OVER(PARTITION BY [Customer Name]) as Sales
	FROM [Project4].[dbo].[SuperStore]
	ORDER By [Sales] DESC


WITH Top25CustomerBySales AS (
SELECT *, FORMAT(CUME_DIST() OVER (ORDER BY [Sales] DESC),'P2')  as [Cumulative distribution]
FROM  #CustomerOfSales
)
SELECT *
FROM Top25CustomerBySales
WHERE [Cumulative distribution] < '25%' AND [Customer Name] != 'Michael Oakman'
ORDER BY [Sales] DESC

-- 4.e) Customer of Sales with Sales greater than Average Sales
SELECT *
FROM #CustomerOfSales
WHERE [Sales] > (SELECT AVG(SALES) FROM [Project4].[dbo].[SuperStore])
ORDER BY [Sales] DESC

--4.f) Sales  by Segment.
SELECT DISTINCT [Segment],
	SUM([Sales]) OVER (PARTITION BY [Segment]) as Sales
FROM   [Project4].[dbo].[SuperStore]
ORDER BY Sales DESC

-- 4.g) The Quantity of Orders by Segment 
SELECT DISTINCT 
		[Segment],
		count(*) OVER (PARTITION BY [Segment]) as [The Quantity of Orders]
FROM [Project4].[dbo].[SuperStore]
ORDER BY [The Quantity of Orders] DESC
--4.h) Total Quantity by Segment
SELECT count([Segment]) as [Total Quantity of Segment]
FROM [Project4].[dbo].[SuperStore]

-- 4.i) CREATE a VIEW TABLE to store data
CREATE VIEW QuantityOfOrdersAllSegment AS 
	SELECT DISTINCT [Segment], 
				count(*) OVER (PARTITION BY [Segment]) as [The Quantity of Orders]
	FROM   [Project4].[dbo].[SuperStore]


--4.j) The percetnage Quantity of Orders by Segment in all years
DECLARE @TotalQuantity FLOAT
SET @TotalQuantity = (SELECT count([Segment]) as [Total Quantity of Segment] FROM [Project4].[dbo].[SuperStore])
PRINT @TotalQuantity
SELECT [Segment], FORMAT([The Quantity of Orders]/@TotalQuantity, 'P2') as [The percetnage Quantity of Orders]
FROM QuantityOfOrdersAllSegment
ORDER BY [The Quantity of Orders] DESC

--4. k) A table-valued function was used to store the quantity of orders by segment in all years 
CREATE FUNCTION QuantityOfOrdersBySegmentInYears
(
	@Year int
)
RETURNS TABLE
AS 
RETURN 
	SELECT DISTINCT [Segment], 
	count(*) OVER (PARTITION BY [Segment]) as [The Quantity of Orders]
	FROM   [Project4].[dbo].[SuperStore]
	WHERE YearOfOrderDate = @Year

-- 4. l) The Quantity of Order by Segment in 2011
SELECT *
FROM QuantityOfOrdersBySegmentInYears(2011)
ORDER BY [The Quantity of Orders] DESC
--4. m) The Quantity of Order by Segment in 2012
SELECT *
FROM QuantityOfOrdersBySegmentInYears(2012)
ORDER BY [The Quantity of Orders] DESC
--4.n) The Quantity of Order by Segment in 2013
SELECT *
FROM QuantityOfOrdersBySegmentInYears(2013)
ORDER BY [The Quantity of Orders] DESC
-- 4.o) The Quantity of Order by Segment in 2014
SELECT *
FROM QuantityOfOrdersBySegmentInYears(2014)
ORDER BY [The Quantity of Orders] DESC


-- 4. p) The Percentage Quantity of Order by Segment in all years
DECLARE @TotalQuantity2011 FLOAT
SET @TotalQuantity2011 = (SELECT count([Segment]) as [Total Quantity of Segment] FROM [Project4].[dbo].[SuperStore] WHERE YearOfOrderDate = 2011)
PRINT @TotalQuantity2011
DECLARE @TotalQuantity2012 FLOAT
SET @TotalQuantity2012 = (SELECT count([Segment]) as [Total Quantity of Segment] FROM [Project4].[dbo].[SuperStore] WHERE YearOfOrderDate = 2012)
PRINT @TotalQuantity2012
DECLARE @TotalQuantity2013 FLOAT
SET @TotalQuantity2013 = (SELECT count([Segment]) as [Total Quantity of Segment] FROM [Project4].[dbo].[SuperStore] WHERE YearOfOrderDate = 2013)
PRINT @TotalQuantity2013
DECLARE @TotalQuantity2014 FLOAT
SET @TotalQuantity2014 = (SELECT count([Segment]) as [Total Quantity of Segment] FROM [Project4].[dbo].[SuperStore] WHERE YearOfOrderDate = 2014)
PRINT @TotalQuantity2014;

WITH ThePercentageQuantityOfOrderBySegment2011 ([Segment], [% of Orders 2011])  AS 
(
SELECT [Segment],
		FORMAT([The Quantity of Orders]/@TotalQuantity2011, 'P2') as [The percetnage Quantity of Orders]
FROM QuantityOfOrdersBySegmentInYears(2011)
),  ThePercentageQuantityOfOrderBySegment2012 ([Segment], [% of Orders 2012]) AS
(
SELECT [Segment],
		FORMAT([The Quantity of Orders]/@TotalQuantity2012, 'P2') as [The percetnage Quantity of Orders]
FROM QuantityOfOrdersBySegmentInYears(2012)
),  ThePercentageQuantityOfOrderBySegment2013 ([Segment], [% of Orders 2013]) AS 
(
SELECT [Segment],
		FORMAT([The Quantity of Orders]/@TotalQuantity2013, 'P2') as [The percetnage Quantity of Orders]
FROM QuantityOfOrdersBySegmentInYears(2013)
), ThePercentageQuantityOfOrderBySegment2014 ([Segment], [% of Orders 2014]) AS 
(
SELECT [Segment],
		FORMAT([The Quantity of Orders]/@TotalQuantity2014, 'P2') as [The percetnage Quantity of Orders]
FROM QuantityOfOrdersBySegmentInYears(2014)
)
SELECT *
FROM ThePercentageQuantityOfOrderBySegment2011 Seg2011
	JOIN ThePercentageQuantityOfOrderBySegment2012 Seg2012
		ON Seg2011.[Segment] = Seg2012.[Segment]
	JOIN ThePercentageQuantityOfOrderBySegment2013 Seg2013
		ON Seg2011.[Segment] = Seg2013.[Segment]
	JOIN ThePercentageQuantityOfOrderBySegment2014 Seg2014
		ON Seg2011.[Segment] = Seg2014.[Segment]


--4.q) Creaate Table-valued functions in order to return data of Sales of Customer by Segment in all years - 
CREATE FUNCTION SalesOfCustomerBySegmentAndYears (
@segment varchar(500),
@startyear int,
@endyear int
)
RETURNS TABLE 
AS
RETURN
	SELECT DISTINCT 
			[Customer Name],
			[Segment],
			SUM(Sales) OVER (PARTITION BY [Customer Name]) as [Sales]
	FROM  
		[Project4].[dbo].[SuperStore]

	WHERE 
		Segment = @segment AND
		YearOfOrderDate between @startyear AND @endyear;

-- Home Office
SELECT *
FROM SalesOfCustomerBySegmentAndYears('Home Office',2011,2014)
ORDER BY [Sales] DESC
-- 2011
SELECT *
FROM SalesOfCustomerBySegmentAndYears('Home Office',2011,2011)
ORDER BY [Sales] DESC
--2012
SELECT *
FROM SalesOfCustomerBySegmentAndYears('Home Office',2012,2012)
ORDER BY [Sales] DESC
--2013
SELECT *
FROM SalesOfCustomerBySegmentAndYears('Home Office',2013,2013)
ORDER BY [Sales] DESC
--2014
SELECT *
FROM SalesOfCustomerBySegmentAndYears('Home Office',2014,2014)
ORDER BY [Sales] DESC

--Consumer
SELECT *
FROM SalesOfCustomerBySegmentAndYears('Consumer',2011,2014)
ORDER BY [Sales] DESC
--2011
SELECT *
FROM SalesOfCustomerBySegmentAndYears('Consumer',2011,2011)
ORDER BY [Sales] DESC
--2012
SELECT *
FROM SalesOfCustomerBySegmentAndYears('Consumer',2012,2012)
ORDER BY [Sales] DESC
--2013
SELECT *
FROM SalesOfCustomerBySegmentAndYears('Consumer',2013,2013)
ORDER BY [Sales] DESC
--2014
SELECT *
FROM SalesOfCustomerBySegmentAndYears('Consumer',2014,2014)
ORDER BY [Sales] DESC

--Corporate

SELECT *
FROM SalesOfCustomerBySegmentAndYears('Corporate',2011,2014)
ORDER BY [Sales] DESC
--2011
SELECT *
FROM SalesOfCustomerBySegmentAndYears('Corporate',2011,2011)
ORDER BY [Sales] DESC
--2012
SELECT *
FROM SalesOfCustomerBySegmentAndYears('Corporate',2012,2012)
ORDER BY [Sales] DESC
--2013
SELECT *
FROM SalesOfCustomerBySegmentAndYears('Corporate',2013,2013)
ORDER BY [Sales] DESC
--2014
SELECT *
FROM SalesOfCustomerBySegmentAndYears('Corporate',2014,2014)
ORDER BY [Sales] DESC



-- 4.r) TOP10 Customer in each Segment
CREATE PROCEDURE TOP10CustomerInEachSegment @Segment varchar(30)
AS	
	SELECT DISTINCT TOP 10 with TIES
		[Customer Name], [Segment],SUM(Sales) OVER (PARTITION BY [Customer Name]) as [Sales]
	FROM [Project4].[dbo].[SuperStore]
	WHERE Segment =  @Segment
	ORDER BY [Sales] DESC
GO

EXEC TOP10CustomerInEachSegment @Segment = 'Home Office'
EXEC TOP10CustomerInEachSegment @Segment = 'Consumer'
EXEC TOP10CustomerInEachSegment @Segment = 'Corporate'

-- 4.s) Customer with Sales by each Segment greater than Average
CREATE PROCEDURE CustomerWithSalesGreaterThanAverage @Segment varchar(30)
AS
	SELECT DISTINCT
		[Customer Name], [Segment],SUM(Sales) OVER (PARTITION BY [Customer Name]) as [Sales]
	FROM [Project4].[dbo].[SuperStore]
	WHERE Sales > (SELECT AVG(Sales) FROM [Project4].[dbo].[SuperStore]) AND Segment = @Segment
	ORDER BY [Sales] DESC
GO

EXEC CustomerWithSalesGreaterThanAverage @Segment = 'Home Office'
EXEC CustomerWithSalesGreaterThanAverage @Segment = 'Consumer'
EXEC CustomerWithSalesGreaterThanAverage @Segment = 'Corporate'

-- 4.t) Customer with The highest and lowest Sales and Ranking
DROP TABLE IF EXISTS #CustomerBySegment
CREATE TABLE #CustomerBySegment (
	[Customer Name] VARCHAR(MAX),
	[Segment] VARCHAR(MAX),
	[Sales] INT
);

INSERT INTO #CustomerBySegment
	SELECT DISTINCT [Customer Name], 
		[Segment],
		SUM(Sales) OVER (PARTITION BY [Customer Name]) as [Sales]
	FROM [Project4].[dbo].[SuperStore]
	ORDER BY Segment DESC, Sales DESC


-- 4. u) The Ranking of  Customer by Segment
CREATE PROCEDURE RankingOfCustomer @Segment varchar(MAX)
AS
	SELECT RANK() OVER (PARTITION BY [Segment] ORDER BY Sales DESC) as Ranking, 
		[Customer Name], 
		[Segment], 
		[Sales]
	FROM #CustomerBySegment
	WHERE [Segment] = @Segment;
GO
		
EXEC RankingOfCustomer @Segment = 'Consumer'
EXEC RankingOfCustomer @Segment = 'Corporate'
EXEC RankingOfCustomer @Segment = 'Home Office'


-- 4. v) The greatest and lowest Sales by Segment
WITH GreatestSales ([Segment], [Customer with the greatest Sales],[Sales]) AS 
(
SELECT DISTINCT
	[Segment],
	FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Segment] ORDER BY [Sales] DESC) as [Customer with the greatest Sales],
	MAX(Sales) OVER (PARTITION BY [Segment]) as [Sales]
FROM #CustomerBySegment
), LowestSales ([Segment],[Customer with the lowest Sales],[Sales]) AS
(
SELECT DISTINCT 
	[Segment],
	LAST_VALUE([Customer Name]) OVER (PARTITION BY [Segment] ORDER BY [Sales] DESC 
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the lowest Sales],
	MIN(Sales) OVER (PARTITION BY [Segment]) as [Sales]
FROM #CustomerBySegment
)
SELECT *
FROM GreatestSales  G
	LEFT JOIN LowestSales L
		 ON G.Segment = L.Segment

--4. W) Group of Customer of Sales by Segment
DROP PROCEDURE GroupOfCustomerBySegment
CREATE PROCEDURE GroupOfCustomerBySegment @Segment varchar(MAX)
AS
	WITH GroupOfCustomerByLevelOfSales AS (
	SELECT [Customer Name],
	NTILE(3) OVER (ORDER BY Sales DESC) as [Group of Customer]
	FROM #CustomerBySegment
	WHERE [Segment] = @Segment
)
SELECT [Customer Name],
	CASE
		WHEN [Group Of Customer] = 1  THEN 'High Sales'
		WHEN [Group Of Customer] = 2  THEN 'Mid Sales'
		WHEN [Group Of Customer] = 3  THEN 'Low Sales'
	END AS [Level of Sales]
FROM GroupOfCustomerByLevelOfSales
GO

EXEC GroupOfCustomerBySegment @Segment = 'Consumer'
EXEC GroupOfCustomerBySegment @Segment = 'Corporate'
EXEC GroupOfCustomerBySegment @Segment = 'Home Office'




--5a) The Quantity of Orders by Category
SELECT DISTINCT [Category], count(*) OVER (PARTITION BY [Category]) as [The Quantity of Orders]
FROM   [Project4].[dbo].[SuperStore]
ORDER BY [The Quantity of Orders] DESC
-- 5b) The Total Quantity of Orders
SELECT COUNT([Category]) as [The Total Quantity of Orders]
FROM   [Project4].[dbo].[SuperStore]
-- 5.c) TVF was used to return the data of the quantity of Order by Category in all years
CREATE FUNCTION QuantityOfOrderByCategory
(
	@StartYear int,
	@EndYear int
)
RETURNS TABLE
AS
RETURN
		SELECT DISTINCT [Category], count(*) OVER (PARTITION BY [Category]) as [The Quantity of Orders]
		FROM   [Project4].[dbo].[SuperStore]
		WHERE [YearOfOrderDate] BETWEEN @StartYear AND @EndYear

-- The  Quantity of Orders by Category in all years
SELECT *
FROM QuantityOfOrderByCategory(2011,2014)
ORDER BY [The Quantity of Orders] DESC
--2011
SELECT *
FROM QuantityOfOrderByCategory(2011,2011)
ORDER BY [The Quantity of Orders] DESC
--2012
SELECT *
FROM QuantityOfOrderByCategory(2012,2012)
ORDER BY [The Quantity of Orders] DESC
--2013
SELECT *
FROM QuantityOfOrderByCategory(2013,2013)
ORDER BY [The Quantity of Orders] DESC
--2014
SELECT *
FROM QuantityOfOrderByCategory(2014,2014)
ORDER BY [The Quantity of Orders] DESC
-- 5.d) The Percetange Quantity of Orders by Category in all years
DECLARE @TotalQuanaityOfCategory FLOAT
SET @TotalQuanaityOfCategory = (SELECT COUNT([Category]) as [The Total Quantity of Orders] FROM   [Project4].[dbo].[SuperStore])
PRINT @TotalQuanaityOfCategory
SELECT [Category], 
		FORMAT([The Quantity of Orders] / @TotalQuanaityOfCategory, 'P2') as [% of Orders]
FROM QuantityOfOrderByCategory(2011,2014)
ORDER BY [The Quantity of Orders] DESC

-- 5.e)The Percetange Quantity of Orders by Category in all years

DECLARE @TotalQuanaityOfCategory2011 FLOAT
SET @TotalQuanaityOfCategory2011 = (SELECT COUNT([Category]) as [The Total Quantity of Orders] FROM   [Project4].[dbo].[SuperStore] WHERE [YearOfOrderDate] = 2011)
PRINT @TotalQuanaityOfCategory2011
DECLARE @TotalQuanaityOfCategory2012 FLOAT
SET @TotalQuanaityOfCategory2012 = (SELECT COUNT([Category]) as [The Total Quantity of Orders] FROM   [Project4].[dbo].[SuperStore] WHERE [YearOfOrderDate] = 2012)
PRINT @TotalQuanaityOfCategory2012
DECLARE @TotalQuanaityOfCategory2013 FLOAT
SET @TotalQuanaityOfCategory2013 = (SELECT COUNT([Category]) as [The Total Quantity of Orders] FROM   [Project4].[dbo].[SuperStore] WHERE [YearOfOrderDate] = 2013)
PRINT @TotalQuanaityOfCategory2013
DECLARE @TotalQuanaityOfCategory2014 FLOAT
SET @TotalQuanaityOfCategory2014 = (SELECT COUNT([Category]) as [The Total Quantity of Orders] FROM   [Project4].[dbo].[SuperStore] WHERE [YearOfOrderDate] = 2014)
PRINT @TotalQuanaityOfCategory2014;
WITH QuantityOfOrderByCategory2011 ([Category],[The Quantity of Orders], [% of Order 2011]) AS 
(
	SELECT [Category],[The Quantity of Orders],
			FORMAT([The Quantity of Orders] / @TotalQuanaityOfCategory2011, 'P2') as [% of Orders]
	FROM QuantityOfOrderByCategory(2011,2011)
), QuantityOfOrderByCategory2012 ([Category],[The Quantity of Orders], [% of Order 2012]) AS 
(
	SELECT [Category],[The Quantity of Orders],
			FORMAT([The Quantity of Orders] / @TotalQuanaityOfCategory2012, 'P2') as [% of Orders]
	FROM QuantityOfOrderByCategory(2012,2012)
), QuantityOfOrderByCategory2013 ([Category],[The Quantity of Orders], [% of Order 2013]) AS
(
	SELECT [Category],[The Quantity of Orders],
			FORMAT([The Quantity of Orders] / @TotalQuanaityOfCategory2013, 'P2') as [% of Orders]
	FROM QuantityOfOrderByCategory(2013,2013)
), QuantityOfOrderByCategory2014 ([Category],[The Quantity of Orders], [% of Order 2014]) AS 
(
	SELECT [Category],[The Quantity of Orders],
			FORMAT([The Quantity of Orders] / @TotalQuanaityOfCategory2014, 'P2') as [% of Orders]
	FROM QuantityOfOrderByCategory(2014,2014)
)
SELECT	
	Cat2011.[Category],
	Cat2011.[% of Order 2011],
	Cat2012.[Category],
	Cat2012.[% of Order 2012],
	Cat2013.[Category],
	Cat2013.[% of Order 2013],
	Cat2014.[Category],
	Cat2014.[% of Order 2014]
FROM QuantityOfOrderByCategory2011 Cat2011
	JOIN QuantityOfOrderByCategory2012 Cat2012
		ON Cat2011.[Category] = Cat2012.[Category]
	JOIN QuantityOfOrderByCategory2013 Cat2013
		ON Cat2011.[Category] = Cat2013.[Category]
	JOIN QuantityOfOrderByCategory2014 Cat2014
		ON Cat2011.[Category] = Cat2014.[Category]
ORDER BY Cat2011.[The Quantity of Orders] DESC


--6.a) Sales of Customer by Category 

CREATE PROCEDURE SalesOfCustomerByCategory @Category varchar(30), @StartYear int, @EndYear int
AS
SELECT DISTINCT [Customer Name], [Category], SUM(Sales) OVER (PARTITION BY [Customer Name]) as Sales
FROM [Project4].[dbo].[SuperStore]
WHERE [Category] = @Category AND YearOfOrderDate BETWEEN @StartYear AND @EndYear
ORDER BY Sales DESC
GO

EXEC SalesOfCustomerByCategory @Category = 'Furniture', @StartYear = 2011, @EndYear = 2014;

EXEC SalesOfCustomerByCategory @Category = 'Office Supplies', @StartYear = 2011, @EndYear = 2014;

EXEC SalesOfCustomerByCategory @Category = 'Technology', @StartYear = 2011, @EndYear = 2014;

--6. b) Sales of Customer by Category with Sales greater than Average Sales in all years
CREATE FUNCTION SalesOfCustomerByCategoryGreaterThanAve (
@Category varchar(max)
)
RETURNS TABLE
AS
RETURN
SELECT DISTINCT [Customer Name], 
				[Category],
				SUM(Sales) OVER (PARTITION BY [Customer Name]) as Sales
FROM [Project4].[dbo].[SuperStore]
WHERE [Category] = @Category AND Sales > (SELECT AVG(Sales) FROM [Project4].[dbo].[SuperStore]);

SELECT *
FROM SalesOfCustomerByCategoryGreaterThanAve('Furniture')	
ORDER BY Sales DESC

SELECT *
FROM SalesOfCustomerByCategoryGreaterThanAve('Office Supplies')	
ORDER BY Sales DESC

SELECT *
FROM SalesOfCustomerByCategoryGreaterThanAve('Technology')	
ORDER BY Sales DESC


-- 6.c) TOP 10 Costumer by Category 
DROP PROCEDURE Top10CustomerByCategoryInYears
CREATE PROCEDURE Top10CustomerByCategory @Category varchar(30)
AS
	SELECT DISTINCT TOP 10 WITH TIES
	[Customer Name], 
	[Category], 
	SUM(Sales) OVER (PARTITION BY [Customer Name]) as Sales
	FROM [Project4].[dbo].[SuperStore]
	WHERE [Category] = @Category 
	ORDER BY Sales DESC 
GO

EXEC Top10CustomerByCategory @Category = 'Furniture'
EXEC Top10CustomerByCategory @Category = 'Office Supplies'
EXEC Top10CustomerByCategory @Category = 'Technology'

--6.d) TOP 10 Costumer by Category in all years

CREATE FUNCTION Top10CustomerByCategoryInYear
(
    @Category varchar(MAX),
    @StartYear int,
    @EndYear int
)
RETURNS TABLE
AS RETURN

    WITH L0 AS (
        SELECT @StartYear - 1 + ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS Year
            FROM (VALUES(1),(1),(1),(1),(1),(1),(1),(1),
                        (1),(1),(1),(1),(1),(1),(1),(1),
                        (1),(1),(1),(1),(1),(1),(1),(1),
                        (1),(1),(1),(1),(1),(1),(1),(1)) AS D(c)
    ),
    Years AS (
        SELECT * FROM L0 WHERE Year <= @EndYear
    )
    SELECT
        s.[Customer Name], 
        @Category AS [Category], 
        s.Sales,
        y.Year
    FROM Years y
    CROSS APPLY (
        SELECT TOP 10 WITH TIES
            [Customer Name],
            SUM(Sales) AS Sales
        FROM [Project4].[dbo].[SuperStore] s
        WHERE [Category] = @Category
          AND y.Year = s.YearOfOrderDate
        GROUP BY [Customer Name]
        ORDER BY Sales DESC
    ) s;

GO
--6.e) TOP10 Customer by Category in all years
SELECT *
FROM Top10CustomerByCategoryInYear('Furniture',2011,2014)

SELECT *
FROM Top10CustomerByCategoryInYear('Office Supplies',2011,2014)

SELECT *
FROM Top10CustomerByCategoryInYear('Technology',2011,2014)


-- 6.f) The Ranking of Customer and customers with the greatest and lowest Sales in all categories 
--FURNITURE
CREATE VIEW CustomerOfSalesByFurniture AS 
	SELECT DISTINCT
				[Customer Name],
				[Category], 
				SUM(Sales) OVER (PARTITION BY [Customer Name]) as Sales
	FROM [Project4].[dbo].[SuperStore]
	WHERE [Category] = 'Furniture'
	
SELECT RANK() OVER (PARTITION BY [Category] ORDER BY Sales DESC) AS Ranking, *
FROM CustomerOfSalesByFurniture


-- TECHNOLOGY
CREATE VIEW CustomerOfSalesByTechnology AS 
	SELECT DISTINCT
				[Customer Name],
				[Category], 
				SUM(Sales) OVER (PARTITION BY [Customer Name]) as Sales
	FROM [Project4].[dbo].[SuperStore]
	WHERE [Category] = 'Technology'
	
SELECT RANK() OVER (PARTITION BY [Category] ORDER BY Sales DESC) AS Ranking, *
FROM CustomerOfSalesByTechnology


-- OFFICE SUPPLIES
CREATE VIEW CustomerOfSalesByOfficeSupplies AS 
	SELECT DISTINCT
				[Customer Name],
				[Category], 
				SUM(Sales) OVER (PARTITION BY [Customer Name]) as Sales
	FROM [Project4].[dbo].[SuperStore]
	WHERE [Category] = 'Office Supplies'
	
SELECT RANK() OVER (PARTITION BY [Category] ORDER BY Sales DESC) AS Ranking, *
FROM CustomerOfSalesByOfficeSupplies

--6.g) Customers with the greatest & lowest Sales by all categories

		SELECT DISTINCT [Category], FIRST_VALUE([Customer Name]) OVER(PARTITION BY [Category] ORDER BY Sales DESC) AS [Customer with the greatest Sales by Category],
		MAX(Sales) OVER (PARTITION BY [Category]) as [Sales by Category],
		LAST_VALUE([Customer Name]) OVER(PARTITION BY [Category] ORDER BY Sales DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) AS [Customer with the lowest Sales by Category],
		MIN(Sales) OVER (PARTITION BY [Category]) as [Sales by Category]
		FROM CustomerOfSalesByFurniture
UNION
		SELECT DISTINCT [Category], FIRST_VALUE([Customer Name]) OVER(PARTITION BY [Category] ORDER BY Sales DESC) AS [Customer with the greatest Sales by Category],
		MAX(Sales) OVER (PARTITION BY [Category]) as [Sales by Category],
		LAST_VALUE([Customer Name]) OVER(PARTITION BY [Category] ORDER BY Sales DESC 
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) AS [Customer with the lowest Sales by Category],
		MIN(Sales) OVER (PARTITION BY [Category]) as [Sales by Category]
		FROM CustomerOfSalesByOfficeSupplies
UNION
		SELECT DISTINCT [Category], FIRST_VALUE([Customer Name]) OVER(PARTITION BY [Category] ORDER BY Sales DESC) AS [Customer with the greatest Sales by Category],
		MAX(Sales) OVER (PARTITION BY [Category]) as [Sales by Category],
		LAST_VALUE([Customer Name]) OVER(PARTITION BY [Category] ORDER BY Sales DESC	
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) AS [Customer with the lowest Sales by Category],
		MIN(Sales) OVER (PARTITION BY [Category]) as [Sales By Category]
FROM CustomerOfSalesByTechnology


--6h) The Group of Customer by Categories

--FURNITURE
WITH GroupOfCustomerByFurniture AS (
	SELECT *, NTILE(3) OVER (ORDER BY Sales DESC) as [Group of Customer]
	FROM CustomerOfSalesByFurniture
)
SELECT [Customer Name],
CASE 
	WHEN [Group of Customer] = 1 Then 'High Sales in Furniture'
	WHEN [Group of Customer] = 2 Then 'Mid Sales in Furniture'
	WHEN [Group of Customer] = 3 Then 'Low Sales in Furniture'
		END AS [Level of Sales in Furniture]
FROM GroupOfCustomerByFurniture

-- OFFICE SUPPLIES
WITH GroupOfCustomerByOfficeSupplies AS (
	SELECT *, NTILE(3) OVER (ORDER BY Sales DESC) as [Group of Customer]
	FROM CustomerOfSalesByOfficeSupplies
)
SELECT [Customer Name],
CASE 
	WHEN [Group of Customer] = 1 Then 'High Sales in Office Supplies'
	WHEN [Group of Customer] = 2 Then 'Mid Sales in Office Supplies'
	WHEN [Group of Customer] = 3 Then 'Low Sales in Office Supplies'
		END AS [Level of Sales in Office Supplies]
FROM GroupOfCustomerByOfficeSupplies;

--Technology
WITH GroupofCustomerByTechnology AS (
	SELECT *, NTILE(3) OVER (ORDER BY Sales DESC) as [Group of Customer]
	FROM CustomerOfSalesByTechnology
)
SELECT [Customer Name],
CASE 
	WHEN [Group of Customer] = 1 Then 'High Sales in Technology'
	WHEN [Group of Customer] = 2 Then 'Mid Sales in Technology'
	WHEN [Group of Customer] = 3 Then 'Low Sales in Technology'
		END AS [Level of Sales in Technology]
FROM GroupofCustomerByTechnology

--7a). Quantity of Orders by Ship Mode 
SELECT DISTINCT [Ship Mode], count(*) OVER (PARTITION BY [Ship Mode]) as [The Quantity of Orders]
FROM   [Project4].[dbo].[SuperStore]
ORDER BY [The Quantity of Orders] DESC
--7b) A table valued function was used to return the data of the Quantity of Orders by Ship Mode 
CREATE FUNCTION [Quantity of Orders by Ship Mode]
(
	@YearOfOrderDate int
)
RETURNS TABLE
AS
RETURN
	SELECT DISTINCT [Ship Mode], count(*) OVER (PARTITION BY [Ship Mode]) as [The Quantity of Orders]
	FROM   [Project4].[dbo].[SuperStore]
	WHERE YearOfOrderDate = @YearOfOrderDate;



--7c). The Quantity of Orders by Ship Mode year by year
--2011
SELECT *
FROM [Quantity of Orders by Ship Mode](2011)
ORDER BY [The Quantity of Orders] DESC
--2012
SELECT *
FROM [Quantity of Orders by Ship Mode](2012)
ORDER BY [The Quantity of Orders] DESC
--2013
SELECT *
FROM [Quantity of Orders by Ship Mode](2013)
ORDER BY [The Quantity of Orders] DESC
--2014
SELECT *
FROM [Quantity of Orders by Ship Mode](2014)
ORDER BY [The Quantity of Orders] DESC

--7d). The Percentage Quantity of Orders by Ship Mode in all years
CREATE VIEW PercentageQuantityOfOrdersByShipMode AS 
	SELECT DISTINCT [Ship Mode], count(*) OVER (PARTITION BY [Ship Mode]) as [The Quantity of Orders]
	FROM   [Project4].[dbo].[SuperStore]

DECLARE @SumOfQuanaityOfOrders FLOAT
SET  @SumOfQuanaityOfOrders = (SELECT SUM([The Quantity of Orders]) FROM  PercentageQuantityOfOrdersByShipMode )
PRINT @SumOfQuanaityOfOrders
SELECT [Ship Mode], FORMAT(([The Quantity Of Orders] / @SumOfQuanaityOfOrders) , 'P2') as [The percentage of the quantity of Orderds by Ship Mode]
FROM PercentageQuantityOfOrdersByShipMode
ORDER BY [The Quantity Of Orders] DESC


--7.e) The Percentage Quantity of Orders by Ship Mode Year by Year
DECLARE @SumOfQuantityOrders2011 FLOAT
SET @SumOfQuantityOrders2011 = (SELECT SUM([The Quantity of Orders]) FROM [Quantity of Orders by Ship Mode](2011))
PRINT @SumOfQuantityOrders2011

DECLARE @SumOfQuantityOrders2012 FLOAT
SET @SumOfQuantityOrders2012 = (SELECT SUM([The Quantity of Orders]) FROM [Quantity of Orders by Ship Mode](2012))
PRINT @SumOfQuantityOrders2012

DECLARE @SumOfQuantityOrders2013 FLOAT
SET @SumOfQuantityOrders2013 = (SELECT SUM([The Quantity of Orders]) FROM [Quantity of Orders by Ship Mode](2013))
PRINT @SumOfQuantityOrders2013

DECLARE @SumOfQuantityOrders2014 FLOAT
SET @SumOfQuantityOrders2014 = (SELECT SUM([The Quantity of Orders]) FROM [Quantity of Orders by Ship Mode](2014))
PRINT @SumOfQuantityOrders2014;

WITH PercentageQuantityOfOrderByShipMode2011  AS
(
	SELECT [Ship Mode], [The Quantity of Orders], FORMAT(([The Quantity of Orders] / @SumOfQuantityOrders2011) , 'P2') as [The Percentage Quantity of Orders by Ship Mode]
	FROM [Quantity of Orders by Ship Mode](2011)
), PercentageQuantityOfOrderByShipMode2012 AS 
(
	SELECT [Ship Mode],[The Quantity of Orders], FORMAT(([The Quantity of Orders] / @SumOfQuantityOrders2012) , 'P2') as [The Percentage Quantity of Orders by Ship Mode]
	FROM [Quantity of Orders by Ship Mode](2012)
), PercentageQuantityOfOrderByShipMode2013 AS 
(
	SELECT [Ship Mode],[The Quantity of Orders], FORMAT(([The Quantity of Orders] / @SumOfQuantityOrders2013) , 'P2') as [The Percentage Quantity of Orders by Ship Mode]
	FROM [Quantity of Orders by Ship Mode](2013)
), PercentageQuantityOfOrderByShipMode2014 AS 
(
SELECT [Ship Mode],[The Quantity of Orders], FORMAT(([The Quantity of Orders] / @SumOfQuantityOrders2014) , 'P2') as [The Percentage Quantity of Orders by Ship Mode]
	FROM [Quantity of Orders by Ship Mode](2014)
)
SELECT S2011.[Ship Mode], S2011.[The Percentage Quantity of Orders by Ship Mode] as [The Percentage Quantity of Orders by Ship Mode 2011],
	 S2012.[The Percentage Quantity of Orders by Ship Mode] as [The Percentage Quantity of Orders by Ship Mode 2012],
	 S2013.[The Percentage Quantity of Orders by Ship Mode]  as [The Percentage Quantity of Orders by Ship Mode 2013],
	S2014.[The Percentage Quantity of Orders by Ship Mode] as [The Percentage Quantity of Orders by Ship Mode 2014]
FROM PercentageQuantityOfOrderByShipMode2011 S2011
	LEFT JOIN PercentageQuantityOfOrderByShipMode2012 S2012
		ON S2011.[Ship Mode] = S2012.[Ship Mode]
	LEFT JOIN PercentageQuantityOfOrderByShipMode2013 S2013
		ON S2011.[Ship Mode] = S2013.[Ship Mode]
	LEFT JOIN PercentageQuantityOfOrderByShipMode2014 S2014
		ON S2011.[Ship Mode] = S2014.[Ship Mode]
ORDER BY S2011.[The Quantity of Orders] DESC



-- 7. f) The quantity of Shipe Mode by Customer in all years
DROP PROCEDURE TheQuantityOfShipModeByCustomer
CREATE PROCEDURE TheQuantityOfShipModeByCustomer @ShipMode nvarchar(MAX), @StartYear int, @EndYear int
AS 
	SELECT DISTINCT [Customer Name], [Ship Mode], COUNT([Ship Mode]) OVER (PARTITION BY [Customer Name]) as [Quantity of Ship Mode]
	FROM [Project4].[dbo].[SuperStore]
	WHERE [Ship Mode] = @ShipMode AND YearOfOrderDate BETWEEN @StartYear AND @EndYear
	ORDER BY [Quantity of Ship Mode] DESC
GO:

EXEC TheQuantityOfShipModeByCustomer @ShipMode = 'Standard Class', @StartYear = 2011, @EndYear = 2014
EXEC TheQuantityOfShipModeByCustomer @ShipMode = 'Second Class', @StartYear = 2011, @EndYear = 2014
EXEC TheQuantityOfShipModeByCustomer @ShipMode = 'First Class', @StartYear = 2011, @EndYear = 2014
EXEC TheQuantityOfShipModeByCustomer @ShipMode = 'Same Day', @StartYear = 2011, @EndYear = 2014

--7. g) The Sales of Ship Mode, The Quantity of Orders of Ship Mode by Customer
--The Sales of Ship Mode by Customer 
CREATE PROCEDURE SalesOfShipModeByCustomer @ShipMode nvarchar(30), @StartYear int, @EndYear int
AS
	SELECT [Customer Name], SUM([Sales]) OVER (PARTITION BY [Sales]) as [Sales]
	FROM [Project4].[dbo].[SuperStore]
	WHERE [Ship Mode] = @ShipMode AND  YearOfOrderDate BETWEEN @StartYear AND @EndYear
	ORDER BY [Sales] DESC
GO

EXEC SalesOfShipModeByCustomer @ShipMode = 'Standard Class', @StartYear = 2011, @EndYear = 2014
EXEC SalesOfShipModeByCustomer @ShipMode = 'Second Class', @StartYear = 2011, @EndYear = 2014
EXEC SalesOfShipModeByCustomer @ShipMode = 'First Class', @StartYear = 2011, @EndYear = 2014
EXEC SalesOfShipModeByCustomer @ShipMode = 'Same Day', @StartYear = 2011, @EndYear = 2014

-- 7. h) Quantity of Orders by Customer in Ship Mode
DROP FUNCTION QuantityOfShipModeByCustomer
CREATE FUNCTION QuantityOfShipModeByCustomer 
(
	@ShipMode nvarchar(MAX),
	@StartYear int,
	@EndYear int

)
RETURNS TABLE
AS
RETURN
		SELECT DISTINCT [Customer Name],[Ship Mode], [YearOfOrderDate], COUNT([Ship Mode]) OVER (PARTITION BY [Customer Name]) as [Quantity of Ship Mode]
		FROM [Project4].[dbo].[SuperStore]
		WHERE [Ship Mode] = @ShipMode 
			AND  [YearOfOrderDate]  BETWEEN @StartYear AND @EndYear 

-- Quantity of Orders by Customer in Standard Class
SELECT DISTINCT [Customer Name],[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Standard Class', 2011, 2014)
ORDER BY [Quantity of Ship Mode] DESC

-- Quantity of Orders by Customer in Second Class
SELECT DISTINCT [Customer Name],[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Second Class', 2011, 2014)
ORDER BY [Quantity of Ship Mode] DESC

-- Quantity of Orders by Customer in First Class
SELECT DISTINCT [Customer Name],[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('First Class', 2011, 2014)
ORDER BY [Quantity of Ship Mode] DESC

-- Quantity of Orders by Customer in Same Day
SELECT DISTINCT [Customer Name],[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Same Day', 2011, 2014)
ORDER BY [Quantity of Ship Mode] DESC

--7. i) The whole Quantity of Orders by Customer in Ship Mode
SELECT DISTINCT [Customer Name],[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Standard Class', 2011, 2014)
UNION
SELECT DISTINCT [Customer Name],[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Second Class', 2011, 2014)
UNION
SELECT DISTINCT [Customer Name],[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('First Class', 2011, 2014)
UNION
SELECT DISTINCT [Customer Name],[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Same Day', 2011, 2014)
ORDER BY [Ship Mode] DESC, [Quantity of Ship Mode] DESC


-- 7. j) Quantity of Orders by Customer in Standard Classs in a year
--2011
SELECT DISTINCT [Customer Name],[YearOfOrderDate] as Year,[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Standard Class', 2011, 2011)
ORDER BY [Quantity of Ship Mode] DESC
--2012
SELECT DISTINCT [Customer Name],[YearOfOrderDate] as Year,[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Standard Class', 2012, 2012)
ORDER BY [Quantity of Ship Mode] DESC
--2013
SELECT DISTINCT [Customer Name],[YearOfOrderDate] as Year,[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Standard Class', 2013, 2013)
ORDER BY [Quantity of Ship Mode] DESC
--2014
SELECT DISTINCT [Customer Name],[YearOfOrderDate] as Year,[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Standard Class', 2014, 2014)
ORDER BY [Quantity of Ship Mode] DESC


-- 7. k) Quantity of Orders by Customer in Second Class in a year
--2011
SELECT DISTINCT [Customer Name],[YearOfOrderDate] as Year,[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Second Class', 2011, 2011)
ORDER BY [Quantity of Ship Mode] DESC
--2012
SELECT DISTINCT [Customer Name],[YearOfOrderDate] as Year,[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Second Class', 2012, 2012)
ORDER BY [Quantity of Ship Mode] DESC
--2013
SELECT DISTINCT [Customer Name],[YearOfOrderDate] as Year,[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Second Class', 2013, 2013)
ORDER BY [Quantity of Ship Mode] DESC
--2014
SELECT DISTINCT [Customer Name],[YearOfOrderDate] as Year,[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Second Class', 2014, 2014)
ORDER BY [Quantity of Ship Mode] DESC

-- 7. l) Quantity of Orders by Customer in First Class in a year
--2011
SELECT DISTINCT [Customer Name],[YearOfOrderDate] as Year,[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('First Class', 2011, 2011)
ORDER BY [Quantity of Ship Mode] DESC
--2012
SELECT DISTINCT [Customer Name],[YearOfOrderDate] as Year,[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('First Class', 2012, 2012)
ORDER BY [Quantity of Ship Mode] DESC
--2013
SELECT DISTINCT [Customer Name],[YearOfOrderDate] as Year,[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('First Class', 2013, 2013)
ORDER BY [Quantity of Ship Mode] DESC
--2014
SELECT DISTINCT [Customer Name],[YearOfOrderDate] as Year,[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('First Class', 2014, 2014)
ORDER BY [Quantity of Ship Mode] DESC

--7. m) Quantity of Orders by Customer in First Class in a year
--2011
SELECT DISTINCT [Customer Name],[YearOfOrderDate] as Year,[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Same Day', 2011, 2011)
ORDER BY [Quantity of Ship Mode] DESC
--2012
SELECT DISTINCT [Customer Name],[YearOfOrderDate] as Year,[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Same Day', 2012, 2012)
ORDER BY [Quantity of Ship Mode] DESC
--2013
SELECT DISTINCT [Customer Name],[YearOfOrderDate] as Year,[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Same Day', 2013, 2013)
ORDER BY [Quantity of Ship Mode] DESC
--2014
SELECT DISTINCT [Customer Name],[YearOfOrderDate] as Year,[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Same Day', 2014, 2014)
ORDER BY [Quantity of Ship Mode] DESC

--
--7. n) Greatest and Lowest Quantity of Orders of Ship Mode by Customers
SELECT DISTINCT [Ship Mode],
			FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Quantity of Ship Mode] DESC) as [Customer with greatest quantity of Order by Ship Mode], 
			MAX([Quantity of Ship Mode]) OVER (PARTITION BY [Ship Mode]) as [Quantity of Ship Mode],
			LAST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Quantity of Ship Mode] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the lowest quantity of Order by Ship Mode],
			MIN([Quantity of Ship Mode]) OVER (PARTITION BY [Ship Mode]) as [Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Standard Class', 2011, 2014)
UNION
SELECT DISTINCT [Ship Mode],
			FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Quantity of Ship Mode] DESC) as [Customer with greatest quantity of Order by Ship Mode], 
			MAX([Quantity of Ship Mode]) OVER (PARTITION BY [Ship Mode]) as [Quantity of Ship Mode],
			LAST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Quantity of Ship Mode] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the lowest quantity of Order by Ship Mode],
			MIN([Quantity of Ship Mode]) OVER (PARTITION BY [Ship Mode]) as [Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Second Class', 2011, 2014)
UNION
SELECT DISTINCT [Ship Mode],
				FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Quantity of Ship Mode] DESC) as [Customer with greatest quantity of Order by Ship Mode], 
			MAX([Quantity of Ship Mode]) OVER (PARTITION BY [Ship Mode]) as [Quantity of Ship Mode],
			LAST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Quantity of Ship Mode] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the lowest quantity of Order by Ship Mode],
			MIN([Quantity of Ship Mode]) OVER (PARTITION BY [Ship Mode]) as [Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('First Class', 2011, 2014)
UNION
SELECT DISTINCT [Ship Mode],
			FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Quantity of Ship Mode] DESC) as [Customer with greatest quantity of Order by Ship Mode], 
			MAX([Quantity of Ship Mode]) OVER (PARTITION BY [Ship Mode]) as [Quantity of Ship Mode],
			LAST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Quantity of Ship Mode] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the lowest quantity of Order by Ship Mode],
			MIN([Quantity of Ship Mode]) OVER (PARTITION BY [Ship Mode]) as [Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Same Day', 2011, 2014)



-- 7.o)Greatest and Lowest Sales of Ship Mode by Customers
--CREATE VIEW TO STORE THE QUERY
CREATE VIEW SalesOfCustomerByStandardClass AS 
	SELECT DISTINCT [Customer Name],[Ship Mode], SUM([Sales]) OVER (PARTITION BY [Customer Name]) as [Sales]
	FROM [Project4].[dbo].[SuperStore]
	WHERE [Ship Mode] = 'Standard Class' 
	

CREATE VIEW SalesOfCustomerBySecondClass AS 
	SELECT DISTINCT [Customer Name],[Ship Mode], SUM([Sales]) OVER (PARTITION BY [Customer Name]) as [Sales]
	FROM [Project4].[dbo].[SuperStore]
	WHERE [Ship Mode] = 'Second Class'

CREATE VIEW SalesOfCustomerByFirstClass AS 
	SELECT DISTINCT [Customer Name],[Ship Mode], SUM([Sales]) OVER (PARTITION BY [Customer Name]) as [Sales]
	FROM [Project4].[dbo].[SuperStore]
	WHERE [Ship Mode] = 'First Class'

CREATE VIEW SalesOfCustomerBySameDay AS 
	SELECT DISTINCT [Customer Name],[Ship Mode], SUM([Sales]) OVER (PARTITION BY [Customer Name]) as [Sales]
	FROM [Project4].[dbo].[SuperStore]
	WHERE [Ship Mode] = 'Same Day'

-- CREATE CTE TO COMBINE ALL VIEW TABLES IN ONE TABLE
WITH MaxSalesOfCustomerByShipMode AS (
SELECT DISTINCT [Ship Mode], FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Sales] DESC) as [Customer with the greatest Sales by Ship Mode],
				MAX([Sales]) OVER (PARTITION BY [Ship Mode]) as [Sales]
FROM SalesOfCustomerByStandardClass
UNION
SELECT DISTINCT [Ship Mode], FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Sales] DESC) as [Customer with the greatest Sales by Ship Mode],
				MAX([Sales]) OVER (PARTITION BY [Ship Mode]) as [Sales]
FROM SalesOfCustomerBySecondClass
UNION
SELECT DISTINCT [Ship Mode], FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Sales] DESC) as [Customer with the greatest Sales by Ship Mode],
				MAX([Sales]) OVER (PARTITION BY [Ship Mode]) as [Sales]
FROM SalesOfCustomerByFirstClass
UNION
SELECT DISTINCT [Ship Mode], FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Sales] DESC) as [Customer with the greatest Sales by Ship Mode],
				MAX([Sales]) OVER (PARTITION BY [Ship Mode]) as [Sales]
FROM SalesOfCustomerBySameDay
), MinSalesOfCustomerByShipMode AS (
SELECT DISTINCT [Ship Mode],
			LAST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Sales] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the lowest Sales by Ship Mode],
			MIN([Sales]) OVER (PARTITION BY [Ship Mode]) as [Sales]
FROM SalesOfCustomerByStandardClass
UNION
SELECT DISTINCT [Ship Mode],
			LAST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Sales] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the lowest Sales by Ship Mode],
			MIN([Sales]) OVER (PARTITION BY [Ship Mode]) as [Sales]
FROM SalesOfCustomerBySecondClass
UNION
SELECT DISTINCT [Ship Mode],
			LAST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Sales] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the lowest Sales by Ship Mode],
			MIN([Sales]) OVER (PARTITION BY [Ship Mode]) as [Sales]
FROM SalesOfCustomerByFirstClass
UNION
SELECT DISTINCT [Ship Mode],
			LAST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Sales] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the lowest Sales by Ship Mode],
			MIN([Sales]) OVER (PARTITION BY [Ship Mode]) as [Sales]
FROM SalesOfCustomerBySameDay
)
SELECT *
FROM MaxSalesOfCustomerByShipMode
	JOIN MinSalesOfCustomerByShipMode
		ON MaxSalesOfCustomerByShipMode.[Ship Mode] = MinSalesOfCustomerByShipMode.[Ship Mode]


/*
PROFIT

*/
--1.a) Profit of Customer
CREATE VIEW CustomerOfProfit AS 
	SELECT DISTINCT  [Customer Name], 
			SUM([Profit]) OVER (PARTITION BY [Customer Name]) as Profit
	FROM [Project4].[dbo].[SuperStore]
	WHERE [Profit] >= 1
	--
--1.b) The Ranking of Customer of Profit
SELECT rank() OVER (ORDER BY [Profit] DESC) as  Ranking, *
FROM CustomerOfProfit
ORDER BY Profit DESC
-- 1.c) Customer of Profit greater than average profit

SELECT DISTINCT [Customer Name], SUM([Profit]) OVER (PARTITION BY [Customer Name]) as [Profit]
FROM [Project4].[dbo].[SuperStore]
WHERE [Profit] > (SELECT AVG([Profit]) FROM [Project4].[dbo].[SuperStore])
ORDER BY [Profit] DESC

-- 1.d) Customer with greatest and lowest Profit
WITH CustomerWithGreatestandLowestProfit ([Customer Name],[Profit],[Customer with the greatest Profit],[Customer with the lowest Profit])  AS 
(
	SELECT  DISTINCT [Customer Name], [Profit], 
					FIRST_VALUE([Customer Name]) OVER (ORDER BY [Profit] DESC) as [Customer with the greatest Profit],
					LAST_VALUE([Customer Name]) OVER (ORDER BY [Profit] DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS [Customer with the lowest Profit]
	FROM CustomerOfProfit
)
SELECT DISTINCT [Customer with the greatest Profit], [Customer with the lowest Profit]
FROM CustomerWithGreatestandLowestProfit
-- 1.e) . TOP 10 Customer of Profit:
SELECT DISTINCT TOP 10 with TIES [Customer Name], 
		SUM([Profit]) OVER (PARTITION BY [Customer Name]) as Profit
FROM [Project4].[dbo].[SuperStore]
ORDER BY Profit DESC

-- 1.f). Grouping of Customer by buckets (high Mid and low Profit )
DROP TABLE IF EXISTS #GroupOfCustomer
CREATE TABLE #GroupOfCustomer (
[Customer Name] nvarchar(MAX),
[Profit] int
)

INSERT INTO #GroupOfCustomer
	SELECT DISTINCT  [Customer Name], 
			SUM([Profit]) OVER (PARTITION BY [Customer Name]) as Profit
	FROM [Project4].[dbo].[SuperStore]
	WHERE [Profit] >= 1
	ORDER BY Profit DESC
-- Group of Customer by three levels
WITH GroupOfCustomer AS (
	SELECT *, NTILE(3) OVER (ORDER BY [Profit] DESC) as Buckets
	FROM #GroupOfCustomer
)
SELECT [Customer Name], 
	CASE
		WHEN [Buckets] = 1 THEN 'High Profit'
		WHEN [Buckets] = 2 THEN 'Mid Profit'
		WHEN [Buckets] = 3 THEN 'Low Profit'
	END AS [Level of Profit]
FROM GroupOfCustomer

-- 1.g) Group of Customer by Segment by three levels
CREATE FUNCTION GroupOfCustomerOfProfitBySegment
(
 @Segment nvarchar(MAX)
)
RETURNS TABLE
AS RETURN
		SELECT DISTINCT 
			[Customer Name], 
			SUM([Profit]) OVER (PARTITION BY [Customer Name]) as Profit
			FROM [Project4].[dbo].[SuperStore]
			WHERE [Profit] >= 1 AND [Segment] = @Segment

-- Group of Customer of Profit by Corporate
WITH GroupOfCustomerOfProfitByCorporate AS (
	SELECT *, NTILE(3) OVER (ORDER BY [Profit] DESC) as Buckets		
	FROM GroupOfCustomerOfProfitBySegment('Corporate')

)
SELECT [Customer Name],
		CASE	
			WHEN Buckets = 1 THEN 'High Profit'
			WHEN Buckets = 2 THEN 'Mid Profit'
			WHEN Buckets = 3 THEN 'Low Profit'
			END AS 'Level of Profit'
FROM GroupOfCustomerOfProfitByCorporate



-- Group of Customer of Profit by Consumer
WITH GroupOfCustomerOfProfitByConsumer AS (
	SELECT *, NTILE(3) OVER (ORDER BY [Profit] DESC) as Buckets		
	FROM GroupOfCustomerOfProfitBySegment('Consumer')

)
SELECT [Customer Name],
		CASE	
			WHEN Buckets = 1 THEN 'High Profit'
			WHEN Buckets = 2 THEN 'Mid Profit'
			WHEN Buckets = 3 THEN 'Low Profit'
			END AS 'Level of Profit'
FROM GroupOfCustomerOfProfitByConsumer

-- Group of Customer of Profit by Home Office
WITH GroupOfCustomerOfProfitByHomeOffice AS (
	SELECT *, NTILE(3) OVER (ORDER BY [Profit] DESC) as Buckets		
	FROM GroupOfCustomerOfProfitBySegment('Home Office')

)
SELECT [Customer Name],
		CASE	
			WHEN Buckets = 1 THEN 'High Profit'
			WHEN Buckets = 2 THEN 'Mid Profit'
			WHEN Buckets = 3 THEN 'Low Profit'
			END AS 'Level of Profit'
FROM GroupOfCustomerOfProfitByHomeOffice


--2.a) TOP 10 Customer by Segment

CREATE PROCEDURE TOP10CustomerBySegment @Segment nvarchar(MAX)
AS
	SELECT DISTINCT TOP 10 with TIES [Customer Name], 
			SUM([Profit]) OVER (PARTITION BY [Customer Name]) as Profit
	FROM [Project4].[dbo].[SuperStore]
	WHERE Segment = @Segment
	ORDER BY Profit DESC


EXEC TOP10CustomerBySegment @Segment = 'Corporate'
EXEC TOP10CustomerBySegment @Segment = 'Consumer'
EXEC TOP10CustomerBySegment @Segment = 'Home Office'


--2. b) Profit of Segment by Customer

--CREATE A Table-Valued function to return the data  of all customers by all segments
CREATE FUNCTION ProfitOfCustomerBySegment
(
	@Segment varchar(max),
	@StartYear int,
	@EndYear int
)
RETURNS TABLE
AS
RETURN
	SELECT DISTINCT  [Customer Name],
					[Segment], 
					SUM([Profit]) OVER (PARTITION BY [Customer Name]) AS Profit
	FROM   [Project4].[dbo].[SuperStore]
	WHERE Segment = @Segment AND YearOfOrderDate BETWEEN @StartYear AND @EndYear
	
-- 2.c) Customer of Profit by Segment greater  than average profit
--Corporate
SELECT *
FROM ProfitOfCustomerBySegment('Corporate',2011,2014)
WHERE Profit > (SELECT AVG([Profit])  FROM [Project4].[dbo].[SuperStore])
ORDER BY Profit DESC
-- Consumer
SELECT *
FROM ProfitOfCustomerBySegment('Consumer',2011,2014)
WHERE Profit > (SELECT AVG([Profit])  FROM [Project4].[dbo].[SuperStore])
ORDER BY Profit DESC
-- Home Office
SELECT *
FROM ProfitOfCustomerBySegment('Home Office',2011,2014)
WHERE Profit > (SELECT AVG([Profit])  FROM [Project4].[dbo].[SuperStore])
ORDER BY Profit DESC
-

--2.d) CREATE A VIEW TABLE to calculate Cumulative distrubtion of Customer by Profit and the ranking
CREATE VIEW ProfitOfCustomerByCorporate AS 
	SELECT *
	FROM ProfitOfCustomerBySegment('Corporate',2011,2014)
-- 2.e) The Ranking of Customer of Profit by Corporate
SELECT rank() OVER (PARTITION BY [Segment] ORDER BY [Profit] DESC) AS Ranking, *
FROM ProfitOfCustomerByCorporate

--2.f) Cumulative distrubtion of Customer of Profit
SELECT [Customer Name], 
		[Profit], 
		FORMAT(CUME_DIST() OVER (ORDER BY [Profit] DESC), 'P2') as [Cumulative distribution]
FROM ProfitOfCustomerByCorporate
--2.g) Customer with Profit by Corporate
With CustomerGeneratesProfit AS 
(
SELECT [Customer Name], 
		[Profit], 
		FORMAT(CUME_DIST() OVER (ORDER BY [Profit] DESC), 'P2') as [Cumulative distribution]
FROM ProfitOfCustomerByCorporate
)
SELECT *
FROM CustomerGeneratesProfit
WHERE [Profit] >= 1

-- 2.h) Customer without Profit by Corporate
With CustomerWithoutProfit AS 
(
SELECT [Customer Name], 
		[Profit], 
		FORMAT(CUME_DIST() OVER (ORDER BY [Profit] DESC), 'P2') as [Cumulative distribution]
FROM ProfitOfCustomerByCorporate
)
SELECT *
FROM CustomerWithoutProfit
WHERE [Profit] <= 0


-- 2.i) Profit of Customer  by Corporate year by year
--2011
SELECT *
FROM ProfitOfCustomerBySegment('Corporate',2011,2011)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2012
SELECT *
FROM ProfitOfCustomerBySegment('Corporate',2012,2012)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2013
SELECT *
FROM ProfitOfCustomerBySegment('Corporate',2013,2013)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2014
SELECT *
FROM ProfitOfCustomerBySegment('Corporate',2014,2014)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
-- 2.j) Profit of Customer by Consumer
--Consumer
CREATE VIEW ProfitOfCustomerByConsumer AS 
	SELECT *
	FROM ProfitOfCustomerBySegment('Consumer',2011,2014)


-- 2.k) The Ranking of Customer of Profit by Consumer
SELECT rank() OVER (PARTITION BY [Segment] ORDER BY [Profit] DESC) as Ranking,*
FROM ProfitOfCustomerByConsumer
WHERE [Profit] >= 1
ORDER BY [Profit] DESC


-- 2.l) Cumulative distrubtion of Customer by Consumer
SELECT [Customer Name], 
		[Profit], 
		FORMAT(CUME_DIST() OVER (ORDER BY [Profit] DESC), 'P2') as [Cumulative distribution]
FROM ProfitOfCustomerByConsumer


--  2.m) Customer with Profit by Consumer
With CustomerGeneratesProfit AS 
(
SELECT [Customer Name], 
		[Profit], 
		FORMAT(CUME_DIST() OVER (ORDER BY [Profit] DESC), 'P2') as [Cumulative distribution]
FROM ProfitOfCustomerByConsumer
)
SELECT *
FROM CustomerGeneratesProfit
WHERE [Profit] >= 1

-- 2.n) Customer without Profit by Consumer

With CustomerWithoutProfit AS 
(
SELECT [Customer Name], 
		[Profit], 
		FORMAT(CUME_DIST() OVER (ORDER BY [Profit] DESC), 'P2') as [Cumulative distribution]
FROM ProfitOfCustomerByConsumer
)
SELECT *
FROM CustomerWithoutProfit
WHERE [Profit] <= 0

-- 2.o) Profit of Customer  by Consumer year by year
--2011
SELECT *
FROM ProfitOfCustomerBySegment('Consumer',2011,2011)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2012
SELECT *
FROM ProfitOfCustomerBySegment('Consumer',2012,2012)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2013
SELECT *
FROM ProfitOfCustomerBySegment('Consumer',2013,2013)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2014
SELECT *
FROM ProfitOfCustomerBySegment('Consumer',2014,2014)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC

---- 2.p) Profit of Customer by  Home Office
CREATE VIEW ProfitOfCustomerByHomeOffice AS 
	SELECT *
	FROM ProfitOfCustomerBySegment('Home Office',2011,2014)

--2.q) The Ranking of Customer of Profit by Home Office
SELECT RANK() OVER (PARTITION BY [Segment] ORDER BY [Profit] DESC) as Ranking,*
FROM ProfitOfCustomerByHomeOffice
WHERE [Profit] >= 1
ORDER BY [Profit] DESC

-- 2.r) Cumulative distrubtion of Customer by Home Office

SELECT [Customer Name], 
		[Profit], 
		FORMAT(CUME_DIST() OVER (ORDER BY [Profit] DESC), 'P2') as [Cumulative distribution]
FROM ProfitOfCustomerByHomeOffice 

-- 2.s) Customer with Profit by Home Office
With CustomerGeneratesProfit AS 
(
SELECT [Customer Name], 
		[Profit], 
		FORMAT(CUME_DIST() OVER (ORDER BY [Profit] DESC), 'P2') as [Cumulative distribution]
FROM ProfitOfCustomerByHomeOffice 
)
SELECT *
FROM CustomerGeneratesProfit
WHERE [Profit] >= 1

-- 2.t) Customer without Profit by Home Office

With CustomerWithoutProfit AS 
(
SELECT [Customer Name], 
		[Profit], 
		FORMAT(CUME_DIST() OVER (ORDER BY [Profit] DESC), 'P2') as [Cumulative distribution]
FROM ProfitOfCustomerByHomeOffice 
)
SELECT *
FROM CustomerWithoutProfit
WHERE [Profit] <= 0

-- 2. u)  Profit of Customer  by Home Office year by year
--2011
SELECT *
FROM ProfitOfCustomerBySegment('Home Office',2011,2011)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2012
SELECT *
FROM ProfitOfCustomerBySegment('Home Office',2012,2012)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2013
SELECT *
FROM ProfitOfCustomerBySegment('Home Office',2013,2013)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2014
SELECT *
FROM ProfitOfCustomerBySegment('Home Office',2014,2014)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC


--2.v)  Customer with the greatest Profit and Lowest Profit by Corporate, Consumer and Home Office Segmentsin all years
SELECT DISTINCT [Segment], FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Segment] ORDER BY [Profit] DESC) as [Customer with the greatest Profit by Corporate],
			MAX([Profit]) OVER (PARTITION BY [Segment]) as [Profit],
			LAST_VALUE([Customer Name]) OVER (PARTITION BY [Segment] ORDER BY [Profit] DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) as [Customer with the lowest Profit by Corporate],
			MIN([Profit]) OVER (PARTITION BY [Segment]) as [Profit]	
FROM ProfitOfCustomerByCorporate
WHERE [Profit] >= 1
UNION
SELECT DISTINCT [Segment], 
		FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Segment] ORDER BY [Profit] DESC) as [Customer with the greatest Profit by Consumer],
		MAX([Profit]) OVER (PARTITION BY [Segment]) as [Profit],
		LAST_VALUE([Customer Name]) OVER (PARTITION BY [Segment] ORDER BY [Profit] DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the lowest Profit by Consumer],
		MIN([Profit]) OVER (PARTITION BY [Segment]) as [Profit]	
FROM ProfitOfCustomerByConsumer
WHERE [Profit] >= 1
UNION
SELECT DISTINCT [Segment],
		FIRST_VALUE([Customer Name]) OVER ( PARTITION BY [Segment] ORDER BY [Profit] DESC) as [Customer with the greatest Profit by Home Office],
		MAX([Profit]) OVER (PARTITION BY [Segment]) as [Profit],
		LAST_VALUE([Customer Name]) OVER (PARTITION BY [Segment] ORDER BY [Profit] DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the lowest Profit by Home Office],
		MIN([Profit]) OVER (PARTITION BY [Segment]) as [Profit]	
FROM ProfitOfCustomerByHomeOffice
WHERE [Profit] >= 1


--3.a) Profit of Category and Profit of Customer by Category

CREATE PROCEDURE ProfitOfCategoryByYear  @StartYear int, @EndYear int
AS
	SELECT DISTINCT [Category],		
				SUM([Profit]) OVER (PARTITION BY [Category]) as [Profit]
	FROM [Project4].[dbo].[SuperStore]
	WHERE YearOfOrderDate BETWEEN @StartYear AND @EndYear
	ORDER BY [Profit] DESC
GO

-- Profit of Category in all years
EXEC ProfitOfCategoryByYear @StartYear = 2011, @EndYear = 2014
-- Profit of Category year over year
--2011
EXEC ProfitOfCategoryByYear @StartYear = 2011, @EndYear = 2011
--2012
EXEC ProfitOfCategoryByYear @StartYear = 2012, @EndYear = 2012
--2013
EXEC ProfitOfCategoryByYear @StartYear = 2013, @EndYear = 2013
--2014
EXEC ProfitOfCategoryByYear @StartYear = 2014, @EndYear = 2014
--3.b) Profit of Customer by Category 
--A table valued function was used to return the data
CREATE FUNCTION ProfitOfCategoryByCustomer 
(
@Category nvarchar(max),
@StartYear int,
@EndYear int
)
RETURNS TABLE
AS
RETURN	
	SELECT DISTINCT [Customer Name], [Category], SUM([Profit]) OVER (PARTITION BY [Customer Name]) as Profit
	FROM [Project4].[dbo].[SuperStore]
	WHERE [Category] = @Category and YearOfOrderDate BETWEEN @StartYear AND @EndYear

--3.c) Customer of Profit by Technology
SELECT RANK() OVER (PARTITION BY [Category] ORDER BY [Profit] DESC) as Ranking, *
FROM ProfitOfCategoryByCustomer('Technology',2011,2014)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--3.d) Customer of Profit by Technolog year by year
--2011
SELECT *
FROM ProfitOfCategoryByCustomer('Technology',2011,2011)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2012
SELECT *
FROM ProfitOfCategoryByCustomer('Technology',2012,2012)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2013
SELECT *
FROM ProfitOfCategoryByCustomer('Technology',2013,2013)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2014
SELECT *
FROM ProfitOfCategoryByCustomer('Technology',2014,2014)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC

--3.d) Customer of Profit by Technology greater than average profit
SELECT *
FROM ProfitOfCategoryByCustomer('Technology',2011,2014)
WHERE [Profit] > (SELECT AVG([Profit]) FROM [Project4].[dbo].[SuperStore])
ORDER BY [Profit] DESC
--3.e) TOP 10 Customers of Profit by Technology
SELECT TOP 10 with TIES *
FROM ProfitOfCategoryByCustomer('Technology',2011,2014)
ORDER BY [Profit] DESC

--3.f) Group of Sales of  Customers by Technology
WITH GroupOfProfitByTechnology AS (
SELECT *, NTILE(3) OVER (ORDER BY [Profit] DESC) as Buckets
FROM ProfitOfCategoryByCustomer('Technology',2011,2014)
WHERE [Profit] >= 1
)
SELECT [Customer Name], 
		CASE 
			WHEN Buckets = 1 THEN 'High Profit'
			WHEN Buckets = 2 THEN 'Mid Profit'
			WHEN Buckets = 3 THEN 'Low Profit'
		END AS [Level of Profit]
FROM GroupOfProfitByTechnology
ORDER BY [Profit] DESC

--3. g) Cumulative distrubution of Profit by Customer for Technology
SELECT *, CAST(ROUND((cume_dist()  OVER (PARTITION BY [Category] ORDER BY [Profit] DESC))*100,2) AS FLOAT) as [Cumulative Distribution (%)]
FROM ProfitOfCategoryByCustomer('Technology',2011,2014)

--3. h) Cumulative distrubution of Profit by Customer for Technology with Profit
WITH CustomerwithProfitByCategory AS (	
SELECT *, CAST(ROUND((cume_dist()  OVER (PARTITION BY [Category] ORDER BY [Profit] DESC))*100,2) AS FLOAT) as [Cumulative Distribution (%)]
FROM ProfitOfCategoryByCustomer('Technology',2011,2014)
)
SELECT [Customer Name], [Category], [Profit],  [Cumulative Distribution (%)]
FROM CustomerwithProfitByCategory
WHERE  [Cumulative Distribution (%)] <= 77

--3.i) Cumulative distrubution of Profit by Customer for Technology without Profit
WITH CustomerwithoutProfitByCategory AS (	
SELECT *, CAST(ROUND((cume_dist()  OVER (PARTITION BY [Category] ORDER BY [Profit] DESC))*100,2) AS FLOAT)  as [Cumulative Distribution (%)]
FROM ProfitOfCategoryByCustomer('Technology',2011,2014)
)
SELECT [Customer Name], [Category], [Profit], [Cumulative Distribution (%)]
FROM CustomerwithoutProfitByCategory
WHERE [Cumulative Distribution (%)] >= 77

--3.j) Customer of Profit by Office Supplies
SELECT RANK() OVER (PARTITION BY [Category] ORDER BY [Profit] DESC) as Ranking,*
FROM ProfitOfCategoryByCustomer('Office Supplies',2011,2014)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
-- 3.k) Customer of Profit by Office Supplies year by year
--2011
SELECT RANK() OVER (PARTITION BY [Category] ORDER BY [Profit] DESC) as Ranking,*
FROM ProfitOfCategoryByCustomer('Office Supplies',2011,2011)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2012
SELECT RANK() OVER (PARTITION BY [Category] ORDER BY [Profit] DESC) as Ranking,*
FROM ProfitOfCategoryByCustomer('Office Supplies',2012,2012)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2013
SELECT RANK() OVER (PARTITION BY [Category] ORDER BY [Profit] DESC) as Ranking,*
FROM ProfitOfCategoryByCustomer('Office Supplies',2013,2013)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2014
SELECT RANK() OVER (PARTITION BY [Category] ORDER BY [Profit] DESC) as Ranking,*
FROM ProfitOfCategoryByCustomer('Office Supplies',2014,2014)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
-- 3.l) Customer of Profit by Office Supplies greater than average profit
SELECT *
FROM ProfitOfCategoryByCustomer('Office Supplies',2011,2014)
WHERE [Profit] > (SELECT AVG([Profit]) FROM [Project4].[dbo].[SuperStore] WHERE [Category] = 'Office Supplies')
ORDER BY [Profit] DESC 

--3.k)  TOP 10 Customers of Profit by Office Supplies
SELECT TOP 10 with TIES *
FROM ProfitOfCategoryByCustomer('Office Supplies',2011,2014)
ORDER BY [Profit] DESC
-- 3.l) Group of Sales of Customer by Office Supplies
WITH GroupOfProfitByOfficeSupplies AS (
SELECT *, NTILE(3) OVER (ORDER BY [Profit] DESC) as Buckets
FROM ProfitOfCategoryByCustomer('Office Supplies',2011,2014)
WHERE [Profit] >= 1
)
SELECT [Customer Name],
	CASE
		WHEN Buckets = 1 THEN 'High Profit'
		WHEN Buckets = 2 THEN 'Mid Profit'
		WHEN Buckets = 3 THEN 'Low Profit'
	END AS [Level of Profit]
FROM GroupOfProfitByOfficeSupplies
ORDER BY [Profit] DESC 

--3.m) Cumulative Distribution of Profit by Customer for Office Suplies
SELECT *, CAST(ROUND((cume_dist() OVER (PARTITION BY [Category] ORDER BY [Profit] DESC))*100,2) AS FLOAT) as [Cumulative Distribution (%)]
FROM ProfitOfCategoryByCustomer('Office Supplies',2011,2014)
--3. n) Cumulative distrubution of Profit by Customer for Office Supplies with Profit
WITH CustomerwithProfitByOfficeSupplies AS (
SELECT *, CAST(ROUND((cume_dist() OVER (PARTITION BY [Category] ORDER BY [Profit] DESC))*100,2) AS FLOAT) as [Cumulative Distribution (%)]
FROM ProfitOfCategoryByCustomer('Office Supplies',2011,2014)
)
SELECT *
FROM CustomerwithProfitByOfficeSupplies
WHERE [Cumulative Distribution (%)] <= 75.55

--3. o) Cumulative distrubution of Profit by Customer for Office Supplies without Profit
WITH CustomerwithProfitByOfficeSupplies AS (
SELECT *, CAST(ROUND((cume_dist() OVER (PARTITION BY [Category] ORDER BY [Profit] DESC))*100,2) AS FLOAT) as [Cumulative Distribution (%)]
FROM ProfitOfCategoryByCustomer('Office Supplies',2011,2014)
)
SELECT *
FROM CustomerwithProfitByOfficeSupplies
WHERE [Cumulative Distribution (%)] >= 75.55


--3. p) Customer of Profit by Furniture
SELECT RANK() OVER (PARTITION BY [Category] ORDER BY [Profit] DESC) as Ranking, *
FROM ProfitOfCategoryByCustomer('Furniture',2011,2014)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC

-- 3.q) Customer of Profit by Furniture year by year
--2011
SELECT RANK() OVER (PARTITION BY [Category] ORDER BY [Profit] DESC) as Ranking, *
FROM ProfitOfCategoryByCustomer('Furniture',2011,2011)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2012
SELECT RANK() OVER (PARTITION BY [Category] ORDER BY [Profit] DESC) as Ranking, *
FROM ProfitOfCategoryByCustomer('Furniture',2012,2012)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2013
SELECT RANK() OVER (PARTITION BY [Category] ORDER BY [Profit] DESC) as Ranking, *
FROM ProfitOfCategoryByCustomer('Furniture',2013,2013)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2014
SELECT RANK() OVER (PARTITION BY [Category] ORDER BY [Profit] DESC) as Ranking, *
FROM ProfitOfCategoryByCustomer('Furniture',2014,2014)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--3. r) Customer of Profit by Furniture greater than average 
SELECT *
FROM ProfitOfCategoryByCustomer('Furniture',2011,2014)
WHERE [Profit] > (SELECT AVG([Profit]) FROM [Project4].[dbo].[SuperStore] WHERE [Category] = 'Furniture')
ORDER BY [Profit] DESC

-- 3. s) TOP 10 Customer of Profit by Furniture
SELECT TOP 10 with TIES *
FROM ProfitOfCategoryByCustomer('Furniture',2011,2014)
ORDER BY [Profit] DESC


--3. t) Group of Customer of Profit by Furniture
WITH GroupOfThreeLevels AS (
SELECT *, NTILE(3) OVER (ORDER BY [Profit] DESC) as Buckets
FROM ProfitOfCategoryByCustomer('Furniture',2011,2014)
WHERE [Profit] >= 1 
)
SELECT [Customer Name],
	CASE	
		WHEN Buckets = 1 THEN 'High Profit'
		WHEN Buckets = 2 THEN 'Mid Profit'
		WHEN Buckets = 3 THEN 'Low Profit'
	END AS [Level of Profit]
FROM GroupOfThreeLevels
ORDER BY [Profit] DESC
--3. u) Cumulative Distrubtion of Profit of Customer by Furniture

SELECT *, CAST(ROUND(CUME_DIST() OVER (PARTITION BY [Category] ORDER BY [Profit] DESC)*100,2) AS FLOAT) as [Cumulative Distrubution (%)]
FROM ProfitOfCategoryByCustomer('Furniture',2011,2014)
--3.v)  Cumulative Distrubtion of Customer by Furniture with Profit
WITH CustomerWithProfitByFurniture AS (
SELECT *, CAST(ROUND(CUME_DIST() OVER (PARTITION BY [Category] ORDER BY [Profit] DESC)*100,2) AS FLOAT) as [Cumulative Distrubution (%)]
FROM ProfitOfCategoryByCustomer('Furniture',2011,2014)
)
SELECT *
FROM CustomerWithProfitByFurniture
WHERE [Cumulative Distrubution (%)] <= 50.20
-- 3.w) Cumulative Distrubtion of Customer by Furniture without Profit
WITH CustomerWithProfitByFurniture AS (
SELECT *, CAST(ROUND(CUME_DIST() OVER (PARTITION BY [Category] ORDER BY [Profit] DESC)*100,2) AS FLOAT) as [Cumulative Distrubution (%)]
FROM ProfitOfCategoryByCustomer('Furniture',2011,2014)
)
SELECT *
FROM CustomerWithProfitByFurniture
WHERE [Cumulative Distrubution (%)] >= 50.20

-- 3.x) The greatest and lowest Profit of Customer by Category
WITH CustomerOfMaxProfitByCategory AS (
SELECT DISTINCT 
		[Category],
		FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Category] ORDER BY [Profit] DESC) as [Customer with the greatest Profit],
		MAX([Profit]) OVER (PARTITION BY [Category]) as [Profit]
FROM ProfitOfCategoryByCustomer('Technology',2011,2014)
WHERE [Profit] >= 1
UNION
SELECT DISTINCT
	[Category],
	FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Category] ORDER BY [Profit] DESC) as [Customer with the greatest Profit],
	MAX([Profit]) OVER (PARTITION BY [Category]) as [Profit]
FROM ProfitOfCategoryByCustomer('Office Supplies',2011,2014)
WHERE [Profit] >= 1
UNION
SELECT DISTINCT
	[Category],
	FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Category] ORDER BY [Profit] DESC) as [Customer with the greatest Profit],
	MAX([Profit]) OVER (PARTITION BY [Category]) as [Profit]
FROM ProfitOfCategoryByCustomer('Furniture',2011,2014)
WHERE [Profit] >= 1
), CustomerOfMinProfitByCategory AS
(
SELECT DISTINCT 
		[Category],
		LAST_VALUE([Customer Name]) OVER (PARTITION BY [Category] ORDER BY [Profit] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
		) as [Customer with the greatest Profit],
		MIN([Profit]) OVER (PARTITION BY [Category]) as [Profit]
FROM ProfitOfCategoryByCustomer('Technology',2011,2014)
WHERE [Profit] >= 1
UNION
SELECT DISTINCT
	[Category],
	LAST_VALUE([Customer Name]) OVER (PARTITION BY [Category] ORDER BY [Profit] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
	) as [Customer with the greatest Profit],
	MIN([Profit]) OVER (PARTITION BY [Category]) as [Profit]
FROM ProfitOfCategoryByCustomer('Office Supplies',2011,2014)
WHERE [Profit] >= 1
UNION
SELECT DISTINCT
	[Category],
	LAST_VALUE([Customer Name]) OVER (PARTITION BY [Category] ORDER BY [Profit] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
	) as [Customer with the greatest Profit],
	MIN([Profit]) OVER (PARTITION BY [Category]) as [Profit]
FROM ProfitOfCategoryByCustomer('Furniture',2011,2014)
WHERE [Profit] >= 1
)
SELECT *
FROM CustomerOfMaxProfitByCategory maxcat
	JOIN CustomerOfMinProfitByCategory mincat
		on maxcat.[Category] = mincat.[Category]
ORDER BY maxcat.[Profit] DESC


-- 4.a) Profit of Ship Mode Year by Year
CREATE PROCEDURE ProfitOfShipModeByYear  @StartYear int, @EndYear int
AS
SELECT DISTINCT [Ship Mode], SUM([Profit]) OVER (PARTITION BY [Ship Mode]) as Profit
FROM [Project4].[dbo].[SuperStore]
WHERE  [YearOfOrderDate] BETWEEN @StartYear AND @EndYear
ORDER BY [Profit] DESC
GO
-- Profit of Ship Mode 2011 - 2014
EXEC ProfitOfShipModeByYear @StartYear = 2011, @EndYear = 2014
--2011
EXEC ProfitOfShipModeByYear  @StartYear = 2011, @EndYear = 2011
--2012
EXEC ProfitOfShipModeByYear  @StartYear = 2012, @EndYear = 2012
--2013
EXEC ProfitOfShipModeByYear  @StartYear = 2013, @EndYear = 2013
--2014
EXEC ProfitOfShipModeByYear  @StartYear = 2014, @EndYear = 2014



-- 4.b) A valued table function was created to calculate the profit of Ship Mode by Customer
CREATE FUNCTION ProfitOfShipModeByCustomers
(
	@ShipMode nvarchar(MAX),
	@StartYear int,
	@EndYear int
)
RETURNS TABLE
AS 
RETURN
	SELECT DISTINCT [Customer Name], [Ship Mode], SUM([Profit]) OVER (PARTITION BY [Customer Name]) as Profit
	FROM [Project4].[dbo].[SuperStore]
	WHERE [Ship Mode] = @ShipMode AND [YearOfOrderDate] BETWEEN @StartYear AND @EndYear


--4.c)  Profit of Customer by  First Class
SELECT *
FROM ProfitOfShipModeByCustomers('First Class', 2011, 2014) 
ORDER BY [Profit] DESC
--4.d)  Profit of Customer by First Class year over year
--2011
SELECT *
FROM ProfitOfShipModeByCustomers('First Class', 2011, 2014) 
ORDER BY [Profit] DESC
--2012
SELECT *
FROM ProfitOfShipModeByCustomers('First Class', 2012, 2012) 
ORDER BY [Profit] DESC
--2013
SELECT *
FROM ProfitOfShipModeByCustomers('First Class', 2013, 2013) 
ORDER BY [Profit] DESC
--2014
SELECT *
FROM ProfitOfShipModeByCustomers('First Class', 2014, 2014) 
ORDER BY [Profit] DESC
--4.e)  Profit of Customer by  Same Day
SELECT *
FROM ProfitOfShipModeByCustomers('Same Day', 2011, 2014) 
ORDER BY [Profit] DESC
--4.d) Profit of Customer by First Class year by year
--2011
SELECT *
FROM ProfitOfShipModeByCustomers('Same Day', 2011, 2014) 
ORDER BY [Profit] DESC
--2012
SELECT *
FROM ProfitOfShipModeByCustomers('Same Day', 2012, 2012) 
ORDER BY [Profit] DESC
--2013
SELECT *
FROM ProfitOfShipModeByCustomers('Same Day', 2013, 2013) 
ORDER BY [Profit] DESC
--2014
SELECT *
FROM ProfitOfShipModeByCustomers('Same Day', 2014, 2014) 
ORDER BY [Profit] DESC

-- 4.e) Profit of Customer by  Standard Class
SELECT *
FROM ProfitOfShipModeByCustomers('Standard Class', 2011, 2014) 
ORDER BY [Profit] DESC
-- 4.f) Profit of Customer by First Class year over year
--2011
SELECT *
FROM ProfitOfShipModeByCustomers('Standard Class', 2011, 2014) 
ORDER BY [Profit] DESC
--2012
SELECT *
FROM ProfitOfShipModeByCustomers('Standard Class', 2012, 2012) 
ORDER BY [Profit] DESC
--2013
SELECT *
FROM ProfitOfShipModeByCustomers('Standard Class', 2013, 2013) 
ORDER BY [Profit] DESC
--2014
SELECT *
FROM ProfitOfShipModeByCustomers('Standard Class', 2014, 2014) 
ORDER BY [Profit] DESC


-- 4.g) Profit of Customer by  Second Class
SELECT *
FROM ProfitOfShipModeByCustomers('Second Class', 2011, 2014) 
ORDER BY [Profit] DESC
-- 4.h) Profit of Customer by First Class year over year
--2011
SELECT *
FROM ProfitOfShipModeByCustomers('Second Class', 2011, 2014) 
ORDER BY [Profit] DESC
--2012
SELECT *
FROM ProfitOfShipModeByCustomers('Second Class', 2012, 2012) 
ORDER BY [Profit] DESC
--2013
SELECT *
FROM ProfitOfShipModeByCustomers('Second Class', 2013, 2013) 
ORDER BY [Profit] DESC
--2014
SELECT *
FROM ProfitOfShipModeByCustomers('Second Class', 2014, 2014) 
ORDER BY [Profit] DESC

-- 4.i) The greatest and lowest Profit of Ship Mode by Customer
WITH TheGreatestProfitofCustomerByShipMode AS 
(
	SELECT DISTINCT [Ship Mode], FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Profit] DESC) as [The greatest profit of Customer by Ship Mode],
			MAX([Profit]) OVER (PARTITION BY [Ship Mode]) as [The Greatest Profit]
	FROM ProfitOfShipModeByCustomers('Same Day', 2011, 2014) 
	WHERE [Profit] >= 1
	UNION
	SELECT DISTINCT [Ship Mode], FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Profit] DESC) as [The greatest profit of Customer by Ship Mode],
			MAX([Profit]) OVER (PARTITION BY [Ship Mode]) as [The Greatest Profit]
	FROM ProfitOfShipModeByCustomers('First Class', 2011, 2014) 
	WHERE [Profit] >= 1
	UNION
	SELECT DISTINCT [Ship Mode], FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Profit] DESC) as [The greatest profit of Customer by Ship Mode],
			MAX([Profit]) OVER (PARTITION BY [Ship Mode]) as [The Greatest Profit]
	FROM ProfitOfShipModeByCustomers('Standard Class', 2011, 2014) 
	WHERE [Profit] >= 1
	UNION
	SELECT DISTINCT [Ship Mode], FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Profit] DESC) as [The greatest profit of Customer by Ship Mode],
			MAX([Profit]) OVER (PARTITION BY [Ship Mode]) as [The Greatest Profit]
	FROM ProfitOfShipModeByCustomers('Second Class', 2011, 2014) 
	WHERE [Profit] >= 1
), TheLowestProfitofCustomerByShipMode AS
(
	SELECT DISTINCT [Ship Mode], LAST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Profit] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The lowest profit of Customer by Ship Mode],
			MIN([Profit]) OVER (PARTITION BY [Ship Mode]) as [The Lowest Profit]
	FROM ProfitOfShipModeByCustomers('Same Day', 2011, 2014) 
	WHERE [Profit] >= 1
	UNION
	SELECT DISTINCT [Ship Mode], LAST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Profit] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The lowest profit of Customer by Ship Mode],
			MIN([Profit]) OVER (PARTITION BY [Ship Mode]) as [The Lowest Profit]
	FROM ProfitOfShipModeByCustomers('First Class', 2011, 2014) 
	WHERE [Profit] >= 1
	UNION
	SELECT DISTINCT [Ship Mode], LAST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Profit] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The lowest profit of Customer by Ship Mode],
			MIN([Profit]) OVER (PARTITION BY [Ship Mode]) as [The Lowest Profit]
	FROM ProfitOfShipModeByCustomers('Standard Class', 2011, 2014) 
	WHERE [Profit] >= 1
	UNION
	SELECT DISTINCT [Ship Mode], LAST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Profit] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The lowest profit of Customer by Ship Mode],
			MIN([Profit]) OVER (PARTITION BY [Ship Mode]) as [The Lowest Profit]
	FROM ProfitOfShipModeByCustomers('Second Class', 2011, 2014) 
	WHERE [Profit] >= 1
)
SELECT SMGP.[Ship Mode],	
	SMGP.[The greatest profit of Customer by Ship Mode], 
	SMGP.[The Greatest Profit],
	SMLP.[The lowest profit of Customer by Ship Mode],
	SMLP.[The Lowest Profit]
FROM TheGreatestProfitofCustomerByShipMode SMGP 
	JOIN TheLowestProfitofCustomerByShipMode SMLP
		ON SMGP.[Ship Mode] = SMLP.[Ship Mode]



--5.a) The Greatest and Lowest Profit & Sales by Customer in Ship Mode

WITH TheGreatestProfitofCustomerByShipMode AS 
(
	SELECT DISTINCT [Ship Mode], FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Profit] DESC) as [The greatest profit of Customer by Ship Mode],
			MAX([Profit]) OVER (PARTITION BY [Ship Mode]) as [The Greatest Profit]
	FROM ProfitOfShipModeByCustomers('Same Day', 2011, 2014) 
	WHERE [Profit] >= 1
	UNION
	SELECT DISTINCT [Ship Mode], FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Profit] DESC) as [The greatest profit of Customer by Ship Mode],
			MAX([Profit]) OVER (PARTITION BY [Ship Mode]) as [The Greatest Profit]
	FROM ProfitOfShipModeByCustomers('First Class', 2011, 2014) 
	WHERE [Profit] >= 1
	UNION
	SELECT DISTINCT [Ship Mode], FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Profit] DESC) as [The greatest profit of Customer by Ship Mode],
			MAX([Profit]) OVER (PARTITION BY [Ship Mode]) as [The Greatest Profit]
	FROM ProfitOfShipModeByCustomers('Standard Class', 2011, 2014) 
	WHERE [Profit] >= 1
	UNION
	SELECT DISTINCT [Ship Mode], FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Profit] DESC) as [The greatest profit of Customer by Ship Mode],
			MAX([Profit]) OVER (PARTITION BY [Ship Mode]) as [The Greatest Profit]
	FROM ProfitOfShipModeByCustomers('Second Class', 2011, 2014) 
	WHERE [Profit] >= 1
), TheLowestProfitofCustomerByShipMode AS
(
	SELECT DISTINCT [Ship Mode], LAST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Profit] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The lowest profit of Customer by Ship Mode],
			MIN([Profit]) OVER (PARTITION BY [Ship Mode]) as [The Lowest Profit]
	FROM ProfitOfShipModeByCustomers('Same Day', 2011, 2014) 
	WHERE [Profit] >= 1
	UNION
	SELECT DISTINCT [Ship Mode], LAST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Profit] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The lowest profit of Customer by Ship Mode],
			MIN([Profit]) OVER (PARTITION BY [Ship Mode]) as [The Lowest Profit]
	FROM ProfitOfShipModeByCustomers('First Class', 2011, 2014) 
	WHERE [Profit] >= 1
	UNION
	SELECT DISTINCT [Ship Mode], LAST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Profit] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The lowest profit of Customer by Ship Mode],
			MIN([Profit]) OVER (PARTITION BY [Ship Mode]) as [The Lowest Profit]
	FROM ProfitOfShipModeByCustomers('Standard Class', 2011, 2014) 
	WHERE [Profit] >= 1
	UNION
	SELECT DISTINCT [Ship Mode], LAST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Profit] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The lowest profit of Customer by Ship Mode],
			MIN([Profit]) OVER (PARTITION BY [Ship Mode]) as [The Lowest Profit]
	FROM ProfitOfShipModeByCustomers('Second Class', 2011, 2014) 
	WHERE [Profit] >= 1
), MaxSalesOfCustomerByShipMode AS (
SELECT DISTINCT [Ship Mode], FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Sales] DESC) as [Customer with the greatest Sales by Ship Mode],
				MAX([Sales]) OVER (PARTITION BY [Ship Mode]) as [Sales]
FROM SalesOfCustomerByStandardClass
UNION
SELECT DISTINCT [Ship Mode], FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Sales] DESC) as [Customer with the greatest Sales by Ship Mode],
				MAX([Sales]) OVER (PARTITION BY [Ship Mode]) as [Sales]
FROM SalesOfCustomerBySecondClass
UNION
SELECT DISTINCT [Ship Mode], FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Sales] DESC) as [Customer with the greatest Sales by Ship Mode],
				MAX([Sales]) OVER (PARTITION BY [Ship Mode]) as [Sales]
FROM SalesOfCustomerByFirstClass
UNION
SELECT DISTINCT [Ship Mode], FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Sales] DESC) as [Customer with the greatest Sales by Ship Mode],
				MAX([Sales]) OVER (PARTITION BY [Ship Mode]) as [Sales]
FROM SalesOfCustomerBySameDay
), MinSalesOfCustomerByShipMode AS (
SELECT DISTINCT [Ship Mode],
			LAST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Sales] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the lowest Sales by Ship Mode],
			MIN([Sales]) OVER (PARTITION BY [Ship Mode]) as [Sales]
FROM SalesOfCustomerByStandardClass
UNION
SELECT DISTINCT [Ship Mode],
			LAST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Sales] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the lowest Sales by Ship Mode],
			MIN([Sales]) OVER (PARTITION BY [Ship Mode]) as [Sales]
FROM SalesOfCustomerBySecondClass
UNION
SELECT DISTINCT [Ship Mode],
			LAST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Sales] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the lowest Sales by Ship Mode],
			MIN([Sales]) OVER (PARTITION BY [Ship Mode]) as [Sales]
FROM SalesOfCustomerByFirstClass
UNION
SELECT DISTINCT [Ship Mode],
			LAST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Sales] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the lowest Sales by Ship Mode],
			MIN([Sales]) OVER (PARTITION BY [Ship Mode]) as [Sales]
FROM SalesOfCustomerBySameDay
)SELECT 
	SMGP.[Ship Mode],
	SMGP.[The greatest profit of Customer by Ship Mode] as [The greatest profit of Customer],
	SMGP.[The Greatest Profit] as [Profit],
	SMLP.[Ship Mode],
	SMLP.[The lowest profit of Customer by Ship Mode] as [The lowest profit of Customer],
	SMLP.[The Lowest Profit],
	[MaxSales].[Ship Mode],
	[MaxSales].[Customer with the greatest Sales by Ship Mode] as [Customer with the greatest Sales],
	[MaxSales].[Sales],
	[MinSales].[Ship Mode],
	[MinSales].[Customer with the lowest Sales by Ship Mode] as [Customer with the lowest Sales],
	[MinSales].Sales
FROM TheGreatestProfitofCustomerByShipMode SMGP 
	JOIN TheLowestProfitofCustomerByShipMode SMLP
		ON SMGP.[Ship Mode] = SMLP.[Ship Mode]
	JOIN MaxSalesOfCustomerByShipMode MaxSales
		ON SMGP.[Ship Mode] = MaxSales.[Ship Mode] 
	JOIN MinSalesOfCustomerByShipMode MinSales
		ON SMGP.[Ship Mode] = MinSales.[Ship Mode]


--6.a) The Greatest and Lowest Profit & Sales by Customer in Category
WITH CustomerOfMaxProfitByCategory AS (
SELECT DISTINCT 
		[Category],
		FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Category] ORDER BY [Profit] DESC) as [Customer with the greatest Profit],
		MAX([Profit]) OVER (PARTITION BY [Category]) as [Profit]
FROM ProfitOfCategoryByCustomer('Technology',2011,2014)
WHERE [Profit] >= 1
UNION
SELECT DISTINCT
	[Category],
	FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Category] ORDER BY [Profit] DESC) as [Customer with the greatest Profit],
	MAX([Profit]) OVER (PARTITION BY [Category]) as [Profit]
FROM ProfitOfCategoryByCustomer('Office Supplies',2011,2014)
WHERE [Profit] >= 1
UNION
SELECT DISTINCT
	[Category],
	FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Category] ORDER BY [Profit] DESC) as [Customer with the greatest Profit],
	MAX([Profit]) OVER (PARTITION BY [Category]) as [Profit]
FROM ProfitOfCategoryByCustomer('Furniture',2011,2014)
WHERE [Profit] >= 1
), CustomerOfMinProfitByCategory AS
(
SELECT DISTINCT 
		[Category],
		LAST_VALUE([Customer Name]) OVER (PARTITION BY [Category] ORDER BY [Profit] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
		) as [Customer with the greatest Profit],
		MIN([Profit]) OVER (PARTITION BY [Category]) as [Profit]
FROM ProfitOfCategoryByCustomer('Technology',2011,2014)
WHERE [Profit] >= 1
UNION
SELECT DISTINCT
	[Category],
	LAST_VALUE([Customer Name]) OVER (PARTITION BY [Category] ORDER BY [Profit] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
	) as [Customer with the greatest Profit],
	MIN([Profit]) OVER (PARTITION BY [Category]) as [Profit]
FROM ProfitOfCategoryByCustomer('Office Supplies',2011,2014)
WHERE [Profit] >= 1
UNION
SELECT DISTINCT
	[Category],
	LAST_VALUE([Customer Name]) OVER (PARTITION BY [Category] ORDER BY [Profit] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
	) as [Customer with the greatest Profit],
	MIN([Profit]) OVER (PARTITION BY [Category]) as [Profit]
FROM ProfitOfCategoryByCustomer('Furniture',2011,2014)
WHERE [Profit] >= 1
), GreatestLowestSales AS (
SELECT DISTINCT [Category], FIRST_VALUE([Customer Name]) OVER(PARTITION BY [Category] ORDER BY Sales DESC) AS [Customer with the greatest Sales by Category],
		MAX(Sales) OVER (PARTITION BY [Category]) as [Sales by Category1],
		LAST_VALUE([Customer Name]) OVER(PARTITION BY [Category] ORDER BY Sales DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) AS [Customer with the lowest Sales by Category],
		MIN(Sales) OVER (PARTITION BY [Category]) as [Sales by Category2]
		FROM CustomerOfSalesByFurniture
UNION
		SELECT DISTINCT [Category], FIRST_VALUE([Customer Name]) OVER(PARTITION BY [Category] ORDER BY Sales DESC) AS [Customer with the greatest Sales by Category],
		MAX(Sales) OVER (PARTITION BY [Category]) as [Sales by Category3],
		LAST_VALUE([Customer Name]) OVER(PARTITION BY [Category] ORDER BY Sales DESC 
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) AS [Customer with the lowest Sales by Category],
		MIN(Sales) OVER (PARTITION BY [Category]) as [Sales by Category4]
		FROM CustomerOfSalesByOfficeSupplies
UNION
		SELECT DISTINCT [Category], FIRST_VALUE([Customer Name]) OVER(PARTITION BY [Category] ORDER BY Sales DESC) AS [Customer with the greatest Sales by Category],
		MAX(Sales) OVER (PARTITION BY [Category]) as [Sales by Category5],
		LAST_VALUE([Customer Name]) OVER(PARTITION BY [Category] ORDER BY Sales DESC	
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) AS [Customer with the lowest Sales by Category],
		MIN(Sales) OVER (PARTITION BY [Category]) as [Sales By Category6]
FROM CustomerOfSalesByTechnology
)
SELECT	
		maxcat.[Category],
		maxcat.[Customer with the greatest Profit],
		maxcat.[Profit],
		mincat.[Category],
		mincat.[Customer with the greatest Profit],
		mincat.[Profit],
		SalesCat.[Category],
		SalesCat.[Customer with the greatest Sales by Category] as [Customer with the greatest Sales],
		SalesCat.[Sales by Category1] as [Sales],
		SalesCat.[Category],
		SalesCat.[Customer with the lowest Sales by Category] as [Customer with the lowest Sales],
		SalesCat.[Sales by Category2] as [Sales]
FROM CustomerOfMaxProfitByCategory maxcat
	JOIN CustomerOfMinProfitByCategory mincat
		on maxcat.[Category] = mincat.[Category]
	JOIN GreatestLowestSales SalesCat
		on maxcat.[Category] = SalesCat.[Category]
ORDER BY maxcat.[Profit] DESC

--7.a)  The Greatest and Lowest Profit & Sales by Customer in Segment
WITH GreatestSales  AS 
(
SELECT DISTINCT
	[Segment],
	FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Segment] ORDER BY [Sales] DESC) as [Customer with the greatest Sales],
	MAX(Sales) OVER (PARTITION BY [Segment]) as [Sales]
FROM #CustomerBySegment
), LowestSales AS
(
SELECT DISTINCT 
	[Segment],
	LAST_VALUE([Customer Name]) OVER (PARTITION BY [Segment] ORDER BY [Sales] DESC 
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the lowest Sales],
	MIN(Sales) OVER (PARTITION BY [Segment]) as [Sales]
FROM #CustomerBySegment
), GreatestProfit AS 
(
SELECT DISTINCT [Segment], FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Segment] ORDER BY [Profit] DESC) as [Customer with the greatest Profit by Corporate],
			MAX([Profit]) OVER (PARTITION BY [Segment]) as [Profit1],
			LAST_VALUE([Customer Name]) OVER (PARTITION BY [Segment] ORDER BY [Profit] DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) as [Customer with the lowest Profit by Corporate],
			MIN([Profit]) OVER (PARTITION BY [Segment]) as [Profit2]	
FROM ProfitOfCustomerByCorporate
WHERE [Profit] >= 1
UNION
SELECT DISTINCT [Segment], 
		FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Segment] ORDER BY [Profit] DESC) as [Customer with the greatest Profit by Consumer],
		MAX([Profit]) OVER (PARTITION BY [Segment]) as [Profit3],
		LAST_VALUE([Customer Name]) OVER (PARTITION BY [Segment] ORDER BY [Profit] DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the lowest Profit by Consumer],
		MIN([Profit]) OVER (PARTITION BY [Segment]) as [Profit4]	
FROM ProfitOfCustomerByConsumer
WHERE [Profit] >= 1
UNION
SELECT DISTINCT [Segment],
		FIRST_VALUE([Customer Name]) OVER ( PARTITION BY [Segment] ORDER BY [Profit] DESC) as [Customer with the greatest Profit by Home Office],
		MAX([Profit]) OVER (PARTITION BY [Segment]) as [Profit5],
		LAST_VALUE([Customer Name]) OVER (PARTITION BY [Segment] ORDER BY [Profit] DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the lowest Profit by Home Office],
		MIN([Profit]) OVER (PARTITION BY [Segment]) as [Profit6]	
FROM ProfitOfCustomerByHomeOffice
WHERE [Profit] >= 1
)
SELECT 
	G.[Segment],
	G.[Customer with the greatest Sales],
	G.[Sales],
	L.[Segment],
	L.[Customer with the lowest Sales],
	L.[Sales],
	P.[Segment],
	P.[Customer with the greatest Profit by Corporate] as [Customer with the greatest Profit],
	P.[Profit1] as [Profit],
	P.[Segment],
	P.[Customer with the lowest Profit by Corporate] as [Customer with the lowest Profit],
	P.[Profit2] as Profit
FROM GreatestSales  G
	LEFT JOIN LowestSales L
		 ON G.Segment = L.Segment
	LEFT JOIN GreatestProfit P
		ON P.Segment = G.Segment




--8. a) Average of Sales, Profit and Shipping Cost by Customer
SELECT DISTINCT [Customer Name], 
		ROUND(AVG(Sales) OVER (PARTITION BY [Customer Name]),2) as [Average Sales],
		ROUND(AVG([Profit]) OVER (PARTITION BY [Customer Name]),2) as [Average Profit],
		ROUND(AVG([Shipping Cost]) OVER (PARTITION BY [Customer Name]),2) as [Average Shipping Cost]
FROM  [Project4].[dbo].[SuperStore]



--9.a)  Quantity of Orders by City 

SELECT DISTINCT [Country],
			[City],
			count(*) OVER (PARTITION BY [City]) as [Quantity of Orders by City]
FROM   [Project4].[dbo].[SuperStore]
ORDER BY [Country] ASC

-- 9.b) A table-valued function was created to return data of Quantity of Orders by City in all years
CREATE FUNCTION MostOrdersCity (
	@StartYear int,
	@EndYear int
)
RETURNS TABLE
AS
RETURN
	SELECT DISTINCT [Country],
			[City],
			count(*) OVER (PARTITION BY [City]) as [Quantity of Orders by City]
		FROM   [Project4].[dbo].[SuperStore]
		WHERE YearOfOrderDate BETWEEN @StartYear AND @EndYear

--9.c)  Quantity of Orders by City in all years
SELECT DISTINCT *
FROM MostOrdersCity(2011,2014)

--9.d)-Quantity of Orders by City

SELECT [Country],
		DENSE_RANK() OVER (PARTITION BY [Country] ORDER BY [Quantity of Orders by City] DESC) as [Ranking of City],
		[City], 
		[Quantity of Orders by City]
FROM MostOrdersCity(2011,2014)
ORDER BY [Country] ASC

--9.e) Country and its City with the greatest quantity of Orders
SELECT DISTINCT  *
FROM MostOrdersCity(2011,2014)
WHERE [Quantity of Orders by City] = (SELECT MAX([Quantity of Orders by City]) FROM MostOrdersCity(2011,2014))
--9.f) Country and its City with the lowest quantity of Orders
SELECT DISTINCT  *
FROM MostOrdersCity(2011,2014)
WHERE [Quantity of Orders by City] = (SELECT MIN([Quantity of Orders by City]) FROM MostOrdersCity(2011,2014))

--9.g) The greatest and lowest quantity of Orders by City
SELECT DISTINCT [Country],
	FIRST_VALUE([City]) OVER (PARTITION BY [Country] ORDER BY [Quantity of Orders by City] DESC) as [City with the highest Orders],
	MAX([Quantity of Orders by City]) OVER (PARTITION BY [Country]) as [Quantity of Orders],
	LAST_VALUE([City]) OVER (PARTITION BY [Country] ORDER BY [Quantity of Orders by City] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
	) as [City with the highest Orders],
	MIN([Quantity of Orders by City]) OVER (PARTITION BY [Country]) as [Quantity of Orders]
FROM MostOrdersCity(2011,2014)

--9.h) Countries and their cities with Quantity of Orders year over year 
--2011
SELECT *
FROM MostOrdersCity(2011,2011)
ORDER BY [Country] ASC
--2012
SELECT *
FROM MostOrdersCity(2012,2012)
ORDER BY [Country] ASC
--2013
SELECT *
FROM MostOrdersCity(2013,2013)
ORDER BY [Country] ASC
--2014
SELECT *
FROM MostOrdersCity(2014,2014)
ORDER BY [Country] ASC

--9.i)  Country with the greatest quantity of Orders 
DROP FUNCTION QuantityofOrdersByCountry
CREATE FUNCTION QuantityofOrdersByCountry
(
	@StartYear int,
	@EndYear int
)
RETURNS TABLE
AS
RETURN
	SELECT DISTINCT YearOfOrderDate,[Country],
			count(*) OVER (PARTITION BY [Country]) as [Quantity of Orders by Country]	
FROM   [Project4].[dbo].[SuperStore]
WHERE YearOfOrderDate BETWEEN @StartYear AND @EndYear

--9. j) The Quantity of Orders by Country in all years
SELECT DISTINCT [Country], [Quantity of Orders by Country]
FROM QuantityofOrdersByCountry(2011,2014)
ORDER BY [Quantity of Orders by Country] DESC
--9. k)  The Top 10 Countries of Quantity of Orders in all years
SELECT DISTINCT TOP 10 WITH TIES [Country], [Quantity of Orders by Country]
FROM QuantityofOrdersByCountry(2011,2014)
ORDER BY [Quantity of Orders by Country] DESC
-- 9. l) The greatest and lowest Quantity of Orders by Country
WITH GreatestAndLowestQuantityOfOrders AS
(
	SELECT DISTINCT [Country], [Quantity of Orders by Country],
					FIRST_VALUE([Country]) OVER (ORDER BY [Quantity of Orders by Country] DESC) as [Country with the Greatest Quantity of Orders],
					MAX([Quantity of Orders by Country]) OVER () as [The Greatest Quantity of Orders],
					LAST_VALUE([Country]) OVER (ORDER BY [Quantity of Orders by Country] DESC
					RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
					 as [Country with the Lowestt Quantity of Orders],
					 MIN([Quantity of Orders by Country]) OVER () as [The Lowest Quantity of Orders]
	FROM QuantityofOrdersByCountry(2011,2014)
)
SELECT DISTINCT [Country with the Greatest Quantity of Orders],[The Greatest Quantity of Orders],[Country with the Lowestt Quantity of Orders],[The Lowest Quantity of Orders]
FROM GreatestAndLowestQuantityOfOrders

--9. m) Countries Orders year by year
--2011
SELECT DISTINCT [Country], [Quantity of Orders by Country]
FROM QuantityofOrdersByCountry(2011,2011)
ORDER BY [Quantity of Orders by Country] DESC
--2012
SELECT DISTINCT [Country], [Quantity of Orders by Country]
FROM QuantityofOrdersByCountry(2012,2012)
ORDER BY [Quantity of Orders by Country] DESC
--2013
SELECT DISTINCT [Country], [Quantity of Orders by Country]
FROM QuantityofOrdersByCountry(2013,2013)
ORDER BY [Quantity of Orders by Country] DESC
--2014
SELECT DISTINCT [Country], [Quantity of Orders by Country]
FROM QuantityofOrdersByCountry(2014,2014)
ORDER BY [Quantity of Orders by Country] DESC



--9.n)  The Greatest and Lowest Quantity of Orders by Country year by year 
SELECT DISTINCT YearOfOrderDate as [Year], FIRST_VALUE([Country]) OVER (ORDER BY [Quantity of Orders by Country] DESC) as [Country with the Greatest Quantity of Orders],
					MAX([Quantity of Orders by Country]) OVER () as [The Greatest Quantity of Orders],
						LAST_VALUE([Country]) OVER (ORDER BY [Quantity of Orders by Country] DESC
					RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
					 as [Country with the Lowestt Quantity of Orders],
					 MIN([Quantity of Orders by Country]) OVER () as [The Lowest Quantity of Orders]
FROM QuantityofOrdersByCountry(2011,2011)
UNION
SELECT DISTINCT YearOfOrderDate as [Year], FIRST_VALUE([Country]) OVER (ORDER BY [Quantity of Orders by Country] DESC) as [Country with the Greatest Quantity of Orders],
					MAX([Quantity of Orders by Country]) OVER () as [The Greatest Quantity of Orders],
						LAST_VALUE([Country]) OVER (ORDER BY [Quantity of Orders by Country] DESC
					RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
					 as [Country with the Lowestt Quantity of Orders],
					 MIN([Quantity of Orders by Country]) OVER () as [The Lowest Quantity of Orders]
FROM QuantityofOrdersByCountry(2012,2012)
UNION
SELECT DISTINCT YearOfOrderDate as [Year], FIRST_VALUE([Country]) OVER (ORDER BY [Quantity of Orders by Country] DESC) as [Country with the Greatest Quantity of Orders],
					MAX([Quantity of Orders by Country]) OVER () as [The Greatest Quantity of Orders],
						LAST_VALUE([Country]) OVER (ORDER BY [Quantity of Orders by Country] DESC
					RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
					 as [Country with the Lowestt Quantity of Orders],
					 MIN([Quantity of Orders by Country]) OVER () as [The Lowest Quantity of Orders]
FROM QuantityofOrdersByCountry(2013,2013)
UNION
SELECT DISTINCT YearOfOrderDate as [Year], FIRST_VALUE([Country]) OVER (ORDER BY [Quantity of Orders by Country] DESC) as [Country with the Greatest Quantity of Orders],
					MAX([Quantity of Orders by Country]) OVER () as [The Greatest Quantity of Orders],
						LAST_VALUE([Country]) OVER (ORDER BY [Quantity of Orders by Country] DESC
					RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
					 as [Country with the Lowestt Quantity of Orders],
					 MIN([Quantity of Orders by Country]) OVER () as [The Lowest Quantity of Orders]
FROM QuantityofOrdersByCountry(2014,2014)
-- 9. o) Quantity of Orders by Year
SELECT DISTINCT [YearOfOrderDate], count(*) OVER (PARTITION BY [YearOfOrderDate]) as [Quantity of Orders]
FROM  [Project4].[dbo].[SuperStore]
ORDER BY [Quantity of Orders]
--9. p)  Quantity of Orders Month over Month in selected years
CREATE VIEW QuanitityOfOrdersByMonth AS
	SELECT DISTINCT [YearOfOrderDate],[OrderDate],DateName(Month,[OrderDate]) as MonthName, 
			Month([OrderDate]) as Month, count(*) OVER (PARTITION BY [OrderDate]) as [Orders]
	FROM  [Project4].[dbo].[SuperStore]
-- Quantity of Orders Month over Month in 2011	
SELECT DISTINCT [YearOfOrderDate] as [Year],Month, MonthName as [Month Name], 
			SUM([Orders]) OVER (PARTITION BY [Month]) as [Quantity of Orders by Month]
FROM QuanitityOfOrdersByMonth
WHERE [YearOfOrderDate] = 2011
ORDER BY [Month] ASC
--Quantity of Orders Month over Month in 2012	
SELECT DISTINCT [YearOfOrderDate] as [Year],Month, MonthName as [Month Name], 
			SUM([Orders]) OVER (PARTITION BY [Month]) as [Quantity of Orders by Month]
FROM QuanitityOfOrdersByMonth
WHERE [YearOfOrderDate] = 2012
ORDER BY [Month] ASC
--Quantity of Orders Month over Month in 2013	
SELECT DISTINCT [YearOfOrderDate] as [Year],Month, MonthName as [Month Name], 
			SUM([Orders]) OVER (PARTITION BY [Month]) as [Quantity of Orders by Month]
FROM QuanitityOfOrdersByMonth
WHERE [YearOfOrderDate] = 2013
ORDER BY [Month] ASC
--Quantity of Orders Month over Month in 2014	
SELECT DISTINCT [YearOfOrderDate] as [Year],Month, MonthName as [Month Name], 
			SUM([Orders]) OVER (PARTITION BY [Month]) as [Quantity of Orders by Month]
FROM QuanitityOfOrdersByMonth
WHERE [YearOfOrderDate] = 2014
ORDER BY [Month] ASC

--9.q) Quantity of Orders month over month for all years created by Pivot
SELECT 
	Year,
	[January], [February], [March], [April], [May], [June], [July], [August], [September], [October], [November], [December]
FROM
(
SELECT DISTINCT [YearOfOrderDate] as [Year], MonthName as [Month Name], 
			SUM([Orders]) OVER (PARTITION BY [Month]) as [Quantity of Orders by Month]
FROM QuanitityOfOrdersByMonth
WHERE [YearOfOrderDate] = 2011
) as Src
PIVOT 
(
	SUM([Quantity of Orders by Month])
	FOR [Month Name] IN ([January], [February], [March], [April], [May], [June], [July], [August], [September], [October], [November], [December])
) as Pvt
UNION
SELECT [Year],
	[January], [February], [March], [April], [May], [June], [July], [August], [September], [October], [November], [December]
FROM
(
SELECT DISTINCT [YearOfOrderDate] as [Year], MonthName as [Month Name], 
			SUM([Orders]) OVER (PARTITION BY [Month]) as [Quantity of Orders by Month]
FROM QuanitityOfOrdersByMonth
WHERE [YearOfOrderDate] = 2012
) as Src1
PIVOT (
	SUM([Quantity of Orders by Month])
	FOR [Month Name] IN ([January], [February], [March], [April], [May], [June], [July], [August], [September], [October], [November], [December])

) as Pvt1
UNION
SELECT [Year],
	[January], [February], [March], [April], [May], [June], [July], [August], [September], [October], [November], [December]
FROM
(
SELECT DISTINCT [YearOfOrderDate] as [Year], MonthName as [Month Name], 
			SUM([Orders]) OVER (PARTITION BY [Month]) as [Quantity of Orders by Month]
FROM QuanitityOfOrdersByMonth
WHERE [YearOfOrderDate] = 2013
) as Src2
PIVOT
(
	SUM([Quantity of Orders by Month])
	FOR [Month Name] IN ([January], [February], [March], [April], [May], [June], [July], [August], [September], [October], [November], [December])
) as PvT2
UNION
SELECT [Year],
		[January], [February], [March], [April], [May], [June], [July], [August], [September], [October], [November], [December]
FROM
(
SELECT DISTINCT [YearOfOrderDate] as [Year], MonthName as [Month Name], 
			SUM([Orders]) OVER (PARTITION BY [Month]) as [Quantity of Orders by Month]
FROM QuanitityOfOrdersByMonth
WHERE [YearOfOrderDate] = 2014
) as Src3
PIVOT
(
	SUM([Quantity of Orders by Month])
	FOR [Month Name] IN ([January], [February], [March], [April], [May], [June], [July], [August], [September], [October], [November], [December])
) as Pvt3

-- 10.a) Sales by Country
CREATE FUNCTION SalesOfCountryByYears
(
	@StartYear int,
	@EndYear int
)
RETURNS TABLE
AS
RETURN
	SELECT DISTINCT [Country], SUM([Sales]) OVER (PARTITION BY [Country]) as Sales
	FROM [Project4].[dbo].[SuperStore]
	WHERE [YearOfOrderDate] BETWEEN @StartYear AND @EndYear
--10.b) Sales of Country in all years
SELECT *
FROM SalesOfCountryByYears(2011,2014)
ORDER BY [Sales] DESC
--2011
SELECT *
FROM SalesOfCountryByYears(2011,2011)
ORDER BY [Sales] DESC
--2012
SELECT *
FROM SalesOfCountryByYears(2012,2012)
ORDER BY [Sales] DESC
--2013
SELECT *
FROM SalesOfCountryByYears(2013,2013)
ORDER BY [Sales] DESC
--2014
SELECT *
FROM SalesOfCountryByYears(2014,2014)
ORDER BY [Sales] DESC

--10.c)  TOP10 Countries of Sales
SELECT TOP 10 with TIES *
FROM SalesOfCountryByYears(2011,2014)
ORDER BY [Sales] DESC
--10.d)  Countries with Sales greater than Average
SELECT *
FROM SalesOfCountryByYears(2011,2014)
WHERE [Sales] > (SELECT AVG([Sales]) FROM [Project4].[dbo].[SuperStore]) 
ORDER BY [Sales] DESC
--10.e) Country with the greatest Sales and Lowest Sales in all years
SELECT DISTINCT FIRST_VALUE([Country]) OVER (ORDER BY [Sales] DESC) AS [Country with the greatest Sales], MAX([Sales]) OVER () as [The Greatest Sales],
		LAST_VALUE([Country]) OVER (ORDER BY [Sales] DESC 
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Sales],
		MIN([Sales]) OVER () as [The Lowest Sales]
FROM SalesOfCountryByYears(2011,2014)

-- 10.f) Cumulative Distribution of Sales by Country
CREATE VIEW CumDistOfSales AS 
	SELECT *, CAST(ROUND(CUME_DIST() OVER (ORDER BY [Sales] DESC)*100,2) AS FLOAT) as [Cumulative Distrubtion %]
	FROM SalesOfCountryByYears(2011,2014)

-- 10.g) Cumulative Distribution of Sales
SELECT *
FROM CumDistOfSales

-- 10.h) TOP 25 % Sales of Country 
SELECT *
FROM CumDistOfSales
WHERE [Cumulative Distrubtion %] < 25

-- 10.i) Percentage Rank of Country of Sales
CREATE VIEW PercentageRankOfCountry AS 
	SELECT *, CAST(ROUND(PERCENT_RANK() over (ORDER BY [Sales])*100,2) AS FLOAT) as [Percentage Rank]
	FROM SalesOfCountryByYears(2011,2014)

SELECT *
FROM PercentageRankOfCountry
--10.j) Group of Country of Sales by 3 levels (Low, Mid, High)

WITH GroupOfCountryBy3Levels AS 
(
	SELECT *, NTILE(3) OVER (ORDER BY [Sales] DESC) AS [Buckets]
	FROM SalesOfCountryByYears(2011,2014)
	
)
SELECT Country,
	CASE	
		WHEN [Buckets] = 1 THEN 'High Sales'
		WHEN [Buckets] = 2 THEN 'Mid Sales'
		WHEN [Buckets] = 3 THEN 'Low Sales'
	END AS [Level of Sales]
FROM GroupOfCountryBy3Levels


-- 10.k) Group of Country of Sales by three levels in each year 

--2011
WITH GroupOfCountryOfSalesByThreeLevels2011 AS 
(
SELECT *, NTILE(3) OVER (ORDER BY [Sales] DESC) as 'Buckets'
FROM SalesOfCountryByYears(2011,2011)
)
SELECT [Country], 
	CASE
		WHEN [Buckets] = 1 THEN 'High Sales'
		WHEN [Buckets] = 2 THEN 'Mid Sales'
		WHEN [Buckets] = 3 THEN 'Low Sales'
	END AS [Level of Sales]
FROM GroupOfCountryOfSalesByThreeLevels2011
ORDER BY [Sales] DESC

--2012
WITH GroupOfCountryOfSalesByThreeLevels2012 AS 
(
SELECT *, NTILE(3) OVER (ORDER BY [Sales] DESC) as 'Buckets'
FROM SalesOfCountryByYears(2012,2012)
)
SELECT [Country], 
	CASE
		WHEN [Buckets] = 1 THEN 'High Sales'
		WHEN [Buckets] = 2 THEN 'Mid Sales'
		WHEN [Buckets] = 3 THEN 'Low Sales'
	END AS [Level of Sales]
FROM GroupOfCountryOfSalesByThreeLevels2012
ORDER BY [Sales] DESC
--2013
WITH GroupOfCountryOfSalesByThreeLevels2013 AS 
(
SELECT *, NTILE(3) OVER (ORDER BY [Sales] DESC) as 'Buckets'
FROM SalesOfCountryByYears(2013,2013)
)
SELECT [Country], 
	CASE
		WHEN [Buckets] = 1 THEN 'High Sales'
		WHEN [Buckets] = 2 THEN 'Mid Sales'
		WHEN [Buckets] = 3 THEN 'Low Sales'
	END AS [Level of Sales]
FROM GroupOfCountryOfSalesByThreeLevels2013
ORDER BY [Sales] DESC
--2014
WITH GroupOfCountryOfSalesByThreeLevels2014 AS 
(
SELECT *, NTILE(3) OVER (ORDER BY [Sales] DESC) as 'Buckets'
FROM SalesOfCountryByYears(2014,2014)
)
SELECT [Country], 
	CASE
		WHEN [Buckets] = 1 THEN 'High Sales'
		WHEN [Buckets] = 2 THEN 'Mid Sales'
		WHEN [Buckets] = 3 THEN 'Low Sales'
	END AS [Level of Sales]
FROM GroupOfCountryOfSalesByThreeLevels2014
ORDER BY [Sales] DESC


-- 10.l) The greatest and Lowest Sales of Country in all year
CREATE FUNCTION GreatestAndLowestSalesOfCountry
( 
	@Year int
)
RETURNS TABLE 
AS
RETURN
	SELECT DISTINCT [YearOfOrderDate],[Country], SUM([Sales]) OVER (PARTITION BY [Country]) as Sales
	FROM [Project4].[dbo].[SuperStore]
	WHERE [YearOfOrderDate] = @Year


--10. m)  The greatest and Lowest Sales of Country in all year
	SELECT DISTINCT [YearOfOrderDate] as [Year],FIRST_VALUE([Country]) OVER (ORDER BY [Sales] DESC) AS [Country with the greatest Sales], MAX([Sales]) OVER () as [The Greatest Sales],
		LAST_VALUE([Country]) OVER (ORDER BY [Sales] DESC 
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Sales],
		MIN([Sales]) OVER () as [The Lowest Sales]
	FROM GreatestAndLowestSalesOfCountry(2011)
UNION
	SELECT DISTINCT [YearOfOrderDate] as [Year],FIRST_VALUE([Country]) OVER (ORDER BY [Sales] DESC) AS [Country with the greatest Sales], MAX([Sales]) OVER () as [The Greatest Sales],
		LAST_VALUE([Country]) OVER (ORDER BY [Sales] DESC 
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Sales],
		MIN([Sales]) OVER () as [The Lowest Sales]
	FROM GreatestAndLowestSalesOfCountry(2012)
UNION
	SELECT DISTINCT [YearOfOrderDate] as [Year],FIRST_VALUE([Country]) OVER (ORDER BY [Sales] DESC) AS [Country with the greatest Sales], MAX([Sales]) OVER () as [The Greatest Sales],
		LAST_VALUE([Country]) OVER (ORDER BY [Sales] DESC 
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Sales],
		MIN([Sales]) OVER () as [The Lowest Sales]
	FROM GreatestAndLowestSalesOfCountry(2013)
UNION
	SELECT DISTINCT [YearOfOrderDate] as [Year], FIRST_VALUE([Country]) OVER (ORDER BY [Sales] DESC) AS [Country with the greatest Sales], MAX([Sales]) OVER () as [The Greatest Sales],
		LAST_VALUE([Country]) OVER (ORDER BY [Sales] DESC 
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Sales],
		MIN([Sales]) OVER () as [The Lowest Sales]
	FROM GreatestAndLowestSalesOfCountry(2014)



--11.a) Profit of Country

CREATE FUNCTION ProfitOfCountry 
(
	@StartYear int,
	@EndYear int

)
RETURNS TABLE
AS
RETURN	
	SELECT DISTINCT [Country], SUM([Profit]) OVER (PARTITION BY [Country]) as Profit
	FROM [Project4].[dbo].[SuperStore]
	WHERE [YearOfOrderDate] BETWEEN @StartYear AND @EndYear
	

--11.b)  Profit of Country
SELECT *
FROM ProfitOfCountry(2011,2014)
ORDER BY [Profit] DESC

--11.c) Profit of  Country in all years
--2011
SELECT *
FROM ProfitOfCountry(2011,2011)
ORDER BY [Profit] DESC
--2012
SELECT *
FROM ProfitOfCountry(2012,2012)
ORDER BY [Profit] DESC
--2013
SELECT *
FROM ProfitOfCountry(2013,2013)
ORDER BY [Profit] DESC
--2014
SELECT *
FROM ProfitOfCountry(2014,2014)
ORDER BY [Profit] DESC

-- 10.d) TOP10 Countries of Profit
SELECT TOP 10 WITH TIES *
FROM ProfitOfCountry(2011,2014)
ORDER BY [Profit] DESC

-- 10.e) Countires with Profit greater than average
SELECT *
FROM ProfitOfCountry(2011,2014)
WHERE [Profit] > (SELECT AVG([Profit]) FROM [Project4].[dbo].[SuperStore])
ORDER BY [Profit] DESC

--10.f)  Country with the greatest and Lowest Profit in all years
SELECT DISTINCT  FIRST_VALUE([Country]) OVER (ORDER BY [Profit] DESC) as [Country with the greatest Profit],
		MAX([Profit]) OVER () as [The Greatest Profit],
		LAST_VALUE([Country]) OVER (ORDER BY [Profit] DESC 
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Profit],
		MIN([Profit]) OVER () as [The lowest Profit]
FROM ProfitOfCountry(2011,2014)
WHERE [Profit] >= 1

--10.g) Cumulative Distrubtion of Profit for Countries

CREATE VIEW CumulativeDistributionOfProfitCountries AS 
	SELECT *,
		CAST(ROUND(CUME_DIST() OVER (ORDER BY [Profit] DESC)*100,2) AS FLOAT) as [Cumulative Distriubtion %]
	FROM ProfitOfCountry(2011,2014)

--10.h) Cumulative Distriubtion of Countries with Profit
SELECT *
FROM CumulativeDistributionOfProfitCountries
WHERE [Cumulative Distriubtion %] < 78
-- 10.i) Cumulative Distriubtion of Countries without Profit
SELECT *
FROM CumulativeDistributionOfProfitCountries
WHERE [Cumulative Distriubtion %] > 78

-- 10.j) TOP 25 % Profit of Countries
SELECT *
FROM CumulativeDistributionOfProfitCountries
WHERE [Cumulative Distriubtion %] < 25


-- 10.k) The Perctange Rank of Country of Profit
SELECT *, CAST(ROUND(PERCENT_RANK() OVER (ORDER BY [Profit])*100,2) AS FLOAT) as [The Percentage Rank %]
FROM ProfitOfCountry(2011,2014)
WHERE [Profit] >= 1

-- 10.l) Group of Country of Profit by 3 levels in all years
WITH GroupOfCountiesBy3Levels AS
(
	SELECT *, NTILE(3) OVER (ORDER BY [Profit] DESC) as [Buckets]
	FROM ProfitOfCountry(2011,2014)
	WHERE [Profit] >= 1
)
SELECT [Country],
		CASE
			WHEN [Buckets] = 1 THEN 'High Profit'
			WHEN [Buckets] = 2 THEN 'Mid Profit'
			WHEN [Buckets] = 3 THEN 'Low Profit'
	END AS [Level of Profit]
FROM GroupOfCountiesBy3Levels

-- 10.m) Group of Country of Profit by three levels  in each year
--2011
WITH GroupOfCountryOfProfitYearByYear2011 AS 
(
SELECT *,NTILE(3) OVER (ORDER BY [Profit] DESC) as 'Buckets'
FROM ProfitOfCountry(2011,2011)
WHERE [Profit] >= 1
)
SELECT [Country],
	CASE 
		WHEN [Buckets] = 1 THEN 'High Profit'
		WHEN [Buckets] = 2 THEN 'Mid Profit'
		WHEN [Buckets] = 3 THEN 'Low Profit'
	END AS [Level of Profit]
FROM GroupOfCountryOfProfitYearByYear2011
ORDER BY [Profit] DESC
--2012
WITH GroupOfCountryOfProfitYearByYear2012 AS 
(
SELECT *,NTILE(3) OVER (ORDER BY [Profit] DESC) as 'Buckets'
FROM ProfitOfCountry(2012,2012)
WHERE [Profit] >= 1
)
SELECT [Country],
	CASE 
		WHEN [Buckets] = 1 THEN 'High Profit'
		WHEN [Buckets] = 2 THEN 'Mid Profit'
		WHEN [Buckets] = 3 THEN 'Low Profit'
	END AS [Level of Profit]
FROM GroupOfCountryOfProfitYearByYear2012
ORDER BY [Profit] DESC
--2013
WITH GroupOfCountryOfProfitYearByYear2013 AS 
(
SELECT *,NTILE(3) OVER (ORDER BY [Profit] DESC) as 'Buckets'
FROM ProfitOfCountry(2013,2013)
WHERE [Profit] >= 1
)
SELECT [Country],
	CASE 
		WHEN [Buckets] = 1 THEN 'High Profit'
		WHEN [Buckets] = 2 THEN 'Mid Profit'
		WHEN [Buckets] = 3 THEN 'Low Profit'
	END AS [Level of Profit]
FROM GroupOfCountryOfProfitYearByYear2013
ORDER BY [Profit] DESC
--2014
WITH GroupOfCountryOfProfitYearByYear2014 AS 
(
SELECT *,NTILE(3) OVER (ORDER BY [Profit] DESC) as 'Buckets'
FROM ProfitOfCountry(2014,2014)
WHERE [Profit] >= 1
)
SELECT [Country],
	CASE 
		WHEN [Buckets] = 1 THEN 'High Profit'
		WHEN [Buckets] = 2 THEN 'Mid Profit'
		WHEN [Buckets] = 3 THEN 'Low Profit'
	END AS [Level of Profit]
FROM GroupOfCountryOfProfitYearByYear2014
ORDER BY [Profit] DESC

--10.n) The greatest and lowest Profit year by year

CREATE FUNCTION ProfitOfCountryYearbyYear
(
		@Year int
)
RETURNS TABLE
AS
RETURN
	SELECT DISTINCT [Country], SUM([Profit]) OVER (PARTITION BY [Country]) as Profit,
			[YearOfOrderDate] as [Year]
	FROM [Project4].[dbo].[SuperStore]
	WHERE [YearOfOrderDate] = @Year

SELECT DISTINCT [Year],
		FIRST_VALUE([Country]) OVER (ORDER BY [Profit] DESC) as [Country with the Greatest Profit],
		MAX([Profit]) OVER () as [The greatest Profit],
		LAST_VALUE([Country]) OVER (ORDER BY [Profit] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Profit],
		MIN([Profit]) OVER () as [The Lowest Profit]
FROM ProfitOfCountryYearbyYear(2011)
WHERE [Profit] >= 1
UNION
SELECT DISTINCT [Year],
		FIRST_VALUE([Country]) OVER (ORDER BY [Profit] DESC) as [Country with the Greatest Profit],
		MAX([Profit]) OVER () as [The greatest Profit],
		LAST_VALUE([Country]) OVER (ORDER BY [Profit] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)  as [Country with the lowest Profit],
		MIN([Profit]) OVER () as [The lowest Profit]
FROM ProfitOfCountryYearbyYear(2012)
WHERE [Profit] >= 1
UNION
SELECT DISTINCT [Year],
		FIRST_VALUE([Country]) OVER (ORDER BY [Profit] DESC) as [Country with the Greatest Profit],
		MAX([Profit]) OVER () as [The greatest Profit],
		LAST_VALUE([Country]) OVER (ORDER BY [Profit] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)  as [Country with the lowest Profit],
		MIN([Profit]) OVER () as [The lowest Profit]
FROM ProfitOfCountryYearbyYear(2013)
WHERE [Profit] >= 1
UNION
SELECT DISTINCT [Year],
		FIRST_VALUE([Country]) OVER (ORDER BY [Profit] DESC) as [Country with the Greatest Profit],
		MAX([Profit]) OVER () as [The greatest Profit],
		LAST_VALUE([Country]) OVER (ORDER BY [Profit] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)  as [Country with the lowest Profit],
		MIN([Profit]) OVER () as [The lowest Profit]
FROM ProfitOfCountryYearbyYear(2014)
WHERE [Profit] >= 1

---11.a) The Shipping cost of City

CREATE FUNCTION ShippingCostYear (
	@StartYear int,
	@EndYear int

)
RETURNS TABLE
AS
RETURN
	SELECT DISTINCT [Country], SUM([Shipping Cost]) OVER (PARTITION BY [Country]) as [Shipping Cost]
	FROM [Project4].[dbo].[SuperStore]
	WHERE [YearOfOrderDate] BETWEEN @StartYear and @EndYear



--11.b) Shipping Cost of Country in all years
SELECT *
FROM ShippingCostYear(2011,2014)
ORDER BY [Shipping Cost] DESC
--2011
SELECT *
FROM ShippingCostYear(2011,2011)
ORDER BY [Shipping Cost] DESC
--2012
SELECT *
FROM ShippingCostYear(2012,2012)
ORDER BY [Shipping Cost] DESC
--2013
SELECT *
FROM ShippingCostYear(2013,2013)
ORDER BY [Shipping Cost] DESC
--2014
SELECT *
FROM ShippingCostYear(2014,2014)
ORDER BY [Shipping Cost] DESC


-- 11.c) TOP 10 Countries in all years
--TOP10 Shipping Cost of Countries
SELECT TOP 10 with TIES * 
FROM ShippingCostYear(2011,2014)
ORDER BY [Shipping Cost] DESC
--TOP10 Shipping Cost of Countries 2011
SELECT TOP 10 with TIES *
FROM ShippingCostYear(2011,2011)
ORDER BY [Shipping Cost] DESC
--TOP10 Shipping Cost of Countries 2012
SELECT TOP 10 with TIES *
FROM ShippingCostYear(2012,2012)
ORDER BY [Shipping Cost] DESC
--TOP10 Shipping Cost of Countries 2013
SELECT TOP 10 with TIES *
FROM ShippingCostYear(2013,2013)
ORDER BY [Shipping Cost] DESC
--TOP10 Shipping Cost of Countries 2014
SELECT TOP 10 with TIES *
FROM ShippingCostYear(2014,2014)
ORDER BY [Shipping Cost] DESC
-- 11.d) Countries with Shipping Cost higher than Average
SELECT *
FROM ShippingCostYear(2011,2014)
WHERE [Shipping Cost] > (SELECT AVG([Shipping Cost]) FROM [Project4].[dbo].[SuperStore])
ORDER BY [Shipping Cost] DESC
--11.e)  Countries with the greatest and lowest Shipping Cost
SELECT DISTINCT 
			FIRST_VALUE([Country]) OVER (ORDER BY [Shipping Cost] DESC) as [Country with the greatest Shipping Cost],
			MAX([Shipping Cost]) OVER () as [The Greatest Shipping Cost],
			LAST_VALUE([Country]) OVER (ORDER BY [Shipping Cost] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Shipping Cost],
			MIN([Shipping Cost]) OVER () as [The Lowest Shipping Cost]
FROM ShippingCostYear(2011,2014)

--11.f) Shipping Cost  Year by year
DROP FUNCTION ShippingCostYearByYear
CREATE FUNCTION ShippingCostYearByYear (
	@StartYear int

)
RETURNS TABLE
AS
RETURN
	SELECT DISTINCT [YearOfOrderDate], [Country], SUM([Shipping Cost]) OVER (PARTITION BY [Country]) as [Shipping Cost]
	FROM [Project4].[dbo].[SuperStore]
	WHERE [YearOfOrderDate] = @StartYear 


SELECT		[YearOfOrderDate] as [Year],
			FIRST_VALUE([Country]) OVER (ORDER BY [Shipping Cost] DESC) as [Country with the greatest Shipping Cost],
			MAX([Shipping Cost]) OVER () as [The Greatest Shipping Cost],
			LAST_VALUE([Country]) OVER (ORDER BY [Shipping Cost] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Shipping Cost],
			MIN([Shipping Cost]) OVER () as [The Lowest Shipping Cost]
FROM ShippingCostYearByYear(2011)
UNION
SELECT		[YearOfOrderDate] as [Year],
			FIRST_VALUE([Country]) OVER (ORDER BY [Shipping Cost] DESC) as [Country with the greatest Shipping Cost],
			MAX([Shipping Cost]) OVER () as [The Greatest Shipping Cost],
			LAST_VALUE([Country]) OVER (ORDER BY [Shipping Cost] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Shipping Cost],
			MIN([Shipping Cost]) OVER () as [The Lowest Shipping Cost]
FROM ShippingCostYearByYear(2012)
UNION
SELECT		[YearOfOrderDate] as [Year],
			FIRST_VALUE([Country]) OVER (ORDER BY [Shipping Cost] DESC) as [Country with the greatest Shipping Cost],
			MAX([Shipping Cost]) OVER () as [The Greatest Shipping Cost],
			LAST_VALUE([Country]) OVER (ORDER BY [Shipping Cost] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Shipping Cost],
			MIN([Shipping Cost]) OVER () as [The Lowest Shipping Cost]
FROM ShippingCostYearByYear(2013)
UNION
SELECT		[YearOfOrderDate] as [Year],
			FIRST_VALUE([Country]) OVER (ORDER BY [Shipping Cost] DESC) as [Country with the greatest Shipping Cost],
			MAX([Shipping Cost]) OVER () as [The Greatest Shipping Cost],
			LAST_VALUE([Country]) OVER (ORDER BY [Shipping Cost] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Shipping Cost],
			MIN([Shipping Cost]) OVER () as [The Lowest Shipping Cost]
FROM ShippingCostYearByYear(2014)



---12.a)  Sales by City 
CREATE FUNCTION SalesByCity 
(
	@StartYear int,
	@EndYear int
)
RETURNS TABLE
AS
RETURN
	SELECT DISTINCT 
			[Country], [City], SUM([Sales]) OVER (PARTITION BY [City]) as [Sales by City]
	FROM   [Project4].[dbo].[SuperStore]
	WHERE [YearOfOrderDate] BETWEEN @StartYear AND @EndYear


--12.b) Ranking of City by Sales 2011-2014
SELECT rank() OVER (ORDER BY [Sales by City] DESC) as Ranking, *
FROM SalesByCity(2011,2014)
ORDER BY [Sales by City] DESC
--12.c)  Group of City by three level of Sales (low, mid, high)
WITH GroupOfSalesByCity AS (
	SELECT *, NTILE(3) OVER (ORDER BY [Sales by City] DESC) as [Buckets]
	FROM SalesByCity(2011,2014)
)
SELECT [Country], [City],
		CASE
			WHEN [Buckets] = 1 THEN 'High Sales'
			WHEN [Buckets] = 2 THEN 'Mid Sales'
			WHEN [Buckets] = 3 THEN 'Low Sales'
		END AS 'Level of Sales'
FROM GroupOfSalesByCity

-- 12.d) Ranking of City by Sales with Sales greater than average
SELECT rank() OVER (ORDER BY [Sales by City] DESC) as Ranking, *
FROM SalesByCity(2011,2014)
WHERE [Sales By City] > (SELECT AVG(Sales) FROM [Project4].[dbo].[SuperStore])
ORDER BY [Sales by City] DESC
-- 12.e) The greatest and lowest Sales of City
SELECT DISTINCT 
	FIRST_VALUE([Country]) OVER (ORDER BY [Sales by City] DESC) as [City with the greatest Sales],
	FIRST_VALUE([City]) OVER (ORDER BY [Sales by City] DESC) as [City with the greatest Sales],
	MAX([Sales by City]) OVER () as [City with the greatest Sales],
	LAST_VALUE([Country]) OVER (ORDER BY [Sales by City] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the lowest Sales],
	LAST_VALUE([City]) OVER (ORDER BY [Sales by City] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the lowest Sales],
	MIN([Sales by City]) OVER () as [City with the greatest Sales]
FROM SalesByCity(2011,2014)


--12.f) Ranking of City by Sales 2011-2011
SELECT rank() OVER (ORDER BY [Sales by City] DESC) as Ranking,*
FROM SalesByCity(2011,2011)
ORDER BY [Sales by City] DESC
--Ranking of City by Sales 2012-2012
SELECT rank() OVER (ORDER BY [Sales by City] DESC) as Ranking,*
FROM SalesByCity(2012,2012)
ORDER BY [Sales by City] DESC
--Ranking of City by Sales 2013-2013
SELECT rank() OVER (ORDER BY [Sales by City] DESC) as Ranking, *
FROM SalesByCity(2013,2013)
ORDER BY [Sales by City] DESC
--Ranking of City by Sales 2014-2014
SELECT rank() OVER (ORDER BY [Sales by City] DESC) as Ranking,*
FROM SalesByCity(2014,2014)
ORDER BY [Sales by City] DESC


--12.g) Sales of City Year by year
CREATE FUNCTION SalesByCityYearByYear
(
	@Year int
)
RETURNS TABLE
AS
RETURN
	SELECT DISTINCT 
			[YearOfOrderDate] ,[Country], [City], SUM([Sales]) OVER (PARTITION BY [City]) as [Sales by City]
	FROM   [Project4].[dbo].[SuperStore]
	WHERE [YearOfOrderDate] = @Year

--12.h)  Sales of City Year by Year
SELECT DISTINCT
	[YearOfOrderDate] as [Year],
	FIRST_VALUE([Country]) OVER (ORDER BY [Sales by City] DESC) as [City with the greatest Sales],
	FIRST_VALUE([City]) OVER (ORDER BY [Sales by City] DESC) as [City with the greatest Sales],
	MAX([Sales by City]) OVER () as [City with the greatest Sales],
	LAST_VALUE([Country]) OVER (ORDER BY [Sales by City] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the lowest Sales],
	LAST_VALUE([City]) OVER (ORDER BY [Sales by City] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the lowest Sales],
	MIN([Sales by City]) OVER () as [City with the greatest Sales]
FROM SalesByCityYearByYear(2011)
UNION
SELECT DISTINCT
	[YearOfOrderDate] as [Year],
	FIRST_VALUE([Country]) OVER (ORDER BY [Sales by City] DESC) as [City with the greatest Sales],
	FIRST_VALUE([City]) OVER (ORDER BY [Sales by City] DESC) as [City with the greatest Sales],
	MAX([Sales by City]) OVER () as [City with the greatest Sales],
	LAST_VALUE([Country]) OVER (ORDER BY [Sales by City] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the lowest Sales],
	LAST_VALUE([City]) OVER (ORDER BY [Sales by City] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the lowest Sales],
	MIN([Sales by City]) OVER () as [City with the greatest Sales]
FROM SalesByCityYearByYear(2012)
UNION
SELECT DISTINCT
	[YearOfOrderDate] as [Year],
	FIRST_VALUE([Country]) OVER (ORDER BY [Sales by City] DESC) as [City with the greatest Sales],
	FIRST_VALUE([City]) OVER (ORDER BY [Sales by City] DESC) as [City with the greatest Sales],
	MAX([Sales by City]) OVER () as [City with the greatest Sales],
	LAST_VALUE([Country]) OVER (ORDER BY [Sales by City] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the lowest Sales],
	LAST_VALUE([City]) OVER (ORDER BY [Sales by City] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the lowest Sales],
	MIN([Sales by City]) OVER () as [City with the greatest Sales]
FROM SalesByCityYearByYear(2013)
UNION
SELECT DISTINCT
	[YearOfOrderDate] as [Year],
	FIRST_VALUE([Country]) OVER (ORDER BY [Sales by City] DESC) as [City with the greatest Sales],
	FIRST_VALUE([City]) OVER (ORDER BY [Sales by City] DESC) as [City with the greatest Sales],
	MAX([Sales by City]) OVER () as [City with the greatest Sales],
	LAST_VALUE([Country]) OVER (ORDER BY [Sales by City] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the lowest Sales],
	LAST_VALUE([City]) OVER (ORDER BY [Sales by City] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the lowest Sales],
	MIN([Sales by City]) OVER () as [City with the greatest Sales]
FROM SalesByCityYearByYear(2014)




-- 12. i) TOP 10 City of Sales
SELECT DISTINCT TOP 10 with TIES
			[Country], [City],  SUM([Sales]) OVER (PARTITION BY [City]) as [Sales by City]
FROM   [Project4].[dbo].[SuperStore]
ORDER BY [Sales by City] DESC


-- 12.j) TOP 10 City of Sales Year by Year 
CREATE PROCEDURE TOP10ofSalesYear @Year int
AS
	SELECT DISTINCT TOP 10 with TIES
			[Country], [City],  
			SUM([Sales]) OVER (PARTITION BY [City]) as [Sales by City]
	FROM   [Project4].[dbo].[SuperStore]
	WHERE [YearOfOrderDate] = @Year
	ORDER BY [Sales by City] DESC
GO

EXEC TOP10ofSalesYear @Year = 2011
EXEC TOP10ofSalesYear @Year = 2012
EXEC TOP10ofSalesYear @Year = 2013
EXEC TOP10ofSalesYear @Year = 2014
-- 12. k) TOP 10 BOTTOM City of Sales Year by Year
CREATE PROCEDURE TOP10OfSalesBottomYear @Year int
AS
	SELECT DISTINCT TOP 10 with TIES
			[Country], [City],  
			SUM([Sales]) OVER (PARTITION BY [City]) as [Sales by City]
	FROM   [Project4].[dbo].[SuperStore]
	WHERE [YearOfOrderDate] = @Year
	ORDER BY [Sales by City] ASC

GO

EXEC TOP10OfSalesBottomYear @Year = 2011
EXEC TOP10OfSalesBottomYear @Year = 2012
EXEC TOP10OfSalesBottomYear @Year = 2013
EXEC TOP10OfSalesBottomYear @Year = 2014


--12.l)  Temp Table was created to calculate  Cumulative Distrubtion of City!
DROP TABLE IF EXISTS #SalesByCity 
CREATE TABLE #SalesByCity 
(
	[City] nvarchar(max),
	[Sales by City] bigint
)

INSERT INTO #SalesByCity
SELECT DISTINCT 
		 [City], SUM([Sales]) OVER (PARTITION BY [City]) as [Sales by City]
FROM   [Project4].[dbo].[SuperStore]

--12.m) Cumulative Distribution of City
SELECT *, CAST(ROUND(CUME_DIST() OVER (ORDER BY [Sales by City] DESC)*100,2) as FLOAT) as [Cumulative Distribution (%)]
FROM #SalesByCity

--12.n)  TOP 25 % of City 
WITH TOP25ofCity AS (
	SELECT *, CAST(ROUND(CUME_DIST() OVER (ORDER BY [Sales by City] DESC)*100,2) as FLOAT) as [Cumulative Distribution (%)]
	FROM #SalesByCity
)
SELECT [City], [Cumulative Distribution (%)]
FROM TOP25ofCity
WHERE [Cumulative Distribution (%)] <= 25

--12.o)  The Percentage Rank of Sales by City

SELECT [City], CAST(ROUND(Percent_RANK() OVER (ORDER BY [Sales by City])*100,2) as FLOAT) as [Percentage Rank (%)]
FROM #SalesByCity


--12.p) Sales of Country and their cities with the highest Sales and Lowest Sales. 
CREATE VIEW SalesOfCountryAndTheirCities AS
	SELECT DISTINCT 
				[Country],
				[City], 
				SUM([Sales]) OVER (PARTITION BY [City]) as [Sales by City]
		FROM   [Project4].[dbo].[SuperStore]
--12.q) Ranking of City	
SELECT [Country], RANK() OVER (PARTITION BY [Country] ORDER BY [Sales by City] DESC) as Ranking, 
		[City], 
		[Sales by City]
FROM SalesOfCountryAndTheirCities

-- 12.r) Country and their Cities with the greatest and lowest Sales
WITH GreatestAndLowestSalesByCity AS (
SELECT [Country], 
		[City], 
		[Sales by City]
FROM SalesOfCountryAndTheirCities
)
SELECT DISTINCT [Country],
				FIRST_VALUE([City]) OVER (PARTITION BY [Country] ORDER BY [Sales by City] DESC) as [The Greatest Sales by City],
				MAX([Sales by City]) OVER (PARTITION BY [Country] ORDER BY [Sales by City] DESC) as [The Greatest Sales by City],
				LAST_VALUE([City]) OVER (PARTITION BY [Country] ORDER BY [Sales by City] DESC
				RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The Lowest Sales by City],
				MIN([Sales by City]) OVER (PARTITION BY [Country]) as [The Lowest Sales by City]
FROM GreatestAndLowestSalesByCity

--12.s)  The most Sales from Country and which Year
CREATE PROCEDURE SalesOfCountryAndTheirCountry @Year int
AS
	SELECT DISTINCT 
			[YearOfOrderDate],
			[Country],
			[City],
			SUM([Sales]) OVER (PARTITION BY [City],[YearOfOrderDate]) as [Sales by City]
	FROM   [Project4].[dbo].[SuperStore]
	WHERE [YearOfOrderDate] = @Year

-- 12.t) Sales by City 
--2011
EXEC SalesOfCountryAndTheirCountry @Year = 2011
--2012
EXEC SalesOfCountryAndTheirCountry @Year = 2012
--2013
EXEC SalesOfCountryAndTheirCountry @Year = 2013
--2014
EXEC SalesOfCountryAndTheirCountry @Year = 2014


-- 12. u) Sales of Country and their City by Customer
CREATE TABLE #SalesOfCountryCityByCustomer (
 [Country] nvarchar(max),
 [City] nvarchar(max),
 [Customer Name] nvarchar(max),
 [Sales of City by Customer] bigint
)

INSERT INTO #SalesOfCountryCityByCustomer
	SELECT DISTINCT 
				[Country],
				[City],
				[Customer Name], 
				SUM([Sales]) OVER (PARTITION BY [Customer Name],[City]) as [Sales of City By Customer]
	FROM   [Project4].[dbo].[SuperStore]

-- 12.v) Ranking of Customer from each city
SELECT [Country],
		RANK() OVER (PARTITION BY [Country] ORDER BY [Sales of City By Customer] DESC) as [Ranking],
		[City],
		[Customer Name],
		[Sales of City by Customer]
FROM #SalesOfCountryCityByCustomer

--12.w)  Customers with the greatest and lowest Sales and their city and country
WITH GreatestAndLowestSalesByCustomerAndCity AS (
SELECT [Country],
		[City],
		[Customer Name],
		[Sales of City by Customer]
FROM #SalesOfCountryCityByCustomer
)
SELECT DISTINCT
				[Country],
				FIRST_VALUE([City]) OVER (PARTITION BY [Country] ORDER BY [Sales of City By Customer] DESC) as [City],
				FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Country] ORDER BY [Sales of City By Customer] DESC) as [Customer with the greatest Sales],
				MAX([Sales of City by Customer]) OVER (PARTITION BY [Country]) as [The Greatest Sales],
				LAST_VALUE([City]) OVER (PARTITION BY [Country] ORDER BY [Sales of City by Customer] DESC 
				RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City],
				LAST_VALUE([Customer Name]) OVER (PARTITION BY [Country] ORDER BY [Sales of City by Customer] DESC 
				RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the lowest Sales],
				MIN([Sales of City by Customer]) OVER (Partition by [Country]) as [The lowest Sales]
FROM GreatestAndLowestSalesByCustomerAndCity
ORDER BY [Country] ASC
-- 12.x) Customer with the greatest and lowest Sales from City and Country
SELECT DISTINCT
	FIRST_VALUE([Customer Name]) OVER (ORDER BY [Sales of City by Customer] DESC) as [Customer Name],
	FIRST_VALUE([Country]) OVER (ORDER BY [Sales of City by Customer] DESC) as [Country],
	FIRST_VALUE([City]) OVER (ORDER BY [Sales of City by Customer] DESC) as [City],
	MAX([Sales of City by Customer]) OVER () as [The Greatest Sales],
	LAST_VALUE([Customer Name]) OVER (ORDER BY [Sales of City by Customer] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer Name],
	LAST_VALUE([Country]) OVER (ORDER BY [Sales of City by Customer] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country],
	LAST_VALUE([City]) OVER (ORDER BY [Sales of City by Customer] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City],
	MIN([Sales of City by Customer]) OVER () as [The lowest Sales]
FROM #SalesOfCountryCityByCustomer




-- 12.y) Sales of Country and  City by Customer year by year

SELECT DISTINCT 
	[YearOfOrderDate],[Country], [City],[Customer Name], 
	SUM([Sales]) OVER (PARTITION BY [Customer Name],[City],[YearOfOrderDate]) as [Sales of City By Customer]
	FROM   [Project4].[dbo].[SuperStore]
	WHERE [YearOfOrderDate] = 2011

CREATE PROCEDURE SalesCountryCityYearByYear @Year int
AS
	SELECT DISTINCT 
	[YearOfOrderDate],[Country], [City],[Customer Name], 
	SUM([Sales]) OVER (PARTITION BY [Customer Name],[City],[YearOfOrderDate]) as [Sales of City By Customer]
	FROM   [Project4].[dbo].[SuperStore]
	WHERE [YearOfOrderDate] = @Year
GO

EXEC SalesCountryCityYearByYear @Year = 2011
EXEC SalesCountryCityYearByYear @Year = 2012
EXEC SalesCountryCityYearByYear @Year = 2013
EXEC SalesCountryCityYearByYear @Year = 2014



-- 12.z) The Greatest and Lowest Sales by Customer, City and Country and Ranking

CREATE FUNCTION SalesOfCountryCityYearByYear (
	@StartYear int,
	@EndYear int
)
RETURNS TABLE
AS
RETURN
	SELECT DISTINCT 
	[YearOfOrderDate],
	[Country], 
	[City],
	[Customer Name], 
	SUM([Sales]) OVER (PARTITION BY [Customer Name],[City],[YearOfOrderDate]) as [Sales of City By Customer]
	FROM   [Project4].[dbo].[SuperStore]
	WHERE [YearOfOrderDate] BETWEEN @StartYear AND @EndYear

--	12. aa)The Ranking Sales of Country and  City by Customer in all years
SELECT *
FROM SalesOfCountryCityYearByYear(2011,2014)

--2011
SELECT [YearOfOrderDate], [Country], RANK() OVER (PARTITION BY [Country] ORDER BY [Sales Of City By Customer] DESC) as Ranking,
		[City], [Customer Name], [Sales of City by Customer]
FROM SalesOfCountryCityYearByYear(2011,2011)
 
--2012
SELECT [YearOfOrderDate], [Country], RANK() OVER (PARTITION BY [Country] ORDER BY [Sales Of City By Customer] DESC) as Ranking,
		[City], [Customer Name], [Sales of City by Customer]
FROM SalesOfCountryCityYearByYear(2012,2012)

-- 2013
SELECT [YearOfOrderDate], [Country], RANK() OVER (PARTITION BY [Country] ORDER BY [Sales Of City By Customer] DESC) as Ranking,
		[City], [Customer Name], [Sales of City by Customer]
FROM SalesOfCountryCityYearByYear(2013,2013)

--2014
SELECT [YearOfOrderDate], [Country], RANK() OVER (PARTITION BY [Country] ORDER BY [Sales Of City By Customer] DESC) as Ranking,
		[City], [Customer Name], [Sales of City by Customer]
FROM SalesOfCountryCityYearByYear(2014,2014)

-- 12. ab) TOP 10 Customer, City with the greatest Sales
SELECT TOP 10 WITH TIES *
FROM SalesOfCountryCityYearByYear(2011,2014)
ORDER BY [Sales of City By Customer] DESC
-- 12. ac) TOP 10 Customer, City with the lowest Sales
SELECT TOP 10 WITH TIES *
FROM SalesOfCountryCityYearByYear(2011,2014)
ORDER BY [Sales of City By Customer] ASC
-- 12. ad) Customer, City with the greatest Sales than Average
SELECT *
FROM SalesOfCountryCityYearByYear(2011,2014)
WHERE [Sales of City by Customer] > (SELECT AVG([Sales]) FROM   [Project4].[dbo].[SuperStore])
--

-- 12.ae) The greatest Sales of Customer, City, Country and Year
WITH TheGreatestLowestSalesByCustomerAndCity AS (
	SELECT *
	FROM SalesOfCountryCityYearByYear(2011,2014)
)
SELECT DISTINCT	
				FIRST_VALUE([YearOfOrderDate]) OVER (PARTITION BY [Country] ORDER BY [Sales Of City By Customer] DESC) as [Year Of The Greatest Sales],
				[Country],
			FIRST_VALUE([City]) OVER (PARTITION BY [Country] ORDER BY [Sales Of City By Customer] DESC) as [City of The Greatest Sales],
			FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Country] ORDER BY [Sales Of City By Customer] DESC) as [Customer with the Greatest Sales],
			MAX([Sales of City by Customer]) OVER (PARTITION BY [Country]) as [The Greatest Sales],
			LAST_VALUE([YearOfOrderDate]) OVER (PARTITION BY [Country] ORDER BY [Sales Of City By Customer] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Year Of The Lowest Sales],
			LAST_VALUE([City]) OVER (PARTITION BY [Country] ORDER BY [Sales Of City By Customer] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City of The Greatest Sales],
			LAST_VALUE([Customer Name]) OVER (PARTITION BY [Country] ORDER BY [Sales Of City By Customer] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the Greatest Sales],
			MIN([Sales of City by Customer]) OVER (PARTITION BY [Country]) as [The Lowest Sales]
FROM TheGreatestLowestSalesByCustomerAndCity
ORDER BY [Country] ASC
--12.af) Cumulative Distribution of Sales
SELECT *, ROUND(CUME_DIST() OVER (ORDER BY [Sales of City By Customer] DESC)*100,4) as [Cumulative Distribution (%)]
FROM SalesOfCountryCityYearByYear(2011,2014)
ORDER BY [Sales of City by Customer] DESC
-- 12.ag) 25% TOP Sales of Cumulative Distriubtuion by City, Customer and Year 
WITH TOP25SalesCumulativeDistributionCityCustomer AS 
(
	SELECT *, ROUND(CUME_DIST() OVER (ORDER BY [Sales of City By Customer] DESC)*100,4) as [Cumulative Distribution (%)]
	FROM SalesOfCountryCityYearByYear(2011,2014)
)
SELECT [Country], [City], [Customer Name], [Sales of City by Customer], [Cumulative Distribution (%)]
FROM TOP25SalesCumulativeDistributionCityCustomer
WHERE [Cumulative Distribution (%)] <= 25
--12.ah) The greatest and Lowest Sales by Customer and City
--2011
SELECT DISTINCT
		[YearOfOrderDate] as [Year],
				[Country],
			FIRST_VALUE([City]) OVER (PARTITION BY [Country] ORDER BY [Sales Of City By Customer] DESC) as [City of The Greatest Sales],
			FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Country] ORDER BY [Sales Of City By Customer] DESC) as [Customer with the Greatest Sales],
			MAX([Sales of City by Customer]) OVER (PARTITION BY [Country]) as [The Greatest Sales],
			LAST_VALUE([YearOfOrderDate]) OVER (PARTITION BY [Country] ORDER BY [Sales Of City By Customer] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Year Of The Lowest Sales],
			LAST_VALUE([City]) OVER (PARTITION BY [Country] ORDER BY [Sales Of City By Customer] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City of The Greatest Sales],
			LAST_VALUE([Customer Name]) OVER (PARTITION BY [Country] ORDER BY [Sales Of City By Customer] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the Greatest Sales],
			MIN([Sales of City by Customer]) OVER (PARTITION BY [Country]) as [The Lowest Sales]
FROM SalesOfCountryCityYearByYear(2011,2011)
--2012
SELECT DISTINCT
	[YearOfOrderDate] as [Year],
				[Country],
			FIRST_VALUE([City]) OVER (PARTITION BY [Country] ORDER BY [Sales Of City By Customer] DESC) as [City of The Greatest Sales],
			FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Country] ORDER BY [Sales Of City By Customer] DESC) as [Customer with the Greatest Sales],
			MAX([Sales of City by Customer]) OVER (PARTITION BY [Country]) as [The Greatest Sales],
			LAST_VALUE([YearOfOrderDate]) OVER (PARTITION BY [Country] ORDER BY [Sales Of City By Customer] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Year Of The Lowest Sales],
			LAST_VALUE([City]) OVER (PARTITION BY [Country] ORDER BY [Sales Of City By Customer] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City of The Greatest Sales],
			LAST_VALUE([Customer Name]) OVER (PARTITION BY [Country] ORDER BY [Sales Of City By Customer] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the Greatest Sales],
			MIN([Sales of City by Customer]) OVER (PARTITION BY [Country]) as [The Lowest Sales]
FROM SalesOfCountryCityYearByYear(2012,2012)

--2013
SELECT  DISTINCT
			[YearOfOrderDate] as [Year],
				[Country],
			FIRST_VALUE([City]) OVER (PARTITION BY [Country] ORDER BY [Sales Of City By Customer] DESC) as [City of The Greatest Sales],
			FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Country] ORDER BY [Sales Of City By Customer] DESC) as [Customer with the Greatest Sales],
			MAX([Sales of City by Customer]) OVER (PARTITION BY [Country]) as [The Greatest Sales],
			LAST_VALUE([YearOfOrderDate]) OVER (PARTITION BY [Country] ORDER BY [Sales Of City By Customer] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Year Of The Lowest Sales],
			LAST_VALUE([City]) OVER (PARTITION BY [Country] ORDER BY [Sales Of City By Customer] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City of The Greatest Sales],
			LAST_VALUE([Customer Name]) OVER (PARTITION BY [Country] ORDER BY [Sales Of City By Customer] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the Greatest Sales],
			MIN([Sales of City by Customer]) OVER (PARTITION BY [Country]) as [The Lowest Sales]
FROM SalesOfCountryCityYearByYear(2013,2013)
--2014
SELECT DISTINCT
			[YearOfOrderDate] as [Year],
				[Country],
			FIRST_VALUE([City]) OVER (PARTITION BY [Country] ORDER BY [Sales Of City By Customer] DESC) as [City of The Greatest Sales],
			FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Country] ORDER BY [Sales Of City By Customer] DESC) as [Customer with the Greatest Sales],
			MAX([Sales of City by Customer]) OVER (PARTITION BY [Country]) as [The Greatest Sales],
			LAST_VALUE([YearOfOrderDate]) OVER (PARTITION BY [Country] ORDER BY [Sales Of City By Customer] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Year Of The Lowest Sales],
			LAST_VALUE([City]) OVER (PARTITION BY [Country] ORDER BY [Sales Of City By Customer] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City of The Greatest Sales],
			LAST_VALUE([Customer Name]) OVER (PARTITION BY [Country] ORDER BY [Sales Of City By Customer] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the Greatest Sales],
			MIN([Sales of City by Customer]) OVER (PARTITION BY [Country]) as [The Lowest Sales]
FROM SalesOfCountryCityYearByYear(2014,2014)


-- 12. ai) The greatest and Lowest of Sales by Customer and City by all years
-- All years
WITH TheGreatestAndLowestSalesByCustomerYearCityandCountry AS (
	SELECT *
	FROM SalesOfCountryCityYearByYear(2011,2014)
) 
SELECT DISTINCT 
		FIRST_VALUE([YearOfOrderDate]) OVER (ORDER BY [Sales of City by Customer] DESC) as [Year],
		FIRST_VALUE([Country]) OVER (ORDER BY [Sales of City by Customer] DESC) as [Country with the greatest Sales],
		FIRST_VALUE([City]) OVER (ORDER BY [Sales of City by Customer] DESC) as [City with the greatest Sales],
		FIRST_VALUE([Customer Name]) OVER (ORDER BY [Sales of City by Customer] DESC) as [Customer with the greatest Sales],
		MAX([Sales of City by Customer]) OVER () as [The Greatest Sales],
		LAST_VALUE([YearOfOrderDate]) OVER (ORDER BY [Sales of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Year],
		LAST_VALUE([Country]) OVER (ORDER BY [Sales of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the greatest Sales],
		LAST_VALUE([City]) OVER (ORDER BY [Sales of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the greatest Sales],
		LAST_VALUE([Customer Name]) OVER (ORDER BY [Sales of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the greatest Sales],
		MIN([Sales of City by Customer]) OVER () as [The Lowest Sales]
FROM TheGreatestAndLowestSalesByCustomerYearCityandCountry
--12.aj) The greatest and Lowest of Sales by Customer and City by year by year and combined it by one table using UNION
SELECT DISTINCT
		[YearOfOrderDate] as [Year],
		FIRST_VALUE([Country]) OVER (ORDER BY [Sales of City by Customer] DESC) as [Country with the greatest Sales],
		FIRST_VALUE([City]) OVER (ORDER BY [Sales of City by Customer] DESC) as [City with the greatest Sales],
		FIRST_VALUE([Customer Name]) OVER (ORDER BY [Sales of City by Customer] DESC) as [Customer with the greatest Sales],
		MAX([Sales of City by Customer]) OVER () as [The Greatest Sales],
		LAST_VALUE([Country]) OVER (ORDER BY [Sales of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the greatest Sales],
		LAST_VALUE([City]) OVER (ORDER BY [Sales of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the greatest Sales],
		LAST_VALUE([Customer Name]) OVER (ORDER BY [Sales of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the greatest Sales],
		MIN([Sales of City by Customer]) OVER () as [The Lowest Sales]
FROM SalesOfCountryCityYearByYear(2011,2011)
UNION
SELECT DISTINCT
		[YearOfOrderDate] as [Year],
		FIRST_VALUE([Country]) OVER (ORDER BY [Sales of City by Customer] DESC) as [Country with the greatest Sales],
		FIRST_VALUE([City]) OVER (ORDER BY [Sales of City by Customer] DESC) as [City with the greatest Sales],
		FIRST_VALUE([Customer Name]) OVER (ORDER BY [Sales of City by Customer] DESC) as [Customer with the greatest Sales],
		MAX([Sales of City by Customer]) OVER () as [The Greatest Sales],
		LAST_VALUE([Country]) OVER (ORDER BY [Sales of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the greatest Sales],
		LAST_VALUE([City]) OVER (ORDER BY [Sales of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the greatest Sales],
		LAST_VALUE([Customer Name]) OVER (ORDER BY [Sales of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the greatest Sales],
		MIN([Sales of City by Customer]) OVER () as [The Lowest Sales]
FROM SalesOfCountryCityYearByYear(2012,2012)
UNION
SELECT DISTINCT
		[YearOfOrderDate] as [Year],
		FIRST_VALUE([Country]) OVER (ORDER BY [Sales of City by Customer] DESC) as [Country with the greatest Sales],
		FIRST_VALUE([City]) OVER (ORDER BY [Sales of City by Customer] DESC) as [City with the greatest Sales],
		FIRST_VALUE([Customer Name]) OVER (ORDER BY [Sales of City by Customer] DESC) as [Customer with the greatest Sales],
		MAX([Sales of City by Customer]) OVER () as [The Greatest Sales],
		LAST_VALUE([Country]) OVER (ORDER BY [Sales of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the greatest Sales],
		LAST_VALUE([City]) OVER (ORDER BY [Sales of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the greatest Sales],
		LAST_VALUE([Customer Name]) OVER (ORDER BY [Sales of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the greatest Sales],
		MIN([Sales of City by Customer]) OVER () as [The Lowest Sales]
FROM SalesOfCountryCityYearByYear(2013,2013)
UNION
SELECT DISTINCT
		[YearOfOrderDate] as [Year],
		FIRST_VALUE([Country]) OVER (ORDER BY [Sales of City by Customer] DESC) as [Country with the greatest Sales],
		FIRST_VALUE([City]) OVER (ORDER BY [Sales of City by Customer] DESC) as [City with the greatest Sales],
		FIRST_VALUE([Customer Name]) OVER (ORDER BY [Sales of City by Customer] DESC) as [Customer with the greatest Sales],
		MAX([Sales of City by Customer]) OVER () as [The Greatest Sales],
		LAST_VALUE([Country]) OVER (ORDER BY [Sales of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the greatest Sales],
		LAST_VALUE([City]) OVER (ORDER BY [Sales of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the greatest Sales],
		LAST_VALUE([Customer Name]) OVER (ORDER BY [Sales of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the greatest Sales],
		MIN([Sales of City by Customer]) OVER () as [The Lowest Sales]
FROM SalesOfCountryCityYearByYear(2014,2014)



--13.a)  Profit of City
CREATE FUNCTION ProfitOfCity (
	@StartYear int,
	@EndYear int

)
RETURNS TABLE
AS
RETURN 
	SELECT DISTINCT [Country], [City], SUM([Profit]) OVER (PARTITION BY [City]) as [Profit by City]
	FROM   [Project4].[dbo].[SuperStore]
	WHERE [YearOfOrderDate] BETWEEN @StartYear AND @EndYear
	
-- 13.b) Ranking of City by Profit
SELECT RANK() OVER (ORDER BY [Profit by City] DESC) as [Ranking], *
FROM ProfitOfCity(2011,2014)
WHERE [Profit by City] >= 1
-- 13.c) Group of City by three levels of Profit (low, mid and high Profit]
WITH GroupOfCity AS (
SELECT *, NTILE(3) OVER (ORDER BY [Profit by City] DESC) as [Buckets]
FROM ProfitOfCity(2011,2014)
WHERE [Profit by City] >= 1
)
SELECT [Country], [City],
	CASE	
		WHEN [Buckets] = 1 THEN 'High Profit'
		WHEN [Buckets] = 2 THEN 'Mid Profit'
		WHEN [Buckets] = 3 THEN 'Low Profit'
	END AS [Level Of Profit]
FROM GroupOfCity
-- 13.d) Ranking of City of Profit with Profit greater than Average:
SELECT RANK() OVER (ORDER BY [Profit by City] DESC) as [Ranking], *
FROM ProfitOfCity(2011,2014)
WHERE [Profit by City] > (SELECT AVG([Profit]) FROM [Project4].[dbo].[SuperStore])
--13.e) The greatest and lowest Profit by City
SELECT DISTINCT 
		FIRST_VALUE([Country]) OVER (ORDER BY [Profit by City] DESC) as [Country with the greatest Profit],
		FIRST_VALUE([City]) OVER (ORDER BY [Profit by City] DESC) as [City with the greatest Profit],
		MAX([Profit by City]) OVER () as [Profit of City],
		LAST_VALUE([Country]) OVER (ORDER BY [Profit by City] DESC 
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Profit],
		LAST_VALUE([City]) OVER (ORDER BY [Profit by City] DESC 
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the lowest Profit],
		MIN([Profit by City]) OVER () as [Profit by City]
FROM ProfitOfCity(2011,2014)
WHERE [Profit by City] >= 1
-- 13.f) TOP 10 Profit by City
SELECT TOP 10 WITH TIES *
FROM ProfitOfCity(2011,2014)
WHERE [Profit by City] >= 1
ORDER BY [Profit by City] DESC
-- 13.g) TOP 10 BOTTOM PROFIT BY CITY
SELECT TOP 10 WITH TIES *
FROM ProfitOfCity(2011,2014)
WHERE [Profit by City] >= 1
ORDER BY [Profit by City] ASC
--13.h)  Cumulative Distribution of City of Profit
SELECT *, 
	CAST(ROUND(CUME_DIST() OVER (ORDER BY [Profit by City] DESC)*100,2) as FLOAT) as [Cumulative Distribution (%)]
FROM ProfitOfCity(2011,2014)
--13.i)  Cumulative Distrubtion TOP 25 % Profit of City
WITH TOP25ProcentofProfitOfCity AS (
SELECT *, 
	CAST(ROUND(CUME_DIST() OVER (ORDER BY [Profit by City] DESC)*100,2) as FLOAT) as [Cumulative Distribution (%)]
FROM ProfitOfCity(2011,2014)
)
SELECT *
FROM TOP25ProcentofProfitOfCity
WHERE [Cumulative Distribution (%)] <= 25
--13.j)  Cumulative Distrubtion of Profit of City, which generates Profit
WITH TOP25ProcentofProfitOfCity AS (
SELECT *, 
	CAST(ROUND(CUME_DIST() OVER (ORDER BY [Profit by City] DESC)*100,2) as FLOAT) as [Cumulative Distribution (%)]
FROM ProfitOfCity(2011,2014)
)
SELECT *
FROM TOP25ProcentofProfitOfCity
WHERE [Cumulative Distribution (%)] < 78.02
-- 13.k) Cumulative Distrubtion of Profit of City, which does not generate Profit
WITH TOP25ProcentofProfitOfCity AS (
SELECT *, 
	CAST(ROUND(CUME_DIST() OVER (ORDER BY [Profit by City] DESC)*100,2) as FLOAT) as [Cumulative Distribution (%)]
FROM ProfitOfCity(2011,2014)
)
SELECT *
FROM TOP25ProcentofProfitOfCity
WHERE [Cumulative Distribution (%)] >= 78.02

-- 13.l) The percentage rank of City
SELECT *, ROUND(PERCENT_RANK() OVER (ORDER BY [Profit by City])*100,2) as [The Percentage Rank (%)]
FROM ProfitOfCity(2011,2014)
WHERE [Profit by City] >= 1

-- 13.m) Profit of City year by Year
CREATE FUNCTION ProfitOfCityYearByYear (
	@Year int
)
RETURNS TABLE
AS
RETURN 
			SELECT DISTINCT [YearOfOrderDate],[Country], [City],
			SUM([Profit]) OVER (PARTITION BY [City]) as [Profit by City]
			FROM   [Project4].[dbo].[SuperStore]
			WHERE [YearOfOrderDate] = @Year




-- 13.n) Ranking of City year by year
-- 2011
SELECT DENSE_RANK() OVER (ORDER BY [Profit by City] DESC) as [Ranking], *
FROM ProfitOfCity(2011,2011)
WHERE [Profit by City] >= 1
--2012
SELECT DENSE_RANK() OVER (ORDER BY [Profit by City] DESC) as [Ranking], *
FROM ProfitOfCity(2012,2012)
WHERE [Profit by City] >= 1
--2013
SELECT DENSE_RANK() OVER (ORDER BY [Profit by City] DESC) as [Ranking], *
FROM ProfitOfCity(2013,2013)
WHERE [Profit by City] >= 1
--2014
SELECT DENSE_RANK() OVER (ORDER BY [Profit by City] DESC) as [Ranking], *
FROM ProfitOfCity(2014,2014)
WHERE [Profit by City] >= 1


-- 13.o) The greatest and lowest Profit by City year by year 
SELECT DISTINCT
	[YearOfOrderDate] as [Year],
	FIRST_VALUE([Country]) OVER (ORDER BY [Profit by City] DESC) as [Country with the greatest Profit],
	FIRST_VALUE([City]) OVER (ORDER BY [Profit by City] DESC) as [City with the greatest Profit],
	MAX([Profit by City]) OVER () as [City with the greatest Profit],
	LAST_VALUE([Country]) OVER (ORDER BY [Profit by City] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Profit],
	LAST_VALUE([City]) OVER (ORDER BY [Profit by City] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the lowest Profit],
	MIN([Profit by City]) OVER () as [City with the lowest Profit]
FROM ProfitOfCityYearByYear(2011)
WHERE [Profit by City] >= 1
UNION
SELECT DISTINCT
	[YearOfOrderDate] as [Year],
	FIRST_VALUE([Country]) OVER (ORDER BY [Profit by City] DESC) as [Country with the greatest Profit],
	FIRST_VALUE([City]) OVER (ORDER BY [Profit by City] DESC) as [City with the greatest Profit],
	MAX([Profit by City]) OVER () as [City with the greatest Profit],
	LAST_VALUE([Country]) OVER (ORDER BY [Profit by City] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Profit],
	LAST_VALUE([City]) OVER (ORDER BY [Profit by City] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the lowest Profit],
	MIN([Profit by City]) OVER () as [City with the lowest Profit]
FROM ProfitOfCityYearByYear(2012)
WHERE [Profit by City] >= 1
UNION
SELECT DISTINCT
	[YearOfOrderDate] as [Year],
	FIRST_VALUE([Country]) OVER (ORDER BY [Profit by City] DESC) as [Country with the greatest Profit],
	FIRST_VALUE([City]) OVER (ORDER BY [Profit by City] DESC) as [City with the greatest Profit],
	MAX([Profit by City]) OVER () as [City with the greatest Profit],
	LAST_VALUE([Country]) OVER (ORDER BY [Profit by City] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Profit],
	LAST_VALUE([City]) OVER (ORDER BY [Profit by City] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the lowest Profit],
	MIN([Profit by City]) OVER () as [City with the lowest Profit]
FROM ProfitOfCityYearByYear(2013)
WHERE [Profit by City] >= 1
UNION
SELECT DISTINCT
	[YearOfOrderDate] as [Year],
	FIRST_VALUE([Country]) OVER (ORDER BY [Profit by City] DESC) as [Country with the greatest Profit],
	FIRST_VALUE([City]) OVER (ORDER BY [Profit by City] DESC) as [City with the greatest Profit],
	MAX([Profit by City]) OVER () as [City with the greatest Profit],
	LAST_VALUE([Country]) OVER (ORDER BY [Profit by City] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Profit],
	LAST_VALUE([City]) OVER (ORDER BY [Profit by City] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the lowest Profit],
	MIN([Profit by City]) OVER () as [City with the lowest Profit]
FROM ProfitOfCityYearByYear(2014)
WHERE [Profit by City] >= 1

-- 13.p) TOP 10 of City of Profit year by year 
CREATE PROCEDURE ProfitOfCityYearByYears @Year int
AS
			SELECT DISTINCT TOP 10 with TIES 
			[Country], [City],
			SUM([Profit]) OVER (PARTITION BY [City]) as [Profit by City]
			FROM   [Project4].[dbo].[SuperStore]
			WHERE [YearOfOrderDate] = @Year
			ORDER BY [Profit by City] DESC
GO



EXEC ProfitOfCityYearByYears @Year = 2011
EXEC ProfitOfCityYearByYears @Year = 2012
EXEC ProfitOfCityYearByYears @Year = 2013
EXEC ProfitOfCityYearByYears @Year = 2014

--13.q)  TOP 10 BOTTOM of City of Profit year by year
DROP PROCEDURE TOP10BottomProfitOfCityYearByYears
CREATE PROCEDURE TOP10BottomProfitOfCityYearByYears @Year int
AS
			SELECT DISTINCT TOP 10 with TIES 
			[Country], [City],
			SUM([Profit]) OVER (PARTITION BY [City]) as [Profit by City]
			FROM   [Project4].[dbo].[SuperStore]
			WHERE [YearOfOrderDate] = @Year AND [Profit] >= 1
			ORDER BY [Profit by City] ASC 
GO

EXEC TOP10BottomProfitOfCityYearByYears 2011
EXEC TOP10BottomProfitOfCityYearByYears 2012
EXEC TOP10BottomProfitOfCityYearByYears 2013
EXEC TOP10BottomProfitOfCityYearByYears 2014


-- 13.r) The ranking of City by their countries
SELECT  [Country],RANK() OVER (PARTITION BY [Country] ORDER BY [Profit by City] DESC) as [Ranking], [City], [Profit by City]
FROM ProfitOfCity(2011,2014)
WHERE [Profit by City] >= 1
--13.s) The Greatest and Lowest Profit by cities and their country
SELECT  DISTINCT Country, 
		FIRST_VALUE([City]) OVER (PARTITION BY [Country] ORDER BY [Profit by City] DESC) as [City with the greatest Profit],
		MAX([Profit by City]) OVER (PARTITION BY [Country]) AS  [The greatest Profit],
		LAST_VALUE([City]) OVER (PARTITION BY [Country] ORDER BY [Profit by City] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the lowest Profit],
		MIN([Profit by City]) OVER (PARTITION BY [Country]) AS [The lowest Profit]
FROM ProfitOfCity(2011,2014)
WHERE [Profit by City] >= 1
-- 13.t) Profit of City by Year
DROP PROCEDURE ProfitByCityYear
CREATE PROCEDURE ProfitByCityYear @Year int
AS
	SELECT DISTINCT  
		[YearOfOrderDate] as [Year],
		[Country],
		[City],
		SUM([Profit]) OVER (PARTITION BY [City],[YearOfOrderDate]) as [Profit by City]
	FROM   [Project4].[dbo].[SuperStore]
	WHERE  [Profit] >= 1 AND [YearOfOrderDate]= @Year
	
GO


EXEC ProfitByCityYear @Year = 2011
EXEC ProfitByCityYear @Year = 2012
EXEC ProfitByCityYear @Year = 2013
EXEC ProfitByCityYear @Year = 2014


-- 13. u)Profit of Countries and their City by Customer
CREATE TABLE #ProfitOfCountryCityByCustomer
(
	[Country] nvarchar(MAX),
	[City] nvarchar(MAX),
	[Customer Name] nvarchar(MAX),
	[Profit by Customer] bigint

)

INSERT INTO #ProfitOfCountryCityByCustomer
SELECT DISTINCT  
		[Country],
		[City],
		[Customer Name],
		SUM([Profit]) OVER (PARTITION BY [City],[Customer Name]) as [Profit by Customer]
	FROM   [Project4].[dbo].[SuperStore]
	WHERE  [Profit] >= 1

--13.v)   The ranking of customer from each city 
SELECT [Country], 
		RANK() OVER (PARTITION BY [Country] ORDER BY [Profit by Customer] DESC) as [Ranking],
		[City],
		[Customer Name],
		[Profit by Customer]
FROM #ProfitOfCountryCityByCustomer
-- 13.w) Customer with the greatest and lowest Profit and their city and country
SELECT DISTINCT 
		[Country],
		FIRST_VALUE([City]) OVER (PARTITION BY [Country] ORDER BY [Profit By Customer] DESC) as [City with the greatest Profit],
		FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Country] ORDER BY [Profit By Customer] DESC) as [Customer Name with the greatest Profit],
		MAX([Profit By Customer]) OVER (PARTITION BY [Country]) as [The greatest Profit],
		LAST_VALUE([City]) OVER (PARTITION BY [Country] ORDER BY [Profit By Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the lowest Profit],
		LAST_VALUE([Customer Name]) OVER (PARTITION BY [Country] ORDER BY [Profit By Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer Name with the lowest Profit],
		MIN([Profit By Customer]) OVER (PARTITION BY [Country]) as [The lowest Profit]
FROM #ProfitOfCountryCityByCustomer

-- 13.x) Customer with the greatest and lowest Profit from City and Country
SELECT DISTINCT
	FIRST_VALUE([Country]) OVER (ORDER BY [Profit by Customer] DESC) as [Country with the greatest Profit],
	FIRST_VALUE([City]) OVER (ORDER BY [Profit by Customer] DESC) as [City with the greatest Profit],
	FIRST_VALUE([Customer Name]) OVER (ORDER BY [Profit by Customer] DESC) as [Customer with the greatest Profit],
	MAX([Profit by Customer]) OVER () as [The greatest Profit],
	LAST_VALUE([Country]) OVER (ORDER BY [Profit by Customer] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the greatest Profit],
	LAST_VALUE([City]) OVER (ORDER BY [Profit by Customer] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the greatest Profit],
	LAST_VALUE([Customer Name]) OVER (ORDER BY [Profit by Customer] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the greatest Profit],
	MIN([Profit by Customer]) OVER () as [The greatest Profit]
FROM  #ProfitOfCountryCityByCustomer

--13.y) Profit of Country and City by Customer year by year
SELECT DISTINCT
		[YearOfOrderDate], [Country], [City],[Customer Name],
		SUM([Profit]) OVER (PARTITION BY [Customer Name], [City], [YearOfOrderDate]) as [Profit of City by Customer]
FROM   [Project4].[dbo].[SuperStore]
WHERE [YearOfOrderDate] = 2011 and [Profit] >= 1

-- A store procedure was created to store the code.
CREATE PROCEDURE ProfitOfCountryCityByCustomerYear @Year int
AS
SELECT DISTINCT
		[YearOfOrderDate], [Country], [City],[Customer Name],
		SUM([Profit]) OVER (PARTITION BY [Customer Name], [City], [YearOfOrderDate]) as [Profit of City by Customer]
FROM   [Project4].[dbo].[SuperStore]
WHERE [YearOfOrderDate] = @Year and [Profit] >= 1
ORDER BY [Country] ASC, [Profit of City by Customer] DESC
GO

EXEC ProfitOfCountryCityByCustomerYear @Year = 2011
EXEC ProfitOfCountryCityByCustomerYear @Year = 2012
EXEC ProfitOfCountryCityByCustomerYear @Year = 2013
EXEC ProfitOfCountryCityByCustomerYear @Year = 2014


-- 13.z) The Greatest and Lowest Profit by Customer, City, Country and Ranking

CREATE FUNCTION GreatestLowestProfitCustomerCityCountry 
(
	@StartYear int,
	@EndYear int
)
RETURNS TABLE
AS
RETURN 
SELECT DISTINCT
		[YearOfOrderDate], [Country], [City],[Customer Name],
		SUM([Profit]) OVER (PARTITION BY [Customer Name], [City], [YearOfOrderDate]) as [Profit of City by Customer]
FROM   [Project4].[dbo].[SuperStore]
WHERE [YearOfOrderDate] BETWEEN @StartYear AND @EndYear and [Profit] >= 1


-- Profit of Customer, City, Country in all years
SELECT *
FROM  GreatestLowestProfitCustomerCityCountry(2011,2014)
ORDER BY [Country] ASC, [Profit of City by Customer] DESC
-- Profit Of Country and City and Customer year over year
--Ranking of Customer by Profit
--2011
SELECT 
	[YearOfOrderDate] as [Year],
	[Country],
	RANK() OVER (PARTITION BY [Country] ORDER BY [Profit of City by Customer] DESC) as [Ranking],
	[City],
	[Customer Name],
	[Profit of City by Customer]
FROM  GreatestLowestProfitCustomerCityCountry(2011,2011)
-- Profit Of Country and City and Customer year over year
--Ranking of Customer by Profit
--2012
SELECT 
	[YearOfOrderDate] as [Year],
	[Country],
	RANK() OVER (PARTITION BY [Country] ORDER BY [Profit of City by Customer] DESC) as [Ranking],
	[City],
	[Customer Name],
	[Profit of City by Customer]
FROM  GreatestLowestProfitCustomerCityCountry(2012,2012)
-- Profit Of Country and City and Customer year over year
--Ranking of Customer by Profit
--2013
SELECT 
	[YearOfOrderDate] as [Year],
	[Country],
	RANK() OVER (PARTITION BY [Country] ORDER BY [Profit of City by Customer] DESC) as [Ranking],
	[City],
	[Customer Name],
	[Profit of City by Customer]
FROM  GreatestLowestProfitCustomerCityCountry(2013,2013)
-- Profit Of Country and City and Customer year over year
--Ranking of Customer by Profit
--2014
SELECT 
	[YearOfOrderDate] as [Year],
	[Country],
	RANK() OVER (PARTITION BY [Country] ORDER BY [Profit of City by Customer] DESC) as [Ranking],
	[City],
	[Customer Name],
	[Profit of City by Customer]
FROM  GreatestLowestProfitCustomerCityCountry(2014,2014)
--13.aa) TOP 10 Customer with the greatest Profit
SELECT TOP 10 WITH TIES *
FROM GreatestLowestProfitCustomerCityCountry(2011,2014)
ORDER BY [Profit of City by Customer] DESC
--13.ab) TOP 10 Customer with the lowest Profit
SELECT TOP 10 WITH TIES *
FROM GreatestLowestProfitCustomerCityCountry(2011,2014)
ORDER BY [Profit of City by Customer] ASC

--13.ac)  Customer,City with the greatest Sales than Average
SELECT *
FROM GreatestLowestProfitCustomerCityCountry(2011,2014)
WHERE [Profit of City by Customer] >= (SELECT AVG([Profit]) FROM   [Project4].[dbo].[SuperStore]) 
ORDER BY [Profit of City by Customer] DESC


-- 13.ad) The greatest Profit of Customer, City, Country and Year
WITH TheGreatestLowestProfitByCustomerAndCity  AS 
(
SELECT *
FROM GreatestLowestProfitCustomerCityCountry(2011,2014)
)
SELECT DISTINCT
			FIRST_VALUE([YearOfOrderDate]) OVER (PARTITION BY [Country] ORDER BY [Profit of City by Customer] DESC) as [Year],
			[Country],
			FIRST_VALUE([City]) OVER (PARTITION BY [Country] ORDER BY [Profit of City by Customer] DESC) as [City],
			FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Country] ORDER BY [Profit of City by Customer] DESC) as [Customer Name with the greatest Profit],
			MAX([Profit of City by Customer]) OVER (PARTITION BY [Country]) as [The Greatest Profit],
			LAST_VALUE([YearOfOrderDate]) OVER (PARTITION BY [Country] ORDER BY [Profit of City by Customer] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Year],
			LAST_VALUE([City]) OVER (PARTITION BY [Country] ORDER BY [Profit of City by Customer]  DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City],
			LAST_VALUE([Customer Name]) OVER (PARTITION BY [Country] ORDER BY [Profit of City by Customer] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer Name with the Lowest Profit],
			MIN([Profit of City by Customer]) OVER (PARTITION BY [Country]) as [The Lowest Profit]
FROM TheGreatestLowestProfitByCustomerAndCity
ORDER BY [Country] ASC

-- 13.ae) Cumulative Distribution of Profit by City, Customer and Year
CREATE VIEW CumDisOfProfitByCityCustomerYear AS 
	SELECT DISTINCT
			[YearOfOrderDate], [Country], [City],[Customer Name],
			SUM([Profit]) OVER (PARTITION BY [Customer Name], [City], [YearOfOrderDate]) as [Profit of City by Customer]
	FROM   [Project4].[dbo].[SuperStore]

-- 13.af) Cumulative Distribution of Profit by City, Customer and Year
SELECT *, 
	ROUND(CUME_DIST() OVER (ORDER BY [Profit of City by Customer] DESC)*100,3) as [Cumulative Distribution (%)]
FROM CumDisOfProfitByCityCustomerYear

--13.ag)  25% TOP  of Cumulative Distribution by City, Customer and Year
WITH TOP25CumDistrProfit AS (
SELECT *, 
	ROUND(CUME_DIST() OVER (ORDER BY [Profit of City by Customer] DESC)*100,3) as [Cumulative Distribution (%)]
FROM CumDisOfProfitByCityCustomerYear
)
SELECT *
FROM TOP25CumDistrProfit
WHERE [Cumulative Distribution (%)] <= 25
-- 13.ah) The greatest and lowest Profit by Customer and City
-- 2011
SELECT DISTINCT
	[YearOfOrderDate] as [Year],
	[Country],
	FIRST_VALUE([City]) OVER (PARTITION BY [Country] ORDER BY [Profit of City by Customer] DESC) as [City with the greatest Profit],
	FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Country] ORDER BY [Profit of City by Customer] DESC) as [City with the greatest Profit],
	MAX([Profit of City by Customer]) OVER (PARTITION BY [Country]) as [The greatest Profit],
	LAST_VALUE([City]) OVER (PARTITION BY [Country] ORDER BY [Profit of City by Customer] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the greatest Profit],
	LAST_VALUE([Customer Name]) OVER (PARTITION BY [Country] ORDER BY [Profit of City by Customer] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the greatest Profit],
	MIN([Profit of City by Customer]) OVER (PARTITION BY [Country]) as [The greatest Profit]
FROM  GreatestLowestProfitCustomerCityCountry(2011,2011)
-- 2012
SELECT DISTINCT
	[YearOfOrderDate] as [Year],
	[Country],
	FIRST_VALUE([City]) OVER (PARTITION BY [Country] ORDER BY [Profit of City by Customer] DESC) as [City with the greatest Profit],
	FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Country] ORDER BY [Profit of City by Customer] DESC) as [City with the greatest Profit],
	MAX([Profit of City by Customer]) OVER (PARTITION BY [Country]) as [The greatest Profit],
	LAST_VALUE([City]) OVER (PARTITION BY [Country] ORDER BY [Profit of City by Customer] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the greatest Profit],
	LAST_VALUE([Customer Name]) OVER (PARTITION BY [Country] ORDER BY [Profit of City by Customer] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the greatest Profit],
	MIN([Profit of City by Customer]) OVER (PARTITION BY [Country]) as [The greatest Profit]
FROM  GreatestLowestProfitCustomerCityCountry(2012,2012)
-- 2013
SELECT DISTINCT
	[YearOfOrderDate] as [Year],
	[Country],
	FIRST_VALUE([City]) OVER (PARTITION BY [Country] ORDER BY [Profit of City by Customer] DESC) as [City with the greatest Profit],
	FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Country] ORDER BY [Profit of City by Customer] DESC) as [City with the greatest Profit],
	MAX([Profit of City by Customer]) OVER (PARTITION BY [Country]) as [The greatest Profit],
	LAST_VALUE([City]) OVER (PARTITION BY [Country] ORDER BY [Profit of City by Customer] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the greatest Profit],
	LAST_VALUE([Customer Name]) OVER (PARTITION BY [Country] ORDER BY [Profit of City by Customer] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the greatest Profit],
	MIN([Profit of City by Customer]) OVER (PARTITION BY [Country]) as [The greatest Profit]
FROM  GreatestLowestProfitCustomerCityCountry(2013,2013)
-- 2014
SELECT DISTINCT
	[YearOfOrderDate] as [Year],
	[Country],
	FIRST_VALUE([City]) OVER (PARTITION BY [Country] ORDER BY [Profit of City by Customer] DESC) as [City with the greatest Profit],
	FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Country] ORDER BY [Profit of City by Customer] DESC) as [City with the greatest Profit],
	MAX([Profit of City by Customer]) OVER (PARTITION BY [Country]) as [The greatest Profit],
	LAST_VALUE([City]) OVER (PARTITION BY [Country] ORDER BY [Profit of City by Customer] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the greatest Profit],
	LAST_VALUE([Customer Name]) OVER (PARTITION BY [Country] ORDER BY [Profit of City by Customer] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the greatest Profit],
	MIN([Profit of City by Customer]) OVER (PARTITION BY [Country]) as [The greatest Profit]
FROM  GreatestLowestProfitCustomerCityCountry(2014,2014)


--13.ai)  The greatest and lowest of Profit by Customer and City by all years
SELECT DISTINCT 
		FIRST_VALUE([YearOfOrderDate]) OVER (ORDER BY [Profit of City by Customer] DESC) as [Year],
		FIRST_VALUE([Country]) OVER (ORDER BY [Profit of City by Customer] DESC) as [Country with the greatest Profit],
		FIRST_VALUE([City]) OVER (ORDER BY [Profit of City by Customer] DESC) as [City with the greatest Profit ],
		FIRST_VALUE([Customer Name]) OVER (ORDER BY [Profit of City by Customer] DESC) as [Customer with the greatest Profit],
		MAX([Profit of City by Customer]) OVER () as [The Greatest Profit],
		LAST_VALUE([YearOfOrderDate]) OVER (ORDER BY [Profit of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Year],
		LAST_VALUE([Country]) OVER (ORDER BY [Profit of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the greatest Profit],
		LAST_VALUE([City]) OVER (ORDER BY [Profit of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the greatest Profit ],
		LAST_VALUE([Customer Name]) OVER (ORDER BY [Profit of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the greatest Profit],
		MIN([Profit of City by Customer]) OVER () as [The Greatest Profit]
FROM  GreatestLowestProfitCustomerCityCountry(2011,2014)
-- 13.aj) The greatest and lowest of Profit by Customer and City year by year
SELECT DISTINCT 
		FIRST_VALUE([YearOfOrderDate]) OVER (ORDER BY [Profit of City by Customer] DESC) as [Year],
		FIRST_VALUE([Country]) OVER (ORDER BY [Profit of City by Customer] DESC) as [Country with the greatest Profit],
		FIRST_VALUE([City]) OVER (ORDER BY [Profit of City by Customer] DESC) as [City with the greatest Profit ],
		FIRST_VALUE([Customer Name]) OVER (ORDER BY [Profit of City by Customer] DESC) as [Customer with the greatest Profit],
		MAX([Profit of City by Customer]) OVER () as [The Greatest Profit],
		LAST_VALUE([YearOfOrderDate]) OVER (ORDER BY [Profit of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Year],
		LAST_VALUE([Country]) OVER (ORDER BY [Profit of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the greatest Profit],
		LAST_VALUE([City]) OVER (ORDER BY [Profit of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the greatest Profit ],
		LAST_VALUE([Customer Name]) OVER (ORDER BY [Profit of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the greatest Profit],
		MIN([Profit of City by Customer]) OVER () as [The Greatest Profit]
FROM  GreatestLowestProfitCustomerCityCountry(2011,2011)
UNION
SELECT DISTINCT 
		FIRST_VALUE([YearOfOrderDate]) OVER (ORDER BY [Profit of City by Customer] DESC) as [Year],
		FIRST_VALUE([Country]) OVER (ORDER BY [Profit of City by Customer] DESC) as [Country with the greatest Profit],
		FIRST_VALUE([City]) OVER (ORDER BY [Profit of City by Customer] DESC) as [City with the greatest Profit ],
		FIRST_VALUE([Customer Name]) OVER (ORDER BY [Profit of City by Customer] DESC) as [Customer with the greatest Profit],
		MAX([Profit of City by Customer]) OVER () as [The Greatest Profit],
		LAST_VALUE([YearOfOrderDate]) OVER (ORDER BY [Profit of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Year],
		LAST_VALUE([Country]) OVER (ORDER BY [Profit of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the greatest Profit],
		LAST_VALUE([City]) OVER (ORDER BY [Profit of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the greatest Profit ],
		LAST_VALUE([Customer Name]) OVER (ORDER BY [Profit of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the greatest Profit],
		MIN([Profit of City by Customer]) OVER () as [The Greatest Profit]
FROM  GreatestLowestProfitCustomerCityCountry(2012,2012)
UNION
SELECT DISTINCT 
		FIRST_VALUE([YearOfOrderDate]) OVER (ORDER BY [Profit of City by Customer] DESC) as [Year],
		FIRST_VALUE([Country]) OVER (ORDER BY [Profit of City by Customer] DESC) as [Country with the greatest Profit],
		FIRST_VALUE([City]) OVER (ORDER BY [Profit of City by Customer] DESC) as [City with the greatest Profit ],
		FIRST_VALUE([Customer Name]) OVER (ORDER BY [Profit of City by Customer] DESC) as [Customer with the greatest Profit],
		MAX([Profit of City by Customer]) OVER () as [The Greatest Profit],
		LAST_VALUE([YearOfOrderDate]) OVER (ORDER BY [Profit of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Year],
		LAST_VALUE([Country]) OVER (ORDER BY [Profit of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the greatest Profit],
		LAST_VALUE([City]) OVER (ORDER BY [Profit of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the greatest Profit ],
		LAST_VALUE([Customer Name]) OVER (ORDER BY [Profit of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the greatest Profit],
		MIN([Profit of City by Customer]) OVER () as [The Greatest Profit]
FROM  GreatestLowestProfitCustomerCityCountry(2013,2013)
UNION
SELECT DISTINCT 
		FIRST_VALUE([YearOfOrderDate]) OVER (ORDER BY [Profit of City by Customer] DESC) as [Year],
		FIRST_VALUE([Country]) OVER (ORDER BY [Profit of City by Customer] DESC) as [Country with the greatest Profit],
		FIRST_VALUE([City]) OVER (ORDER BY [Profit of City by Customer] DESC) as [City with the greatest Profit ],
		FIRST_VALUE([Customer Name]) OVER (ORDER BY [Profit of City by Customer] DESC) as [Customer with the greatest Profit],
		MAX([Profit of City by Customer]) OVER () as [The Greatest Profit],
		LAST_VALUE([YearOfOrderDate]) OVER (ORDER BY [Profit of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Year],
		LAST_VALUE([Country]) OVER (ORDER BY [Profit of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the greatest Profit],
		LAST_VALUE([City]) OVER (ORDER BY [Profit of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [City with the greatest Profit ],
		LAST_VALUE([Customer Name]) OVER (ORDER BY [Profit of City by Customer] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the greatest Profit],
		MIN([Profit of City by Customer]) OVER () as [The Greatest Profit]
FROM  GreatestLowestProfitCustomerCityCountry(2014,2014)

---14.a) Shipping Cost by City


CREATE FUNCTION ShippingCostByCity 
(
	@StartYear int,
	@EndYear int
)
RETURNS TABLE
AS
RETURN 
	SELECT DISTINCT [Country], [City], SUM([Shipping Cost]) OVER (PARTITION BY [City]) as [Shipping Cost by City]
	FROM   [Project4].[dbo].[SuperStore]
	WHERE [YearOfOrderDate] BETWEEN @StartYear AND @EndYear


-- 14.b) Shipping cost by City in all years
SELECT *
FROM ShippingCostByCity(2011,2014)
ORDER BY [Country] ASC
-- 14.c) The group of City by three levels (low,mid and high)
WITH GroupOfCityByLevelsOfShippingCost AS (
SELECT *, NTILE(3) OVER (ORDER BY [Shipping Cost by City] DESC) as [Buckets]
FROM ShippingCostByCity(2011,2014)
)
SELECT [Country], [City],
		CASE
			WHEN [Buckets] = 1 THEN 'High Shipping Cost'
			WHEN [Buckets] = 2 THEN 'Mid Shipping Cost'
			WHEN [Buckets] = 3 THEN 'Low Shipping Cost'
		END AS [Level of Shipping Cost]
FROM GroupOfCityByLevelsOfShippingCost


--14.d)  The Shipping Cost and Quantity of Orders by City by Order Priority
CREATE PROCEDURE TheShippingCostQuanatityOfOrdersByOrderPriority @OrderPriority nvarchar(MAX)
AS
	SELECT DISTINCT 
	[Country],
	[City], 
	SUM([Shipping Cost]) OVER (PARTITION BY [City]) as [Shipping Cost by City],
	COUNT(*) OVER (PARTITION BY [City]) as [Quantity of Orders]
	FROM [Project4].[dbo].[SuperStore]
	WHERE [Order Priority] = @OrderPriority
	ORDER BY [Shipping Cost by City] DESC
GO
-- Low Order Priority
EXEC TheShippingCostQuanatityOfOrdersByOrderPriority @OrderPriority = 'Low'
-- Med Order Priority
EXEC TheShippingCostQuanatityOfOrdersByOrderPriority @OrderPriority = 'Medium'
-- High Order Priority
EXEC TheShippingCostQuanatityOfOrdersByOrderPriority @OrderPriority = 'High'
-- Low Order Priority
EXEC TheShippingCostQuanatityOfOrdersByOrderPriority @OrderPriority = 'Critical'

--14.e) The Shipping Cost and Quantity of Orders by City by Category
CREATE PROCEDURE TheShippingCostQuanatityOfOrdersByCategory @Category nvarchar(MAX)
AS
	SELECT DISTINCT 
	[Country],
	[City], 
	SUM([Shipping Cost]) OVER (PARTITION BY [City]) as [Shipping Cost by City],
	COUNT(*) OVER (PARTITION BY [City]) as [Quantity of Orders]
	FROM [Project4].[dbo].[SuperStore]
	WHERE [Category] = @Category
	ORDER BY [Shipping Cost by City] DESC
GO
-- 14.f) Shipping Cost by City and Quantity of Orders by Category
EXEC TheShippingCostQuanatityOfOrdersByCategory @Category = 'Office Supplies'
EXEC TheShippingCostQuanatityOfOrdersByCategory @Category = 'Furniture'
EXEC TheShippingCostQuanatityOfOrdersByCategory @Category = 'Technology'

-- 14.g) Ranking of City by Shipping Cost for all years
SELECT [Country], RANK() OVER (PARTITION BY [Country] ORDER BY [Shipping Cost by City] DESC) as [Ranking], City, [Shipping Cost by City]
FROM ShippingCostByCity(2011,2014)
ORDER BY [Country] ASC
-- 14.h) TOP10 the greatest shipping cost
SELECT TOP 10 WITH TIES *
FROM ShippingCostByCity(2011,2014)
ORDER BY [Shipping Cost by City] DESC
--14.i)  TOP 10 the lowest Shipping cost in all years
SELECT TOP 10 WITH TIES *
FROM ShippingCostByCity(2011,2014)
ORDER BY [Shipping Cost by City] ASC
--14.j) Countries and City with Shipping Cost greater than average Shipping Cost
SELECT *
FROM ShippingCostByCity(2011,2014)
WHERE [Shipping Cost by City] > (SELECT AVG([Shipping Cost]) FROM [Project4].[dbo].[SuperStore])
ORDER BY [Shipping Cost by City] DESC
-- 14.k) Ranking of City by Shipping Cost year over year
-- 2011
SELECT [Country], RANK() OVER (PARTITION BY [Country] ORDER BY [Shipping Cost by City] DESC) as [Ranking], City, [Shipping Cost by City]
FROM ShippingCostByCity(2011,2011)
ORDER BY [Country] ASC
-- 2012
SELECT [Country], RANK() OVER (PARTITION BY [Country] ORDER BY [Shipping Cost by City] DESC) as [Ranking], City, [Shipping Cost by City]
FROM ShippingCostByCity(2012,2012)
ORDER BY [Country] ASC
-- 2013
SELECT [Country], RANK() OVER (PARTITION BY [Country] ORDER BY [Shipping Cost by City] DESC) as [Ranking], City, [Shipping Cost by City]
FROM ShippingCostByCity(2013,2013)
ORDER BY [Country] ASC
-- 2014
SELECT [Country], RANK() OVER (PARTITION BY [Country] ORDER BY [Shipping Cost by City] DESC) as [Ranking], City, [Shipping Cost by City]
FROM ShippingCostByCity(2014,2014)
ORDER BY [Country] ASC

-- 14.l) TOP 10 the greatest shipping cost year by year
CREATE PROCEDURE TOPShippingCost @Year int
AS
	SELECT DISTINCT TOP 10 WITH TIES [Country], [City], SUM([Shipping Cost]) OVER (PARTITION BY [City]) as [Shipping Cost by City]
	FROM   [Project4].[dbo].[SuperStore]
	WHERE [YearOfOrderDate] = @Year
	ORDER BY [Shipping Cost by City] DESC
GO
--2011
EXEC TOPShippingCost @Year = 2011
--2012
EXEC TOPShippingCost @Year = 2012
--2013
EXEC TOPShippingCost @Year = 2013
--2014
EXEC TOPShippingCost @Year = 2014
-- 14.m) TOP 10 the lowest shipping cost year by year
CREATE PROCEDURE TOPBOTTOMSHIPPINHCOST @Year int
AS
	SELECT DISTINCT TOP 10 WITH TIES [Country], [City], SUM([Shipping Cost]) OVER (PARTITION BY [City]) as [Shipping Cost by City]
	FROM   [Project4].[dbo].[SuperStore]
	WHERE [YearOfOrderDate] = @Year
	ORDER BY [Shipping Cost by City] ASC
GO

--2011
EXEC TOPBOTTOMSHIPPINHCOST @Year = 2011
--2012
EXEC TOPBOTTOMSHIPPINHCOST @Year = 2012
--2013
EXEC TOPBOTTOMSHIPPINHCOST @Year = 2013
--2014
EXEC TOPBOTTOMSHIPPINHCOST @Year = 2014

-- 14.n) The greatest and the lowest Shipping cost by City in all years
SELECT  DISTINCT
				FIRST_VALUE([Country]) OVER (ORDER BY [Shipping Cost by City] DESC) as [Country with the greatest Shipping Cost],
				FIRST_VALUE([City]) OVER (ORDER BY [Shipping Cost by City] DESC) as [City with the greatest Shipping Cost],
				MAX([Shipping Cost by City]) OVER () AS [The greatest Shipping Cost],
				LAST_VALUE([Country]) OVER (ORDER BY [Shipping Cost by City] DESC
				RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Shipping Cost],
				LAST_VALUE([City]) OVER (ORDER BY [Shipping Cost by City] DESC
				RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Shipping Cost],
				MIN([Shipping Cost by City]) OVER () AS [The lowest Shipping Cost]
FROM ShippingCostByCity(2011,2014)

-- 14.o) The greatest and lowest Shipping cost from each country and city in year 
CREATE FUNCTION ShippingCostByCityYear 
(
	@StartYear int,
	@EndYear int
)
RETURNS TABLE
AS
RETURN 
	SELECT DISTINCT [YearOfOrderDate],[Country], [City], SUM([Shipping Cost]) OVER (PARTITION BY [City]) as [Shipping Cost by City]
	FROM   [Project4].[dbo].[SuperStore]
	WHERE [YearOfOrderDate] BETWEEN @StartYear AND @EndYear

SELECT  DISTINCT
				FIRST_VALUE([YearOfOrderDate]) OVER (PARTITION BY [Country] ORDER BY [Shipping Cost by City] DESC) as [Year with the greatest Shipping Cost],
				FIRST_VALUE([Country]) OVER (PARTITION BY [Country] ORDER BY [Shipping Cost by City] DESC) as [Country with the greatest Shipping Cost],
				FIRST_VALUE([City]) OVER (PARTITION BY [Country] ORDER BY [Shipping Cost by City] DESC) as [City with the greatest Shipping Cost],
				MAX([Shipping Cost by City]) OVER (PARTITION BY [Country]) AS [The greatest Shipping Cost],
				LAST_VALUE([YearOfOrderDate]) OVER (PARTITION BY [Country] ORDER BY [Shipping Cost by City] DESC
				RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Year with the lowest Shipping Cost],
				LAST_VALUE([Country]) OVER (PARTITION BY [Country] ORDER BY [Shipping Cost by City] DESC
				RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Shipping Cost],
				LAST_VALUE([City]) OVER (PARTITION BY [Country] ORDER BY [Shipping Cost by City] DESC
				RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Shipping Cost],
				MIN([Shipping Cost by City]) OVER (PARTITION BY [Country]) AS [The lowest Shipping Cost]
FROM ShippingCostByCityYear(2011,2014)

--14.p)  The greatest and lowest Shipping cost from each country and city year by year 

SELECT	DISTINCT 		
				[YearOfOrderDate] as [Year],
				FIRST_VALUE([Country]) OVER (ORDER BY [Shipping Cost by City] DESC) as [Country with the greatest Shipping Cost],
				FIRST_VALUE([City]) OVER (ORDER BY [Shipping Cost by City] DESC) as [City with the greatest Shipping Cost],
				MAX([Shipping Cost by City]) OVER () AS [The greatest Shipping Cost],
				LAST_VALUE([Country]) OVER (ORDER BY [Shipping Cost by City] DESC
				RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Shipping Cost],
				LAST_VALUE([City]) OVER (ORDER BY [Shipping Cost by City] DESC
				RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Shipping Cost],
				MIN([Shipping Cost by City]) OVER () AS [The lowest Shipping Cost]
FROM ShippingCostByCityYear(2011,2011)
UNION
SELECT	DISTINCT 		
				[YearOfOrderDate] as [Year],
				FIRST_VALUE([Country]) OVER (ORDER BY [Shipping Cost by City] DESC) as [Country with the greatest Shipping Cost],
				FIRST_VALUE([City]) OVER (ORDER BY [Shipping Cost by City] DESC) as [City with the greatest Shipping Cost],
				MAX([Shipping Cost by City]) OVER () AS [The greatest Shipping Cost],
				LAST_VALUE([Country]) OVER (ORDER BY [Shipping Cost by City] DESC
				RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Shipping Cost],
				LAST_VALUE([City]) OVER (ORDER BY [Shipping Cost by City] DESC
				RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Shipping Cost],
				MIN([Shipping Cost by City]) OVER () AS [The lowest Shipping Cost]
FROM ShippingCostByCityYear(2012,2012)
UNION
SELECT	DISTINCT 		
				[YearOfOrderDate] as [Year],
				FIRST_VALUE([Country]) OVER (ORDER BY [Shipping Cost by City] DESC) as [Country with the greatest Shipping Cost],
				FIRST_VALUE([City]) OVER (ORDER BY [Shipping Cost by City] DESC) as [City with the greatest Shipping Cost],
				MAX([Shipping Cost by City]) OVER () AS [The greatest Shipping Cost],
				LAST_VALUE([Country]) OVER (ORDER BY [Shipping Cost by City] DESC
				RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Shipping Cost],
				LAST_VALUE([City]) OVER (ORDER BY [Shipping Cost by City] DESC
				RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Shipping Cost],
				MIN([Shipping Cost by City]) OVER () AS [The lowest Shipping Cost]
FROM ShippingCostByCityYear(2013,2013)
UNION
SELECT	DISTINCT 		
				[YearOfOrderDate] as [Year],
				FIRST_VALUE([Country]) OVER (ORDER BY [Shipping Cost by City] DESC) as [Country with the greatest Shipping Cost],
				FIRST_VALUE([City]) OVER (ORDER BY [Shipping Cost by City] DESC) as [City with the greatest Shipping Cost],
				MAX([Shipping Cost by City]) OVER () AS [The greatest Shipping Cost],
				LAST_VALUE([Country]) OVER (ORDER BY [Shipping Cost by City] DESC
				RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Shipping Cost],
				LAST_VALUE([City]) OVER (ORDER BY [Shipping Cost by City] DESC
				RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Shipping Cost],
				MIN([Shipping Cost by City]) OVER () AS [The lowest Shipping Cost]
FROM ShippingCostByCityYear(2014,2014)


--15.a) The Quantity of Orders by City

CREATE FUNCTION QuantityOfOrdersByCity (
	@StartYear int,
	@EndYear int
)
RETURNS TABLE
AS
RETURN
	SELECT DISTINCT [City], count(*) OVER (PARTITION BY [City]) as [The Quantity of Orders]
	FROM   [Project4].[dbo].[SuperStore]
	WHERE YearOfOrderDate BETWEEN @StartYear and @EndYear

--15.b) The Quantity of Orders by City in all years
SELECT *
FROM QuantityOfOrdersByCity(2011,2014)
ORDER BY [The Quantity of Orders] DESC
--15.c) The Percentage Quantity of Orders by City in all years
DECLARE @TotalQuantityOrders20112014 FLOAT
SET @TotalQuantityOrders20112014 = (SELECT DISTINCT count([City]) OVER () as [The Total Quantity of Orders] FROM [Project4].[dbo].[SuperStore])
PRINT @TotalQuantityOrders20112014
SELECT [City],
		ROUND([The Quantity of Orders]/@TotalQuantityOrders20112014,6)*100 as [The percentage Quantity of Orders (%)]
FROM QuantityOfOrdersByCity(2011,2014)
ORDER BY [The Quantity of Orders] DESC
--The Quantity of Orders by City in 2011
SELECT *
FROM QuantityOfOrdersByCity(2011,2011)
ORDER BY [The Quantity of Orders] DESC
--The Percentage Quantity of Orders by City in 2011
DECLARE @TotalQuantityOrders2011 FLOAT
SET @TotalQuantityOrders2011 = (SELECT DISTINCT count([City]) OVER () as [The Total Quantity of Orders] FROM [Project4].[dbo].[SuperStore] WHERE YearOfOrderDate = 2011)
PRINT @TotalQuantityOrders2011
SELECT [City],
		ROUND([The Quantity of Orders]/@TotalQuantityOrders2011,6)*100 as [The percentage Quantity of Orders (%)]
FROM QuantityOfOrdersByCity(2011,2011)
ORDER BY [The Quantity of Orders] DESC
--The Quantity of Orders by City in 2012
SELECT *
FROM QuantityOfOrdersByCity(2012,2012)
ORDER BY [The Quantity of Orders] DESC
--The Percentage Quantity of Orders by City in 2012
DECLARE @TotalQuantityOrders2012 FLOAT
SET @TotalQuantityOrders2012 = (SELECT DISTINCT count([City]) OVER () as [The Total Quantity of Orders] FROM [Project4].[dbo].[SuperStore] WHERE YearOfOrderDate = 2012)
PRINT @TotalQuantityOrders2012
SELECT [City],
		ROUND([The Quantity of Orders]/@TotalQuantityOrders2012,6)*100 as [The percentage Quantity of Orders (%)]
FROM QuantityOfOrdersByCity(2012,2012)
ORDER BY [The Quantity of Orders] DESC
--The Quantity of Orders by City in 2013
SELECT *
FROM QuantityOfOrdersByCity(2013,2013)
ORDER BY [The Quantity of Orders] DESC
--The Percentage Quantity of Orders by City in 2013
DECLARE @TotalQuantityOrders2013 FLOAT
SET @TotalQuantityOrders2013 = (SELECT DISTINCT count([City]) OVER () as [The Total Quantity of Orders] FROM [Project4].[dbo].[SuperStore] WHERE YearOfOrderDate = 2013)
PRINT @TotalQuantityOrders2013
SELECT [City],
		ROUND([The Quantity of Orders]/@TotalQuantityOrders2013,6)*100 as [The percentage Quantity of Orders (%)]
FROM QuantityOfOrdersByCity(2013,2013)
ORDER BY [The Quantity of Orders] DESC
--The Quantity of Orders by City in 2014
SELECT *
FROM QuantityOfOrdersByCity(2014,2014)
ORDER BY [The Quantity of Orders] DESC
--The Percentage Quantity of Orders by City in 2014
DECLARE @TotalQuantityOrders2014 FLOAT
SET @TotalQuantityOrders2014 = (SELECT DISTINCT count([City]) OVER () as [The Total Quantity of Orders] FROM [Project4].[dbo].[SuperStore] WHERE YearOfOrderDate = 2014)
PRINT @TotalQuantityOrders2014
SELECT [City],
		ROUND([The Quantity of Orders]/@TotalQuantityOrders2014,6)*100 as [The percentage Quantity of Orders (%)]
FROM QuantityOfOrdersByCity(2014,2014)
ORDER BY [The Quantity of Orders] DESC
-- 16.a) Quantity of Orders by City and Category

SELECT DISTINCT [City], [Category], count([Category]) OVER (PARTITION BY [City],[Category]) as [The Quantity of Orders]				
FROM   [Project4].[dbo].[SuperStore]
ORDER BY [The Quantity of Orders] DESC
-- 16.b) Quantity of Orders by City and Category by Pivot

SELECT [City],COALESCE([Office Supplies],0) as [Office Supplies], COALESCE([Furniture],0) as [Furniture],COALESCE([Technology],0) as [Technology]
FROM
(
SELECT DISTINCT [City], [Category], count([Category]) OVER (PARTITION BY [City],[Category]) as [The Quantity of Orders]				
FROM   [Project4].[dbo].[SuperStore]
) as Src1
PIVOT
(
	SUM([The Quantity of Orders])
	FOR [Category] IN ([Office Supplies], [Furniture], [Technology])
) as PvT1
-- 16.c) Quantity of Orders by City and Category year by year 
CREATE FUNCTION QuantityOfOrdersByCityCategoryYear 
(
	@Year int
)
RETURNS TABLE
AS
RETURN
	SELECT DISTINCT [City], [Category], count([Category]) OVER (PARTITION BY [City],[Category]) as [The Quantity of Orders]				
	FROM   [Project4].[dbo].[SuperStore]
	WHERE [YearOfOrderDate] = @Year

--  Quantity of Orders by City and Category in 2011
SELECT *
FROM QuantityOfOrdersByCityCategoryYear(2011)
 Quantity of Orders by City and Category in 2011 by Pivot
SELECT [City], COALESCE([Office Supplies], 0) as [Office Supplies], COALESCE([Furniture],0) as [Furniture], COALESCE([Technology],0) as [Technology]
FROM
(
SELECT *
FROM QuantityOfOrdersByCityCategoryYear(2011)
) AS Src2
PIVOT
(
	SUM([The Quantity of Orders])
	FOR [Category] IN ([Office Supplies], [Furniture], [Technology])

) as Pvt2
-- Quantity of Orders by City and Category in 2012
SELECT *
FROM QuantityOfOrdersByCityCategoryYear(2012)
-- Quantity of Orders by City and Category in 2012 by Pivot
SELECT [City], COALESCE([Office Supplies], 0) as [Office Supplies], COALESCE([Furniture],0) as [Furniture], COALESCE([Technology],0) as [Technology]
FROM
(
SELECT *
FROM QuantityOfOrdersByCityCategoryYear(2012)
) as SrC3
PIVOT 
(
	SUM([The Quantity of Orders])
	FOR [Category] IN ([Office Supplies], [Furniture], [Technology])
) as PvT3
-- Quantity of Orders by City and Category in 2013
SELECT *
FROM QuantityOfOrdersByCityCategoryYear(2013)
-- Quantity of Orders by City and Category in 2013 by Pivot
SELECT [City], COALESCE([Office Supplies],0) as [Office Supplies], COALESCE([Furniture],0) as [Furniture], COALESCE([Technology],0) as [Technology]
FROM
(
SELECT *
FROM QuantityOfOrdersByCityCategoryYear(2013)
) as SrC4
PIVOT
(
	SUM([The Quantity of Orders])
	FOR [Category] IN ([Office Supplies], [Furniture], [Technology])
) as PvT4
-- Quantity of Orders by City and Category in 2014
SELECT *
FROM QuantityOfOrdersByCityCategoryYear(2014)
-- Quantity of Orders by City and Category in 2014 by Pivot
SELECT [City], COALESCE([Office Supplies],0) as [Office Supplies], COALESCE([Furniture],0) as [Furniture], COALESCE([Technology],0) as [Technology]
FROM
(
	SELECT *
	FROM QuantityOfOrdersByCityCategoryYear(2014)
) as SrC4
PIVOT
(
	SUM([The Quantity of Orders])
	FOR [Category] IN ([Office Supplies], [Furniture], [Technology])
) as PvT4



--17.a) The Quantity of Orders by Country-- 
DROP TABLE IF EXISTS #QuantityOfOrders
CREATE TABLE #QuantityOfOrders
(
	Country nvarchar(max),
	[The Quantity of Orders] int,
	[Year of Order Date] int
)

INSERT INTO #QuantityOfOrders
	SELECT DISTINCT [Country], 
	count(*) OVER (PARTITION BY [Country],[YearOfOrderDate]) as [The Quantity of Orders], 
	[YearOfOrderDate]
	FROM   [Project4].[dbo].[SuperStore]
	ORDER BY [Country] ASC

SELECT *
FROM #QuantityOfOrders


SELECT [Country], COALESCE([2011],0) as [2011],
				COALESCE([2012],0) as [2012],
				COALESCE([2013],0) as [2013],
				COALESCE([2014],0) as [2014]
FROM
(
SELECT DISTINCT [Country], [The Quantity of Orders], [Year of Order Date]
FROM  #QuantityOfOrders
) as Src1
PIVOT 
(
	SUM([The Quantity of Orders])
	FOR [Year of Order Date] IN ([2011], [2012],[2013],[2014])
) as PvT1


--17.b)  Quantity of Orders month by month in all years
SELECT *
FROM [Project4].[dbo].[SuperStore]

CREATE FUNCTION OrderOfCountryByMonths
(
	@Year int
)
RETURNS TABLE 
AS
RETURN
	SELECT DISTINCT [Country], 
	count(*) OVER (PARTITION BY [Country],[OrderDate]) as [The Quantity of Orders], 
	DATENAME(Month,[OrderDate]) as [Month Name], Month([OrderDate]) as [Month]
	FROM   [Project4].[dbo].[SuperStore]
	WHERE [YearOfOrderDate] = @Year
	

SELECT *
FROM OrderOfCountryByMonths(2011)
ORDER BY [Country] ASC, [Month] ASC
-- Quantity of Orders by Countries Month over Month in 2011	
SELECT [Country], 
		COALESCE([January],0) as [January],
		COALESCE([February],0) as [February],
		COALESCE([March],0) as [March],
		COALESCE([April],0) as [April],
		COALESCE([May],0) as  [May],
		COALESCE([June],0) as  [June],
		COALESCE([July],0) as [July],
		COALESCE([August],0) as [August],
		COALESCE([September],0) as [September],
		COALESCE([October],0) as [October],
		COALESCE([November],0) as [November],
		COALESCE([December],0) as [December]
FROM 
(
	SELECT [Country], [The Quantity of Orders], [Month Name]
	FROM OrderOfCountryByMonths(2011)
) as Src1
PIVOT
(
	SUM([The Quantity of Orders])
	FOR [Month Name] IN ([January], [February], [March], [April], [May], [June], [July], [August], [September], [October], [November],[December])
) as PvT1
-- Quantity of Orders by Countries Month over Month in 2012	
SELECT [Country], 
		COALESCE([January],0) as [January],
		COALESCE([February],0) as [February],
		COALESCE([March],0) as [March],
		COALESCE([April],0) as [April],
		COALESCE([May],0) as  [May],
		COALESCE([June],0) as  [June],
		COALESCE([July],0) as [July],
		COALESCE([August],0) as [August],
		COALESCE([September],0) as [September],
		COALESCE([October],0) as [October],
		COALESCE([November],0) as [November],
		COALESCE([December],0) as [December]
FROM 
(
	SELECT [Country], [The Quantity of Orders], [Month Name]
	FROM OrderOfCountryByMonths(2012)
) as Src1
PIVOT
(
	SUM([The Quantity of Orders])
	FOR [Month Name] IN ([January], [February], [March], [April], [May], [June], [July], [August], [September], [October], [November],[December])
) as PvT1
-- Quantity of Orders by Countries Month over Month in 2013	
SELECT [Country], 
		COALESCE([January],0) as [January],
		COALESCE([February],0) as [February],
		COALESCE([March],0) as [March],
		COALESCE([April],0) as [April],
		COALESCE([May],0) as  [May],
		COALESCE([June],0) as  [June],
		COALESCE([July],0) as [July],
		COALESCE([August],0) as [August],
		COALESCE([September],0) as [September],
		COALESCE([October],0) as [October],
		COALESCE([November],0) as [November],
		COALESCE([December],0) as [December]
FROM 
(
	SELECT [Country], [The Quantity of Orders], [Month Name]
	FROM OrderOfCountryByMonths(2013)
) as Src1
PIVOT
(
	SUM([The Quantity of Orders])
	FOR [Month Name] IN ([January], [February], [March], [April], [May], [June], [July], [August], [September], [October], [November],[December])
) as PvT1
-- Quantity of Orders by Countries Month over Month in 2014	
SELECT [Country], 
		COALESCE([January],0) as [January],
		COALESCE([February],0) as [February],
		COALESCE([March],0) as [March],
		COALESCE([April],0) as [April],
		COALESCE([May],0) as  [May],
		COALESCE([June],0) as  [June],
		COALESCE([July],0) as [July],
		COALESCE([August],0) as [August],
		COALESCE([September],0) as [September],
		COALESCE([October],0) as [October],
		COALESCE([November],0) as [November],
		COALESCE([December],0) as [December]
FROM 
(
	SELECT [Country], [The Quantity of Orders], [Month Name]
	FROM OrderOfCountryByMonths(2014)
) as Src1
PIVOT
(
	SUM([The Quantity of Orders])
	FOR [Month Name] IN ([January], [February], [March], [April], [May], [June], [July], [August], [September], [October], [November],[December])
) as PvT1


--17.c) The Quantity of Orders in Quarters by all years indicated by Pivot 
CREATE FUNCTION QuantityOfOrdersByCountryByQuarters
(
	@Year int
)
RETURNS TABLE
AS
RETURN
	SELECT DISTINCT [Country], 
	count(*) OVER (PARTITION BY [Country],[OrderDate]) as [The Quantity of Orders], 
	DATEPART(QQ,[OrderDate]) as [Quarter]
	FROM   [Project4].[dbo].[SuperStore]
	WHERE [YearOfOrderDate] = @Year

	SELECT *
	FROM QuantityOfOrdersByCountryByQuarters(2011)

-- The Quantity of Orders in Quarters by all years
WITH QuantityOfOrdersIn2011Quarters AS (
	SELECT [Country], 
			COALESCE([1],0) as Q1,
			COALESCE([2],0) as Q2,
			COALESCE([3],0) as Q3,
			COALESCE([4],0) as Q4
	FROM
	(
	SELECT *
	FROM QuantityOfOrdersByCountryByQuarters(2011)
	) as SrC1
	PIVOT
	(
		SUM([The Quantity of Orders])
		FOR [Quarter] IN ([1],[2],[3],[4])
	) as PvT1
), QuantityOfOrdersIn2012Quarters AS
(
	SELECT [Country], 
			COALESCE([1],0) as Q1,
			COALESCE([2],0) as Q2,
			COALESCE([3],0) as Q3,
			COALESCE([4],0) as Q4
	FROM
	(
	SELECT *
	FROM QuantityOfOrdersByCountryByQuarters(2012)
	) as SrC2
	PIVOT
	(
		SUM([The Quantity of Orders])
		FOR [Quarter] IN ([1],[2],[3],[4])
	) as PvT2
), QuantityOfOrdersIn2013Quarters AS (
	SELECT [Country], 
			COALESCE([1],0) as Q1,
			COALESCE([2],0) as Q2,
			COALESCE([3],0) as Q3,
			COALESCE([4],0) as Q4
	FROM
	(
	SELECT *
	FROM QuantityOfOrdersByCountryByQuarters(2013)
	) as SrC3
	PIVOT
	(
		SUM([The Quantity of Orders])
		FOR [Quarter] IN ([1],[2],[3],[4])
	) as PvT3
),  QuantityOfOrdersIn2014Quarters AS (

	SELECT [Country], 
			COALESCE([1],0) as Q1,
			COALESCE([2],0) as Q2,
			COALESCE([3],0) as Q3,
			COALESCE([4],0) as Q4
	FROM
	(
	SELECT *
	FROM QuantityOfOrdersByCountryByQuarters(2014)
	) as SrC4
	PIVOT
	(
		SUM([The Quantity of Orders])
		FOR [Quarter] IN ([1],[2],[3],[4])
	) as PvT4
)
SELECT Q2011.Country as [Country],
		Q2011.Q1 as [Q1 2011],
		Q2011.Q2 as [Q2 2011],
		Q2011.Q3 as [Q3 2011],
		Q2011.Q4 as [Q4 2011],
		Q2012.Q1 as [Q1 2012],
		Q2012.Q2 as [Q2 2012],
		Q2012.Q3 as [Q3 2012],
		Q2012.Q4 as [Q4 2012],
		Q2013.Q1 as [Q1 2013],
		Q2013.Q2 as [Q2 2013],
		Q2013.Q3 as [Q3 2013],
		Q2013.Q4 as [Q4 2013],
		Q2014.Q1 as [Q1 2014],
		Q2014.Q2 as [Q2 2014],
		Q2014.Q3 as [Q3 2014],
		Q2014.Q4 as [Q4 2014]
FROM QuantityOfOrdersIn2011Quarters Q2011
	LEFT JOIN QuantityOfOrdersIn2012Quarters Q2012
		ON Q2011.Country = Q2012.Country
	LEFT JOIN QuantityOfOrdersIn2013Quarters Q2013
		ON Q2011.Country = Q2013.Country
	LEFT JOIN QuantityOfOrdersIn2014Quarters Q2014
		ON Q2011.Country = Q2014.Country


--18.a)  The Quantity of Orders by Market-- 

-- The Quantity of Orders, SUM of Profit and Sales in Market in all years
SELECT DISTINCT [Market],
			count(*) OVER (PARTITION BY [Market]) as [The Quantity of Orders],
			SUM([Sales]) OVER (PARTITION BY [Market]) as [Sales],
			SUM([Profit]) OVER (PARTITION BY [Market]) as [Profit],
			SUM([Shipping Cost]) OVER (PARTITION BY [Market]) as [Shipping Cost]
FROM   [Project4].[dbo].[SuperStore]
ORDER BY [The Quantity of Orders] DESC
-- The Quantity of Orders, SUM of Profit and Sales in Market year by year
CREATE PROCEDURE QuantityOfOrdersSalesProfitByMarket @Year int
AS
SELECT DISTINCT [Market],
			count(*) OVER (PARTITION BY [Market]) as [The Quantity of Orders],
			SUM([Sales]) OVER (PARTITION BY [Market]) as [Sales],
			SUM([Profit]) OVER (PARTITION BY [Market]) as [Profit],
			SUM([Shipping Cost]) OVER (PARTITION BY [Market]) as [Shipping Cost]
FROM   [Project4].[dbo].[SuperStore]
WHERE [YearOfOrderDate] = @Year
ORDER BY [The Quantity of Orders] DESC
GO

--2011
EXEC QuantityOfOrdersSalesProfitByMarket @Year = 2011
--2012
EXEC QuantityOfOrdersSalesProfitByMarket @Year = 2012
--2013
EXEC QuantityOfOrdersSalesProfitByMarket @Year = 2013
--2014
EXEC QuantityOfOrdersSalesProfitByMarket @Year = 2014



--18.b)  A scalar function was used to calculate the percentage of Quantity of Orders
DROP FUNCTION PercentageOfQuantityOfOrders
CREATE FUNCTION PercentageOfQuantityOfOrders(
	@n float,
	@m float
)
RETURNS FLOAT
AS
BEGIN
	DECLARE @Result float
	SELECT @Result = @n / @m
RETURN @Result
END;

-- The percentage Quantity of Orders in all years

CREATE VIEW QuantityOfOrdersMarket AS
	SELECT DISTINCT [Market],
				count(*) OVER (PARTITION BY [Market]) as [The Quantity of Orders]
	FROM   [Project4].[dbo].[SuperStore]
	
DECLARE @TotalQuantityOfOrders FLOAT
SET @TotalQuantityOfOrders = (SELECT count([Market]) as [Total Quantity of Orders in Market] FROM [Project4].[dbo].[SuperStore])
PRINT @TotalQuantityOfOrders
SELECT [Market],
	ROUND(CAST([dbo].PercentageOfQuantityOfOrders([The Quantity of Orders],@TotalQuantityOfOrders)*100 as float),2) as [The percentage of Quantity of Orders (%)]
FROM QuantityOfOrdersMarket
ORDER BY [The percentage of Quantity of Orders (%)] DESC


-- 18.c) a table valued function was calculated to return the result of  the quantity of year by year
CREATE FUNCTION PercentageQuantityOfOrdersInYear
(
	@Year int
)
RETURNS TABLE
AS
RETURN

	SELECT DISTINCT [Market],
				count(*) OVER (PARTITION BY [Market]) as [The Quantity of Orders]
	FROM   [Project4].[dbo].[SuperStore]
	WHERE [YearOfOrderDate] = @Year



DECLARE @TotalQuantityOfOrders2011 FLOAT
SET @TotalQuantityOfOrders2011 = (SELECT count([Market]) as [Total Quantity of Orders in Market] FROM [Project4].[dbo].[SuperStore] WHERE [YearOfOrderDate] = 2011)
PRINT @TotalQuantityOfOrders2011
DECLARE @TotalQuantityOfOrders2012 FLOAT
SET @TotalQuantityOfOrders2012 = (SELECT count([Market]) as [Total Quantity of Orders in Market] FROM [Project4].[dbo].[SuperStore] WHERE [YearOfOrderDate] = 2012)
PRINT @TotalQuantityOfOrders2012
DECLARE @TotalQuantityOfOrders2013 FLOAT
SET @TotalQuantityOfOrders2013 = (SELECT count([Market]) as [Total Quantity of Orders in Market] FROM [Project4].[dbo].[SuperStore] WHERE [YearOfOrderDate] = 2013)
PRINT @TotalQuantityOfOrders2013
DECLARE @TotalQuantityOfOrders2014 FLOAT
SET @TotalQuantityOfOrders2014 = (SELECT count([Market]) as [Total Quantity of Orders in Market] FROM [Project4].[dbo].[SuperStore] WHERE [YearOfOrderDate] = 2014)
PRINT @TotalQuantityOfOrders2014;
WITH PercentageOfQuantityOfOrders2011 AS (
	SELECT [Market],
		ROUND(CAST([dbo].PercentageOfQuantityOfOrders([The Quantity of Orders],@TotalQuantityOfOrders2011)*100 as float),2) as [The percentage of Quantity of Orders (%)]
	FROM PercentageQuantityOfOrdersInYear(2011)
), PercentageOfQuantityOfOrders2012 AS (
SELECT [Market],
	ROUND(CAST([dbo].PercentageOfQuantityOfOrders([The Quantity of Orders],@TotalQuantityOfOrders2012)*100 as float),2) as [The percentage of Quantity of Orders (%)]
FROM PercentageQuantityOfOrdersInYear(2012)
), PercentageOfQuantityOfOrders2013 AS (
SELECT [Market],
	ROUND(CAST([dbo].PercentageOfQuantityOfOrders([The Quantity of Orders],@TotalQuantityOfOrders2013)*100 as float),2) as [The percentage of Quantity of Orders (%)]
FROM PercentageQuantityOfOrdersInYear(2013)
), PercentageOfQuantityOfOrders2014 AS (
SELECT [Market],
	ROUND(CAST([dbo].PercentageOfQuantityOfOrders([The Quantity of Orders],@TotalQuantityOfOrders2014)*100 as float),2) as [The percentage of Quantity of Orders (%)]
FROM PercentageQuantityOfOrdersInYear(2014)
)
SELECT PQO2011.[Market] as [Market],
		PQO2011.[The percentage of Quantity of Orders (%)] as [The percentage of Quantity of Orders 2011 (%)],
		PQO2012.[The percentage of Quantity of Orders (%)] as [The percentage of Quantity of Orders 2012 (%)],
		PQO2013.[The percentage of Quantity of Orders (%)] as [The percentage of Quantity of Orders 2013 (%)],
		PQO2014.[The percentage of Quantity of Orders (%)] as [The percentage of Quantity of Orders 2014 (%)]
FROM PercentageOfQuantityOfOrders2011 PQO2011
	LEFT JOIN PercentageOfQuantityOfOrders2012 PQO2012
		ON PQO2011.[Market] = PQO2012.[Market]
	LEFT JOIN PercentageOfQuantityOfOrders2013 PQO2013
		ON PQO2011.[Market] = PQO2013.[Market]
	LEFT JOIN PercentageOfQuantityOfOrders2014 PQO2014
		ON PQO2011.[Market] = PQO2014.[Market]
ORDER BY PQO2011.[Market] DESC


-- 19.a) Shipping Cost in Order Priority (LOW, HIGH, MEDIUM, CRITICAL) by Market in all years
SELECT [Market],
	[Low] as [Low Order Priority],
	[Medium] as [Medium Order Priority],
	[High] as [High Order Priority],
	[Critical] as [Critical Order Priority]
FROM
(
SELECT DISTINCT [Market],[Order Priority],
			SUM([Shipping Cost]) OVER (PARTITION BY [Market],[Order Priority]) as [Shipping Cost]
FROM   [Project4].[dbo].[SuperStore]
) as SrC1
PIVOT
(
	SUM([Shipping Cost])
	FOR [Order Priority] IN ([Low],[Medium],[High],[Critical])

) as PvT1

--Shipping Cost in Order Priority by Market 2011
	SELECT [Market],
		[Low] as [Low Order Priority],
		[Medium] as [Medium Order Priority],
		[High] as [High Order Priority],
		[Critical] as [Critical Order Priority]
	FROM
	(
	SELECT DISTINCT [Market],[Order Priority],
				SUM([Shipping Cost]) OVER (PARTITION BY [Market],[Order Priority]) as [Shipping Cost]
	FROM   [Project4].[dbo].[SuperStore]
	WHERE [YearOforderDate] = 2011
	) as SrC2
	PIVOT
	(
		SUM([Shipping Cost])
		FOR [Order Priority] IN ([Low],[Medium],[High],[Critical])

	) as PvT2
--Shipping Cost in Order Priority by Market 2012

	SELECT [Market],
		[Low] as [Low Order Priority],
		[Medium] as [Medium Order Priority],
		[High] as [High Order Priority],
		[Critical] as [Critical Order Priority]
	FROM
	(
	SELECT DISTINCT [Market],[Order Priority],
				SUM([Shipping Cost]) OVER (PARTITION BY [Market],[Order Priority]) as [Shipping Cost]
	FROM   [Project4].[dbo].[SuperStore]
	WHERE [YearOforderDate] = 2012
	) as SrC3
	PIVOT
	(
		SUM([Shipping Cost])
		FOR [Order Priority] IN ([Low],[Medium],[High],[Critical])

	) as PvT3

--Shipping Cost in Order Priority by Market 2013
	SELECT [Market],
		[Low] as [Low Order Priority],
		[Medium] as [Medium Order Priority],
		[High] as [High Order Priority],
		[Critical] as [Critical Order Priority]
	FROM
	(
	SELECT DISTINCT [Market],[Order Priority],
				SUM([Shipping Cost]) OVER (PARTITION BY [Market],[Order Priority]) as [Shipping Cost]
	FROM   [Project4].[dbo].[SuperStore]
	WHERE [YearOforderDate] = 2013
	) as SrC4
	PIVOT
	(
		SUM([Shipping Cost])
		FOR [Order Priority] IN ([Low],[Medium],[High],[Critical])

	) as PvT4

--Shipping Cost in Order Priority by Market 2014

SELECT [Market],
	[Low] as [Low Order Priority],
	[Medium] as [Medium Order Priority],
	[High] as [High Order Priority],
	[Critical] as [Critical Order Priority]
FROM
(
SELECT DISTINCT [Market],[Order Priority],
			SUM([Shipping Cost]) OVER (PARTITION BY [Market],[Order Priority]) as [Shipping Cost]
FROM   [Project4].[dbo].[SuperStore]
WHERE [YearOforderDate] = 2014
) as SrC5
PIVOT
(
	SUM([Shipping Cost])
	FOR [Order Priority] IN ([Low],[Medium],[High],[Critical])

) as PvT5


-- 20.a) Shipping Cost in  Category by Market

SELECT [Market],
		[Office Supplies],
		[Furniture],
		[Technology]
FROM
(
SELECT DISTINCT [Market],[Category],
			SUM([Shipping Cost]) OVER (PARTITION BY [Market],[Category]) as [Shipping Cost]
FROM   [Project4].[dbo].[SuperStore]
) as Src1
PIVOT
(
 SUM([Shipping Cost])
 FOR [Category] in ([Furniture],[Technology],[Office Supplies])
) as PvT1

---- 20.b) Shipping Cost by Market year by year 
SELECT [Market],
		[2011],
		[2012],
		[2013],
		[2014]
FROM
(
SELECT DISTINCT [Market],[YearOfOrderDate],
			SUM([Shipping Cost]) OVER (PARTITION BY [Market],[YearOfOrderDate]) as [Shipping Cost]
FROM   [Project4].[dbo].[SuperStore]
) as SrC2
PIVOT
(
	SUM([Shipping Cost])
	FOR [YearOfOrderDate] IN ([2011],[2012],[2013],[2014])
) as PvT2

--Shipping Cost by Market in quarters by all years
WITH ShippingCostMarket2011Quarters AS (
	SELECT [Market],
			[1] AS [Q1 2011],
			[2] AS [Q2 2011],
			[3] AS [Q3 2011],
			[4] AS [Q4 2011]
	FROM
	(
	SELECT DISTINCT  [Market], DATEPART(QQ, [OrderDate]) as Quarters, SUM([Shipping Cost]) OVER (PARTITION BY [Market],[OrderDate]) as [Shipping Cost]
	FROM   [Project4].[dbo].[SuperStore]
	WHERE [YearOfOrderDate] = 2011
	) as Src1
	PIVOT
	(
		SUM([Shipping Cost])
		FOR [Quarters] in ([1],[2],[3],[4])
	) as PvT1
), ShippingCostMarket2012Quarters AS (
SELECT [Market],
			[1] AS [Q1 2012],
			[2] AS [Q2 2012],
			[3] AS [Q3 2012],
			[4] AS [Q4 2012]
	FROM
	(
	SELECT DISTINCT  [Market], DATEPART(QQ, [OrderDate]) as Quarters, SUM([Shipping Cost]) OVER (PARTITION BY [Market],[OrderDate]) as [Shipping Cost]
	FROM   [Project4].[dbo].[SuperStore]
	WHERE [YearOfOrderDate] = 2012
	) as Src1
	PIVOT
	(
		SUM([Shipping Cost])
		FOR [Quarters] in ([1],[2],[3],[4])
	) as PvT1
), ShippingCostMarket2013Quarters AS (
SELECT [Market],
			[1] AS [Q1 2013],
			[2] AS [Q2 2013],
			[3] AS [Q3 2013],
			[4] AS [Q4 2013]
	FROM
	(
	SELECT DISTINCT  [Market], DATEPART(QQ, [OrderDate]) as Quarters, SUM([Shipping Cost]) OVER (PARTITION BY [Market],[OrderDate]) as [Shipping Cost]
	FROM   [Project4].[dbo].[SuperStore]
	WHERE [YearOfOrderDate] = 2013
	) as Src1
	PIVOT
	(
		SUM([Shipping Cost])
		FOR [Quarters] in ([1],[2],[3],[4])
	) as PvT1

), ShippingCostMarket2014Quarters AS (
SELECT [Market],
			[1] AS [Q1 2014],
			[2] AS [Q2 2014],
			[3] AS [Q3 2014],
			[4] AS [Q4 2014]
	FROM
	(
	SELECT DISTINCT  [Market], DATEPART(QQ, [OrderDate]) as Quarters, SUM([Shipping Cost]) OVER (PARTITION BY [Market],[OrderDate]) as [Shipping Cost]
	FROM   [Project4].[dbo].[SuperStore]
	WHERE [YearOfOrderDate] = 2014
	) as Src1
	PIVOT
	(
		SUM([Shipping Cost])
		FOR [Quarters] in ([1],[2],[3],[4])
	) as PvT1

)
SELECT 
	SC2011Q.[Market] as [Market],
	SC2011Q.[Q1 2011] as [Q1 2011],
	SC2011Q.[Q2 2011] as [Q2 2011],
	SC2011Q.[Q3 2011] as [Q3 2011],
	SC2011Q.[Q4 2011] as [Q4 2011],
	SC2012Q.[Q1 2012] as [Q1 2012],
	SC2012Q.[Q2 2012] as [Q2 2012],
	SC2012Q.[Q3 2012] as [Q3 2012],
	SC2012Q.[Q4 2012] as [Q4 2012],
	SC2013Q.[Q1 2013] as [Q1 2013],
	SC2013Q.[Q2 2013] as [Q2 2013],
	SC2013Q.[Q3 2013] as [Q3 2013],
	SC2013Q.[Q4 2013] as [Q4 2013],
	SC2014Q.[Q1 2014] as [Q1 2014],
	SC2014Q.[Q2 2014] as [Q2 2014],
	SC2014Q.[Q3 2014] as [Q3 2014],
	SC2014Q.[Q4 2014] as [Q4 2014]
FROM ShippingCostMarket2011Quarters SC2011Q
	LEFT JOIN ShippingCostMarket2012Quarters SC2012Q
		ON SC2011Q.[Market] = SC2012Q.[Market]
	LEFT JOIN ShippingCostMarket2013Quarters SC2013Q
		ON SC2011Q.[Market] = SC2013Q.[Market]
	LEFT JOIN ShippingCostMarket2014Quarters SC2014Q
		ON SC2011Q.[Market] = SC2014Q.[Market]


-- 21a.) Quantity of Orders by Region in all years
--A scalar function was created to calculate the percentage of region
DROP FUNCTION dbo.PercentageOfRegion
CREATE FUNCTION dbo.PercentageOfRegion
(
	@n float,
	@m float
)
RETURNS FLOAT
AS BEGIN 
	DECLARE @Result FLOAT
	SELECT @Result = CAST(ROUND((@n / @m)*100,2) as FLOAT)
RETURN @Result
END

-- A table valud function was created to store the data
CREATE FUNCTION QuantityOfOrdersByRegion
(
	@StartYear int,
	@EndYear int
)
RETURNS TABLE
AS
RETURN
	SELECT DISTINCT [Region], count(*) OVER (PARTITION BY [Region]) as [Quantity of Orders]
	FROM   [Project4].[dbo].[SuperStore]
	WHERE [YearOfOrderDate] BETWEEN @StartYear AND @EndYear


-- 21.b) The Percentage Quantity of Orders in all years
DECLARE @TotalQuantityOfOrdersRegion FLOAT
SET @TotalQuantityOfOrdersRegion = (SELECT DISTINCT count([Region]) as [Total Orders Region] FROM   [Project4].[dbo].[SuperStore])
PRINT @TotalQuantityOfOrdersRegion
SELECT [Region],
		dbo.PercentageOfRegion([Quantity of Orders],@TotalQuantityOfOrdersRegion) as [The percentage quantity of orders by Region (%)]
FROM QuantityOfOrdersByRegion(2011,2014)
ORDER BY [The percentage quantity of orders by Region (%)] DESC


-- 21.c) Shipping Cost of Region in Quarters in all years
WITH ShippingCostRegion2011Quarter AS (
	SELECT 
		[Region],
		[1],
		[2],
		[3],
		[4]
	FROM
	(
	SELECT [Region],
			DATEPART(QQ, [OrderDate]) as [Quarters],
			SUM([Shipping Cost]) OVER (PARTITION BY [Market],[OrderDate]) as [Shipping Cost by Quarter] 
	FROM   [Project4].[dbo].[SuperStore]
	WHERE [YearOfOrderDate] = 2011
	) SrC1
	PIVOT
	(
		SUM([Shipping Cost by Quarter])
		FOR [Quarters] IN ([1],[2],[3],[4])
	) as PvT1
), ShippingCostRegion2012Quarter AS (
	SELECT 
		[Region],
		[1],
		[2],
		[3],
		[4]
	FROM
	(
	SELECT [Region],
			DATEPART(QQ, [OrderDate]) as [Quarters],
			SUM([Shipping Cost]) OVER (PARTITION BY [Market],[OrderDate]) as [Shipping Cost by Quarter] 
	FROM   [Project4].[dbo].[SuperStore]
	WHERE [YearOfOrderDate] = 2012
	) SrC1
	PIVOT
	(
		SUM([Shipping Cost by Quarter])
		FOR [Quarters] IN ([1],[2],[3],[4])
	) as PvT1
), ShippingCostRegion2013Quarter AS (
	SELECT 
		[Region],
		[1],
		[2],
		[3],
		[4]
	FROM
	(
	SELECT [Region],
			DATEPART(QQ, [OrderDate]) as [Quarters],
			SUM([Shipping Cost]) OVER (PARTITION BY [Market],[OrderDate]) as [Shipping Cost by Quarter] 
	FROM   [Project4].[dbo].[SuperStore]
	WHERE [YearOfOrderDate] = 2013
	) SrC1
	PIVOT
	(
		SUM([Shipping Cost by Quarter])
		FOR [Quarters] IN ([1],[2],[3],[4])
	) as PvT1
), ShippingCostRegion2014Quarter AS (
	SELECT 
		[Region],
		[1],
		[2],
		[3],
		[4]
	FROM
	(
	SELECT [Region],
			DATEPART(QQ, [OrderDate]) as [Quarters],
			SUM([Shipping Cost]) OVER (PARTITION BY [Market],[OrderDate]) as [Shipping Cost by Quarter] 
	FROM   [Project4].[dbo].[SuperStore]
	WHERE [YearOfOrderDate] = 2014
	) SrC1
	PIVOT
	(
		SUM([Shipping Cost by Quarter])
		FOR [Quarters] IN ([1],[2],[3],[4])
	) as PvT1
)
SELECT	
		Q11.[Region],
		Q11.[1] as [Q1 2011],
		Q11.[2] as [Q2 2011],
		Q11.[3] as [Q3 2011],
		Q11.[4] as [Q4 2011],
		Q12.[1] as [Q1 2012],
		Q12.[2] as [Q2 2012],
		Q12.[3] as [Q3 2012],
		Q12.[4] as [Q4 2012],
		Q13.[1] as [Q1 2013],
		Q13.[2] as [Q2 2013],
		Q13.[3] as [Q3 2013],
		Q13.[4] as [Q4 2013],
		Q14.[1] as [Q1 2014],
		Q14.[2] as [Q2 2014],
		Q14.[3] as [Q3 2014],
		Q14.[4] as [Q4 2014]
FROM ShippingCostRegion2011Quarter Q11
	LEFT JOIN ShippingCostRegion2012Quarter Q12
		 ON Q11.[Region] = Q12.[Region]
	LEFT JOIN ShippingCostRegion2013Quarter Q13
		ON Q11.[Region] = Q13.[Region]
	LEFT JOIN ShippingCostRegion2014Quarter Q14
		ON Q11.[Region] = Q14.[Region]



--22.a) The percentage quantity of orders of  Sub-Category
-- A scalar function was created for calculation
DROP FUNCTION dbo.PercentageOfValue
CREATE FUNCTION dbo.PercentageOfValue
	( 
		@n FLOAT,
		@m FLOAT
	)
RETURNS FLOAT
AS
BEGIN
	DECLARE @Result FLOAT
	SELECT @Result = ROUND((@n / @m)*100,2) 
RETURN @Result 
END
-- A table variable was created to store data
DECLARE @SubCategoryTableQuantity TABLE (
	[Sub-Category] nvarchar(max),
	[The Quantity of Orders] FLOAT

);

INSERT INTO @SubCategoryTableQuantity
	SELECT DISTINCT [Sub-Category], count(*) OVER (PARTITION BY [Sub-Category])  as [The Quantity of Orders]
	FROM   [Project4].[dbo].[SuperStore]
	ORDER BY [The Quantity of Orders] DESC
-- DECLARE THE TOTAL Quantity of Orderds by Sub Category
DECLARE @TotalQuantity FLOAT
SET @TotalQuantity = (SELECT count([Sub-Category]) as [Total Quantity of Orders] FROM   [Project4].[dbo].[SuperStore])
PRINT @TotalQuantity

--23.a)  The percentage quantity of Sub Category in all years
SELECT [Sub-Category],
		dbo.PercentageOfValue([The Quantity of Orders],@TotalQuantity) as [The Percentage Quantity of Sub Category (%)]
FROM @SubCategoryTableQuantity
ORDER BY [The Percentage Quantity of Sub Category (%)] DESC




--24.a)  Sales of Sub-Category
CREATE VIEW SalesOfSubCategory AS 
	SELECT DISTINCT [Sub-Category], SUM([Sales]) OVER (PARTITION BY [Sub-Category]) as Sales
	FROM   [Project4].[dbo].[SuperStore] 
-- The ranking of Sub-Category
SELECT RANK() OVER (ORDER BY [Sales] DESC) as [Ranking], *
FROM SalesOfSubCategory

--24.b)  Profit of Sub-Category 
CREATE VIEW ProfitOfSubCategory AS 
	SELECT DISTINCT [Sub-Category], SUM([Profit]) OVER (PARTITION BY [Sub-Category]) as Profit
	FROM   [Project4].[dbo].[SuperStore] 
-- The ranking of Sub-Category
SELECT RANK() OVER (ORDER BY [Profit] DESC) as [Ranking], *
FROM ProfitOfSubCategory

-- 25.a) Shipping Cost of Sub Category
CREATE VIEW ShippingCostOfSubCategory AS 
	SELECT DISTINCT [Sub-Category], SUM([Shipping Cost]) OVER (PARTITION BY [Sub-Category]) as [Shipping Cost]
	FROM   [Project4].[dbo].[SuperStore] 

SELECT RANK() OVER (ORDER BY [Shipping Cost] DESC) as [Ranking], *
FROM ShippingCostOfSubCategory

-- 26.a) Sales, Profit, Shipping Cost of Sub Category in all years
WITH SalesOfSubCategory AS (
	SELECT 
			[Sub-Category],
			[2011],
			[2012],
			[2013],
			[2014]
	FROM
	(
	SELECT DISTINCT [YearOfOrderDate], [Sub-Category], SUM([Sales]) OVER (PARTITION BY [Sub-Category], [YearOfOrderDate]) as Sales
	FROM   [Project4].[dbo].[SuperStore] 
	) as SrC1
	PIVOT
	(
		SUM(Sales)
		FOR [YearOfOrderDate] IN ([2011],[2012],[2013],[2014])
	) as PvT1
), ProfitOfSubCategory AS (
	SELECT 
			[Sub-Category],
			[2011],
			[2012],
			[2013],
			[2014]
	FROM
	(
	SELECT DISTINCT [YearOfOrderDate], [Sub-Category], SUM([Profit]) OVER (PARTITION BY [Sub-Category], [YearOfOrderDate]) as Profit
	FROM   [Project4].[dbo].[SuperStore] 
	) as SrC2
	PIVOT
	(
		SUM(Profit)
		FOR [YearOfOrderDate] IN ([2011],[2012],[2013],[2014])
	) as PvT2
), ShippingCostOfSubCategory AS (
	SELECT 
			[Sub-Category],
			[2011],
			[2012],
			[2013],
			[2014]
	FROM
	(
	SELECT DISTINCT [YearOfOrderDate], [Sub-Category], SUM([Shipping Cost]) OVER (PARTITION BY [Sub-Category], [YearOfOrderDate]) as [Shipping Cost]
	FROM   [Project4].[dbo].[SuperStore] 
	) as SrC3
	PIVOT
	(
		SUM([Shipping Cost])
		FOR [YearOfOrderDate] IN ([2011],[2012],[2013],[2014])
	) as PvT3
)
SELECT S.[Sub-Category],
		S.[2011] as [Sales 2011],
		S.[2012] as [Sales 2012],
		S.[2013] as [Sales 2014],
		S.[2014] as [Sales 2014],
		P.[2011] as [Profit 2011],
		P.[2012] as [Profit 2012],
		P.[2013] as [Profit 2013],
		P.[2014] as [Profit 2014],
		SC.[2011] as [Shipping Cost 2011],
		SC.[2012] as [Shipping Cost 2012],
		SC.[2013] as [Shipping Cost 2013],
		SC.[2014] as [Shipping Cost 2014]
FROM SalesOfSubCategory S
LEFT JOIN ProfitOfSubCategory P
	ON S.[Sub-Category] = P.[Sub-Category]
LEFT JOIN ShippingCostOfSubCategory SC
	ON S.[Sub-Category] = SC.[Sub-Category]
ORDER BY [Sub-Category] ASC


--27.a)  Sales of Sub Category by Country
DROP TABLE IF EXISTS #SubCategoryCountrySales
CREATE TABLE #SubCategoryCountrySales (
	[Sub-Category] nvarchar(max),
	[Country] nvarchar(max),
	[Sales] bigint

)
INSERT INTO #SubCategoryCountrySales
	SELECT DISTINCT [Sub-Category], 
			[Country], 
			SUM([Sales]) OVER (PARTITION BY [Sub-Category],[Country]) as [Sales]
	FROM   [Project4].[dbo].[SuperStore] 

SELECT RANK() OVER (PARTITION BY [Sub-Category] ORDER BY [Sales] DESC) as [Ranking], *
FROM #SubCategoryCountrySales

SELECT DISTINCT
	[Sub-Category],
	FIRST_VALUE([Country]) OVER (PARTITION BY [Sub-Category] ORDER BY [Sales] DESC) as [Country with the greatest Sales],
	MAX([Sales]) OVER (PARTITION BY [Sub-Category]) as [The greatest Sales],
	LAST_VALUE([Country]) OVER (PARTITION BY [Sub-Category] ORDER BY [Sales] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Sales],
	MIN([Sales]) OVER (PARTITION BY [Sub-Category]) as [The lowest Sales]
FROM #SubCategoryCountrySales

--28.a)  Profit of Sub Category by Country
DROP TABLE IF EXISTS #SubCategoryCountryProfit
CREATE TABLE #SubCategoryCountryProfit (
	[Sub-Category] nvarchar(max),
	[Country] nvarchar(max),
	[Profit] bigint
)

INSERT INTO #SubCategoryCountryProfit
	SELECT DISTINCT [Sub-Category], 
			[Country], 
			SUM([Profit]) OVER (PARTITION BY [Sub-Category],[Country]) as [Profit]
	FROM   [Project4].[dbo].[SuperStore] 
	WHERE [Profit] >= 1

SELECT RANK() OVER (PARTITION BY [Sub-Category] ORDER BY [Profit] DESC) as [Ranking], *
FROM #SubCategoryCountryProfit

--29.a)  Country with the greatest and lowest Profit by Sub-Category
SELECT DISTINCT
	[Sub-Category],
	FIRST_VALUE([Country]) OVER (PARTITION BY [Sub-Category] ORDER BY [Profit] DESC) as [Country with the greatest Profit],
	MAX([Profit]) OVER (PARTITION BY [Sub-Category]) as [The greatest Profit],
	LAST_VALUE([Country]) OVER (PARTITION BY [Sub-Category] ORDER BY [Profit] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Profit],
	MIN([Profit]) OVER (PARTITION BY [Sub-Category]) as [The lowest Profit]
FROM #SubCategoryCountryProfit

-- 30.a) Sales and Profit of SubCategory by Country

WITH SalesOfSubCategoryByCountry AS (
	SELECT DISTINCT
		[Sub-Category],
		FIRST_VALUE([Country]) OVER (PARTITION BY [Sub-Category] ORDER BY [Sales] DESC) as [Country with the greatest Sales],
		MAX([Sales]) OVER (PARTITION BY [Sub-Category]) as [The greatest Sales],
		LAST_VALUE([Country]) OVER (PARTITION BY [Sub-Category] ORDER BY [Sales] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Sales],
		MIN([Sales]) OVER (PARTITION BY [Sub-Category]) as [The lowest Sales]
	FROM #SubCategoryCountrySales
), ProfitOfSubCategoryByCountry AS (
SELECT DISTINCT
	[Sub-Category],
	FIRST_VALUE([Country]) OVER (PARTITION BY [Sub-Category] ORDER BY [Profit] DESC) as [Country with the greatest Profit],
	MAX([Profit]) OVER (PARTITION BY [Sub-Category]) as [The greatest Profit],
	LAST_VALUE([Country]) OVER (PARTITION BY [Sub-Category] ORDER BY [Profit] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Profit],
	MIN([Profit]) OVER (PARTITION BY [Sub-Category]) as [The lowest Profit]
FROM #SubCategoryCountryProfit
)
SELECT 
	SC.[Sub-Category],
	SC.[Country with the greatest Sales],
	SC.[The greatest Sales],
	SC.[Country with the lowest Sales],
	SC.[The lowest Sales],
	PC.[Country with the greatest Profit],
	PC.[The greatest Profit],
	PC.[Country with the lowest Profit],
	PC.[The lowest Profit]
FROM SalesOfSubCategoryByCountry SC
LEFT JOIN ProfitOfSubCategoryByCountry PC
	ON SC.[Sub-Category] = PC.[Sub-Category]



-- 31a.) Sales of Sub Category based on Category
CREATE FUNCTION SalesOfSubCategoryOnCategoryYear 
(
	@StartYear int,
	@EndYear int
)
RETURNS TABLE
AS
RETURN
	SELECT DISTINCT  [Category], [Sub-Category],
			SUM([Sales]) OVER (PARTITION BY [Category],[Sub-Category]) AS [Sales]
	FROM   [Project4].[dbo].[SuperStore]
	WHERE YearOfOrderDate BETWEEN @StartYear and @EndYear

--31. b)  Sales of SubCategory based on Category in all years
SELECT *
FROM SalesOfSubCategoryOnCategoryYear(2011,2014)
ORDER BY Sales DESC
--31.c)  The Ranking of Sub-Category
SELECT [Category], RANK() OVER (PARTITION BY [Category] ORDER BY Sales DESC) as [Ranking], [Sub-Category], [Sales]
FROM SalesOfSubCategoryOnCategoryYear(2011,2014)
--31.d)  The Greatest Sales and Lowest Sales by Sub Category
SELECT DISTINCT
	[Category],
	FIRST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Sales DESC) as [The greatest Sales of Sub-Category],
	MAX([Sales]) OVER (PARTITION BY [Category]) as [The greatest Sales],
	LAST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Sales DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The lowest Sales of Sub-Category],
	MIN([Sales]) OVER (PARTITION BY [Category]) as [The lowest Sales]
FROM SalesOfSubCategoryOnCategoryYear(2011,2014)
-- 31.e) Sales of SubCategory based on Category in 2011
SELECT *
FROM SalesOfSubCategoryOnCategoryYear(2011,2011)
ORDER BY [Category] ASC
-- The Ranking of Sub-Category
SELECT [Category], RANK() OVER (PARTITION BY [Category] ORDER BY Sales DESC) as [Ranking], [Sub-Category], [Sales]
FROM SalesOfSubCategoryOnCategoryYear(2011,2011)
-- The Greatest Sales and Lowest Sales by Sub Category
SELECT DISTINCT
	[Category],
	FIRST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Sales DESC) as [The greatest Sales of Sub-Category],
	MAX([Sales]) OVER (PARTITION BY [Category]) as [The greatest Sales],
	LAST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Sales
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The lowest Sales of Sub-Category],
	MIN([Sales]) OVER (PARTITION BY [Category]) as [The lowest Sales]
FROM SalesOfSubCategoryOnCategoryYear(2011,2011)

-- 31.f) Sales of SubCategory based on Category in 2012
SELECT *
FROM SalesOfSubCategoryOnCategoryYear(2012,2012)
ORDER BY [Category] ASC
-- The Ranking of Sub-Category
SELECT [Category], RANK() OVER (PARTITION BY [Category] ORDER BY Sales DESC) as [Ranking], [Sub-Category], [Sales]
FROM SalesOfSubCategoryOnCategoryYear(2012,2012)
-- The Greatest Sales and Lowest Sales by Sub Category
SELECT DISTINCT
	[Category],
	FIRST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Sales DESC) as [The greatest Sales of Sub-Category],
	MAX([Sales]) OVER (PARTITION BY [Category]) as [The greatest Sales],
	LAST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Sales
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The lowest Sales of Sub-Category],
	MIN([Sales]) OVER (PARTITION BY [Category]) as [The lowest Sales]
FROM SalesOfSubCategoryOnCategoryYear(2012,2012)

--31.g)  Sales of SubCategory based on Category in 2013
SELECT *
FROM SalesOfSubCategoryOnCategoryYear(2013,2013)
ORDER BY [Category] ASC
-- The Ranking of Sub-Category
SELECT [Category], RANK() OVER (PARTITION BY [Category] ORDER BY Sales DESC) as [Ranking], [Sub-Category], [Sales]
FROM SalesOfSubCategoryOnCategoryYear(2013,2013)
-- The Greatest Sales and Lowest Sales by Sub Category
SELECT DISTINCT
	[Category],
	FIRST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Sales DESC) as [The greatest Sales of Sub-Category],
	MAX([Sales]) OVER (PARTITION BY [Category]) as [The greatest Sales],
	LAST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Sales
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The lowest Sales of Sub-Category],
	MIN([Sales]) OVER (PARTITION BY [Category]) as [The lowest Sales]
FROM SalesOfSubCategoryOnCategoryYear(2013,2013)

-- 31.i) Sales of SubCategory based on Category in 2014
SELECT *
FROM SalesOfSubCategoryOnCategoryYear(2014,2014)
ORDER BY [Category] ASC
-- The Ranking of Sub-Category
SELECT [Category], RANK() OVER (PARTITION BY [Category] ORDER BY Sales DESC) as [Ranking], [Sub-Category], [Sales]
FROM SalesOfSubCategoryOnCategoryYear(2014,2014)
-- The Greatest Sales and Lowest Sales by Sub Category
SELECT DISTINCT
	[Category],
	FIRST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Sales DESC) as [The greatest Sales of Sub-Category],
	MAX([Sales]) OVER (PARTITION BY [Category]) as [The greatest Sales],
	LAST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Sales
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The lowest Sales of Sub-Category],
	MIN([Sales]) OVER (PARTITION BY [Category]) as [The lowest Sales]
FROM SalesOfSubCategoryOnCategoryYear(2014,2014)

-- 31.j) The greatest and Lowest Sales by Sub Category in all years

WITH SalesOfSubCategory2011 AS (
	SELECT DISTINCT
		[Category],
		FIRST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Sales DESC) as [The greatest Sales of Sub-Category],
		MAX([Sales]) OVER (PARTITION BY [Category]) as [The greatest Sales],
		LAST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Sales
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The lowest Sales of Sub-Category],
		MIN([Sales]) OVER (PARTITION BY [Category]) as [The lowest Sales]
	FROM SalesOfSubCategoryOnCategoryYear(2011,2011)
), SalesOfSubCategory2012 AS (
	SELECT DISTINCT
		[Category],
		FIRST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Sales DESC) as [The greatest Sales of Sub-Category],
		MAX([Sales]) OVER (PARTITION BY [Category]) as [The greatest Sales],
		LAST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Sales
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The lowest Sales of Sub-Category],
		MIN([Sales]) OVER (PARTITION BY [Category]) as [The lowest Sales]
	FROM SalesOfSubCategoryOnCategoryYear(2012,2012)
), SalesOfSubCategory2013 AS (
	SELECT DISTINCT
		[Category],
		FIRST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Sales DESC) as [The greatest Sales of Sub-Category],
		MAX([Sales]) OVER (PARTITION BY [Category]) as [The greatest Sales],
		LAST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Sales
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The lowest Sales of Sub-Category],
		MIN([Sales]) OVER (PARTITION BY [Category]) as [The lowest Sales]
	FROM SalesOfSubCategoryOnCategoryYear(2013,2013)
), SalesOfSubCategory2014 AS (
	SELECT DISTINCT
		[Category],
		FIRST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Sales DESC) as [The greatest Sales of Sub-Category],
		MAX([Sales]) OVER (PARTITION BY [Category]) as [The greatest Sales],
		LAST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Sales
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The lowest Sales of Sub-Category],
		MIN([Sales]) OVER (PARTITION BY [Category]) as [The lowest Sales]
	FROM SalesOfSubCategoryOnCategoryYear(2014,2014)
)
SELECT 
	S2011.[Category],
	S2011.[The greatest Sales of Sub-Category] as [The greatest Sales of Sub Category 2011],
	S2011.[The greatest Sales] as [The greatest Sales 2011],
	S2011.[The lowest Sales of Sub-Category] as [The lowest Sales of Sub-Category 2011],
	S2011.[The lowest Sales] as [The lowest Sales 2011],
	S2012.[The greatest Sales of Sub-Category] as [The greatest Sales of Sub Category 2012],
	S2012.[The greatest Sales] as [The greatest Sales 2012],
	S2012.[The lowest Sales of Sub-Category] as [The lowest Sales of Sub-Category 2012],
	S2012.[The lowest Sales] as [The lowest Sales 2012],
	S2013.[The greatest Sales of Sub-Category] as [The greatest Sales of Sub Category 2013],
	S2013.[The greatest Sales] as [The greatest Sales 2013],
	S2013.[The lowest Sales of Sub-Category] as [The lowest Sales of Sub-Category 2013],
	S2013.[The lowest Sales] as [The lowest Sales 2013],
	S2014.[The greatest Sales of Sub-Category] as [The greatest Sales of Sub Category 2014],
	S2014.[The greatest Sales] as [The greatest Sales 2014],
	S2014.[The lowest Sales of Sub-Category] as [The lowest Sales of Sub-Category 2014],
	S2014.[The lowest Sales] as [The lowest Sales 2014]
FROM SalesOfSubCategory2011 S2011
	LEFT JOIN SalesOfSubCategory2012 S2012
		ON S2011.[Category] = S2012.[Category]
	LEFT JOIN SalesOfSubCategory2013 S2013
		 ON S2011.[Category] = S2013.[Category]
	LEFT JOIN SalesOfSubCategory2014 S2014
		 ON S2011.[Category] = S2014.[Category]


--
-- 32.a) Profit of Sub Category based on Category
CREATE FUNCTION ProfitOfSubCategoryOnCategoryYear 
(
	@StartYear int,
	@EndYear int
)
RETURNS TABLE
AS
RETURN
	SELECT DISTINCT  [Category], [Sub-Category],
			SUM([Profit]) OVER (PARTITION BY [Category],[Sub-Category]) AS [Profit]
	FROM   [Project4].[dbo].[SuperStore]
	WHERE YearOfOrderDate BETWEEN @StartYear and @EndYear and [Profit] >= 1

-- 32. b) Profit of SubCategory based on Category in all years
SELECT *
FROM ProfitOfSubCategoryOnCategoryYear(2011,2014)
ORDER BY [Category] ASC
-- 32.c) The Ranking of Sub-Category
SELECT [Category], RANK() OVER (PARTITION BY [Category] ORDER BY Profit DESC) as [Ranking], [Sub-Category], [Profit]
FROM ProfitOfSubCategoryOnCategoryYear(2011,2014)
-- 32.d) The Greatest Profit and Lowest Profit by Sub Category
SELECT DISTINCT
	[Category],
	FIRST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Profit DESC) as [The greatest Profit of Sub-Category],
	MAX([Profit]) OVER (PARTITION BY [Category]) as [The greatest Profit],
	LAST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Profit DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The lowest Profit of Sub-Category],
	MIN([Profit]) OVER (PARTITION BY [Category]) as [The lowest Profit]
FROM ProfitOfSubCategoryOnCategoryYear(2011,2014)
-- 32.e) Profit of SubCategory based on Category in 2011
SELECT *
FROM ProfitOfSubCategoryOnCategoryYear(2011,2011)
ORDER BY [Category] ASC
-- The Ranking of Sub-Category
SELECT [Category], RANK() OVER (PARTITION BY [Category] ORDER BY Profit DESC) as [Ranking], [Sub-Category], [Profit]
FROM ProfitOfSubCategoryOnCategoryYear(2011,2011)
-- The Greatest Profit and Lowest Profit by Sub Category
SELECT DISTINCT
	[Category],
	FIRST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Profit DESC) as [The greatest Profit of Sub-Category],
	MAX([Profit]) OVER (PARTITION BY [Category]) as [The greatest Profit],
	LAST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Profit
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The lowest Profit of Sub-Category],
	MIN([Profit]) OVER (PARTITION BY [Category]) as [The lowest Profit]
FROM ProfitOfSubCategoryOnCategoryYear(2011,2011)

--32.f)  Profit of SubCategory based on Category in 2012
SELECT *
FROM ProfitOfSubCategoryOnCategoryYear(2012,2012)
ORDER BY [Category] ASC
-- The Ranking of Sub-Category
SELECT [Category], RANK() OVER (PARTITION BY [Category] ORDER BY Profit DESC) as [Ranking], [Sub-Category], [Profit]
FROM ProfitOfSubCategoryOnCategoryYear(2012,2012)
-- The Greatest Sales and Lowest Sales by Sub Category
SELECT DISTINCT
	[Category],
	FIRST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Profit DESC) as [The greatest Profit of Sub-Category],
	MAX([Profit]) OVER (PARTITION BY [Category]) as [The greatest Profit],
	LAST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Profit
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The lowest Profit of Sub-Category],
	MIN([Profit]) OVER (PARTITION BY [Category]) as [The lowest Profit]
FROM ProfitOfSubCategoryOnCategoryYear(2012,2012)

-- 32.g) Profit of SubCategory based on Category in 2013
SELECT *
FROM ProfitOfSubCategoryOnCategoryYear(2013,2013)
ORDER BY [Category] ASC
-- The Ranking of Sub-Category
SELECT [Category], RANK() OVER (PARTITION BY [Category] ORDER BY Profit DESC) as [Ranking], [Sub-Category], [Profit]
FROM ProfitOfSubCategoryOnCategoryYear(2013,2013)
-- The Greatest Profit and Lowest Profit by Sub Category
SELECT DISTINCT
	[Category],
	FIRST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Profit DESC) as [The greatest Profit of Sub-Category],
	MAX([Profit]) OVER (PARTITION BY [Category]) as [The greatest Profit],
	LAST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Profit
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The lowest Profit of Sub-Category],
	MIN([Profit]) OVER (PARTITION BY [Category]) as [The lowest Profit]
FROM ProfitOfSubCategoryOnCategoryYear(2013,2013)

-- 32.h) Profit of SubCategory based on Category in 2014
SELECT *
FROM ProfitOfSubCategoryOnCategoryYear(2014,2014)
ORDER BY [Category] ASC
-- The Ranking of Sub-Category
SELECT [Category], RANK() OVER (PARTITION BY [Category] ORDER BY Profit DESC) as [Ranking], [Sub-Category], [Profit]
FROM ProfitOfSubCategoryOnCategoryYear(2014,2014)
-- The Greatest Profit and Lowest Profit by Sub Category
SELECT DISTINCT
	[Category],
	FIRST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Profit DESC) as [The greatest Profit of Sub-Category],
	MAX([Profit]) OVER (PARTITION BY [Category]) as [The greatest Profit],
	LAST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Profit
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The lowest Profit of Sub-Category],
	MIN([Profit]) OVER (PARTITION BY [Category]) as [The lowest Profit]
FROM ProfitOfSubCategoryOnCategoryYear(2014,2014)

-- 32.i) The greatest and Lowest Profit by Sub Category in all years

WITH ProfitOfSubCategory2011 AS (
	SELECT DISTINCT
		[Category],
		FIRST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Profit DESC) as [The greatest Profit of Sub-Category],
		MAX([Profit]) OVER (PARTITION BY [Category]) as [The greatest Profit],
		LAST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Profit
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The lowest Profit of Sub-Category],
		MIN([Profit]) OVER (PARTITION BY [Category]) as [The lowest Profit]
	FROM ProfitOfSubCategoryOnCategoryYear(2011,2011)
), ProfitOfSubCategory2012 AS (
	SELECT DISTINCT
		[Category],
		FIRST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Profit DESC) as [The greatest Profit of Sub-Category],
		MAX([Profit]) OVER (PARTITION BY [Category]) as [The greatest Profit],
		LAST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Profit
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The lowest Profit of Sub-Category],
		MIN([Profit]) OVER (PARTITION BY [Category]) as [The lowest Profit]
	FROM ProfitOfSubCategoryOnCategoryYear(2012,2012)
), ProfitOfSubCategory2013 AS (
	SELECT DISTINCT
		[Category],
		FIRST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Profit DESC) as [The greatest Profit of Sub-Category],
		MAX([Profit]) OVER (PARTITION BY [Category]) as [The greatest Profit],
		LAST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Profit
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The lowest Profit of Sub-Category],
		MIN([Profit]) OVER (PARTITION BY [Category]) as [The lowest Profit]
	FROM ProfitOfSubCategoryOnCategoryYear(2013,2013)
), ProfitOfSubCategory2014 AS (
	SELECT DISTINCT
		[Category],
		FIRST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Profit DESC) as [The greatest Profit of Sub-Category],
		MAX([Profit]) OVER (PARTITION BY [Category]) as [The greatest Profit],
		LAST_VALUE([Sub-Category]) OVER (PARTITION BY [Category] ORDER BY Profit
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The lowest Profit of Sub-Category],
		MIN([Profit]) OVER (PARTITION BY [Category]) as [The lowest Profit]
	FROM ProfitOfSubCategoryOnCategoryYear(2014,2014)
)
SELECT 
	P2011.[Category],
	P2011.[The greatest Profit of Sub-Category] as [The greatest Profit of Sub Category 2011],
	P2011.[The greatest Profit] as [The greatest Profit 2011],
	P2011.[The lowest Profit of Sub-Category] as [The lowest Profit of Sub-Category 2011],
	P2011.[The lowest Profit] as [The lowest Profit 2011],
	P2012.[The greatest Profit of Sub-Category] as [The greatest Profit of Sub Category 2012],
	P2012.[The greatest Profit] as [The greatest Profit 2012],
	P2012.[The lowest Profit of Sub-Category] as [The lowest Profit of Sub-Category 2012],
	P2012.[The lowest Profit] as [The lowest Profit 2012],
	P2013.[The greatest Profit of Sub-Category] as [The greatest Profit of Sub Category 2013],
	P2013.[The greatest Profit] as [The greatest Profit 2013],
	P2013.[The lowest Profit of Sub-Category] as [The lowest Profit of Sub-Category 2013],
	P2013.[The lowest Profit] as [The lowest Profit 2013],
	P2014.[The greatest Profit of Sub-Category] as [The greatest Profit of Sub Category 2014],
	P2014.[The greatest Profit] as [The greatest Profit 2014],
	P2014.[The lowest Profit of Sub-Category] as [The lowest Profit of Sub-Category 2014],
	P2014.[The lowest Profit] as [The Profit Sales 2014]
FROM ProfitOfSubCategory2011 P2011
	LEFT JOIN ProfitOfSubCategory2012 P2012
		ON P2011.[Category] = P2012.[Category]
	LEFT JOIN ProfitOfSubCategory2013 P2013
		 ON P2011.[Category] = P2013.[Category]
	LEFT JOIN ProfitOfSubCategory2014 P2014
		 ON P2011.[Category] = P2014.[Category]


-


--33.a) The Quantity of Orders by Product Name

-- The Quantity of Orders of Product Name
SELECT DISTINCT [Product Name], count(*) OVER (PARTITION BY [Product Name]) as [The Quantity of Orders]
FROM   [Project4].[dbo].[SuperStore]
ORDER BY [The Quantity of Orders] DESC

-- The Total quantity of Orders
SELECT COUNT([Product Name]) as [Total Quantity of Orders]
FROM   [Project4].[dbo].[SuperStore]

-- A  Scalar Function was created for calculation
DROP FUNCTION dbo.CalculationofProductName 
CREATE FUNCTION dbo.CalculationofProductName 
(
	@n FLOAT,
	@m FLOAT
)
RETURNS FLOAT
AS
BEGIN
	DECLARE @Result FLOAT
	SELECT @Result = ROUND((@n / @m)*100,4)
RETURN @Result
END


-- A table variable was used to store data
DECLARE @TheQuantityOfProducts TABLE (
	[Product Name] nvarchar(max),
	[The Percentage of Quantity Orders by Product Name] FLOAT
);

INSERT INTO @TheQuantityOfProducts
	SELECT DISTINCT [Product Name], count(*) OVER (PARTITION BY [Product Name]) as [The Quantity of Orders]
	FROM   [Project4].[dbo].[SuperStore]
	ORDER BY [The Quantity of Orders] DESC

-- Total Orders by Product
DECLARE @TotalQuantityOfProduct FLOAT
SET @TotalQuantityOfProduct = (SELECT COUNT([Product Name]) as [Total Quantity of Orders] FROM   [Project4].[dbo].[SuperStore])
PRINT @TotalQuantityOfProduct

--The percetnage of quantity of orders by Product 
SELECT [Product Name], dbo.CalculationofProductName([The Percentage of Quantity Orders by Product Name],@TotalQuantityOfProduct) AS [The Percentage of Quantity Orders by Product Name (%)]
FROM @TheQuantityOfProducts
ORDER BY [The Percentage of Quantity Orders by Product Name] DESC



--34.a) Quantity of Orders, Sales and Profit by Product Name
SELECT DISTINCT [Product Name], count(*) OVER (PARTITION BY [Product Name]) as [The Quantity of Orders],
	SUM([Sales]) OVER (PARTITION BY [Product Name]) as [Sales of Product Name],
	SUM([Profit]) OVER (PARTITION BY [Product Name]) as [Profit of Product Name]
FROM   [Project4].[dbo].[SuperStore]
ORDER BY [The Quantity of Orders] DESC

-- Sales of Product Name
CREATE TABLE #SalesOfProductName 
(
	[Product Name] nvarchar(max),
	[Sales Of Product Name] int
)

INSERT INTO #SalesOfProductName 
	SELECT DISTINCT 
		[Product Name],
		SUM([Sales]) OVER (PARTITION BY [Product Name]) as [Sales of Product Name]
	FROM   [Project4].[dbo].[SuperStore]

-- 34.b) TOP 10 of Sales of Product Name
SELECT TOP 10 WITH TIES *
FROM #SalesOfProductName 
ORDER BY [Sales Of Product Name] DESC
-- 34.c) Sales of Product Name greater than average Sales
SELECT  *
FROM #SalesOfProductName 
WHERE [Sales Of Product Name] > (SELECT AVG([Sales]) FROM  [Project4].[dbo].[SuperStore])
ORDER BY [Sales Of Product Name] DESC

-- 34.d) Cumulative distrubtion of Sales of Product 
SELECT *, 
		CAST(ROUND(CUME_DIST() OVER (ORDER BY [Sales of Product Name] DESC)*100,2) AS FLOAT) as [Cumulative distriubtion (%)]
FROM #SalesOfProductName

--34.e)  Top  25 % Product of Sales
WITH TOP25ProductOfSales AS (
	SELECT [Product Name],
			CAST(ROUND(CUME_DIST() OVER (ORDER BY [Sales of Product Name] DESC)*100,2) AS FLOAT) as [Cumulative distriubtion (%)]
	FROM #SalesOfProductName
)
SELECT [Product Name], [Cumulative distriubtion (%)]
FROM TOP25ProductOfSales
WHERE  [Cumulative distriubtion (%)] <= 25

--34.f) The Percentage Rank of Sales of Product
SELECT *, 
		ROUND(PERCENT_RANK() OVER (ORDER BY [Sales Of Product Name])*100,6) as [Percentage Ranking (%)]
FROM #SalesOfProductName

--34.g)  The group of Product Name by High Sales, Mid Sales and Low Sales
WITH GroupOfProductBy3Levels AS (
	SELECT *, NTILE(3) OVER (ORDER BY [Sales Of Product Name] DESC) as Buckets
	FROM #SalesOfProductName
)
SELECT [Product Name], 
	CASE
		WHEN [Buckets] = 1 THEN 'High Sales'
		WHEN [Buckets] = 2 THEN 'Mid Sales'
		WHEN [Buckets] = 3 THEN 'Low Sales'
	END AS [The Level of Sales]
FROM GroupOfProductBy3Levels

-- 35.a) Profit of Product Names
CREATE TABLE #ProfitOfProductName 
(
	[Product Name] nvarchar(max),
	[Profit Of Product Name] int
)

INSERT INTO #ProfitOfProductName 
	SELECT DISTINCT 
		[Product Name],
		SUM([Profit]) OVER (PARTITION BY [Product Name]) as [Profit of Product Name]
	FROM   [Project4].[dbo].[SuperStore]

-- 35.b) TOP 10 of Profit of  Product Name
SELECT TOP 10 with TIES *
FROM #ProfitOfProductName 
ORDER BY [Profit of Product Name] DESC

--35.c)  Profit of Product name with Profit greater than Average Profit
SELECT *
FROM #ProfitOfProductName 
WHERE [Profit of Product Name] > (SELECT AVG([Profit]) FROM [Project4].[dbo].[SuperStore])
ORDER BY [Profit of Product Name] DESC


-- 35.d) Cumulative distrubtion of Profit of Product 
SELECT *, 
		CAST(ROUND(CUME_DIST() OVER (ORDER BY [Profit of Product Name] DESC)*100,2) AS FLOAT) as [Cumulative distriubtion (%)]
FROM #ProfitOfProductName

-- 35.e) Products which do  generate Profit:
WITH ProductsWithoutProfit AS (
	SELECT *, 
			CAST(ROUND(CUME_DIST() OVER (ORDER BY [Profit of Product Name] DESC)*100,2) AS FLOAT) as [Cumulative distriubtion (%)]
	FROM #ProfitOfProductName
)
SELECT *
FROM ProductsWithoutProfit
WHERE [Cumulative distriubtion (%)] < 64.83
--35.f)  Products which do not  generate Profit:
WITH ProductsWithoutProfit AS (
	SELECT *, 
			CAST(ROUND(CUME_DIST() OVER (ORDER BY [Profit of Product Name] DESC)*100,2) AS FLOAT) as [Cumulative distriubtion (%)]
	FROM #ProfitOfProductName
)
SELECT *
FROM ProductsWithoutProfit
WHERE [Cumulative distriubtion (%)] > 64.83

-- 35.g) Top  25 % Product of Profit
WITH TOP25ProductOfProfit AS (
	SELECT [Product Name],
			CAST(ROUND(CUME_DIST() OVER (ORDER BY [Profit of Product Name] DESC)*100,2) AS FLOAT) as [Cumulative distriubtion (%)]
	FROM #ProfitOfProductName
)
SELECT [Product Name], [Cumulative distriubtion (%)]
FROM TOP25ProductOfProfit
WHERE  [Cumulative distriubtion (%)] <= 25

--35.h) The Percentage Rank of Profit of Product
SELECT *, 
		ROUND(PERCENT_RANK() OVER (ORDER BY [Profit Of Product Name])*100,6) as [Percentage Ranking (%)]
FROM #ProfitOfProductName
WHERE [Profit of Product Name] >= 1
--35.i)  The group of Product Name by High Profit, Mid Profit and Low Profit
WITH GroupOfProductBy3Levels AS (
	SELECT *, NTILE(3) OVER (ORDER BY [Profit Of Product Name] DESC) as Buckets
	FROM #ProfitOfProductName
)
SELECT [Product Name], 
	CASE
		WHEN [Buckets] = 1 THEN 'High Profit'
		WHEN [Buckets] = 2 THEN 'Mid Profit'
		WHEN [Buckets] = 3 THEN 'Low Profit'
	END AS [The Level of Profit]
FROM GroupOfProductBy3Levels

--35.j) The Quantity of Discount by Product Name
SELECT DISTINCT [Category],[Sub-Category],[Product Name], SUM([Discount]) OVER (PARTITION BY [Category],[Sub-Category],[Product Name]) as [Discount]
FROM   [Project4].[dbo].[SuperStore]
WHERE [Discount] >= 1
ORDER BY [Discount] DESC

-- 35.k) The Quantity of Discount by Sub-Category
SELECT DISTINCT [Category],[Sub-Category], SUM([Discount]) OVER (PARTITION BY [Category],[Sub-Category]) as [Discount]
FROM   [Project4].[dbo].[SuperStore]
WHERE [Discount] >= 1
ORDER BY [Discount] DESC

-- 35.l) Discount for each category
-- a scalar function was created for the calculation of the discount
DROP FUNCTION dbo.PercentageDiscout
CREATE FUNCTION dbo.PercentageDiscout (
	@n FLOAT,
	@m FLOAT
)
RETURNS FLOAT
AS
BEGIN
	DECLARE @Result FLOAT
	SELECT @Result = ROUND(CAST((@n / @m)*100 AS FLOAT),2)
RETURN @Result
END

-- Total Quantity of Discount
DECLARE @TotalQuantity FLOAT
SET @TotalQuantity = (SELECT SUM([Discount]) FROM   [Project4].[dbo].[SuperStore])
PRINT @TotalQuantity

-- Create Table variable to store data
DECLARE @DiscountForCategory TABLE (
	[Category] nvarchar(max),
	[The Percentage of Total Discount by Category] FLOAT
)


INSERT INTO @DiscountForCategory
	SELECT DISTINCT [Category] , SUM([Discount]) OVER (PARTITION BY [Category]) as [Total Discount by Category]
	FROM   [Project4].[dbo].[SuperStore]
	WHERE [Discount] >= 1
-- The percentage quantity of Discount for each category	
SELECT [Category], dbo.PercentageDiscout([The Percentage of Total Discount by Category], @TotalQuantity) as [The Percentage of Total Discount by Category (%)]
FROM @DiscountForCategory
ORDER BY [The Percentage of Total Discount by Category] DESC


-- 35. m) Total Discount by Category in all years
SELECT [Category],
	[2011], [2012], [2013], [2014]
FROM
(
SELECT DISTINCT [YearOfOrderDate], [Category] , SUM([Discount]) OVER (PARTITION BY [Category],[YearOfOrderDate]) as [Total Discount by Category]
FROM   [Project4].[dbo].[SuperStore]
) as SrC1
PIVOT
(
	SUM([Total Discount by Category])
	FOR [YearOfOrderDate] IN ([2011], [2012], [2013], [2014])

) as PvT1	




-- 36.a) Sales of Product Name in Category, Sub Category and Product Name
CREATE VIEW SalesOfProductName AS 
	SELECT DISTINCT [Category], [Sub-Category], [Product Name],
	SUM([Sales]) OVER (PARTITION BY [Category], [Sub-Category],[Product Name]) as [Sales]
	FROM [Project4].[dbo].[SuperStore]
-- 36.b) The Ranking of Sales of Product Name
SELECT [Category], 
	[Sub-Category],
	RANK() OVER (PARTITION BY [Sub-Category] ORDER BY [Sales] DESC) as [Ranking],
	[Product Name],
	[Sales]
FROM SalesOfProductName
--36.c) Product Name with the greatest and lowest Sales  
SELECT DISTINCT
	FIRST_VALUE([Category]) OVER (ORDER BY [Sales] DESC) as [Category],
	FIRST_VALUE([Sub-Category]) OVER (ORDER BY [Sales] DESC) as [Sub-Category] ,
	FIRST_VALUE([Product Name]) OVER (ORDER BY [Sales] DESC) [Product with the greatest Sales],
	MAX([Sales]) OVER () as [The Greatest Sales],
	LAST_VALUE([Category]) OVER (ORDER BY [Sales] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Category],
	LAST_VALUE([Sub-Category]) OVER (ORDER BY [Sales] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Sub-Category] ,
	LAST_VALUE([Product Name]) OVER (ORDER BY [Sales] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) [Product with the Lowest Sales],
	MIN([Sales]) OVER () as [The Lowest Sales]
FROM SalesOfProductName


--36.d) Product Name with the greatest and lowest Sales by Sub Category 
SELECT DISTINCT 
	[Sub-Category],
	FIRST_VALUE([Product Name]) OVER (PARTITION BY [Sub-Category] ORDER BY [Sales] DESC) as [The Product Name with the greatest Sales],
	MAX([Sales]) OVER (PARTITION BY [Sub-Category]) as [The greatest Sales of Product Name],
	LAST_VALUE([Product Name]) OVER (PARTITION BY [Sub-Category] ORDER BY [Sales] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The Product Name with the lowest Sales],
	MIN([Sales]) OVER (PARTITION BY [Sub-Category]) as [The lowest Sales of Product Name]
FROM SalesOfProductName


-- 37.a) Profit of Product Name in Category, Sub Category and Product Name
CREATE VIEW ProfitOfProductName AS 
	SELECT DISTINCT [Category], [Sub-Category], [Product Name],
	SUM([Profit]) OVER (PARTITION BY [Category], [Sub-Category],[Product Name]) as [Profit]
	FROM [Project4].[dbo].[SuperStore]
	WHERE [Profit] >= 1
-- 37.b) The Ranking of Profit of Product Name
SELECT [Category], 
	[Sub-Category],
	RANK() OVER (PARTITION BY [Sub-Category] ORDER BY [Profit] DESC) as [Ranking],
	[Product Name],
	[Profit]
FROM ProfitOfProductName

--37.c) Product Name with the greatest and lowest Profit  
SELECT DISTINCT
	FIRST_VALUE([Category]) OVER (ORDER BY [Profit] DESC) as [Category],
	FIRST_VALUE([Sub-Category]) OVER (ORDER BY [Profit] DESC) as [Sub-Category] ,
	FIRST_VALUE([Product Name]) OVER (ORDER BY [Profit] DESC) [Product with the greatest Profit],
	MAX([Profit]) OVER () as [The Greatest Profit],
	LAST_VALUE([Category]) OVER (ORDER BY [Profit] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Category],
	LAST_VALUE([Sub-Category]) OVER (ORDER BY [Profit] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Sub-Category] ,
	LAST_VALUE([Product Name]) OVER (ORDER BY [Profit] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) [Product with the Lowest Profit],
	MIN([Profit]) OVER () as [The Lowest Profit]
FROM ProfitOfProductName


-- 38.a) Product Name with the greatest and lowest Profit by Sub Category 
SELECT DISTINCT 
	[Sub-Category],
	FIRST_VALUE([Product Name]) OVER (PARTITION BY [Sub-Category] ORDER BY [Profit] DESC) as [The Product Name with the greatest Profit],
	MAX([Profit]) OVER (PARTITION BY [Sub-Category]) as [The greatest Profit of Product Name],
	LAST_VALUE([Product Name]) OVER (PARTITION BY [Sub-Category] ORDER BY [Profit] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The Product Name with the lowest Profit],
	MIN([Profit]) OVER (PARTITION BY [Sub-Category]) as [The lowest Profit of Product Name]
FROM ProfitOfProductName
ORDER BY [The Lowest Profit of Product Name] ASC



--39.a) The Quantity of Orders by Order Priority
CREATE FUNCTION QuantityOfOrdersOfCountryByOrderPriorirty
(
	@Year int
)
RETURNS TABLE
AS
RETURN
	SELECT DISTINCT [Country],[Order Priority], 
		count(*) OVER (PARTITION BY [Country],[Order Priority]) as [The Quantity of Orders]
	FROM   [Project4].[dbo].[SuperStore]
	WHERE [YearOfOrderDate] = @Year
	

-- The Quantity of Orders by Order Priority in all years
--2011
	SELECT	COALESCE([Country], 'Lack of Business') as [Country],
			COALESCE([Low],0) as [Low Order Priority 2011],
			COALESCE([Medium],0) as [Medium Order Priority 2011],
			COALESCE([High],0) as [High Order Priority 2011],
			COALESCE([Critical],0) as [Critical Order Priority 2011]
	FROM
	(
	SELECT DISTINCT [Country],[Order Priority], 
			count(*) OVER (PARTITION BY [Country],[Order Priority]) as [The Quantity of Orders]
	FROM   QuantityOfOrdersOfCountryByOrderPriorirty(2011)
	) as SrC1
	PIVOT 
	(
		SUM([The Quantity of Orders])
		FOR [Order Priority] IN ([Low], [Medium], [High], [Critical])
	) as PvT1
--2012
	SELECT	COALESCE([Country], 'Lack of Business') as [Country],
			COALESCE([Low],0) as [Low Order Priority 2012],
			COALESCE([Medium],0) as [Medium Order Priority 2012],
			COALESCE([High],0) as [High Order Priority 2012],
			COALESCE([Critical],0) as [Critical Order Priority 2012]
	FROM
	(
	SELECT DISTINCT [Country],[Order Priority], 
			count(*) OVER (PARTITION BY [Country],[Order Priority]) as [The Quantity of Orders]
	FROM   QuantityOfOrdersOfCountryByOrderPriorirty(2012)
	) as SrC1
	PIVOT 
	(
		SUM([The Quantity of Orders])
		FOR [Order Priority] IN ([Low], [Medium], [High], [Critical])
	) as PvT1
--2013
	SELECT	COALESCE([Country], 'Lack of Business') as [Country],
			COALESCE([Low],0) as [Low Order Priority 2013],
			COALESCE([Medium],0) as [Medium Order Priority 2013],
			COALESCE([High],0) as [High Order Priority 2013],
			COALESCE([Critical],0) as [Critical Order Priority 2013]
	FROM
	(
	SELECT DISTINCT [Country],[Order Priority], 
			count(*) OVER (PARTITION BY [Country],[Order Priority]) as [The Quantity of Orders]
	FROM   QuantityOfOrdersOfCountryByOrderPriorirty(2013)
	) as SrC1
	PIVOT 
	(
		SUM([The Quantity of Orders])
		FOR [Order Priority] IN ([Low], [Medium], [High], [Critical])
	) as PvT1
--2014
	SELECT	COALESCE([Country], 'Lack of Business') as [Country],
			COALESCE([Low],0) as [Low Order Priority 2014],
			COALESCE([Medium],0) as [Medium Order Priority 2014],
			COALESCE([High],0) as [High Order Priority 2014],
			COALESCE([Critical],0) as [Critical Order Priority 2014]
	FROM
	(
	SELECT DISTINCT [Country],[Order Priority], 
			count(*) OVER (PARTITION BY [Country],[Order Priority]) as [The Quantity of Orders]
	FROM   QuantityOfOrdersOfCountryByOrderPriorirty(2014)
	) as SrC1
	PIVOT 
	(
		SUM([The Quantity of Orders])
		FOR [Order Priority] IN ([Low], [Medium], [High], [Critical])
	) as PvT1


-- 40.a) The Order Priority by Sub Category in all years
DROP TABLE IF EXISTS #QuantityOfOrdersOfSubCategoryByOrderPriority
CREATE TABLE #QuantityOfOrdersOfSubCategoryByOrderPriority
(
	[Year] int,
	[Sub-Category] nvarchar(max),
	[Order Priority] nvarchar(max),
	[The Quantity of Orders] int

)

INSERT INTO #QuantityOfOrdersOfSubCategoryByOrderPriority
SELECT DISTINCT [YearOfOrderDate],
		[Sub-Category],
		[Order Priority], 
		count(*) OVER (PARTITION BY [YearOfOrderDate],[Sub-Category],[Order Priority]) as [The Quantity of Orders]
FROM   [Project4].[dbo].[SuperStore]

SELECT [Year],[Sub-Category],[Order Priority], [The Quantity of Orders]
FROM #QuantityOfOrdersOfSubCategoryByOrderPriority

SELECT 
	[Year],
	[Sub-Category],
	[Low] as [Low Order Priority],
	[Medium] as [Medium Order Priority],
	[High] as [High Order Priority],
	[Critical] as [Critical Order Priority]
FROM
(
SELECT [Year],[Sub-Category],[Order Priority],[The Quantity of Orders]
FROM #QuantityOfOrdersOfSubCategoryByOrderPriority
) as SrC1
PIVOT (
	SUM([The Quantity of Orders])
	FOR [Order Priority] IN ([Low], [Medium], [High], [Critical])
) AS PvT1


--41.a)  The Quantity of Orders by Order Priority and Customer Name in all years
SELECT 
	[YearOfOrderDate] as [Year],
	[Customer Name],
	COALESCE([Low],0) as [Low Order Priority],
	COALESCE([Medium],0) as [Medium Order Priority],
	COALESCE([High],0) as [High Order Priority],
	COALESCE([Critical],0) as [Critical Order Priority]
FROM
(
SELECT DISTINCT [YearOfOrderDate],[Customer Name],[Order Priority], 
		count(*) OVER (PARTITION BY [YearOfOrderDate],[Customer Name],[Order Priority]) as [The Quantity of Orders]
FROM   [Project4].[dbo].[SuperStore]
) as Src1
PIVOT
(
	SUM([The Quantity of Orders])
	FOR [Order Priority] IN ([Low],[Medium],[High],[Critical])
) as PvT1


-- 42.a) Sales of  year by year, month by month, quarters by quarters, day by day, 
-- Running total and Running difference by Sales (year over year, month over month, quarter over quarter and week of year over week of year)
CREATE FUNCTION RunningTotalSales (
	@Year int
)
RETURNS TABLE
AS
RETURN
SELECT [Sales], [OrderDate],[YearOfOrderDate], 
		Datename(Month,[OrderDate]) as [Month Name], 
		Month([OrderDate]) as Month, 
		DATEPART(qq,[OrderDate]) as [Quarter],
		DATENAME(weekday,[OrderDate]) as [Day Name],
		DATEPART(weekday,[OrderDate]) as [Weekday],
		DATEPART(wk, [OrderDate]) as [Week of the year]
FROM [Project4].[dbo].[SuperStore]
WHERE [YearOfOrderDate] = @Year

--42.b) Sales Months after Months in years
SELECT 
	[YearOfOrderDate] as [Year],
	[January], 
	[February], 
	[March],
	[April],
	[May],
	[June],
	[July],
	[August],
	[September],
	[October],
	[November],
	[December]
FROM
(
SELECT [YearOfOrderDate],
		[Month Name], 
		SUM(Sales) OVER (PARTITION BY [Month Name]) as [Sales by Month]
FROM RunningTotalSales(2011)
) as Src1
PIVOT
(
	SUM([Sales by Month])
	FOR [Month Name] IN ([January], [February], [March],[April],[May],[June],[July], [August], [September], [October],[November],[December])
) as PvT1
UNION
SELECT 
	[YearOfOrderDate] as [Year],
	[January], 
	[February], 
	[March],
	[April],
	[May],
	[June],
	[July],
	[August],
	[September],
	[October],
	[November],
	[December]
FROM
(
SELECT [YearOfOrderDate],
		[Month Name], 
		SUM(Sales) OVER (PARTITION BY [Month Name]) as [Sales by Month]
FROM RunningTotalSales(2012)
) as Src1
PIVOT
(
	SUM([Sales by Month])
	FOR [Month Name] IN ([January], [February], [March],[April],[May],[June],[July], [August], [September], [October],[November],[December])
) as PvT1
UNION
SELECT 
	[YearOfOrderDate] as [Year],
	[January], 
	[February], 
	[March],
	[April],
	[May],
	[June],
	[July],
	[August],
	[September],
	[October],
	[November],
	[December]
FROM
(
SELECT [YearOfOrderDate],
		[Month Name], 
		SUM(Sales) OVER (PARTITION BY [Month Name]) as [Sales by Month]
FROM RunningTotalSales(2013)
) as Src1
PIVOT
(
	SUM([Sales by Month])
	FOR [Month Name] IN ([January], [February], [March],[April],[May],[June],[July], [August], [September], [October],[November],[December])
) as PvT1
UNION
SELECT 
	[YearOfOrderDate] as [Year],
	[January], 
	[February], 
	[March],
	[April],
	[May],
	[June],
	[July],
	[August],
	[September],
	[October],
	[November],
	[December]
FROM
(
SELECT [YearOfOrderDate],
		[Month Name], 
		SUM(Sales) OVER (PARTITION BY [Month Name]) as [Sales by Month]
FROM RunningTotalSales(2014)
) as Src1
PIVOT
(
	SUM([Sales by Month])
	FOR [Month Name] IN ([January], [February], [March],[April],[May],[June],[July], [August], [September], [October],[November],[December])
) as PvT1



--42.c)  Sales Quarter after Quarter in years
SELECT 
	[YearOfOrderDate] as [Year],
	[1] as [Q1],
	[2] as [Q2],
	[3] as [Q3],
	[4] as [Q4]
FROM
(
SELECT DISTINCT [YearOfOrderDate],[Quarter], SUM([Sales]) OVER (PARTITION BY [Quarter]) as [Quarter Sales]
FROM RunningTotalSales(2011)
) as Src1
PIVOT
(
	SUM([Quarter Sales])
	FOR [Quarter] IN ([1], [2], [3],[4])
) as PvT1
UNION
SELECT 
	[YearOfOrderDate] as [Year],
	[1] as [Q1],
	[2] as [Q2],
	[3] as [Q3],
	[4] as [Q4]
FROM
(
SELECT DISTINCT [YearOfOrderDate],[Quarter], SUM([Sales]) OVER (PARTITION BY [Quarter]) as [Quarter Sales]
FROM RunningTotalSales(2012)
) as Src1
PIVOT
(
	SUM([Quarter Sales])
	FOR [Quarter] IN ([1], [2], [3],[4])
) as PvT1
UNION
SELECT 
	[YearOfOrderDate] as [Year],
	[1] as [Q1],
	[2] as [Q2],
	[3] as [Q3],
	[4] as [Q4]
FROM
(
SELECT DISTINCT [YearOfOrderDate],[Quarter], SUM([Sales]) OVER (PARTITION BY [Quarter]) as [Quarter Sales]
FROM RunningTotalSales(2013)
) as Src1
PIVOT
(
	SUM([Quarter Sales])
	FOR [Quarter] IN ([1], [2], [3],[4])
) as PvT1
UNION
SELECT 
	[YearOfOrderDate] as [Year],
	[1] as [Q1],
	[2] as [Q2],
	[3] as [Q3],
	[4] as [Q4]
FROM
(
SELECT DISTINCT [YearOfOrderDate],[Quarter], SUM([Sales]) OVER (PARTITION BY [Quarter]) as [Quarter Sales]
FROM RunningTotalSales(2014)
) as Src1
PIVOT
(
	SUM([Quarter Sales])
	FOR [Quarter] IN ([1], [2], [3],[4])
) as PvT1


-- 42.d) Sales year after year
SELECT DISTINCT [YearOfOrderDate] as [Year], SUM([Sales]) OVER (PARTITION BY [YearOfOrderDate]) as [Sales]
FROM RunningTotalSales(2011)
UNION
SELECT DISTINCT [YearOfOrderDate] as [Year], SUM([Sales]) OVER (PARTITION BY [YearOfOrderDate]) as [Sales]
FROM RunningTotalSales(2012)
UNION
SELECT DISTINCT [YearOfOrderDate] as [Year], SUM([Sales]) OVER (PARTITION BY [YearOfOrderDate]) as [Sales]
FROM RunningTotalSales(2013)
UNION
SELECT DISTINCT [YearOfOrderDate] as [Year], SUM([Sales]) OVER (PARTITION BY [YearOfOrderDate]) as [Sales]
FROM RunningTotalSales(2014)

--42.e)  Sales on week year after year
SELECT
	[YearOfOrderDate] as [Year],
	[Monday],
	[Tuesday],
	[Wednesday],
	[Thursday],
	[Friday],
	[Saturday],
	[Sunday]
FROM
(
SELECT DISTINCT 
		[YearOfOrderDate],
		[Day Name],
		SUM([Sales]) OVER (PARTITION BY [Day Name]) as [Sales of Day]
FROM RunningTotalSales(2011)
) SrC1
PIVOT
(
	SUM([Sales of Day])
	FOR [Day Name] IN ([Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday], [Sunday])
) as PvT1
UNION
SELECT
	[YearOfOrderDate] as [Year],
	[Monday],
	[Tuesday],
	[Wednesday],
	[Thursday],
	[Friday],
	[Saturday],
	[Sunday]
FROM
(
SELECT DISTINCT 
		[YearOfOrderDate],
		[Day Name],
		SUM([Sales]) OVER (PARTITION BY [Day Name]) as [Sales of Day]
FROM RunningTotalSales(2012)
) SrC1
PIVOT
(
	SUM([Sales of Day])
	FOR [Day Name] IN ([Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday], [Sunday])
) as PvT1
UNION
SELECT
	[YearOfOrderDate] as [Year],
	[Monday],
	[Tuesday],
	[Wednesday],
	[Thursday],
	[Friday],
	[Saturday],
	[Sunday]
FROM
(
SELECT DISTINCT 
		[YearOfOrderDate],
		[Day Name],
		SUM([Sales]) OVER (PARTITION BY [Day Name]) as [Sales of Day]
FROM RunningTotalSales(2013)
) SrC1
PIVOT
(
	SUM([Sales of Day])
	FOR [Day Name] IN ([Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday], [Sunday])
) as PvT1
UNION
SELECT
	[YearOfOrderDate] as [Year],
	[Monday],
	[Tuesday],
	[Wednesday],
	[Thursday],
	[Friday],
	[Saturday],
	[Sunday]
FROM
(
SELECT DISTINCT 
		[YearOfOrderDate],
		[Day Name],
		SUM([Sales]) OVER (PARTITION BY [Day Name]) as [Sales of Day]
FROM RunningTotalSales(2014)
) SrC1
PIVOT
(
	SUM([Sales of Day])
	FOR [Day Name] IN ([Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday], [Sunday])
) as PvT1

---42.f)  Running Total, Running Difference and the percentage growth year over year of Sales by year, month, Quarter, week of year
CREATE FUNCTION RunningTotalSales20112014 (
	@StartYear int,
	@EndYear int
)
RETURNS TABLE
AS
RETURN
SELECT [Sales], [OrderDate],[YearOfOrderDate], 
		Datename(Month,[OrderDate]) as [Month Name], 
		Month([OrderDate]) as Month, 
		DATEPART(qq,[OrderDate]) as [Quarter],
		DATENAME(weekday,[OrderDate]) as [Day Name],
		DATEPART(weekday,[OrderDate]) as [Weekday],
		DATEPART(wk, [OrderDate]) as [Week of the year]
FROM [Project4].[dbo].[SuperStore]
WHERE [YearOfOrderDate] BETWEEN @StartYear and @EndYear

--42.g)  Running Total by Years
WITH RunningTotalYear AS (
	SELECT DISTINCT
		[YearOfOrderDate] as [Year],
		SUM([Sales]) OVER (PARTITION BY [YearOfOrderDate]) as [Sales by Year]
	FROM RunningTotalSales20112014(2011,2014)
)
SELECT	[Year],
		SUM([Sales by Year]) OVER (ORDER BY [Year] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as [Running Total]
FROM RunningTotalYear

--42.h) Running Difference by years
CREATE VIEW RunningDifferenceByYears AS 
	SELECT DISTINCT
			[YearOfOrderDate] as [Year],
			SUM([Sales]) OVER (PARTITION BY [YearOfOrderDate]) as [Sales by Year]
	FROM RunningTotalSales20112014(2011,2014)
--42.i)  Running Difference and the percentage growth year over year 
SELECT *,
	COALESCE(LAG([Sales by Year]) OVER (ORDER BY [Year]),0) as [Sales by Previous Year],
	COALESCE([Sales By Year] - LAG([Sales by Year]) OVER (ORDER BY [Year]),0)  as [Running Difference],
	COALESCE(ROUND(([Sales By Year] - LAG([Sales by Year]) OVER (ORDER BY [Year]))/(LAG([Sales by Year]) OVER (ORDER BY [Year]))*100,2),0) as [The percentage growth year over year (%)]
FROM RunningDifferenceByYears


-- 42. j) Running Total by Months in 2011

WITH RunningTotalByMonth AS (
	SELECT DISTINCT [YearOfOrderDate] as [Year],
	[Month Name],
	[Month], 
		SUM([Sales]) OVER (PARTITION BY [YearOfOrderDate], [Month Name]) as [Sales of Month]
	FROM RunningTotalSales20112014(2011,2011)
)
SELECT [Year],[Month Name],
	SUM([Sales of Month]) OVER (ORDER BY [Month] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as [Running Total]
FROM RunningTotalByMonth
ORDER BY [Month] ASC
--42.k) Running Difference by Months 
CREATE VIEW RunningDifferenceByMonths2011 AS
	SELECT DISTINCT 
	[YearOfOrderDate] as [Year],
	[Month Name],
	[Month], 
	SUM([Sales]) OVER (PARTITION BY [YearOfOrderDate], [Month Name]) as [Sales of Month]
	FROM RunningTotalSales20112014(2011,2011)
--42.l)  Running Difference and the percentage growth month over month 
SELECT *,
	COALESCE(LAG([Sales of Month]) OVER (ORDER BY [Month]),0) as [Sales by previous Month],
	COALESCE(([Sales of Month] - LAG([Sales of Month]) OVER (ORDER BY [Month])),0) as [Running Difference],
	ROUND(COALESCE(([Sales of Month] - LAG([Sales of Month]) OVER (ORDER BY [Month]))/LAG([Sales of Month]) OVER (ORDER BY [Month])*100,0),2) as [The percentage growth month over month (%)]
FROM RunningDifferenceByMonths2011
ORDER BY [Month]

-- 42.m) Running Total by Months in 2012
WITH RunningTotalByMonth AS (
	SELECT DISTINCT [YearOfOrderDate] as [Year],
	[Month Name],
	[Month], 
		SUM([Sales]) OVER (PARTITION BY [YearOfOrderDate], [Month Name]) as [Sales of Month]
	FROM RunningTotalSales20112014(2012,2012)
)
SELECT [Year],[Month Name],
	SUM([Sales of Month]) OVER (ORDER BY [Month] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as [Running Total]
FROM RunningTotalByMonth
ORDER BY [Month] ASC
--42.n) Running Difference by Months 
CREATE VIEW RunningDifferenceByMonths2012 AS
	SELECT DISTINCT 
	[YearOfOrderDate] as [Year],
	[Month Name],
	[Month], 
	SUM([Sales]) OVER (PARTITION BY [YearOfOrderDate], [Month Name]) as [Sales of Month]
	FROM RunningTotalSales20112014(2012,2012)
--42.o)  Running Difference and the percentage growth month over month 
SELECT *,
	COALESCE(LAG([Sales of Month]) OVER (ORDER BY [Month]),0) as [Sales by previous Month],
	COALESCE(([Sales of Month] - LAG([Sales of Month]) OVER (ORDER BY [Month])),0) as [Running Difference],
	ROUND(COALESCE(([Sales of Month] - LAG([Sales of Month]) OVER (ORDER BY [Month]))/LAG([Sales of Month]) OVER (ORDER BY [Month])*100,0),2) as [The percentage growth month over month (%)]
FROM RunningDifferenceByMonths2012
ORDER BY [Month]


--42.p) Running Total by Months 2013
WITH RunningTotalByMonth AS (
	SELECT DISTINCT [YearOfOrderDate] as [Year],
	[Month Name],
	[Month], 
		SUM([Sales]) OVER (PARTITION BY [YearOfOrderDate], [Month Name]) as [Sales of Month]
	FROM RunningTotalSales20112014(2013,2013)
)
SELECT [Year],[Month Name],
	SUM([Sales of Month]) OVER (ORDER BY [Month] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as [Running Total]
FROM RunningTotalByMonth
ORDER BY [Month] ASC
--42.q) Running Difference by Months 
CREATE VIEW RunningDifferenceByMonths2013 AS
	SELECT DISTINCT 
	[YearOfOrderDate] as [Year],
	[Month Name],
	[Month], 
	SUM([Sales]) OVER (PARTITION BY [YearOfOrderDate], [Month Name]) as [Sales of Month]
	FROM RunningTotalSales20112014(2013,2013)
-- 42.r) Running Difference and the percentage growth month over month 
SELECT *,
	COALESCE(LAG([Sales of Month]) OVER (ORDER BY [Month]),0) as [Sales by previous Month],
	COALESCE(([Sales of Month] - LAG([Sales of Month]) OVER (ORDER BY [Month])),0) as [Running Difference],
	ROUND(COALESCE(([Sales of Month] - LAG([Sales of Month]) OVER (ORDER BY [Month]))/LAG([Sales of Month]) OVER (ORDER BY [Month])*100,0),2) as [The percentage growth month over month (%)]
FROM RunningDifferenceByMonths2013
ORDER BY [Month]
---- 42.s) Running Total by Months 2014
WITH RunningTotalByMonth AS (
	SELECT DISTINCT [YearOfOrderDate] as [Year],
	[Month Name],
	[Month], 
		SUM([Sales]) OVER (PARTITION BY [YearOfOrderDate], [Month Name]) as [Sales of Month]
	FROM RunningTotalSales20112014(2014,2014)
)
SELECT [Year],[Month Name],
	SUM([Sales of Month]) OVER (ORDER BY [Month] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as [Running Total]
FROM RunningTotalByMonth
ORDER BY [Month] ASC
--42.t) Running Difference by Months 
CREATE VIEW RunningDifferenceByMonths2014 AS
	SELECT DISTINCT 
	[YearOfOrderDate] as [Year],
	[Month Name],
	[Month], 
	SUM([Sales]) OVER (PARTITION BY [YearOfOrderDate], [Month Name]) as [Sales of Month]
	FROM RunningTotalSales20112014(2014,2014)
--42.u)  Running Difference and the percentage growth month over month 
SELECT *,
	COALESCE(LAG([Sales of Month]) OVER (ORDER BY [Month]),0) as [Sales by previous Month],
	COALESCE(([Sales of Month] - LAG([Sales of Month]) OVER (ORDER BY [Month])),0) as [Running Difference],
	ROUND(COALESCE(([Sales of Month] - LAG([Sales of Month]) OVER (ORDER BY [Month]))/LAG([Sales of Month]) OVER (ORDER BY [Month])*100,0),2) as [The percentage growth month over month (%)]
FROM RunningDifferenceByMonths2014
ORDER BY [Month]


--42.v) Running Total by Quarters 2011
WITH RunningTotalQuarters2011 AS  (
	SELECT DISTINCT 
			[YearOfOrderDate] as [Year],
			[Quarter],
			SUM([Sales]) OVER (PARTITION BY [Quarter]) as [Sales of Quarter]
	FROM RunningTotalSales20112014(2011,2011)
) 
SELECT [Year], [Quarter] ,SUM([Sales of Quarter]) OVER (ORDER BY [Quarter] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as [Running Total]
FROM RunningTotalQuarters2011
--42.w)  Running Difference by Quarters 2011
CREATE VIEW RunningDifferenceQuarters2011 AS 
	SELECT DISTINCT 
		[YearOfOrderDate] as [Year],
		[Quarter],
		SUM([Sales]) OVER (PARTITION BY [Quarter]) as [Sales of Quarter]
	FROM RunningTotalSales20112014(2011,2011)
--42.y) Running Difference and the percentage growth quarter over quarter 
SELECT *,
	COALESCE(LAG([Sales of Quarter]) OVER (ORDER BY [Quarter]),0) as [Sales by previous Quarter],
	COALESCE(([Sales of Quarter] - LAG([Sales of Quarter]) OVER (ORDER BY [Quarter])),0) as [Running Difference],
	ROUND(COALESCE(([Sales of Quarter] - LAG([Sales of Quarter]) OVER (ORDER BY [Quarter]))/LAG([Sales of Quarter]) OVER (ORDER BY [Quarter])*100,0),2) as [The percentage growth quarter over quarter (%)]
FROM RunningDifferenceQuarters2011


--42.z) Running Total by Quarters 2012
WITH RunningTotalQuarters2012 AS  (
	SELECT DISTINCT 
			[YearOfOrderDate] as [Year],
			[Quarter],
			SUM([Sales]) OVER (PARTITION BY [Quarter]) as [Sales of Quarter]
	FROM RunningTotalSales20112014(2012,2012)
)
SELECT [Year], [Quarter] ,SUM([Sales of Quarter]) OVER (ORDER BY [Quarter] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as [Running Total]
FROM RunningTotalQuarters2012
-- 42.aa) Running Difference by Quarters 2012
CREATE VIEW RunningDifferenceQuarters2012 AS 
	SELECT DISTINCT 
		[YearOfOrderDate] as [Year],
		[Quarter],
		SUM([Sales]) OVER (PARTITION BY [Quarter]) as [Sales of Quarter]
	FROM RunningTotalSales20112014(2012,2012)
--42.ab)  Running Difference and the percentage growth  quarter over quarter  
SELECT *,
	COALESCE(LAG([Sales of Quarter]) OVER (ORDER BY [Quarter]),0) as [Sales by previous Quarter],
	COALESCE(([Sales of Quarter] - LAG([Sales of Quarter]) OVER (ORDER BY [Quarter])),0) as [Running Difference],
	ROUND(COALESCE(([Sales of Quarter] - LAG([Sales of Quarter]) OVER (ORDER BY [Quarter]))/LAG([Sales of Quarter]) OVER (ORDER BY [Quarter])*100,0),2) as [The percentage growth quarter over quarter (%)]
FROM RunningDifferenceQuarters2012

--42.ac) Running Total by Quarters 2013
WITH RunningTotalQuarters2013 AS  (
	SELECT DISTINCT 
			[YearOfOrderDate] as [Year],
			[Quarter],
			SUM([Sales]) OVER (PARTITION BY [Quarter]) as [Sales of Quarter]
	FROM RunningTotalSales20112014(2013,2013)
)
SELECT [Year], [Quarter] ,SUM([Sales of Quarter]) OVER (ORDER BY [Quarter] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as [Running Total]
FROM RunningTotalQuarters2013
--42.ad) Running Difference by Quarters 2013
CREATE VIEW RunningDifferenceQuarters2013 AS 
	SELECT DISTINCT 
		[YearOfOrderDate] as [Year],
		[Quarter],
		SUM([Sales]) OVER (PARTITION BY [Quarter]) as [Sales of Quarter]
	FROM RunningTotalSales20112014(2013,2013)
---42.ae) Running Difference and the percentage growth  quarter over quarter 
SELECT *,
	COALESCE(LAG([Sales of Quarter]) OVER (ORDER BY [Quarter]),0) as [Sales by previous Quarter],
	COALESCE(([Sales of Quarter] - LAG([Sales of Quarter]) OVER (ORDER BY [Quarter])),0) as [Running Difference],
	ROUND(COALESCE(([Sales of Quarter] - LAG([Sales of Quarter]) OVER (ORDER BY [Quarter]))/LAG([Sales of Quarter]) OVER (ORDER BY [Quarter])*100,0),2) as [The percentage growth quarter over quarter (%)]
FROM RunningDifferenceQuarters2013


--42.af) Running Total by Quarters 2014
WITH RunningTotalQuarters2014 AS  (
	SELECT DISTINCT 
			[YearOfOrderDate] as [Year],
			[Quarter],
			SUM([Sales]) OVER (PARTITION BY [Quarter]) as [Sales of Quarter]
	FROM RunningTotalSales20112014(2014,2014)
)
SELECT [Year], [Quarter] ,SUM([Sales of Quarter]) OVER (ORDER BY [Quarter] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as [Running Total]
FROM RunningTotalQuarters2014
--42.ag) Running Difference by Quarters 2014
CREATE VIEW RunningDifferenceQuarters2014 AS 
	SELECT DISTINCT 
		[YearOfOrderDate] as [Year],
		[Quarter],
		SUM([Sales]) OVER (PARTITION BY [Quarter]) as [Sales of Quarter]
	FROM RunningTotalSales20112014(2014,2014)
---42.ah) Running Difference and the percentage growth  quarter over quarter 
SELECT *,
	COALESCE(LAG([Sales of Quarter]) OVER (ORDER BY [Quarter]),0) as [Sales by previous Quarter],
	COALESCE(([Sales of Quarter] - LAG([Sales of Quarter]) OVER (ORDER BY [Quarter])),0) as [Running Difference],
	ROUND(COALESCE(([Sales of Quarter] - LAG([Sales of Quarter]) OVER (ORDER BY [Quarter]))/LAG([Sales of Quarter]) OVER (ORDER BY [Quarter])*100,0),2) as [The percentage growth quarter over quarter (%)]
FROM RunningDifferenceQuarters2014


--42.ai) Running Total by Week of year 2011
WITH RunningTotalWeekOfYear2011 AS (
	SELECT DISTINCT  [YearOfOrderDate],[Week of the year],
		SUM([Sales]) OVER (PARTITION BY [Week of the year]) as [Sales of Week of the Year]
	FROM RunningTotalSales20112014(2011,2011)
)
SELECT [YearOfOrderDate] as [Year],
		[Week of the year],
		SUM([Sales of week of the Year]) OVER (ORDER BY [Week of the year] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS [Running Total]
FROM RunningTotalWeekOfYear2011
--42.aj) Running Difference by Week of year 2011
CREATE VIEW RunningDifferenceWeekOfYear2011 AS
		SELECT DISTINCT  [YearOfOrderDate],[Week of the year],
		SUM([Sales]) OVER (PARTITION BY [Week of the year]) as [Sales of Week of the Year]
		FROM RunningTotalSales20112014(2011,2011)

---42.ak) Running Difference and the percentage growth Week of year  2011
SELECT *,
	COALESCE(LAG([Sales of week of the Year]) OVER (ORDER BY [Week of the year]),0) as [Sales by previous week of year],
	COALESCE(([Sales of week of the Year] - LAG([Sales of week of the Year]) OVER (ORDER BY [Week of the year])),0) as [Running Difference],
	ROUND(COALESCE(([Sales of week of the Year] - LAG([Sales of week of the Year]) OVER (ORDER BY [Week of the year]))/LAG([Sales of week of the Year]) OVER (ORDER BY [Week of the year])*100,0),2) as [The percentage growth week of year over week of year (%)]
FROM RunningDifferenceWeekOfYear2011


--42.al)Running Total by Week of year 2012
WITH RunningTotalWeekOfYear2012 AS (
	SELECT DISTINCT  [YearOfOrderDate],[Week of the year],
		SUM([Sales]) OVER (PARTITION BY [Week of the year]) as [Sales of Week of the Year]
	FROM RunningTotalSales20112014(2012,2012)
)
SELECT [YearOfOrderDate] as [Year],
		[Week of the year],
		SUM([Sales of week of the Year]) OVER (ORDER BY [Week of the year] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS [Running Total]
FROM RunningTotalWeekOfYear2012
-- 42.am) Running Difference by Week of year 2012
CREATE VIEW RunningDifferenceWeekOfYear2012 AS
		SELECT DISTINCT  [YearOfOrderDate],[Week of the year],
		SUM([Sales]) OVER (PARTITION BY [Week of the year]) as [Sales of Week of the Year]
		FROM RunningTotalSales20112014(2012,2012)

--42.an)  Running Difference and the percentage growth Week of year  2012
SELECT *,
	COALESCE(LAG([Sales of week of the Year]) OVER (ORDER BY [Week of the year]),0) as [Sales by previous week of year],
	COALESCE(([Sales of week of the Year] - LAG([Sales of week of the Year]) OVER (ORDER BY [Week of the year])),0) as [Running Difference],
	ROUND(COALESCE(([Sales of week of the Year] - LAG([Sales of week of the Year]) OVER (ORDER BY [Week of the year]))/LAG([Sales of week of the Year]) OVER (ORDER BY [Week of the year])*100,0),2) as [The percentage growth week of year over week of year (%)]
FROM RunningDifferenceWeekOfYear2012



--42.ao) Running Total by Week of year 2013
WITH RunningTotalWeekOfYear2013 AS (
	SELECT DISTINCT  [YearOfOrderDate],[Week of the year],
		SUM([Sales]) OVER (PARTITION BY [Week of the year]) as [Sales of Week of the Year]
	FROM RunningTotalSales20112014(2013,2013)
)
SELECT [YearOfOrderDate] as [Year],
		[Week of the year],
		SUM([Sales of week of the Year]) OVER (ORDER BY [Week of the year] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS [Running Total]
FROM RunningTotalWeekOfYear2013
--42.ap) Running Difference by Week of year 2013
CREATE VIEW RunningDifferenceWeekOfYear2013 AS
		SELECT DISTINCT  [YearOfOrderDate],[Week of the year],
		SUM([Sales]) OVER (PARTITION BY [Week of the year]) as [Sales of Week of the Year]
		FROM RunningTotalSales20112014(2013,2013)

--- 42.aq) Running Difference and the percentage growth Week of year  2012
SELECT *,
	COALESCE(LAG([Sales of week of the Year]) OVER (ORDER BY [Week of the year]),0) as [Sales by previous week of year],
	COALESCE(([Sales of week of the Year] - LAG([Sales of week of the Year]) OVER (ORDER BY [Week of the year])),0) as [Running Difference],
	ROUND(COALESCE(([Sales of week of the Year] - LAG([Sales of week of the Year]) OVER (ORDER BY [Week of the year]))/LAG([Sales of week of the Year]) OVER (ORDER BY [Week of the year])*100,0),2) as [The percentage growth week of year over week of year (%)]
FROM RunningDifferenceWeekOfYear2013


--42.ar) Running Total by Week of year 2014
WITH RunningTotalWeekOfYear2014 AS (
	SELECT DISTINCT  [YearOfOrderDate],[Week of the year],
		SUM([Sales]) OVER (PARTITION BY [Week of the year]) as [Sales of Week of the Year]
	FROM RunningTotalSales20112014(2014,2014)
)
SELECT [YearOfOrderDate] as [Year],
		[Week of the year],
		SUM([Sales of week of the Year]) OVER (ORDER BY [Week of the year] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS [Running Total]
FROM RunningTotalWeekOfYear2014
-- 42.as) Running Difference by Week of year 2014
CREATE VIEW RunningDifferenceWeekOfYear2014 AS
		SELECT DISTINCT  [YearOfOrderDate],[Week of the year],
		SUM([Sales]) OVER (PARTITION BY [Week of the year]) as [Sales of Week of the Year]
		FROM RunningTotalSales20112014(2014,2014)

---42.at)  Running Difference and the percentage growth Week of year  2014
SELECT *,
	COALESCE(LAG([Sales of week of the Year]) OVER (ORDER BY [Week of the year]),0) as [Sales by previous week of year],
	COALESCE(([Sales of week of the Year] - LAG([Sales of week of the Year]) OVER (ORDER BY [Week of the year])),0) as [Running Difference],
	ROUND(COALESCE(([Sales of week of the Year] - LAG([Sales of week of the Year]) OVER (ORDER BY [Week of the year]))/LAG([Sales of week of the Year]) OVER (ORDER BY [Week of the year])*100,0),2) as [The percentage growth week of year over week of year (%)]
FROM RunningDifferenceWeekOfYear2014


-- 43.a) Profit of  year by year, month by month, quarters by quarters, day by day, 
-- Running total and Running difference by Profit (year over year, month over month, quarter over quarter and week of year over week of year)
DROP FUNCTION RunningTotalProfit
CREATE FUNCTION RunningTotalProfit (
	@Year int
)
RETURNS TABLE
AS
RETURN
SELECT [Profit], [OrderDate],[YearOfOrderDate], 
		Datename(Month,[OrderDate]) as [Month Name], 
		Month([OrderDate]) as Month, 
		DATEPART(qq,[OrderDate]) as [Quarter],
		DATENAME(weekday,[OrderDate]) as [Day Name],
		DATEPART(weekday,[OrderDate]) as [Weekday],
		DATEPART(wk, [OrderDate]) as [Week of the year]
FROM [Project4].[dbo].[SuperStore]
WHERE [YearOfOrderDate] = @Year

SELECT *
FROM RunningTotalProfit(2011)

--43.b) Profit Months after Months in years
SELECT 
	[YearOfOrderDate] as [Year],
	[January], 
	[February], 
	[March],
	[April],
	[May],
	[June],
	[July],
	[August],
	[September],
	[October],
	[November],
	[December]
FROM
(
SELECT [YearOfOrderDate],
		[Month Name], 
		SUM(Profit) OVER (PARTITION BY [Month Name]) as [Profit by Month]
FROM RunningTotalProfit(2011)
) as Src1
PIVOT
(
	SUM([Profit by Month])
	FOR [Month Name] IN ([January], [February], [March],[April],[May],[June],[July], [August], [September], [October],[November],[December])
) as PvT1
UNION
SELECT 
	[YearOfOrderDate] as [Year],
	[January], 
	[February], 
	[March],
	[April],
	[May],
	[June],
	[July],
	[August],
	[September],
	[October],
	[November],
	[December]
FROM
(
SELECT [YearOfOrderDate],
		[Month Name], 
		SUM(Profit) OVER (PARTITION BY [Month Name]) as [Profit by Month]
FROM RunningTotalProfit(2012)
) as Src1
PIVOT
(
	SUM([Profit by Month])
	FOR [Month Name] IN ([January], [February], [March],[April],[May],[June],[July], [August], [September], [October],[November],[December])
) as PvT1
UNION
SELECT 
	[YearOfOrderDate] as [Year],
	[January], 
	[February], 
	[March],
	[April],
	[May],
	[June],
	[July],
	[August],
	[September],
	[October],
	[November],
	[December]
FROM
(
SELECT [YearOfOrderDate],
		[Month Name], 
		SUM(Profit) OVER (PARTITION BY [Month Name]) as [Profit by Month]
FROM RunningTotalProfit(2013)
) as Src1
PIVOT
(
	SUM([Profit by Month])
	FOR [Month Name] IN ([January], [February], [March],[April],[May],[June],[July], [August], [September], [October],[November],[December])
) as PvT1
UNION
SELECT 
	[YearOfOrderDate] as [Year],
	[January], 
	[February], 
	[March],
	[April],
	[May],
	[June],
	[July],
	[August],
	[September],
	[October],
	[November],
	[December]
FROM
(
SELECT [YearOfOrderDate],
		[Month Name], 
		SUM(Profit) OVER (PARTITION BY [Month Name]) as [Profit by Month]
FROM RunningTotalProfit(2014)
) as Src1
PIVOT
(
	SUM([Profit by Month])
	FOR [Month Name] IN ([January], [February], [March],[April],[May],[June],[July], [August], [September], [October],[November],[December])
) as PvT1



-- 43.c) Profit Quarter after Quarter in years
SELECT 
	[YearOfOrderDate] as [Year],
	[1] as [Q1],
	[2] as [Q2],
	[3] as [Q3],
	[4] as [Q4]
FROM
(
SELECT DISTINCT [YearOfOrderDate],[Quarter], SUM([Profit]) OVER (PARTITION BY [Quarter]) as [Quarter Profit]
FROM RunningTotalProfit(2011)
) as Src1
PIVOT
(
	SUM([Quarter Profit])
	FOR [Quarter] IN ([1], [2], [3],[4])
) as PvT1
UNION
SELECT 
	[YearOfOrderDate] as [Year],
	[1] as [Q1],
	[2] as [Q2],
	[3] as [Q3],
	[4] as [Q4]
FROM
(
SELECT DISTINCT [YearOfOrderDate],[Quarter], SUM([Profit]) OVER (PARTITION BY [Quarter]) as [Quarter Profit]
FROM RunningTotalProfit(2012)
) as Src1
PIVOT
(
	SUM([Quarter Profit])
	FOR [Quarter] IN ([1], [2], [3],[4])
) as PvT1
UNION
SELECT 
	[YearOfOrderDate] as [Year],
	[1] as [Q1],
	[2] as [Q2],
	[3] as [Q3],
	[4] as [Q4]
FROM
(
SELECT DISTINCT [YearOfOrderDate],[Quarter], SUM([Profit]) OVER (PARTITION BY [Quarter]) as [Quarter Profit]
FROM RunningTotalProfit(2013)
) as Src1
PIVOT
(
	SUM([Quarter Profit])
	FOR [Quarter] IN ([1], [2], [3],[4])
) as PvT1
UNION
SELECT 
	[YearOfOrderDate] as [Year],
	[1] as [Q1],
	[2] as [Q2],
	[3] as [Q3],
	[4] as [Q4]
FROM
(
SELECT DISTINCT [YearOfOrderDate],[Quarter], SUM([Profit]) OVER (PARTITION BY [Quarter]) as [Quarter Profit]
FROM RunningTotalProfit(2014)
) as Src1
PIVOT
(
	SUM([Quarter Profit])
	FOR [Quarter] IN ([1], [2], [3],[4])
) as PvT1


-- 43.d) Profit year after year
SELECT DISTINCT [YearOfOrderDate] as [Year], SUM([Profit]) OVER (PARTITION BY [YearOfOrderDate]) as Profit
FROM RunningTotalProfit(2011)
UNION
SELECT DISTINCT [YearOfOrderDate] as [Year], SUM([Profit]) OVER (PARTITION BY [YearOfOrderDate]) as [Profit]
FROM RunningTotalProfit(2012)
UNION
SELECT DISTINCT [YearOfOrderDate] as [Year], SUM([Profit]) OVER (PARTITION BY [YearOfOrderDate]) as [Profit]
FROM RunningTotalProfit(2013)
UNION
SELECT DISTINCT [YearOfOrderDate] as [Year], SUM([Profit]) OVER (PARTITION BY [YearOfOrderDate]) as [Profit]
FROM RunningTotalProfit(2014)

--43.e)  Profit on week year after year
SELECT
	[YearOfOrderDate] as [Year],
	[Monday],
	[Tuesday],
	[Wednesday],
	[Thursday],
	[Friday],
	[Saturday],
	[Sunday]
FROM
(
SELECT DISTINCT 
		[YearOfOrderDate],
		[Day Name],
		SUM([Profit]) OVER (PARTITION BY [Day Name]) as [Profit of Day]
FROM RunningTotalProfit(2011)
) SrC1
PIVOT
(
	SUM([Profit of Day])
	FOR [Day Name] IN ([Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday], [Sunday])
) as PvT1
UNION
SELECT
	[YearOfOrderDate] as [Year],
	[Monday],
	[Tuesday],
	[Wednesday],
	[Thursday],
	[Friday],
	[Saturday],
	[Sunday]
FROM
(
SELECT DISTINCT 
		[YearOfOrderDate],
		[Day Name],
		SUM([Profit]) OVER (PARTITION BY [Day Name]) as [Profit of Day]
FROM RunningTotalProfit(2012)
) SrC1
PIVOT
(
	SUM([Profit of Day])
	FOR [Day Name] IN ([Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday], [Sunday])
) as PvT1
UNION
SELECT
	[YearOfOrderDate] as [Year],
	[Monday],
	[Tuesday],
	[Wednesday],
	[Thursday],
	[Friday],
	[Saturday],
	[Sunday]
FROM
(
SELECT DISTINCT 
		[YearOfOrderDate],
		[Day Name],
		SUM([Profit]) OVER (PARTITION BY [Day Name]) as [Profit of Day]
FROM RunningTotalProfit(2013)
) SrC1
PIVOT
(
	SUM([Profit of Day])
	FOR [Day Name] IN ([Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday], [Sunday])
) as PvT1
UNION
SELECT
	[YearOfOrderDate] as [Year],
	[Monday],
	[Tuesday],
	[Wednesday],
	[Thursday],
	[Friday],
	[Saturday],
	[Sunday]
FROM
(
SELECT DISTINCT 
		[YearOfOrderDate],
		[Day Name],
		SUM([Profit]) OVER (PARTITION BY [Day Name]) as [Profit of Day]
FROM RunningTotalProfit(2014)
) SrC1
PIVOT
(
	SUM([Profit of Day])
	FOR [Day Name] IN ([Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday], [Sunday])
) as PvT1

--- 43.f) Running Total, Running Difference and the percentage growth year over year of Profit by year, month, Quarter, week of year
CREATE FUNCTION RunningTotalProfit20112014 (
	@StartYear int,
	@EndYear int
)
RETURNS TABLE
AS
RETURN
SELECT [Profit], [OrderDate],[YearOfOrderDate], 
		Datename(Month,[OrderDate]) as [Month Name], 
		Month([OrderDate]) as Month, 
		DATEPART(qq,[OrderDate]) as [Quarter],
		DATENAME(weekday,[OrderDate]) as [Day Name],
		DATEPART(weekday,[OrderDate]) as [Weekday],
		DATEPART(wk, [OrderDate]) as [Week of the year]
FROM [Project4].[dbo].[SuperStore]
WHERE [YearOfOrderDate] BETWEEN @StartYear and @EndYear

-- 43.g) Running Total by Years
WITH RunningTotalYear AS (
	SELECT DISTINCT
		[YearOfOrderDate] as [Year],
		SUM([Profit]) OVER (PARTITION BY [YearOfOrderDate]) as [Profit by Year]
	FROM RunningTotalProfit20112014(2011,2014)
)
SELECT	[Year],
		SUM([Profit by Year]) OVER (ORDER BY [Year] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as [Running Total]
FROM RunningTotalYear

--43.h) Running Difference by years
CREATE VIEW RunningDifferenceByYearsProfit AS 
	SELECT DISTINCT
			[YearOfOrderDate] as [Year],
			SUM([Profit]) OVER (PARTITION BY [YearOfOrderDate]) as [Profit by Year]
	FROM RunningTotalProfit20112014(2011,2014)
-- Running Difference and the percentage growth year over year 
SELECT *,
	COALESCE(LAG([Profit by Year]) OVER (ORDER BY [Year]),0) as [Profit by Previous Year],
	COALESCE([Profit by Year] - LAG([Profit by Year]) OVER (ORDER BY [Year]),0)  as [Running Difference],
	COALESCE(ROUND(([Profit by Year] - LAG([Profit by Year]) OVER (ORDER BY [Year]))/(LAG([Profit by Year]) OVER (ORDER BY [Year]))*100,2),0) as [The percentage growth year over year (%)]
FROM RunningDifferenceByYearsProfit


-- 43.i) Running Total by Months in 2011

WITH RunningTotalByMonth AS (
	SELECT DISTINCT [YearOfOrderDate] as [Year],
	[Month Name],
	[Month], 
		SUM([Profit]) OVER (PARTITION BY [YearOfOrderDate], [Month Name]) as [Profit of Month]
	FROM RunningTotalProfit20112014(2011,2011)
)
SELECT [Year],[Month Name],
	SUM([Profit of Month]) OVER (ORDER BY [Month] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as [Running Total]
FROM RunningTotalByMonth
ORDER BY [Month] ASC
--43.j) Running Difference by Months 
CREATE VIEW RunningDifferenceByMonths2011Profit AS
	SELECT DISTINCT 
	[YearOfOrderDate] as [Year],
	[Month Name],
	[Month], 
	SUM([Profit]) OVER (PARTITION BY [YearOfOrderDate], [Month Name]) as [Profit of Month]
	FROM RunningTotalProfit20112014(2011,2011)
-- 43.k) Running Difference and the percentage growth month over month 
SELECT *,
	COALESCE(LAG([Profit of Month]) OVER (ORDER BY [Month]),0) as [Profit by previous Month],
	COALESCE(([Profit of Month] - LAG([Profit of Month]) OVER (ORDER BY [Month])),0) as [Running Difference],
	ROUND(COALESCE(([Profit of Month] - LAG([Profit of Month]) OVER (ORDER BY [Month]))/LAG([Profit of Month]) OVER (ORDER BY [Month])*100,0),2) as [The percentage growth month over month (%)]
FROM RunningDifferenceByMonths2011Profit
ORDER BY [Month]

--43.l)  Running Total by Months in 2012
WITH RunningTotalByMonth AS (
	SELECT DISTINCT [YearOfOrderDate] as [Year],
	[Month Name],
	[Month], 
		SUM([Profit]) OVER (PARTITION BY [YearOfOrderDate], [Month Name]) as [Profit of Month]
	FROM RunningTotalProfit20112014(2012,2012)
)
SELECT [Year],[Month Name],
	SUM([Profit of Month]) OVER (ORDER BY [Month] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as [Running Total]
FROM RunningTotalByMonth
ORDER BY [Month] ASC
--43.m) Running Difference by Months 
CREATE VIEW RunningDifferenceByMonths2012Profit AS
	SELECT DISTINCT 
	[YearOfOrderDate] as [Year],
	[Month Name],
	[Month], 
	SUM([Profit]) OVER (PARTITION BY [YearOfOrderDate], [Month Name]) as [Profit of Month]
	FROM RunningTotalProfit20112014(2012,2012)
--43.n) Running Difference and the percentage growth month over month 
SELECT *,
	COALESCE(LAG([Profit of Month]) OVER (ORDER BY [Month]),0) as [Profit by previous Month],
	COALESCE(([Profit of Month] - LAG([Profit of Month]) OVER (ORDER BY [Month])),0) as [Running Difference],
	ROUND(COALESCE(([Profit of Month] - LAG([Profit of Month]) OVER (ORDER BY [Month]))/LAG([Profit of Month]) OVER (ORDER BY [Month])*100,0),2) as [The percentage growth month over month (%)]
FROM RunningDifferenceByMonths2012Profit
ORDER BY [Month]

--43.o)Running Total by Months 2013
WITH RunningTotalByMonth AS (
	SELECT DISTINCT [YearOfOrderDate] as [Year],
	[Month Name],
	[Month], 
		SUM([Profit]) OVER (PARTITION BY [YearOfOrderDate], [Month Name]) as [Profit of Month]
	FROM RunningTotalProfit20112014(2013,2013)
)
SELECT [Year],[Month Name],
	SUM([Profit of Month]) OVER (ORDER BY [Month] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as [Running Total]
FROM RunningTotalByMonth
ORDER BY [Month] ASC
--43.p) Running Difference by Months 
CREATE VIEW RunningDifferenceByMonths2013Profit AS
	SELECT DISTINCT 
	[YearOfOrderDate] as [Year],
	[Month Name],
	[Month], 
	SUM([Profit]) OVER (PARTITION BY [YearOfOrderDate], [Month Name]) as [Profit of Month]
	FROM RunningTotalProfit20112014(2013,2013)
--43.q) Running Difference and the percentage growth month over month 
SELECT *,
	COALESCE(LAG([Profit of Month]) OVER (ORDER BY [Month]),0) as [Profit by previous Month],
	COALESCE(([Profit of Month] - LAG([Profit of Month]) OVER (ORDER BY [Month])),0) as [Running Difference],
	ROUND(COALESCE(([Profit of Month] - LAG([Profit of Month]) OVER (ORDER BY [Month]))/LAG([Profit of Month]) OVER (ORDER BY [Month])*100,0),2) as [The percentage growth month over month (%)]
FROM RunningDifferenceByMonths2013Profit
ORDER BY [Month]
--43.r) Running Total by Months 2014
WITH RunningTotalByMonth AS (
	SELECT DISTINCT [YearOfOrderDate] as [Year],
	[Month Name],
	[Month], 
		SUM([Profit]) OVER (PARTITION BY [YearOfOrderDate], [Month Name]) as [Profit of Month]
	FROM RunningTotalProfit20112014(2014,2014)
)
SELECT [Year],[Month Name],
	SUM([Profit of Month]) OVER (ORDER BY [Month] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as [Running Total]
FROM RunningTotalByMonth
ORDER BY [Month] ASC
--43.s) Running Difference by Months 
CREATE VIEW RunningDifferenceByMonths2014Profit AS
	SELECT DISTINCT 
	[YearOfOrderDate] as [Year],
	[Month Name],
	[Month], 
	SUM([Profit]) OVER (PARTITION BY [YearOfOrderDate], [Month Name]) as [Profit of Month]
	FROM RunningTotalProfit20112014(2014,2014)
-- 43.t) Running Difference and the percentage growth month over month 
SELECT *,
	COALESCE(LAG([Profit of Month]) OVER (ORDER BY [Month]),0) as [Profit by previous Month],
	COALESCE(([Profit of Month] - LAG([Profit of Month]) OVER (ORDER BY [Month])),0) as [Running Difference],
	ROUND(COALESCE(([Profit of Month] - LAG([Profit of Month]) OVER (ORDER BY [Month]))/LAG([Profit of Month]) OVER (ORDER BY [Month])*100,0),2) as [The percentage growth month over month (%)]
FROM RunningDifferenceByMonths2014Profit
ORDER BY [Month]

--43.u) Running Total by Quarters 2011
WITH RunningTotalQuarters2011Profit AS  (
	SELECT DISTINCT 
			[YearOfOrderDate] as [Year],
			[Quarter],
			SUM([Profit]) OVER (PARTITION BY [Quarter]) as [Profit of Quarter]
	FROM RunningTotalProfit20112014(2011,2011)
) 
SELECT [Year], [Quarter] ,SUM([Profit of Quarter]) OVER (ORDER BY [Quarter] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as [Running Total]
FROM RunningTotalQuarters2011Profit
--43.v) Running Difference by Quarters 2011
CREATE VIEW RunningDifferenceQuarters2011Profit AS 
	SELECT DISTINCT 
		[YearOfOrderDate] as [Year],
		[Quarter],
		SUM([Profit]) OVER (PARTITION BY [Quarter]) as [Profit of Quarter]
	FROM RunningTotalProfit20112014(2011,2011)
--- 43.w) Running Difference and the percentage growth quarter over quarter 
SELECT *,
	COALESCE(LAG([Profit of Quarter]) OVER (ORDER BY [Quarter]),0) as [Profit by previous Quarter],
	COALESCE(([Profit of Quarter] - LAG([Profit of Quarter]) OVER (ORDER BY [Quarter])),0) as [Running Difference],
	ROUND(COALESCE(([Profit of Quarter] - LAG([Profit of Quarter]) OVER (ORDER BY [Quarter]))/LAG([Profit of Quarter]) OVER (ORDER BY [Quarter])*100,0),2) as [The percentage growth quarter over quarter (%)]
FROM RunningDifferenceQuarters2011Profit

--43.w) Running Total by Quarters 2012
WITH RunningTotalQuarters2012Profit AS  (
	SELECT DISTINCT 
			[YearOfOrderDate] as [Year],
			[Quarter],
			SUM([Profit]) OVER (PARTITION BY [Quarter]) as [Profit of Quarter]
	FROM RunningTotalProfit20112014(2012,2012)
)
SELECT [Year], [Quarter] ,SUM([Profit of Quarter]) OVER (ORDER BY [Quarter] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as [Running Total]
FROM RunningTotalQuarters2012Profit
--43.x) Running Difference by Quarters 2012
CREATE VIEW RunningDifferenceQuarters2012Profit AS 
	SELECT DISTINCT 
		[YearOfOrderDate] as [Year],
		[Quarter],
		SUM([Profit]) OVER (PARTITION BY [Quarter]) as [Profit of Quarter]
	FROM RunningTotalProfit20112014(2012,2012)
-- 43.y) Running Difference and the percentage growth  quarter over quarter  
SELECT *,
	COALESCE(LAG([Profit of Quarter]) OVER (ORDER BY [Quarter]),0) as [Profit by previous Quarter],
	COALESCE(([Profit of Quarter] - LAG([Profit of Quarter]) OVER (ORDER BY [Quarter])),0) as [Running Difference],
	ROUND(COALESCE(([Profit of Quarter] - LAG([Profit of Quarter]) OVER (ORDER BY [Quarter]))/LAG([Profit of Quarter]) OVER (ORDER BY [Quarter])*100,0),2) as [The percentage growth quarter over quarter (%)]
FROM RunningDifferenceQuarters2012Profit

--43.z) Running Total by Quarters 2013
WITH RunningTotalQuarters2013Profit AS  (
	SELECT DISTINCT 
			[YearOfOrderDate] as [Year],
			[Quarter],
			SUM([Profit]) OVER (PARTITION BY [Quarter]) as [Profit of Quarter]
	FROM RunningTotalProfit20112014(2013,2013)
)
SELECT [Year], [Quarter] ,SUM([Profit of Quarter]) OVER (ORDER BY [Quarter] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as [Running Total]
FROM RunningTotalQuarters2013Profit
-- 43.aa) Running Difference by Quarters 2013
CREATE VIEW RunningDifferenceQuarters2013Profit AS 
	SELECT DISTINCT 
		[YearOfOrderDate] as [Year],
		[Quarter],
		SUM([Profit]) OVER (PARTITION BY [Quarter]) as [Profit of Quarter]
	FROM RunningTotalProfit20112014(2013,2013)
--43.ab) Running Difference and the percentage growth  quarter over quarter 
SELECT *,
	COALESCE(LAG([Profit of Quarter]) OVER (ORDER BY [Quarter]),0) as [Profit by previous Quarter],
	COALESCE(([Profit of Quarter] - LAG([Profit of Quarter]) OVER (ORDER BY [Quarter])),0) as [Running Difference],
	ROUND(COALESCE(([Profit of Quarter] - LAG([Profit of Quarter]) OVER (ORDER BY [Quarter]))/LAG([Profit of Quarter]) OVER (ORDER BY [Quarter])*100,0),2) as [The percentage growth quarter over quarter (%)]
FROM RunningDifferenceQuarters2013Profit

--43.ac) Running Total by Quarters 2014
WITH RunningTotalQuarters2014Profit AS  (
	SELECT DISTINCT 
			[YearOfOrderDate] as [Year],
			[Quarter],
			SUM([Profit]) OVER (PARTITION BY [Quarter]) as [Profit of Quarter]
	FROM RunningTotalProfit20112014(2014,2014)
)
SELECT [Year], [Quarter] ,SUM([Profit of Quarter]) OVER (ORDER BY [Quarter] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as [Running Total]
FROM RunningTotalQuarters2014Profit
-- 43.ad) Running Difference by Quarters 2014
CREATE VIEW RunningDifferenceQuarters2014Profit AS 
	SELECT DISTINCT 
		[YearOfOrderDate] as [Year],
		[Quarter],
		SUM([Profit]) OVER (PARTITION BY [Quarter]) as [Profit of Quarter]
	FROM RunningTotalProfit20112014(2014,2014)
--43. ae)  Running Difference and the percentage growth  quarter over quarter 
SELECT *,
	COALESCE(LAG([Profit of Quarter]) OVER (ORDER BY [Quarter]),0) as [Profit by previous Quarter],
	COALESCE(([Profit of Quarter] - LAG([Profit of Quarter]) OVER (ORDER BY [Quarter])),0) as [Running Difference],
	ROUND(COALESCE(([Profit of Quarter] - LAG([Profit of Quarter]) OVER (ORDER BY [Quarter]))/LAG([Profit of Quarter]) OVER (ORDER BY [Quarter])*100,0),2) as [The percentage growth quarter over quarter (%)]
FROM RunningDifferenceQuarters2014Profit

--43.af) Running Total by Week of year 2011
WITH RunningTotalWeekOfYear2011Profit AS (
	SELECT DISTINCT  [YearOfOrderDate],[Week of the year],
		SUM([Profit]) OVER (PARTITION BY [Week of the year]) as [Profit of Week of the Year]
	FROM RunningTotalProfit20112014(2011,2011)
)
SELECT [YearOfOrderDate] as [Year],
		[Week of the year],
		SUM([Profit of week of the Year]) OVER (ORDER BY [Week of the year] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS [Running Total]
FROM RunningTotalWeekOfYear2011Profit
-- 43. ag) Running Difference by Week of year 2011
CREATE VIEW RunningDifferenceWeekOfYear2011Profit AS
		SELECT DISTINCT  [YearOfOrderDate],[Week of the year],
		SUM([Profit]) OVER (PARTITION BY [Week of the year]) as [Profit of Week of the Year]
		FROM RunningTotalProfit20112014(2011,2011)

--43.ah)  Running Difference and the percentage growth Week of year  2011
SELECT *,
	COALESCE(LAG([Profit of week of the Year]) OVER (ORDER BY [Week of the year]),0) as [Profit by previous week of year],
	COALESCE(([Profit of week of the Year] - LAG([Profit of week of the Year]) OVER (ORDER BY [Week of the year])),0) as [Running Difference],
	ROUND(COALESCE(([Profit of week of the Year] - LAG([Profit of week of the Year]) OVER (ORDER BY [Week of the year]))/LAG([Profit of week of the Year]) OVER (ORDER BY [Week of the year])*100,0),2) as [The percentage growth week of year over week of year (%)]
FROM RunningDifferenceWeekOfYear2011Profit


--43. ai)Running Total by Week of year 2012
WITH RunningTotalWeekOfYear2012Profit AS (
	SELECT DISTINCT  [YearOfOrderDate],[Week of the year],
		SUM([Profit]) OVER (PARTITION BY [Week of the year]) as [Profit of Week of the Year]
	FROM RunningTotalProfit20112014(2012,2012)
)
SELECT [YearOfOrderDate] as [Year],
		[Week of the year],
		SUM([Profit of week of the Year]) OVER (ORDER BY [Week of the year] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS [Running Total]
FROM RunningTotalWeekOfYear2012Profit
--43. aj) Running Difference by Week of year 2012
CREATE VIEW RunningDifferenceWeekOfYear2012Profit AS
		SELECT DISTINCT  [YearOfOrderDate],[Week of the year],
		SUM([Profit]) OVER (PARTITION BY [Week of the year]) as [Profit of Week of the Year]
		FROM RunningTotalProfit20112014(2012,2012)

--43. ak) Running Difference and the percentage growth Week of year  2012
SELECT *,
	COALESCE(LAG([Profit of week of the Year]) OVER (ORDER BY [Week of the year]),0) as [Profit by previous week of year],
	COALESCE(([Profit of week of the Year] - LAG([Profit of week of the Year]) OVER (ORDER BY [Week of the year])),0) as [Running Difference],
	ROUND(COALESCE(([Profit of week of the Year] - LAG([Profit of week of the Year]) OVER (ORDER BY [Week of the year]))/LAG([Profit of week of the Year]) OVER (ORDER BY [Week of the year])*100,0),2) as [The percentage growth week of year over week of year (%)]
FROM RunningDifferenceWeekOfYear2012Profit

--43.al) Running Total by Week of year 2013
WITH RunningTotalWeekOfYear2013Profit AS (
	SELECT DISTINCT  [YearOfOrderDate],[Week of the year],
		SUM([Profit]) OVER (PARTITION BY [Week of the year]) as [Profit of Week of the Year]
	FROM RunningTotalProfit20112014(2013,2013)
)
SELECT [YearOfOrderDate] as [Year],
		[Week of the year],
		SUM([Profit of week of the Year]) OVER (ORDER BY [Week of the year] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS [Running Total]
FROM RunningTotalWeekOfYear2013Profit
--43.am)  Running Difference by Week of year 2013
CREATE VIEW RunningDifferenceWeekOfYear2013Profit AS
		SELECT DISTINCT  [YearOfOrderDate],[Week of the year],
		SUM([Profit]) OVER (PARTITION BY [Week of the year]) as [Profit of Week of the Year]
		FROM RunningTotalProfit20112014(2013,2013)

--43.an)  Running Difference and the percentage growth Week of year  2012
SELECT *,
	COALESCE(LAG([Profit of week of the Year]) OVER (ORDER BY [Week of the year]),0) as [Profit by previous week of year],
	COALESCE(([Profit of week of the Year] - LAG([Profit of week of the Year]) OVER (ORDER BY [Week of the year])),0) as [Running Difference],
	ROUND(COALESCE(([Profit of week of the Year] - LAG([Profit of week of the Year]) OVER (ORDER BY [Week of the year]))/LAG([Profit of week of the Year]) OVER (ORDER BY [Week of the year])*100,0),2) as [The percentage growth week of year over week of year (%)]
FROM RunningDifferenceWeekOfYear2013Profit


--43.ao) Running Total by Week of year 2014
WITH RunningTotalWeekOfYear2014Profit AS (
	SELECT DISTINCT  [YearOfOrderDate],[Week of the year],
		SUM([Profit]) OVER (PARTITION BY [Week of the year]) as [Profit of Week of the Year]
	FROM RunningTotalProfit20112014(2014,2014)
)
SELECT [YearOfOrderDate] as [Year],
		[Week of the year],
		SUM([Profit of week of the Year]) OVER (ORDER BY [Week of the year] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS [Running Total]
FROM RunningTotalWeekOfYear2014Profit
--43.ap)  Running Difference by Week of year 2014
CREATE VIEW RunningDifferenceWeekOfYear2014Profit AS
		SELECT DISTINCT  [YearOfOrderDate],[Week of the year],
		SUM([Profit]) OVER (PARTITION BY [Week of the year]) as [Profit of Week of the Year]
		FROM RunningTotalProfit20112014(2014,2014)

--43. aq) Running Difference and the percentage growth Week of year  2014
SELECT *,
	COALESCE(LAG([Profit of week of the Year]) OVER (ORDER BY [Week of the year]),0) as [Profit by previous week of year],
	COALESCE(([Profit of week of the Year] - LAG([Profit of week of the Year]) OVER (ORDER BY [Week of the year])),0) as [Running Difference],
	ROUND(COALESCE(([Profit of week of the Year] - LAG([Profit of week of the Year]) OVER (ORDER BY [Week of the year]))/LAG([Profit of week of the Year]) OVER (ORDER BY [Week of the year])*100,0),2) as [The percentage growth week of year over week of year (%)]
FROM RunningDifferenceWeekOfYear2014Profit

-- 44.a) The Quantity of Orders by Customer Name 
SELECT DISTINCT
DENSE_RANK() OVER (ORDER BY COUNT([Customer Name]) DESC) as [Ranking],
	[Customer Name], COUNT([Customer Name])  as [The Quantity of Orders by Customer]
FROM   [Project4].[dbo].[SuperStore]
GROUP BY [Customer Name]

-- 44.b) The Quantity of Orders by Customer ID
SELECT DISTINCT 
	DENSE_RANK() OVER (ORDER BY COUNT([Customer Name]) DESC) as [Ranking],
		[Customer Name], [Customer ID], COUNT([Customer ID]) as [The Quantity of Orders by Customer ID]
FROM   [Project4].[dbo].[SuperStore]
GROUP BY [Customer Name], [Customer ID]
ORDER BY [The Quantity of Orders by Customer ID] DESC
-- 44.c) The Quantity of Customer Name by Customer Name  with Orders greater than 90
SELECT 
		DENSE_RANK() OVER (ORDER BY COUNT([Customer Name]) DESC) as [Ranking],
		[Customer Name], COUNT([Customer Name])  as [Quantity of Orders by Customer Name]
FROM [Project4].[dbo].[SuperStore]
GROUP BY [Customer Name]
HAVING COUNT([Customer Name]) > 90
ORDER BY [Quantity of Orders by Customer Name] DESC
-- 44.d) The Quantity of Customer Name by Customer ID with Orders greater than 80
SELECT DENSE_RANK() OVER (ORDER BY COUNT([Customer ID]) DESC) as [Ranking],
	[Customer Name], [Customer ID], 
	COUNT([Customer ID]) AS [The Quantity of Orders by Customer ID]
FROM [Project4].[dbo].[SuperStore]
GROUP BY [Customer Name], [Customer ID]
HAVING COUNT([Customer ID]) > 80
ORDER BY [The Quantity of Orders by Customer ID] DESC


--45.a) Return the first of 10 Orders (Product Name) for evey customer that purchased more than 90 times.
WITH OrdersByCustomer AS (
	SELECT 
			ROW_NUMBER() OVER (PARTITION BY [Customer Name] ORDER BY [OrderDate]) as [The Quantity of Order],
			[Order ID], [Customer Name], [Product Name], [OrderDate],
			COUNT([Order ID]) OVER (PARTITION BY [Customer Name]) as [The Total Quantity of Orders]
	FROM  [Project4].[dbo].[SuperStore] 
)
SELECT *
FROM OrdersByCustomer
WHERE [The Total Quantity of Orders] > 90 and [The Quantity of Order] <= 10
ORDER BY [The Total Quantity of Orders] DESC
-- 45.b) Return the first of 3 Orders and Product names for every customer that purchased more than 5 times on May 
WITH OrdersByCustomerOnMay AS (
	SELECT [Order ID],
		ROW_NUMBER() OVER (PARTITION BY [Order ID] ORDER BY [OrderDate]) as [The Quantity of Orders],
		[Customer Name], [Product Name],[OrderDate],
				COUNT([Customer Name]) OVER (PARTITION BY [ORDER ID]) as [The Total Quantity of Orders]
	FROM  [Project4].[dbo].[SuperStore] 
	WHERE DATEPART(MONTH,OrderDate) = 5
) 
SELECT *
FROM OrdersByCustomerOnMay
WHERE [The Total Quantity of Orders] > 5 and [The Quantity of Orders] <= 3

-- 45.c) Return the first of 3 Orders and Product name for every customer that purchased more than 5 times on January 
WITH  OrdersByCustomerOnJanuary AS (
	SELECT [Order ID],
		ROW_NUMBER() OVER (PARTITION BY [Customer Name] ORDER BY [OrderDate]) as [The Quantity of Orders],
		[Customer Name], [Product Name], [OrderDate],
		COUNT([Order ID]) OVER (PARTITION BY [Customer Name]) as [The Total Quantity of Orders]
	FROM [Project4].[dbo].[SuperStore] 
	WHERE DATEPART(Month,OrderDate) = 1
)
SELECT *
FROM OrdersByCustomerOnJanuary
WHERE [The Total Quantity of Orders] > 5 AND [The Quantity of Orders] <= 3


--46.a)  Return all Orders from any customers who made less than 10000  in purchased for their first three transactions
CREATE VIEW QuantityOfOrders AS 
	SELECT [Order ID], 
	ROW_NUMBER() OVER (PARTITION BY [Customer Name] ORDER BY [OrderDate]) as [The Number of Orders],
			[Product Name], [Customer Name], [Sales], [OrderDate]
	FROM [Project4].[dbo].[SuperStore] 


WITH QuantityOfOrdersWithSalesLessThan10k AS (
SELECT *, SUM(Sales) OVER (PARTITION BY [Customer Name]) as [Total Sales]
FROM QuantityOfOrders
WHERE [The Number of Orders] <= 3
)
SELECT *
FROM QuantityOfOrdersWithSalesLessThan10k
WHERE [Total Sales] < 10000

--46.b) Return all Orders from any customers who made more than 100 000  in purchased for their first three transactions
CREATE VIEW QuantityOfOrders1 AS
SELECT [Order ID],
		ROW_NUMBER() OVER (PARTITION BY [Customer Name] ORDER BY [OrderDate]) as [The Number of Orders],
			[Product Name], [Customer Name], [Sales], [OrderDate]
	FROM [Project4].[dbo].[SuperStore] 

WITH CustomerWithFirst3Transaction AS (
	SELECT *, SUM(Sales) OVER (PARTITION BY [Customer Name]) as [Total Sales]
	FROM QuantityOfOrders1
	WHERE  [The Number of Orders] <= 3
)
SELECT *
FROM CustomerWithFirst3Transaction
WHERE [Total Sales] > 1000000

--47.a)  Look for the first and last sales for each day of every month of every year 
SELECT [OrderDate],[Sales],
FIRST_VALUE(Sales) OVER (PARTITION BY DAY(OrderDate),MONTH(OrderDate), YEAR(OrderDate) ORDER BY [OrderDate])  as [First Sales],
LAST_VALUE(Sales) OVER (PARTITION BY DAY(OrderDate),MONTH(OrderDate), YEAR(OrderDate) ORDER BY [OrderDate]) as [Last Sales]
FROM [Project4].[dbo].[SuperStore] 
ORDER BY [OrderDate] ASC

-- 47.b) Look for the first and last Profit for each day of every month of every year 
SELECT [OrderDate], [Profit],
FIRST_VALUE([Profit]) OVER (PARTITION BY DAY([OrderDate]), MONTH([OrderDate]), YEAR([OrderDate]) ORDER BY [OrderDate]) as [First Profit],
LAST_VALUE([Profit]) OVER (PARTITION BY DAY([OrderDate]), MONTH([OrderDate]), YEAR([OrderDate]) ORDER BY [OrderDate]) as [Last Profit]
FROM [Project4].[dbo].[SuperStore] 
ORDER BY [OrderDate] ASC

	
--48.a)  The percentage of daily sales to the total sales 
SELECT [OrderDate],[Sales], SUM([Sales]) OVER (PARTITION BY [OrderDate]) as [Daily Sales],
ROUND([Sales] / SUM([Sales]) OVER (PARTITION BY [OrderDate]),5)*100 as [The Percentage of Total Sales (%)]
FROM [Project4].[dbo].[SuperStore] 


-- 49. The Margin (%) in each year and for category
SELECT [Category],[2011],[2012],[2013],[2014]
FROM
(
	SELECT [YearOfOrderDate] as [Year],[Category], ROUND((SUM([Sales]) / SUM([Profit]))*100,2) as [Margin (%)]
	FROM [Project4].[dbo].[SuperStore] 
	GROUP BY [YearOfOrderDate], [Category]
) as SrC1
PIVOT
(
	SUM([Margin (%)])
	FOR [Year] IN ([2011],[2012],[2013],[2014])
) as PvT1
-- 50. The average value of orders in each year and for category
SELECT [Category],[2011],[2012],[2013],[2014]
FROM
(
SELECT [YearofOrderDate] as [Year],[Category],ROUND(SUM([Sales]) / COUNT([Order ID]),2) as [The Average Value of Orders]
FROM [Project4].[dbo].[SuperStore] 
GROUP BY [YearOfOrderDate], [Category]
) as SrC1
PIVOT
(
	SUM([The Average Value of Orders])
	FOR [Year] IN ([2011],[2012],[2013],[2014])
) as PvT1
-- 51. The cost of Product in each year and for category
SELECT [Category],[2011],[2012],[2013],[2014]
FROM
(
SELECT [YearOfOrderDate] as [Year],[Category],SUM([Sales]) - SUM([Profit]) - SUM([Shipping Cost]) as [Product Cost]
FROM [Project4].[dbo].[SuperStore] 
GROUP BY [YearOfOrderDate], [Category]
) as SrC1
PIVOT
(
	SUM([Product Cost])
	FOR [Year] IN ([2011],[2012],[2013],[2014])
) as PvT1
--52. The percentage cost of product (%) to the Sales
SELECT [Category],[2011],[2012],[2013],[2014]
FROM
(
SELECT [YearOfOrderDate] as [Year],[Category],ROUND((SUM([Sales]) - SUM([Profit]) - SUM([Shipping Cost])) / SUM([Sales])*100,2)  as [The percentage cost of product to the Sales (%)]
FROM [Project4].[dbo].[SuperStore] 
GROUP BY [YearOfOrderDate], [Category]
) as SrC1
PIVOT
(
	SUM([The percentage cost of product to the Sales (%)])
	FOR [Year] IN ([2011],[2012],[2013],[2014])
) as PvT1

-- 53. The  Ship Duration
SELECT [OrderDate], [ShipDate], DATEDIFF(DAY,[OrderDate],[ShipDate]) as [Ship Duration]
FROM [Project4].[dbo].[SuperStore]
--54. The average Ship Duration
SELECT [Category],[2011],[2012],[2013],[2014]
FROM
(
SELECT [YearOfOrderDate] as [Year],[Category],AVG(DATEDIFF(DAY,[OrderDate],[ShipDate])) as [The Average Ship Duration]
FROM [Project4].[dbo].[SuperStore]
GROUP BY [YearOfOrderDate], [Category]
) as SrC1
PIVOT
(
	SUM([The Average Ship Duration])
	FOR [Year] IN ([2011],[2012],[2013],[2014])
) as PvT1









