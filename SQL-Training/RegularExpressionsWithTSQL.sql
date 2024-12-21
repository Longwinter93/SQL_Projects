-- REGEX
--Basic Regular Expression Syntax/Common RegEx Patterns
--https://www.mssqltips.com/sqlservertip/3341/powershell-and-tsql-regular-expression-examples-for-sql-server/
--https://www.atlassian.com/data/sql/how-regex-works-in-sql
--https://coderpad.io/blog/development/the-complete-guide-to-regular-expressions-regex/
--https://learn.microsoft.com/en-us/sql/t-sql/language-elements/like-transact-sql?view=sql-server-ver16
--A Regular Expression (or Regex) is a pattern (or filter) that describes a set of strings that matches the pattern.
--In other words, a regex accepts a certain set of strings and rejects the rest.
--A wildcard character is used to substitute one or more characters in a string. 
--Wildcard characters are used with the LIKE operator.
--The LIKE operator is used in a WHERE clause to search for a specified pattern in a column.
--https://www.sqlshack.com/t-sql-regex-commands-in-sql-server/
--https://www.mssqltips.com/sqlservertutorial/9106/using-regular-expressions-with-t-sql-from-beginner-to-advanced/

--1.https://www.sqlshack.com/t-sql-regex-commands-in-sql-server/
USE [AdventureWorks2019];
--1. Output contains rows with first character A or L:
SELECT [Description]
FROM [AdventureWorks2019].[Production].[ProductDescription]
WHERE [Description] LIKE '[AL]%'

--Records with first character A and second characters L
SELECT [Description]
FROM [AdventureWorks2019].[Production].[ProductDescription]
WHERE [Description] LIKE '[A][L]%'
--Records with first character A and second characters L and third characters L
SELECT [Description]
FROM [AdventureWorks2019].[Production].[ProductDescription]
WHERE [Description] LIKE '[A][L][L]%'
--It starts character from A and D
SELECT [Description]
FROM [AdventureWorks2019].[Production].[ProductDescription]
WHERE [Description] LIKE '[A-D]%'
ORDER BY 1 
--The first character should be from A and D alphabets, The second character should be from F and L alphabet
SELECT [Description]
FROM [AdventureWorks2019].[Production].[ProductDescription]
WHERE [Description] LIKE '[A-D][F-I]%'
ORDER BY 1 
--Ending character should be from G and S
SELECT [Description]
FROM [AdventureWorks2019].[Production].[ProductDescription]
WHERE [Description] LIKE '%[G-S]'
ORDER BY 1 
--Starting character should be A (first) and F (second),Ending character should be S
SELECT [Description]
FROM [AdventureWorks2019].[Production].[ProductDescription]
WHERE [Description] LIKE '[A][F]%[S]'
--We do not want the first character of output rows from A to T.
SELECT [Description]
FROM [AdventureWorks2019].[Production].[ProductDescription]
WHERE [Description] LIKE '[^A-T]%'
--The first character from R and S, then either P or I, any characters
SELECT [Description]
FROM [AdventureWorks2019].[Production].[ProductDescription]
WHERE [Description] LIKE '[R-S]%[P][I]%'
--We do not get case sensitive results
SELECT [Description]
FROM [AdventureWorks2019].[Production].[ProductDescription]
WHERE [Description] LIKE '[r-s]%[P][I]%'
--
DROP TABLE IF EXISTS Characters
Create table Characters
(Alphabet char(1))
GO

Insert into Characters values ('A')
Insert into Characters values ('a')
GO

SELECT * FROM Characters
--Case sensitive results to column collation 
select * from Characters 
where Alphabet COLLATE Latin1_General_BIN  like '[A]%'
--Case sensitive results to column collation 
select * from Characters 
where Alphabet COLLATE Latin1_General_BIN  like '[a]%'
--The first character should be uppercase character C,The second character should be lowercase character h
--Rest of the characters can be in any letter case
SELECT [Description]
FROM [AdventureWorks2019].[Production].[ProductDescription]
WHERE [Description] COLLATE Latin1_General_BIN LIKE '[C][h]%'
--Results with rows that contain number 0 to 9 in the beginning.
SELECT [Description]
FROM [AdventureWorks2019].[Production].[ProductDescription]
WHERE [Description] LIKE '[0-9]%'
--First digit from 1-5, the second digit should be in between 0 to 9
SELECT [Description]
FROM [AdventureWorks2019].[Production].[ProductDescription]
WHERE [Description] LIKE '[1-5][0-9]%'


