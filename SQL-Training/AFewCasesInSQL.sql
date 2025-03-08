SELECT 'a' as A, 22 as B
--
WITH cte AS (
    SELECT * FROM (
        VALUES
            ('a', 1),
			('a', 2),
            ('a', 3),

			('b', 2),
			('b', 4),
            ('b', 8),

			('c', 3),
			('c', 6),
            ('c', 9),

			('d', 4),
			('d', 16),
            ('d', 64)
        ) AS a (name, value))
SELECT name, value , sum(value) OVER() as rn
FROM cte 
--
WITH cte AS (
    SELECT * FROM (
        VALUES
            ('a'),
			('b'),
			('c'),
			('d')
        ) AS a (name))
SELECT name, rank() over(ORDER BY name) as rn
FROM cte 
ORDER BY name DESC 

--
WITH cte AS (
    SELECT * FROM (
        VALUES
            ('a', 1),
			('a', 2),
            ('a', 3),
			('a', 1),
			('b', 2),
			('b', 4),
            ('b', 8),
			('c', 3),
			('c', 6),
            ('c', 9),
			('d', 4),
			('d', 16),
            ('d', 64),
			('e', 1),
			('e', 2),
            ('e', 3),
			('e', 1),
			('f', 10)
	--		('f',20)
        ) AS a (name, value))
SELECT name, sum(value) as Amount
FROM cte 
GROUP BY name 
HAVING count(*)> 1
--Look at f

--
WITH cte AS (
    SELECT * FROM (
        VALUES
            ('a', 1, '2024-12-10'), --2
			('a', 2, '2024-12-09'), --1
			('b', 2, '2024-12-07'),--2
			('b', 4, '2024-12-06'), --1 
			('c', 3, '2024-12-01'),-- 1
			('c', 6, '2024-12-02'),--2
			('d', 4, '2024-12-14'), --1
			('d', 16, '2024-12-15')-- 2
        ) AS a (name, value, date))
SELECT name, value, date, ROW_NUMBER() OVER (PARTITION BY name ORDER BY date) as rn 
FROM cte 
ORDER BY name, value     

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
ORDER BY PostalCode DESC;
GO