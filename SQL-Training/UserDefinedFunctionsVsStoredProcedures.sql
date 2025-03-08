--1. User Defined Functions 
--1a) scalar-valued user defined function, 
--1b) an inline table-valued function,
--1c) a multi-statement table-valued function
--https://learn.microsoft.com/en-us/sql/relational-databases/user-defined-functions/user-defined-functions?view=sql-server-ver16
--https://learn.microsoft.com/en-us/sql/relational-databases/user-defined-functions/create-user-defined-functions-database-engine?view=sql-server-ver16
--https://learn.microsoft.com/en-us/sql/t-sql/statements/create-function-transact-sql?view=sql-server-ver16
--https://stackoverflow.com/questions/1179758/function-vs-stored-procedure-in-sql-server
--https://www.sqlservertutorial.net/sql-server-user-defined-functions/sql-server-table-valued-functions/
--https://database.guide/difference-between-multi-statement-table-valued-functions-inline-table-valued-functions-in-sql-server/ 
--https://cloud.google.com/bigquery/docs/table-functions


--User defined function - A user-defined function accepts parameters, 
--performs an action such as a complex calculation,
--and returns the result of that action as a value.
--The return value can either be a scalar (single) value or a table.
--A scalar function is a function that returns one value per invocation; 
--in most cases, you can think of this as returning one value per row. 
--This contrasts with Aggregate functions, which return one value per group of rows.
--Deterministic functions always return the same result any time they're called with a specific set of input values and given the same state of the database.
--AVG() -the function AVG always returns the same result given the qualifications stated above
--Nondeterministic functions may return different results each time they're called with a specific set of input values event if the database state that they access remains the same
--GETDATE() function is non deterministic functions- it returns the current datetime value, always returns a different result.
--

--A table function, also called a table-valued function (TVF),
--is a user-defined function that returns a table. 
--You can use a table function anywhere that you can use a table.
--Table functions behave similarly to views, but a table function can take parameters.
--We typically use table-valued functions as parameterized views. 
--In comparison with stored procedures, the table-valued functions are more flexible because we can use them wherever tables are used.


CREATE DATABASE FunctionsVsStoredProcedure;
GO

CREATE SCHEMA TrainingFunctions;
GO

USE FunctionsVsStoredProcedure;




DROP TABLE IF EXISTS TrainingFunctions.Employers;
GO

CREATE TABLE TrainingFunctions.Employers (
	Name nvarchar(255),
	Surname nvarchar(255),
	Age int,
	Salary decimal(18,2)
);
GO
--
DROP TABLE IF EXISTS TrainingFunctions.Employers2;
GO

CREATE TABLE TrainingFunctions.Employers2 (
	Name nvarchar(255),
	Surname nvarchar(255),
	Age int,
	Salary decimal(18,2)
);
GO

INSERT INTO TrainingFunctions.Employers
VALUES ('Lukasz','Lukaszewski',20,13000), 
('Adam','Nowakowski',18,10000), 
('Ewelina','Ewelinowski',25,12000), 
('Monika','Dabrowski',27,12313), 
('Gosia','Malecki',31,19211), 
('Ola','SugaBuga',56,243111);
GO
--

INSERT INTO TrainingFunctions.Employers2
VALUES ('Henryk','Henrykowski',20,16000), 
('Marcin','Cebula',32,13000), 
('Andrzej','Kozdojek',12,114000), 
('Damian','Walczusia',53,136313), 
('Marcel','Adamski',23,11211), 
('Ewa','Pumpel',11,643111);
GO

SELECT * 
FROM TrainingFunctions.Employers;
GO

SELECT * 
FROM TrainingFunctions.Employers2;
GO

--1. USER DEFINED FUNCTION
DROP FUNCTION IF EXISTS TrainingFunctions.ConvertToCents;
GO

CREATE FUNCTION TrainingFunctions.ConvertToCents(@Salary decimal(18,2))
RETURNS decimal(18,2) 
AS
BEGIN 
	DECLARE @ret decimal;
	SELECT @ret = @Salary * 100
	FROM TrainingFunctions.Employers

RETURN @ret
END; 
GO

SELECT * ,TrainingFunctions.ConvertToCents(Salary) as ConvertToCents
FROM TrainingFunctions.Employers


--2. Table-Valued User-Defined Functions
--A table-valued function is a user-defined function that returns data of a table type.
--The return type of a table-valued function is a table, 
--therefore, you can use the table-valued function just like you would use a table.

