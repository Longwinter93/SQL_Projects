--https://learnsql.com/blog/sql-window-functions-guide/ (all functions)
--https://www.sqlshack.com/an-overview-of-analytic-functions-in-sql-server/ (all functions)
--https://learn.microsoft.com/en-us/sql/t-sql/functions/analytic-functions-transact-sql?view=sql-server-ver16 (all functions)
--https://learnsql.com/blog/sql-window-functions-explanation/ (FIRST AND LAST VALUE FUNCTIONS)
--https://www.red-gate.com/simple-talk/databases/sql-server/t-sql-programming-sql-server/introduction-to-t-sql-window-functions/ (all functions + framing)
--https://learnsql.com/blog/sql-first-value-function/ (FIRST_VALUE())
--https://learnsql.com/blog/common-sql-window-functions-positional-functions/ (FIRST,LAST, LAG, LEAD FUNCTIONS)
--https://www.sqltutorial.org/sql-window-functions/ (On the right Ranking Functions & Value Functions)
--https://www.sqlshack.com/use-window-functions-sql-server/ -- Value Window Functions (all functions)
--https://www.sqlservertutorial.net/sql-server-window-functions/ (All functions)
--https://www.mssqltips.com/tutorial/sql-server-t-sql-window-functions-tutorial/ -- (All functions)

--window frame / row_range clause
--FIRST_VALUE() AND LAST_VALUE() require framing - we should include a frame window in these functions
--FIRST_VALUE() - It returns the first value in an ordered set of values

--Returning values with Least Amount:
USE AdventureWorks2022;
GO

SELECT Name,
    ListPrice,
    FIRST_VALUE(Name) OVER (ORDER BY ListPrice ASC) AS LeastExpensive
FROM Production.Product
WHERE ProductSubcategoryID = 37;
GO
--
USE AnalyticFunctions;
GO

SELECT *,
	FIRST_VALUE(employee_name) OVER (ORDER BY sales_amount ASC) as LeastSalesAmountToEmployeeName
FROM employee_sales
WHERE sales_amount IS NOT NULL;
GO
--
USE AdventureWorks2022;
GO
--The ROWS UNBOUNDED PRECEDING clause specifies the starting point of the window is the first row of each partition.
SELECT JobTitle,
    LastName,
    VacationHours,
    FIRST_VALUE(LastName) OVER (PARTITION BY JobTitle ORDER BY VacationHours ASC ROWS UNBOUNDED PRECEDING) AS FewestVacationHours,
	FIRST_VALUE(LastName) OVER (PARTITION BY JobTitle ORDER BY VacationHours ASC) AS FewestVacationHoursWithoutRowsRangeClause
FROM HumanResources.Employee AS e
INNER JOIN Person.Person AS p
    ON e.BusinessEntityID = p.BusinessEntityID
ORDER BY JobTitle;
--
USE AnalyticFunctions;
GO

SELECT *,
	FIRST_VALUE(employee_name) OVER(PARTITION BY department ORDER BY sales_amount ASC ROWS UNBOUNDED PRECEDING) as LeastSalesAmount,
	FIRST_VALUE(employee_name) OVER(PARTITION BY department ORDER BY sales_amount ASC) as LeastSalesAmountWithoutRowRangeClause
FROM employee_sales
WHERE sales_amount IS NOT NULL;
GO
--Difference current first
--https://learnsql.com/blog/sql-window-functions-guide/#first-value
SELECT *,
	FIRST_VALUE(sales_amount) OVER(ORDER BY sales_amount ASC) FirstValue,
	sales_amount - FIRST_VALUE(sales_amount) OVER(ORDER BY sales_amount ASC) difference_current_first
FROM employee_sales
WHERE sales_amount IS NOT NULL;
GO
--ORDER BY IN ARGUMENT ASC
SELECT *,
	FIRST_VALUE(sales_amount) OVER(PARTITION BY department ORDER BY sales_month ASC) FirstValueBasedOnArguments,
	sales_amount - FIRST_VALUE(sales_amount) OVER(PARTITION BY department ORDER BY sales_month ASC) difference_current_first
FROM employee_sales
WHERE sales_amount IS NOT NULL;
GO
--ORDER BY IN ARGUMENT  DESC
SELECT *,
	FIRST_VALUE(sales_amount) OVER(PARTITION BY department ORDER BY sales_month DESC) FirstValueBasedOnArguments,
	sales_amount - FIRST_VALUE(sales_amount) OVER(PARTITION BY department ORDER BY sales_month DESC) difference_current_first
