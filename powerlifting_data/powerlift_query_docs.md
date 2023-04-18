# Data Cleaning
Before we do any querying, we will cleaning our data first, hence our query result will be more accurate. Our data cleaning tasks include removing duplicated records, removing irrelevant column, validating data type, correcting misspelings, etc

## Check Duplicated Data
Frst let's check the number of rows.
```sql
SELECT COUNT(*)
FROM powerlift_dataa
```
Output:

| count |
|---|
|2887199|

Next, we will find the total amount of duplicated rows, the idea is to `COUNT(*)` by `GROUP BY` for each column and filter it by `HAVING COUNT(*) > 1`, then substract it by 1, hence we will get the number of how many the unique rows appeared again. After that, we will sum up all these duplicated rows.

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
LIMIT 1
```
Output:

| total_duplicated |
| --- |
| 3435 |

There are 3435 duplicated rows! Let's drop these duplicated rows by using temporary table.

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

Let's check it by subtract the original number of rows with number of duplicated rows: 2887199 - 3435 = 2883764. It's correct! Let's move to next section.

## Drop Irrelevant Column
We will drop these columns: ageclass, birthyearclass, and weightclasskg, because the information from those columns already included in another column.

```sql
ALTER TABLE powerlift_data
DROP COLUMN ageclass,
DROP COLUMN birthyearclass,
DROP COLUMN weightclasskg;
```

## Validate the Data Type
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