--
DROP TABLE IF EXISTS TSQLREGEX
CREATE TABLE TSQLREGEX(
     Email VARCHAR(1000)
  )
 
Insert into TSQLREGEX values('raj@gmail.com')
Insert into TSQLREGEX values('HSDFX@gmail.com')
Insert into TSQLREGEX values('JHKHKO.PVS@gmail.com')
Insert into TSQLREGEX values('ABC@@gmail.com')
Insert into TSQLREGEX values('ABC.DFG.LKF#@gmail.com')
GO
-- Identify valid email address from the user data
SELECT * 
FROM TSQLREGEX
WHERE [Email] LIKE '%[A-Z0-9][@][A-Z0-9]%[.][A-Z0-9]%'
--https://www.mssqltips.com/sqlservertip/3341/powershell-and-tsql-regular-expression-examples-for-sql-server/
USE AdvancedSQLForDataProfessionals;

DROP TABLE IF EXISTS TSQL_RegExTable
CREATE TABLE TSQL_RegExTable(
 RegExColumn VARCHAR(100)
)

INSERT INTO TSQL_RegExTable
VALUES ('1 The quick brown fox jumped over the lazy dogs.')
 , ('The quick brown fox jumped over the lazy dogs.')
 , ('This sentence does not have every letter of the alphabet.')
 , ('123777')
 , ('@you')
 , ('IsThisAnEmailAddress@YouBet.com')
 , ('*and')
 , ('One')
 , ('One1')
 , ('m')
 , ('4')
 , ('-')
 -- How many rows have one alpha character?
 SELECT * 
 FROM TSQL_RegExTable
 WHERE RegExColumn LIKE '[a-z]'
 -- How many rows have only one alpha character in between h and j?
  SELECT * 
 FROM TSQL_RegExTable
 WHERE RegExColumn LIKE '[h-j]'
 -- How many rows start with any alpha character?
 SELECT * 
 FROM TSQL_RegExTable
 WHERE RegExColumn LIKE '[a-z]%'
 -- How many rows have an alpha character somewhere in them?
 SELECT * 
 FROM TSQL_RegExTable
 WHERE RegExColumn LIKE '%[a-z]%'
-- How many rows have the alpha character z somewhere in them?
 SELECT * 
 FROM TSQL_RegExTable
 WHERE RegExColumn LIKE '%[z]%'
 ---- How many rows have do not start with an alpha character?
 SELECT * 
 FROM TSQL_RegExTable
 WHERE RegExColumn LIKE '[^a-z]%'
 -- How many rows have only one numeric character?
  SELECT * 
 FROM TSQL_RegExTable
 WHERE RegExColumn LIKE '[0-9]'
 ---- How many rows have only one numeric character between 7 and 8?
SELECT * 
FROM TSQL_RegExTable
WHERE RegExColumn LIKE '[7-8]'
-- How many rows start with any numeric character?
SELECT * 
FROM TSQL_RegExTable
WHERE RegExColumn LIKE '[0-9]%'
-- How many rows have any numeric character in them?
SELECT * 
FROM TSQL_RegExTable
WHERE RegExColumn LIKE '%[0-9]%'
---- How many rows have do not start with a numeric character?
SELECT * 
FROM TSQL_RegExTable
WHERE RegExColumn LIKE '[^0-9]%'
-- How many rows start with the character @ or -?
SELECT * 
FROM TSQL_RegExTable
WHERE RegExColumn LIKE '[@-]%'
-- How many rows have an @ or - character in them?
SELECT * 
FROM TSQL_RegExTable
WHERE RegExColumn LIKE '%[@-]%'
-- How many rows have neither one alpha nor one numeric character?
SELECT * 
FROM TSQL_RegExTable
WHERE RegExColumn LIKE '[^0-9a-z]'
--

DROP TABLE IF EXISTS SSNTable
CREATE TABLE SSNTable(
 SSN VARCHAR(11),
 TextField VARCHAR(500)
)

