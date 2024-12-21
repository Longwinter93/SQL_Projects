--CASE Statement in the WHERE Clause
--https://www.mssqltips.com/sqlservertip/7703/sql-case-in-where-clause/


USE AdventureWorks2019;

SELECT * 
FROM [HumanResources].[Employee] 

SELECT NationalIDNumber, MaritalStatus 
FROM  [HumanResources].[Employee] 

--Showing all Single based on WHERE CASE:
SELECT NationalIDNumber, MaritalStatus 
FROM  [HumanResources].[Employee] 
WHERE CASE 
			WHEN [MaritalStatus] = 'S' THEN 1 
			ELSE 0 
			END = 1;

--
SELECT SalesOrderID,TerritoryID,ShipMethodID,BillToAddressID
FROM [AdventureWorks2019].[Sales].[SalesOrderHeader]
--
SELECT SalesOrderID,TerritoryID,ShipMethodID,BillToAddressID
FROM [AdventureWorks2019].[Sales].[SalesOrderHeader]
WHERE CASE 
			WHEN [TerritoryID] = 5 AND [ShipMethodID] = 5 THEN 1 
			WHEN [BillToAddressID] = 947 THEN 1 
			ELSE 0 
			END = 1;
--If we want to exclude the records instead of including them,
---we can change the filter to return records with values set to 0 by the CASE statement.
SELECT SalesOrderID,TerritoryID,ShipMethodID,BillToAddressID
FROM [AdventureWorks2019].[Sales].[SalesOrderHeader]
WHERE CASE WHEN [TerritoryID] = 5 AND [ShipMethodID] = 5 THEN 1 
			WHEN [BillToAddressID] = 947 THEN 1 
			ELSE 0 
			END = 0;

--Similarly, you can combine multiple CASE statement conditions with OR and AND operators.
--For example, the query below returns both Single and Married employees.
SELECT NationalIDNumber,MaritalStatus 
FROM [AdventureWorks2019].[HumanResources].[Employee]
WHERE (CASE 
	WHEN MaritalStatus = 'S' THEN 1
	ELSE 0 
	END = 1)
	OR 
	(CASE 
	WHEN MaritalStatus = 'M' THEN 1
	ELSE 0 
	END = 1)

--Records with an average total due amount over 3000
SELECT *
FROM [AdventureWorks2019].[Sales].[SalesOrderHeader]
WHERE CASE WHEN (SELECT AVG(TotalDue) FROM [Sales].[SalesOrderHeader]) > 3000 THEN 1 
	ELSE 0 END = 1;

--where the CASE statement filters records when the OrderDate is between specified dates.
SELECT * 
FROM [AdventureWorks2019].[Sales].[SalesOrderHeader]
WHERE CASE	
		WHEN OrderDate BETWEEN '2023-01-01' AND '2023-01-31' THEN 1 ELSE 0 
		END = 1;

--All of these queries could be written without the CASE, but sometimes using CASE makes it easier to read the code. 
--Here is an example of using CASE versus using OR for the query.
--These both return the same results and also have the same execution plan.
SELECT SalesOrderID,TerritoryID,ShipMethodID,BillToAddressID
FROM [AdventureWorks2019].[Sales].[SalesOrderHeader]
WHERE CASE
         WHEN [TerritoryID] = 5 AND [ShipMethodID] = 5 THEN 1
         WHEN BillToAddressID = 947 THEN 1
         ELSE 0
      END = 1;

SELECT SalesOrderID, TerritoryID, ShipMethodID, BillToAddressID
FROM [AdventureWorks2019].[Sales].[SalesOrderHeader]
WHERE ([TerritoryID] = 5 AND [ShipMethodID] = 5) OR BillToAddressID = 947;

--Another case using WHEN:
SELECT
   bom.BillOfMaterialsID,
   bom.ProductAssemblyID,
   u.Name,
   u.UnitMeasureCode,
   bom.PerAssemblyQty
FROM Production.BillOfMaterials bom
INNER JOIN Production.UnitMeasure u on u.UnitMeasureCode = bom.UnitMeasureCode
--
SELECT
   bom.BillOfMaterialsID,
   bom.ProductAssemblyID,
   u.Name,
   u.UnitMeasureCode,
   bom.PerAssemblyQty
FROM Production.BillOfMaterials bom
INNER JOIN Production.UnitMeasure u on u.UnitMeasureCode = bom.UnitMeasureCode
WHERE -- filter these data based on conditions:
   PerAssemblyQty >= CASE u.UnitMeasureCode
                       WHEN 'EA' THEN 30
                       WHEN 'OZ' THEN 9
                       WHEN 'IN' THEN 40
                       ELSE 0
                   END;

--Showing records from the [SalesOrderHeader] table where the orderdate is between specified dates.
--If this condition is satisfied, check for orders with a value 1 for column [OnlineOrderFlag]
SELECT *
FROM [AdventureWorks2019].[Sales].[SalesOrderHeader]
WHERE CASE 
		WHEN OrderDate BETWEEN '2014-01-01' AND '2014-12-31' THEN 
		CASE 
			WHEN OnlineOrderFlag = 1 THEN 1 
		ELSE 0 
		END 
		ELSE 0 
		END = 1

--CASE Statement in WHERE Clause as SubQuery
SELECT SalesOrderID,SalesOrderNumber,TotalDue,AccountNumber
FROM [AdventureWorks2019].[Sales].[SalesOrderHeader] 
WHERE SalesOrderID IN (
	SELECT SalesOrderID 
	FROM [AdventureWorks2019].[Sales].[SalesOrderHeader] 
	WHERE CASE 
			WHEN TotalDue > 1000 THEN 1 
			ELSE 0 
			END = 1)