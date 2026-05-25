SELECT*
FROM[dbo].[Football Players]
WHERE [FIRST NAME] = 'sam'

truncate table[dbo].[Football Players]
	
	Questions
--1	 query to find all the players in the "Arizona" team.
SELECT*
FROM [dbo].[Football Players]
WHERE [TEAM] ='ARIZONA'

--2	 query to find all the players who play as a "WR" (Wide Receiver).
SELECT *
FROM [dbo].[Football Players]
WHERE [POSITION] LIKE 'WR'

--3	 query to list all players taller than 6 feet 2 inches.
SELECT *
FROM [dbo].[Football Players]
WHERE [HEIGHT] >= '6-2'
ORDER BY [HEIGHT] ASC

--4	 query to find all players who attended the "Washington" college.
SELECT *
FROM [dbo].[Football Players]
WHERE COLLEGE = 'WASHINGTON'

--5	 query to list players who are 25 years old or younger.
SELECT *
FROM [dbo].[Football Players]
WHERE AGE <= '25'

--6	 query to find all players with missing Age data.
SELECT *
FROM [dbo].[Football Players]
WHERE AGE IS NULL

--7	 query to find players who are rookies (Exp = 'R').
SELECT *
FROM [dbo].[Football Players]
WHERE EXPERIENCE LIKE 'R'

--8	 query to find the tallest player on the "New Orleans" team.
SELECT TOP(5)*
FROM [dbo].[Football Players]
WHERE TEAM = 'NEW ORLEANS'
ORDER BY HEIGHT DESC
--9	 query to find players weighing more than 250 pounds.
SELECT *
FROM [dbo].[Football Players]
WHERE WEIGHT >'250'
ORDER BY WEIGHT DESC
--10	 query to calculate the average height of players at each position.
SELECT POSITION, AVG([HT TOTAL]) AS [AVG HEIGHT]
FROM [dbo].[Football Players]
GROUP BY POSITION
ORDER BY [AVG HEIGHT] DESC

--SELECT  Position, AVG(CAST(SPLIT_PART(Height, '-', 1) AS INTEGER) * 12 + CAST(SPLIT_PART(Height, '-', 2) AS INTEGER)) AS Average_Height_Inches
--FROM [dbo].[Football players]
--GROUP BY Position

--11	 query to find the heaviest player for each position.
SELECT * 
	FROM
		(SELECT *, ROW_NUMBER() OVER(PARTITION BY POSITION ORDER BY WEIGHT DESC) AS WEIGHT_RANK 
		FROM [dbo].[Football players])
		[RANKED PLAYERS]
WHERE WEIGHT_RANK = 1


--SELECT POSITION, MAX(WEIGHT) [MAX WEIGHT]
--FROM [dbo].[Football Players]
--GROUP BY POSITION


--12	 query to rank players by age within their team. If two players have the same age, rank them by their weight.
SELECT *, RANK() 
OVER (PARTITION BY TEAM ORDER BY AGE DESC, WEIGHT DESC) AS AGE_RANK
FROM [dbo].[Football players]

--13	 query to calculate the average height (in inches) for all players older than 25 years.
SELECT AVG(CAST ([HT IN] AS FLOAT))
FROM [dbo].[Football players]
WHERE AGE > '25'

SELECT AVG([HT IN]) AS AVG_HEIGHT
FROM [dbo].[Football players]
WHERE AGE > '25'

SELECT*
FROM[dbo].[Football Players]

--14	 query to find all players whose height is greater than the average height of their respective team.
SELECT * 
	FROM(SELECT *, 
		AVG([HT TOTAL]) OVER(PARTITION BY TEAM ) AS [TEAM AVG HEIGHT] 
		FROM [dbo].[Football players])
		PLAYER_HEIGHT
WHERE [HT TOTAL] > [TEAM AVG HEIGHT]
ORDER BY TEAM, [HT TOTAL] DESC

--15	 query to find all players who share the same last name.
SELECT *
FROM [dbo].[Football players]
WHERE [LAST NAME] IN(
					SELECT [LAST NAME]
					FROM [dbo].[Football players]
					GROUP BY [LAST NAME]
					HAVING COUNT(*) >1
					)