INSERT INTO SSNTable
VALUES ('000-00-0000','The quick brown fox 000-00-0000 jumped over the lazy dogs.')
 , ('000-00-0001','000-00-0001 The quick brown fox jumped over the lazy dogs.')
 , ('000-00-0002',' The quick brown fox jumped over the lazy dogs. 000-00-0002')
 , ('000000003',' The quick brown fox jumped over the 000.00.0002 lazy dogs.')

 SELECT *
 FROM SSNTable

 --How many SSN values of nine digits in a row?
SELECT *
FROM SSNTable
WHERE SSN LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
-- How many SSNs with three digits, a dash, two digits, a dash, and four digits?
SELECT *
FROM SSNTable
WHERE SSN LIKE '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'
-- How many TextFields with three digits, a dash, two digits, a dash, and four digits only?
SELECT *
FROM SSNTable
WHERE TextField LIKE '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'
-- How many TextFields with three digits, a dash, two digits, a dash, and four digits somewhere in them?
SELECT *
FROM SSNTable
WHERE TextField LIKE '%[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]%'
-- How many TextFields with three digits, a non digit, two digits, a non digit, and four digits somewhere in them?
SELECT *
FROM SSNTable
WHERE TextField LIKE '%[0-9][0-9][0-9][^0-9][0-9][0-9][^0-9][0-9][0-9][0-9][0-9]%'

 --https://www.mssqltips.com/sqlservertutorial/9106/using-regular-expressions-with-t-sql-from-beginner-to-advanced/

DROP TABLE IF EXISTS  alphareg
CREATE TABLE alphareg
	(Alphabetic VARCHAR(8000))
 
INSERT INTO alphareg 
VALUES ('Two plus two equals four.')
   , ('But in Rome we must toe the line of fashion, spending beyond our means, and often on borrowed credit.')
   , ('Most dogs sleep 21 hours a day.')
   , ('2')
   , ('We were going to work on the project together, but he had to leave for basic training early.')
   , ('This SENTENCE is NOT written weLl.') 
   , ('Or as Alexander Suvorov would say, "When the training is hard, the fighting is easy."')
   , ('1812! The year of invasions.  Let me tell ya''.') 
   , ('This SENTENCE is NOT written weLl.') 
   , ('A')
   , ('b')
   , ('oooh, this isn''t written WRIGHT in several ways')
   , ('BD')
   , ('As he said this, Cupid sneezed approval on the left as before on the right.')
   , ('I like adverbs.')
   , ('Five?')
   , ('I''m going to the store right now.')
   , ('TWO')
   , ('"Yes"')
   , ('willful waste makes woeful waste')
 
SELECT *
FROM alphareg 

--Regex to Find Where Data is Only One Character and Value is from A to Z
SELECT *
FROM alphareg 
WHERE Alphabetic LIKE '[A-Z]'
--Regex to Find Where Data is Only One Character and Value is from C to D
SELECT *
FROM alphareg 
WHERE Alphabetic LIKE '[C-D]'
--Regex to Find Where Data is Two Characters and Values are from A to Z
SELECT *
FROM alphareg 
WHERE Alphabetic LIKE '[A-Z][A-Z]'
--Regex to Find Where Data is Any Length and First Character has a Value from A to Z
SELECT *
FROM alphareg 
WHERE Alphabetic LIKE '[A-Z]%'
--Geting all the data rows of any character length that start with the alphabetic characters of B.
SELECT *
FROM alphareg 
WHERE Alphabetic LIKE '[B]%'
--Looking for data rows with 2 alphabetic characters in the range of A through D for each character.
SELECT *
FROM alphareg
WHERE Alphabetic LIKE '[A-D][A-D]'
-- first character being a T and the second character being either an A or W.
SELECT *
FROM alphareg
WHERE Alphabetic LIKE '[T][AW]%' --[AW] means the “second character is either an A or W.” 
--
--Any characters are allowed at first (initial %),
--Then a T is required [T] in the second character ,
--Then a H or W is required [HW] in third character,
--Then a O or R is required [OR] in fourth character,
--Then a E or space is required [E ] in fifth character,
--And then any character is allowed after that (last %)
SELECT *
FROM alphareg
WHERE [Alphabetic] LIKE '%[T][HW][OR][E ]%'
--The first data is A 
--while allowing anything else while also requiring that 
--we find a two or three with anything else also ending the string
SELECT *
FROM alphareg
WHERE [Alphabetic] LIKE '[A]%[HW][OR][E ]%'
--Any alphabetic combination in the first character [A-Z]
--With any combination after that %
--And then require a T character [T]
--Followed by either an H or W [HW]
--Followed by any other character %.
SELECT *
FROM alphareg
WHERE [Alphabetic] LIKE '[A-Z]%[T][HW]%'