FROM employee_sales
WHERE sales_amount IS NOT NULL;
GO


--
SELECT *,
	FIRST_VALUE(sales_amount) OVER(PARTITION BY department ORDER BY sales_amount ASC) as FirstValuesBasedOnPartition,
	sales_amount - FIRST_VALUE(sales_amount) OVER(PARTITION BY department ORDER BY sales_amount ASC) AS DiffCurrFirstPARTITION
FROM employee_sales
WHERE sales_amount IS NOT NULL; 
GO
--
SELECT *,
	FIRST_VALUE(sales_month) OVER(ORDER BY sales_month ASC) as FirstValueMonth,
	FIRST_VALUE(sales_month) OVER(ORDER BY department ASC) as FirstValueMonth
FROM employee_sales;
GO 
--
SELECT *,
	FIRST_VALUE(sales_month) OVER(ORDER BY department ASC) as FirstSalesMonthOrderByDepartment
FROM employee_sales;
GO 
--
SELECT *,
	FIRST_VALUE(sales_month) OVER(PARTITION BY department ORDER BY employee_name ASC) FirstValueBasedOnDepAndOrdEmpName
FROM employee_sales;
GO 
--
SELECT *,
	FIRST_VALUE(sales_month) OVER(PARTITION BY department ORDER BY employee_name DESC) FirstValueBasedOnDepAndOrdEmpName
FROM employee_sales;
GO 
--
SELECT *,
	FIRST_VALUE(sales_amount) OVER(PARTITION BY department ORDER BY sales_month ASC) as FirstValueDepOrdSales,
	sales_amount - FIRST_VALUE(sales_amount) OVER(PARTITION BY department ORDER BY sales_month ASC) as difference_current_first
FROM employee_sales;
GO 
--https://www.sqlshack.com/an-overview-of-analytic-functions-in-sql-server/
--Taking name of employee from each department that the most sales:
SELECT *,
	FIRST_VALUE(employee_name) OVER(PARTITION BY department ORDER BY sales_amount DESC) as FirstValueBasedOnArguments
FROM employee_sales;
GO 
--Taking the sales_month where employees from each department sell the most
SELECT *,
	FIRST_VALUE(sales_month) OVER(PARTITION BY department ORDER BY sales_amount DESC) FirstValueBasedOnArg
FROM employee_sales;
GO 
--https://www.red-gate.com/simple-talk/databases/sql-server/t-sql-programming-sql-server/introduction-to-t-sql-window-functions/ 
--FirstName based on the earliest date
SELECT 
	*,
	FIRST_VALUE(employee_name) OVER(PARTITION BY employee_id ORDER BY sales_month ASC) AS FirstEmployeeName,
	FIRST_VALUE(employee_name) OVER(PARTITION BY employee_id ORDER BY sales_month ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS FirstValueEmployeeName2
FROM employee_sales;
GO  
--LastName based on the latest date
SELECT 
	*,
	FIRST_VALUE(employee_name) OVER(PARTITION BY employee_ID ORDER BY sales_month DESC) as FirstValueEmployeeName,
	FIRST_VALUE(employee_name) OVER(PARTITION BY employee_ID ORDER BY sales_month DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as FirstValueEmployeeName2
FROM employee_sales;
GO
--https://learnsql.com/blog/common-sql-window-functions-positional-functions/ FIRST_VALUE()
--Taking biggest sales volumne first for employee (name and id) for each department
SELECT 
	*,
	FIRST_VALUE(employee_name) OVER(PARTITION BY department ORDER BY sales_amount DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as EmployeeFromDepMostSales,
	FIRST_VALUE(employee_id) OVER(PARTITION BY department ORDER BY sales_amount DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as IdFromDepMostSales
FROM employee_sales;
GO
--Taking biggest sales volumne first for employee (name and id) for each month
SELECT 
	*,
	MONTH(sales_month) as month,
	FIRST_VALUE(employee_name) OVER(PARTITION BY MONTH(sales_month) ORDER BY sales_amount DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as FirstNameForSales,
	FIRST_VALUE(employee_id) OVER(PARTITION BY MONTH(sales_month) ORDER BY sales_amount DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as FirstNameForSales
FROM employee_sales;
GO
--https://www.sqltutorial.org/sql-window-functions/ FIRST_VALUE()




--https://learnsql.com/blog/sql-first-value-function/ 


--FIRST_VALUE & LAST_VALUE + framing 
--https://learnsql.com/blog/sql-window-functions-explanation/