ORDER BY [LAST NAME]

--16	 query to find the players with the minimum height for each position.
-- WINDOWS FUNCTION METHOD ( WHERE 'SHORTEST' IS A SUBQUERY ALIAS/ TEMPORARY NICKNAME)
SELECT *
	FROM
		(SELECT *, 
		RANK() OVER (PARTITION BY POSITION ORDER BY [HT TOTAL] ASC) AS MIN_HGT 
		FROM [dbo].[Football players]
		)
		SHORTEST
	WHERE MIN_HGT = 1

--CTE METHOD
WITH CTE AS(
	SELECT *, RANK() OVER (PARTITION BY POSITION ORDER BY [HT TOTAL] ASC) AS MIN_HGT
	FROM [dbo].[Football players]
	)
SELECT *
FROM CTE
WHERE MIN_HGT = 1

--17	 query to get the number of players for each team grouped by their experience level.
SELECT  TEAM,
		EXPERIENCE,
		COUNT(*) AS [PLAYER COUNT]
FROM [dbo].[Football players]
GROUP BY TEAM,EXPERIENCE 
ORDER BY TEAM DESC

--CASE STATEMENT
SELECT TEAM,
	CASE
		WHEN EXPERIENCE='R' THEN 'ROOKIE'
		WHEN EXPERIENCE BETWEEN 1 AND 4 THEN 'JUNIOR VETERAN'
		WHEN EXPERIENCE BETWEEN 5 AND 9 THEN 'VETERAN'
		ELSE 'ELITE VETERAN'
	END AS [EXP LEVEL], COUNT(*) AS [PLAYER COUNT]
FROM [dbo].[Football players]

GROUP BY TEAM,
	CASE
		WHEN EXPERIENCE = 'R' THEN 'ROOKIE'
		WHEN EXPERIENCE BETWEEN 1 AND 4 THEN 'JUNIOR VETERAN'
		WHEN EXPERIENCE BETWEEN 5 AND 9 THEN 'VETERAN'
		ELSE 'ELITE VETERAN'
	END
	ORDER BY TEAM, [PLAYER COUNT] DESC

--18	 query to find the tallest and shortest players from each college.
WITH CTE AS (
	SELECT COLLEGE, [PLAYER NAME],[HT TOTAL],
	RANK() OVER (PARTITION BY COLLEGE ORDER BY [HT TOTAL] DESC) AS TALLEST,
	RANK() OVER (PARTITION BY COLLEGE ORDER BY [HT TOTAL] ASC) AS SHORTEST
	FROM [dbo].[Football players] )

	SELECT COLLEGE, [
		PLAYER NAME],
		[HT TOTAL],
		CASE WHEN TALLEST=1 THEN 'TALLEST' ELSE 'SHORTEST'
	END AS STATUS
FROM CTE
WHERE TALLEST =1 OR SHORTEST = 1
ORDER BY COLLEGE, STATUS DESC


--19	 query to find all players whose weight is above the average weight for their respective position.
WITH CTE AS(
	SELECT TEAM,[PLAYER NAME],	POSITION,	[WEIGHT],	AGE, 	EXPERIENCE,
	AVG(WEIGHT) OVER(PARTITION BY POSITION) AS [POSITION AVG WEIGHT]
FROM [dbo].[Football players] )

SELECT TEAM,[PLAYER NAME], POSITION, [POSITION AVG WEIGHT],[WEIGHT], AGE, EXPERIENCE 
FROM CTE
WHERE WEIGHT > [POSITION AVG WEIGHT]
ORDER BY POSITION ASC

--20	query to calculate the percentage of players in each position for every team.
SELECT*
FROM[dbo].[Football Players]

SELECT TEAM, 
		POSITION, 
		COUNT(*) AS [PLAYER COUNT],
		CAST(COUNT(*) * 100/ SUM(COUNT(*)) OVER (PARTITION BY TEAM) AS DECIMAL(5,2)) AS PERCENTAGE
FROM [dbo].[Football players]
GROUP BY TEAM, POSITION
ORDER BY TEAM, PERCENTAGE DESC