--Two of our data rows from the fourth query have “this” 
--in them with “this” being a word in the sentence,
--not starting the sentence. 
--How would you write the fourth query to only return
--“this” as a word in a sentence (not beginning it)
SELECT *
FROM alphareg
WHERE [Alphabetic] LIKE '[^T]%[T][H][I][S]%'
--
SELECT *
FROM alphareg
WHERE [Alphabetic] LIKE '%[T][H][I][s]%'
--
--Regex Case Sensitivity
--database is not case sensitive:
SELECT *
FROM alphareg
WHERE Alphabetic LIKE '[A-Z]'
--
SELECT *
FROM alphareg
WHERE Alphabetic LIKE '[a-z]' 
--Case sensitivity:
SELECT *
FROM alphareg
WHERE Alphabetic COLLATE Latin1_General_BIN LIKE '[A-Z]'
 --
SELECT *
FROM alphareg
WHERE Alphabetic COLLATE Latin1_General_BIN LIKE '[a-z]'   
--first characters are lower case – and search for any combination of upper case characters.
SELECT *
FROM alphareg
WHERE Alphabetic COLLATE Latin1_General_BIN LIKE '[a-z]%[A-Z]%'   
--Upper Case or Lower Case Characters the first character 
SELECT *
FROM alphareg
WHERE Alphabetic COLLATE Latin1_General_BIN LIKE '[A-Za-z]%[A-Z]%'
--Numeric Regex

DROP TABLE IF EXISTS alphanumreg
CREATE TABLE alphanumreg(
   NumData DECIMAL(15,4),
   NumInt SMALLINT,
   AlphabeticNum VARCHAR(25)
)
 
INSERT INTO alphanumreg
VALUES (22,22,'22')
   , (21.4,21,'21.4')
   , (40.05,40,'40.05')
   , (67,67,'67')
   , (1,1,'1')
   , (1.00,1,'1.00')
   , (121.23,121,'e1213')
   , (33.2341,33,'33.2341')
   , (33.2341,33,'33.2341')
   , (-1.09,-1,'-1.09')
   , (NULL,NULL,'22-E1-9')
   , (NULL,NULL,'11-EA-0')
   , (NULL,NULL,'04-E2-9')
   , (NULL,NULL,'10-E1-7')
   , (NULL,NULL,'106-E1-700')
   , (NULL,NULL,'3-E6-9365')
   , (NULL,NULL,'31-A2-4')
   , (NULL,NULL,'3723812695735285')
   , (NULL,NULL,'IX7254017')
   , (NULL,NULL,'4019638561283650')
GO

SELECT * FROM alphanumreg
WHERE NumData LIKE '[2-5]%'

SELECT * FROM alphanumreg
WHERE NumInt LIKE '[2-5]%'

SELECT * FROM alphanumreg
WHERE AlphabeticNum LIKE '[2-5]%'

--Look at our alphareg table to see if any rows start with any range of numbers 0 through 9
SELECT * 
FROM alphareg
WHERE Alphabetic   LIKE '[0-9]%'
--check for a data row that has a numerical character of any range anywhere in the table alphareg
SELECT * 
FROM alphareg
WHERE Alphabetic LIKE '%[0-9]%'
-- looking for values that only have two digits:
SELECT *
FROM alphanumreg
WHERE NumData   LIKE '[0-9][0-9]'

SELECT *
FROM alphanumreg
WHERE NumInt    LIKE '[0-9][0-9]'

SELECT *
FROM alphanumreg
WHERE AlphabeticNum    LIKE '[0-9][0-9]'

