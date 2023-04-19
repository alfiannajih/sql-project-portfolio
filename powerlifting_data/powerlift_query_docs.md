# Documentation
This file contains the documenation, datasets, and query file. For the sake of datasets availability in this repository, I just attach partial datasets that consists only 50 rows out of 2887199 rows from the original datasets because of the limitation of space. However I still use the original datasets for querying in this documentation.
> This page uses data from the OpenPowerlifting project, https://www.openpowerlifting.org.
You may download a copy of the data at https://data.openpowerlifting.org. (accessed 15 April 2023).


## Table of Contents
1. [Data Preparation](#data_preparaion)
2. [Data Cleaning](#data_cleaning)
    1. [Check Duplicate Data](#duplicate_data)
    2. [Drop Irrelecant Columns](#irrelecant_columns)
    3. [Validate the Data Type](#validate_data_type)
    4. [Validate the Input Data](#validate_input)
        1. [age Column](#validate_age)
        2. [bodyweightkg Column](#validate_bodyweight)
3. [Case Study](#case_study)

# Data Preparation <a name=data_preparation></a>
Because the original data is in csv format, we will put it into our database. First we will create the table in our database.
```sql
CREATE TABLE powerlift_data(
   Name             VARCHAR
  ,Sex              VARCHAR
  ,Event            VARCHAR
  ,Equipment        VARCHAR
  ,Age              NUMERIC
  ,AgeClass         VARCHAR
  ,BirthYearClass   VARCHAR
  ,Division         VARCHAR
  ,BodyweightKg     NUMERIC
  ,WeightClassKg    VARCHAR
  ,Squat1Kg         NUMERIC
  ,Squat2Kg         NUMERIC
  ,Squat3Kg         NUMERIC
  ,Squat4Kg         VARCHAR
  ,Best3SquatKg     NUMERIC
  ,Bench1Kg         NUMERIC
  ,Bench2Kg         NUMERIC
  ,Bench3Kg         NUMERIC
  ,Bench4Kg         VARCHAR
  ,Best3BenchKg     NUMERIC
  ,Deadlift1Kg      NUMERIC
  ,Deadlift2Kg      NUMERIC
  ,Deadlift3Kg      NUMERIC
  ,Deadlift4Kg      VARCHAR
  ,Best3DeadliftKg  NUMERIC
  ,TotalKg          NUMERIC
  ,Place            VARCHAR
  ,Dots             NUMERIC
  ,Wilks            NUMERIC
  ,Glossbrenner     NUMERIC
  ,Goodlift         NUMERIC
  ,Tested           VARCHAR
  ,Country          VARCHAR
  ,State            VARCHAR
  ,Federation       VARCHAR
  ,ParentFederation VARCHAR
  ,Date             DATE
  ,MeetCountry      VARCHAR
  ,MeetState        VARCHAR
  ,MeetTown         VARCHAR
  ,MeetName         VARCHAR
);
```
Output:
> CREATE TABLE

Next we will insert our data from csv into our table on the database.
```sql
\COPY powerlift_data FROM 'openpowerlifting-2023-04-15-62ba32db.csv' DELIMITER ',' CSV HEADER;
```
Output:
> COPY 2887199

# Data Cleaning <a name=data_cleaning></a>
Before we do any querying, we will cleaning our data first, hence our query result will be more accurate. Our data cleaning tasks include removing duplicate records, removing irrelevant column, and validate the data type.

## Check Duplicate Data <a name=duplicate_data></a>
Frst let's check the number of rows.
```sql
SELECT COUNT(*)
FROM powerlift_data;
```
Output:

| count |
|---|
|2887199|

Next, we will find the total amount of duplicate rows, the idea is to `COUNT(*)` by `GROUP BY` for each column and filter it by `HAVING COUNT(*) > 1`, then substract it by 1, hence we will get the number of how many the unique rows appeared again. After that, we will sum up all these duplicate rows.

```sql
SELECT
    SUM(COUNT(*) - 1) OVER() AS total_duplicated
FROM powerlift_data
GROUP BY
    Name,
    Sex,
    Event,
    Equipment,
    Age,
    AgeClass,
    BirthYearClass,
    Division,
    BodyweightKg,
    WeightClassKg,
    Squat1Kg,
    Squat2Kg,
    Squat3Kg,
    Squat4Kg,
    Best3SquatKg,
    Bench1Kg,
    Bench2Kg,
    Bench3Kg,
    Bench4Kg,
    Best3BenchKg,
    Deadlift1Kg,
    Deadlift2Kg,
    Deadlift3Kg,
    Deadlift4Kg,
    Best3DeadliftKg,
    TotalKg,
    Place,
    Dots,
    Wilks,
    Glossbrenner,
    Goodlift,
    Tested,
    Country,
    State,
    Federation,
    ParentFederation,
    Date,
    MeetCountry,
    MeetState,
    MeetTown,
    MeetName
HAVING COUNT(*) > 1
LIMIT 1;
```
Output:

| total_duplicated |
| --- |
| 3435 |

There are 3435 duplicate rows! Let's drop these duplicate rows by using temporary table.

```sql
-- Create temporary table
CREATE TABLE temp (LIKE powerlift_data);

-- Insert distinct row into temporary table
INSERT INTO temp (
    Name,
    Sex,
    Event,
    Equipment,
    Age,
    AgeClass,
    BirthYearClass,
    Division,
    BodyweightKg,
    WeightClassKg,
    Squat1Kg,
    Squat2Kg,
    Squat3Kg,
    Squat4Kg,
    Best3SquatKg,
    Bench1Kg,
    Bench2Kg,
    Bench3Kg,
    Bench4Kg,
    Best3BenchKg,
    Deadlift1Kg,
    Deadlift2Kg,
    Deadlift3Kg,
    Deadlift4Kg,
    Best3DeadliftKg,
    TotalKg,
    Place,
    Dots,
    Wilks,
    Glossbrenner,
    Goodlift,
    Tested,
    Country,
    State,
    Federation,
    ParentFederation,
    Date,
    MeetCountry,
    MeetState,
    MeetTown,
    MeetName
)
SELECT DISTINCT *
FROM powerlift_data;

-- Drop the original table
DROP TABLE powerlift_data;

-- Rename the temporary table to original name
ALTER TABLE temp
RENAME TO powerlift_data;
```
Let's check the number of rows again.
```sql
SELECT COUNT(*)
FROM powerlift_dataa
```
Output:
| count |
|---|
|2883764|

Let's check it by subtract the original number of rows with number of duplicate rows: 2887199 - 3435 = 2883764. It's correct! Let's move to next section.

## Drop Irrelevant Column <a name=irrelevant_columns></a>
We will drop these columns: ageclass, birthyearclass, and weightclasskg, because the information from those columns already included in another column.

```sql
ALTER TABLE powerlift_data
DROP COLUMN ageclass,
DROP COLUMN birthyearclass,
DROP COLUMN weightclasskg;
```
Output:
> ALTER successfully executed.

## Validate the Data Type <a name=validate_data_type></a>
In this section we will validate the data type for each column. First let's check the current data type:
```sql
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'powerlift_data';
```
Output:

|column_name     |data_type        |
|----------------|-----------------|
|squat1kg        |numeric          |
|best3deadliftkg |numeric          |
|totalkg         |numeric          |
|squat2kg        |numeric          |
|dots            |numeric          |
|wilks           |numeric          |
|glossbrenner    |numeric          |
|goodlift        |numeric          |
|squat3kg        |numeric          |
|age             |numeric          |
|best3squatkg    |numeric          |
|bench1kg        |numeric          |
|bench2kg        |numeric          |
|date            |date             |
|bench3kg        |numeric          |
|bodyweightkg    |numeric          |
|best3benchkg    |numeric          |
|deadlift1kg     |numeric          |
|deadlift2kg     |numeric          |
|deadlift3kg     |numeric          |
|meetname        |character varying|
|sex             |character varying|
|event           |character varying|
|equipment       |character varying|
|division        |character varying|
|squat4kg        |character varying|
|bench4kg        |character varying|
|deadlift4kg     |character varying|
|place           |character varying|
|tested          |character varying|
|country         |character varying|
|state           |character varying|
|federation      |character varying|
|parentfederation|character varying|
|meetcountry     |character varying|
|meetstate       |character varying|
|meettown        |character varying|
|name            |character varying|

As we can see some columns have 'inappropiate' data type:
1. age should be an integer.
2. squat4kg, bench4kg, and deadlift4kg should be numeric.

Let's handle age column first, if age is decimal number, we will rounding down those values.
```sql
UPDATE powerlift_data
SET age = FLOOR(age);

ALTER TABLE powerlift_data
ALTER COLUMN age TYPE INTEGER;
```
Output:
> UPDATE successfully executed. 2883764 rows were affected.

> ALTER successfully executed.

Next let's convert these columns: squat4kg, bench4kg, and deadlift4kg into numeric. 
```sql
ALTER TABLE powerlift_data
ALTER COLUMN squat4kg TYPE NUMERIC USING squat4kg::NUMERIC;

ALTER TABLE powerlift_data
ALTER COLUMN bench4kg TYPE NUMERIC USING bench4kg::NUMERIC;

ALTER TABLE powerlift_data
ALTER COLUMN deadlift4kg TYPE NUMERIC USING deadlift4kg::NUMERIC;
```
Output:
> ALTER successfully executed.

> ALTER successfully executed.

> ALTER successfully executed.

## Validate the Input Data <a name=validate_input></a>
Based on the columns, age and bodyweightkg is prone to invalid input data. So let's inspect each of these columns.

### age Column <a name=validate_age></a>
First, we will check the range of input i.e. minimum and maximum value.
```sql
SELECT
    MIN(age),
    MAX(age)
FROM powerlift_data;
```
Output:
|min|max|
|---|---|
|0|98|

The minimum age doesn't make any sense, let's try detect the outliers and eliminate it by using Interquartile Range (IQR) method.
```sql
WITH
age_quartile AS (
    SELECT
        name,
        age,
        NTILE(4) OVER (ORDER BY age) AS quartile
    FROM powerlift_data
    WHERE age IS NOT NULL
),
quart_1_3 AS (
    SELECT
        quartile,
        MAX(age) AS age
    FROM age_quartile
    WHERE quartile IN (1, 3)
    GROUP BY quartile
),
quart_filter AS (
    SELECT
        name,
        age,
        (SELECT age FROM quart_1_3 WHERE quartile = 1) AS quart_1,
        (SELECT age FROM quart_1_3 WHERE quartile = 3) AS quart_3,
        (SELECT age FROM quart_1_3 WHERE quartile = 3) - (SELECT age FROM quart_1_3 WHERE quartile = 1) AS inter_quart
    FROM powerlift_data
)

SELECT
    MIN(age),
    MAX(age)
FROM quart_filter
WHERE
    age > quart_1 - 1.5*inter_quart
    AND
    age < quart_3 + 1.5*inter_quart;
```
|min|max|
|---|---|
|0|64|

The IQR method just remove upper outliers, let's try another method.

Based on this [Powerliftin Sport Rules](https://media.specialolympics.org/resources/sports-essentials/sport-rules/Sports-Essentials-Powerlifting-Rules-2020-v2.pdf), the minimum age to compete is 14 years old, while there is no maximum age limit to compete. So let's count the age that below 14 years old.
```sql
SELECT COUNT(*)
FROM powerlift_data
WHERE age < 14;
```
Output:
|count|
|---|
|27737|

Comparing to the number of rows in the datasets, it is pretty low number, so let's drop these rows.
```sql
DELETE FROM powerlift_data
WHERE age < 14;
```
Output:
> DELETE successfully executed. 27737 rows were affected.

### bodyweightkg Column<a href=validate_bodyweight></a>

# Case Study <a name=case_study></a>