-- CREATE an inline table-valued functions:
DROP FUNCTION IF EXISTS TrainingFunctions.InlineTableValuedFunctionsEmployerOlderThan20;
GO
--
CREATE FUNCTION TrainingFunctions.InlineTableValuedFunctionsEmployerOlderThan20 (@age int)
RETURNS TABLE 
AS 
RETURN (
		SELECT * 
		FROM TrainingFunctions.Employers 
		WHERE Age > @age
	UNION ALL
		SELECT * 
		FROM TrainingFunctions.Employers2
		WHERE Age > @age
);
GO 

SELECT *,TrainingFunctions.ConvertToCents(Salary) as SalaryToCents
FROM TrainingFunctions.InlineTableValuedFunctionsEmployerOlderThan20(20);
GO

--A multi-statement table-valued function or MSTVF is a table-valued function that returns the result of multiple statements.
--The multi-statement-table-valued function is very useful
--because you can execute multiple queries within the function and aggregate results into the returned table.
--CreateMulti-Statment Table-Valued Function
DROP FUNCTION IF EXISTS TrainingFunctions.udfCustomer;
GO


CREATE FUNCTION TrainingFunctions.udfCustomer(@Salary decimal(18,2))
RETURNS @customers TABLE (
	FirstName nvarchar(100),
	SecondName nvarchar(100),
	Name nvarchar(100),
	Origin nvarchar(100)
	)
AS BEGIN 
	INSERT INTO @customers
	SELECT 
		Name,
		Surname,
		CONCAT(Name, ' ', Surname),
		'Employer1'
	FROM TrainingFunctions.Employers
	WHERE Salary > @Salary;

	INSERT INTO @customers
	SELECT 
		Name,
		Surname,
		CONCAT(Name, ' ', Surname),
		'Employer2'
	FROM TrainingFunctions.Employers2
	WHERE Salary > @Salary;

	RETURN;
END;
GO
--
SELECT *
FROM TrainingFunctions.udfCustomer(1);
GO
--
SELECT *
FROM TrainingFunctions.udfCustomer(100000);
GO
--The main benefit of the multi-statement table-valued functions enables us to modify the return/output table
--in the function body so that we can generate more complicated resultset.
--Table-Valued Function is a good alternative for a view or an extra table when parameterization is needed or complex logic is included
--and especially when the amount of data returning from the function is relatively small.
--ITVF is faster than MSTVF. We can use CTE in MSTVF1


--2. STORED PROCEDURE - 
--https://learn.microsoft.com/pl-pl/sql/t-sql/statements/create-procedure-transact-sql?view=sql-server-ver16
--https://www.datacamp.com/tutorial/sql-stored-procedure
--A stored procedure in SQL Server is a group of one or more Transact-SQL statements, 
--Procedures resemble constructs in other programming languages because they can:
--a) Accept input parameters and return multiple values in the form of output parameters to the calling program.
--b) Contain programming statements that perform operations in the database. These include calling other procedures.
--c) Return a status value to a calling program to indicate success or failure (and the reason for failure).
--A SQL Stored Procedure is a collection of SQL statements bundled together to perform a specific task.
--These procedures are stored in the database and can be called upon by users, applications, or other procedures.
--Stored procedures are essential for automating database tasks, improving efficiency, and reducing redundancy.
--By encapsulating logic within stored procedures,
--developers can streamline their workflow and enforce consistent business rules across multiple applications and systems.

--1. Simple SP

CREATE SCHEMA TrainingSP;
GO

DROP TABLE IF EXISTS TrainingSP.Employers;
GO

CREATE TABLE TrainingSP.Employers (
	Name nvarchar(255),
	Surname nvarchar(255),
	City nvarchar(255),
	Age int,
	Salary decimal(18,2)
);
GO

INSERT INTO TrainingSP.Employers
VALUES ('Lukasz','Lukaszewski','Lodz',20,13000), 
('Adam','Nowakowski','Lodz',18,10000), 
('Ewelina','Ewelinowski','Warsaw',25,12000), 
('Monika','Dabrowski','Warsaw',27,12313), 
('Gosia','Malecki','Poznan',31,19211), 
('Ola','SugaBuga','Poznan',56,243111);
GO

SELECT *
FROM TrainingSP.Employers