--How many rows of the decimal data start with either a two or a three?
SELECT *
FROM alphanumreg
WHERE NumData LIKE '[2-3]%'
--Complex Numeric Regex
-- column NumData that start with either a 2 or 3 and have any other character following it,
--but also have a 1 or 5 somewhere else in the data.
SELECT *
FROM alphanumreg
WHERE NumData LIKE '[2-3]%[15]%'
--In first query below this, we want any number with two decimal places only for the AlphabeticNum column. 
SELECT *
FROM alphanumreg
WHERE AlphabeticNum LIKE '%[.][0-9][0-9]'
--In the second query we want the same except three decimal places only for the AlphabeticNum column. 
SELECT *
FROM alphanumreg
WHERE AlphabeticNum LIKE '%[.][0-9][0-9][0-9]'
--In the third query we want any number with at least two decimal places for the AlphabeticNum column.
SELECT *
FROM alphanumreg
WHERE AlphabeticNum LIKE '%[.][0-9][0-9]%'
--Look for negative values:
SELECT NumData
FROM alphanumreg
WHERE NumData LIKE '[-]%'

SELECT NumInt
FROM alphanumreg
WHERE NumInt LIKE '[-]%'

SELECT AlphabeticNum
FROM alphanumreg
WHERE AlphabeticNum LIKE '[-]%'
--Look for a specific pattern
SELECT AlphabeticNum
FROM alphanumreg
WHERE AlphabeticNum LIKE '[0-9][0-9][-][A-Z][0-9][-][0-9]'
--
SELECT AlphabeticNum
FROM alphanumreg
WHERE AlphabeticNum LIKE '[0-9][0-9][-][E-F][0-9][-][0-9]'

--write a regular expression query that looks for 3 first characters of any digit 0 through 9,
--followed by two alphabetic characters E through H, 
--followed by another numerical character 7 through 9.
SELECT AlphabeticNum
FROM alphanumreg
WHERE AlphabeticNum LIKE '[0-9][0-9][0-9]-[E-H][0-9]-[7-9]%'


--Regex for Special Characters
--Look for  data row with one special character of an exclamation point [!]
SELECT *
FROM alphareg
WHERE Alphabetic LIKE '[!]'
--Look for any special character of an exclamation point in any data row anywhere.
SELECT *
FROM alphareg
WHERE Alphabetic LIKE '%[!]%'
--Getting  all the data rows that have punctuation characters
--in them staring with the most common of comma, period, exclamation point, question mark, semicolon and colon.

SELECT *
FROM alphareg
WHERE Alphabetic LIKE '%[,.!?;:]%'
--How many sentences had a special character then a letter right after it (no spaces)?
SELECT *
FROM alphareg
WHERE Alphabetic LIKE '%[,.!?;:][A-Z]%'
--we can also check if we have a special punctuation character, followed by a space,
--followed by any character, followed by an alphabetic character.
SELECT *
FROM alphareg
WHERE Alphabetic LIKE '%[,.!?;:][ ]%[A-Z]%'
--Do any sentences have the special character of ” in our alphareg table
SELECT *
FROM alphareg
WHERE Alphabetic LIKE '%[”]%'


--Regex for Exclude Characters
--Finding all of our data rows from the alphareg table that started with any special character
SELECT *
FROM alphareg
WHERE Alphabetic LIKE '[^A-Z]%'

--Finding any of our data rows from our alphanumreg table where the column AlphabeticNum started with a non-numerical character 
SELECT AlphabeticNum
FROM alphanumreg
WHERE AlphabeticNum LIKE '[^0-9]%'

-- Excluding all the alphabetic and numerical character
SELECT *
FROM alphareg
WHERE Alphabetic LIKE '[^0-9a-z]%' 

--Looking for sentences that start with any alphabetic character, 
--Ending with any alphabetic character or period, and have a special character within them.
SELECT *
FROM alphareg
WHERE Alphabetic LIKE '[A-Z]%[^0-9a-z ]%[a-z.]%' 
--This query also highlights that spaces are considered special characters
INSERT INTO alphareg VALUES ('  space  space  ')

SELECT *
FROM alphareg
WHERE Alphabetic LIKE '[^A-Z0-9]%[^A-Z0-9]%[^A-Z0-9]'

--In some situations, we may not want a space or another special character, 
--so we can include the special character that we want to exclude in our not regular expression,
--such as [^A-Z0-9 ] to exclude a space.
--We want all special characters, except commas.  How would we write that query?
SELECT *
FROM alphareg
WHERE Alphabetic LIKE '%[^A-Z0-9,]%'


