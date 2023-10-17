-- NBA 2022-2023 NBA Player data cleaning project
SELECT *
FROM `myportfolio-401818.NBA.2022_23_Player_Salaries`

-- Getting rid of uneeded columns
CREATE TABLE `myportfolio-401818.NBA.2022_23_Player_Salaries_Cleaned` AS
SELECT string_field_1 AS Name, string_field_2 AS Team, string_field_3 AS Salary
FROM `myportfolio-401818.NBA.2022_23_Player_Salaries`

SELECT * 
FROM `myportfolio-401818.NBA.2022_23_Player_Salaries_Cleaned`

-- Dropping Rows that erroneously contain 'NAME' for Name column
DELETE FROM `myportfolio-401818.NBA.2022_23_Player_Salaries_Cleaned`
WHERE Name = 'NAME'

-- separating name and player position to create two columns
ALTER TABLE `myportfolio-401818.NBA.2022_23_Player_Salaries_Cleaned`
ADD COLUMN Position STRING;

SELECT Salary, Team,
SUBSTRING(Name, 1, STRPOS(Name, ',')-1) as Name
, SUBSTRING(Name, STRPOS(Name, ',')+1, LENGTH(Name)) as Position
FROM `myportfolio-401818.NBA.2022_23_Player_Salaries_Cleaned`


-- changing salary to int data type
SELECT CAST(REPLACE(SUBSTRING(Salary, STRPOS(Salary, '$')+1, LENGTH(Salary)), ',', '')AS INT64) AS Salary, Team,
SUBSTRING(Name, 1, STRPOS(Name, ',')-1) AS Name
, SUBSTRING(Name, STRPOS(Name, ',')+1, LENGTH(Name)) AS Position
FROM `myportfolio-401818.NBA.2022_23_Player_Salaries_Cleaned`
ORDER BY Salary DESC

-- Creating final cleaned table
CREATE OR REPLACE TABLE `myportfolio-401818.NBA.2022_23_Player_Salaries_Cleaned_For_Exploration`
AS
SELECT CAST(REPLACE(SUBSTRING(Salary, STRPOS(Salary, '$')+1, LENGTH(Salary)), ',', '')AS INT64) AS Salary, Team,
SUBSTRING(Name, 1, STRPOS(Name, ',')-1) AS Name
, SUBSTRING(Name, STRPOS(Name, ',')+1, LENGTH(Name)) AS Position
FROM `myportfolio-401818.NBA.2022_23_Player_Salaries_Cleaned`

SELECT *
FROM  `myportfolio-401818.NBA.2022_23_Player_Salaries_Cleaned_For_Exploration`
ORDER BY Salary DESC