--SP with input parameters
CREATE OR ALTER PROCEDURE TrainingFunctions.ShowCustomerFromSpecifiedCity
	@Country VARCHAR(50)
AS 
BEGIN 
	SELECT *
	FROM TrainingSP.Employers
	WHERE City = @Country;
END;
GO

EXEC TrainingFunctions.ShowCustomerFromSpecifiedCity @Country ='Lodz';
GO

CREATE OR ALTER PROCEDURE TrainingFunctions.InsertCustomer
	@Name VARCHAR(50),
	@Surname VARCHAR(50),
	@City VARCHAR(50),
	@Age int,
	@Salary decimal(18,2)
AS 
BEGIN 
	INSERT INTO TrainingSP.Employers 
	VALUES (@Name, @Surname, @City, @Age, @Salary);
	
	SELECT *
	FROM TrainingSP.Employers;

END;
GO

EXEC TrainingFunctions.InsertCustomer @Name = 'Jerzy', @Surname = 'Grzegory', @City = 'Boleslawcow', @Age = 13,@Salary =213131;
GO

--Normal SP
CREATE OR ALTER PROCEDURE TrainingFunctions.RemoveCustomer
AS 
BEGIN 
	DELETE FROM TrainingSP.Employers 
	WHERE Name = 'Jerzy'

	SELECT *
	FROM TrainingSP.Employers;

END;
GO

EXEC TrainingFunctions.RemoveCustomer;
GO

--SP with output parameters
--https://learn.microsoft.com/en-us/previous-versions/sql/sql-server-2008-r2/ms187004(v=sql.105)?redirectedfrom=MSDN

USE AdventureWorks2019;

DROP PROCEDURE IF EXISTS Sales.uspGetEmployeeSalesYTD;
GO

CREATE OR ALTER PROCEDURE Sales.uspGetEmployeeSalesYTD @SalesPerson nvarchar(50),
    @SalesYTD money OUTPUT AS
SET
    NOCOUNT ON;

SELECT
    @SalesYTD = SalesYTD
FROM
    Sales.SalesPerson AS sp
    JOIN HumanResources.vEmployee AS e ON e.BusinessEntityID = sp.BusinessEntityID
WHERE
    LastName = @SalesPerson;

RETURN
GO
    -- Declare the variable to receive the output value of the procedure.
    DECLARE @SalesYTDBySalesPerson money;

-- Execute the procedure specifying a last name for the input parameter
-- and saving the output value in the variable @SalesYTDBySalesPerson
EXECUTE Sales.uspGetEmployeeSalesYTD N'Blythe',
@SalesYTD = @SalesYTDBySalesPerson OUTPUT;

-- Display the value returned by the procedure.
PRINT 'Year-to-date sales for this employee is ' + convert(varchar(10), @SalesYTDBySalesPerson);

GO


SELECT *
FROM [HumanResources].[vEmployee]
WHERE LastName ='Blythe';
GO 

--So basically if you would like your stored procedure to just return just a value instead of a data set,
--you could use the output parameter.
--Output parameters in stored procedures are useful for passing a value back to the calling T-SQL,
--which can then use that value for other things.

USE FunctionsVsStoredProcedure;
GO


CREATE OR ALTER PROCEDURE TrainingFunctions.SPWithOutparameters (
	@row_count INT OUTPUT,
	@city nvarchar(255)
) AS 
BEGIN 
	SELECT @row_count = COUNT(*) 
	FROM TrainingSP.Employers;

	SELECT *
	FROM TrainingSP.Employers
	WHERE City = @city 

END;
GO

DECLARE @count INT;

EXEC TrainingFunctions.SPWithOutparameters @row_count = @count OUTPUT, @city = 'Lodz'

SELECT @count AS 'Number of total rows in the table'
PRINT 'Total number of rows' + ' ' + convert(varchar(10), @count);


--Difference between SP and function:
--https://stackoverflow.com/questions/1179758/function-vs-stored-procedure-in-sql-server
--https://www.scholarhat.com/tutorial/sqlserver/difference-between-stored-procedure-and-function-in-sql-server
--https://www.shiksha.com/online-courses/articles/stored-procedure-vs-function-what-are-the-differences/
--Functions follow the computer-science definition in that they MUST return a value and cannot alter the data 
--they receive as parameters (the arguments). Functions are not allowed to change anything,
--must have at least one parameter, and they must return a value.
--Stored procs do not have to have a parameter, can change database objects, and do not have to return a value.