--Regex Business Examples
DROP TABLE IF EXISTS tbBizExamples
CREATE TABLE tbBizExamples(
   BizVarchar VARCHAR(1000)
)
--
INSERT INTO tbBizExamples
VALUES ('2017-01-01 03:01:30.700')
   , ('2017-01-01')
   , ('2017-01-01 03:01')
   , ('http://dontexist.url/se2639de')
   , ('http://dontexist.url/dkek2284')
   , ('http://dontexist.url/82jdj392')
   , ('dontexistemail1@emaildomain.url')
   , ('dontexistemail2@emaildomain.url')
   , ('dontexistemail3@emaildomain.url')
   , ('4444 4444 4444 4444')
   , ('4444-4444-4444-4444')
   , ('4444x4444x4444x4444')
   , ('4444144441444414444')
--
INSERT INTO tbBizExamples
SELECT Alphabetic
FROM alphareg   

--
SELECT *
FROM tbBizExamples
--Look for dates in the format starting with YYYYXMMXDD where X is a separator of some kind,
--such as a space, dash, letter, or anything except a number.
--Finding dates in the following format of YYYYSeparatorMMSeparatorDDPossibleEnd
SELECT *
FROM tbBizExamples
WHERE BizVarchar LIKE '[1-2][0-9][0-9][0-9][^0-9][0-1][0-9][^0-9][0-3][0-9]%'
--Looking for a 16 digit credit card that begins with a number from 1 to 6 as a possibility 
--follows the format of a separator between each set of 4 digits, with the separator not being a number.
SELECT *
FROM tbBizExamples
WHERE BizVarchar LIKE '[1-6][0-9][0-9][0-9][^0-9][0-9][0-9][0-9][0-9][^0-9][0-9][0-9][0-9][0-9][^0-9][0-9][0-9][0-9][0-9]' 

--Look at another possibility in these cases, by first ensuring the length is 19 using the LEN function 
--and requiring that the first three characters are numbers,
--with the first being 1 through 6 allowed, with the last three characters also being numbers,
--and in the middle there is at least three sets of characters that are also numbers.
SELECT *
FROM tbBizExamples
WHERE LEN(BizVarChar) = 19 
	AND BizVarChar LIKE '[1-6][0-9][0-9]%[0-9][0-9][0-9]%[0-9][0-9][0-9]'

--Look for SSN (Social Security Number) pattern:
SELECT *
FROM tbBizExamples
WHERE LEN(BizVarChar) = 11 
	AND BizVarChar LIKE '%[0-9][0-9][0-9][-][0-9][0-9][-][0-9][0-9][0-9][0-9]%'

--Looking for  Valid Phone Number Patterns with T-SQL
SELECT *
FROM tbBizExamples
WHERE REPLACE(BizVarchar,' ','') LIKE '%[0-9][0-9][0-9][^0-9][0-9][0-9][0-9][^0-9][0-9][0-9][0-9][0-9]%'
OR REPLACE(BizVarchar,' ','') LIKE '%[0-9][0-9][0-9][0-9][0-9][0-9][^0-9][0-9][0-9][0-9][0-9]%'
OR REPLACE(BizVarchar,' ','') LIKE '%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%'

--Looking for Valid URL Patterns with T-SQL

SELECT *
FROM tbBizExamples
WHERE BizVarchar LIKE '%[A-Z0-9][.][A-Z0-9]%[A-Z0-9][/][A-Z0-9]%'
--Looking for Valid Email Patterns with T-SQL
SELECT *
FROM tbBizExamples
WHERE BizVarchar LIKE '%[A-Z0-9][@][A-Z0-9]%[.][A-Z0-9]%'

--
INSERT INTO tbBizExamples
VALUES ('dontexistemail1 [at] emaildomain.url')
     , ('dontexistemail1 (at symbol) emaildomain.url')

SELECT *
FROM tbBizExamples

SELECT *
FROM tbBizExamples
WHERE BizVarchar LIKE '%[A-Z0-9][^A-Z0-9]%at%[^A-Z0-9][A-Z0-9]%[.][A-Z0-9]%'