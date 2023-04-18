# Data Cleaning
Before we do any querying, we will cleaning our data first, hence our query result will be more accurate. Our data cleaning tasks include removing duplicated records, removing irrelevant column, correcting misspelings, etc

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