# Documentation
This file contains the documentation, datasets, and query file. For the sake of datasets availability in this repository, I just attach partial datasets that consists only 50 rows out of 2887199 rows from the original datasets because of the limitation of space. However I still use the original datasets for querying in this documentation.
> This page uses data from the OpenPowerlifting project, https://www.openpowerlifting.org.
You may download a copy of the data at https://data.openpowerlifting.org. (accessed 15 April 2023).


## Table of Contents
1. [Data Preparation](#data_preparation)
2. [Data Cleaning](#data_cleaning)
    1. [Check Duplicate Data](#duplicate_data)
    2. [Drop Irrelevant Columns](#irrelecant_columns)
    3. [Validate the Data Type](#validate_data_type)
    4. [Validate the Input Data](#validate_input)
        1. [age Column](#validate_age)
        2. [bodyweightkg Column](#validate_bodyweight)
    5. [Check Duplicate Data Once Again](#duplicate_data_2)
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

Next, we will find the total amount of duplicate rows, the idea is to `COUNT(*)` by `GROUP BY` for each column and filter it by `HAVING COUNT(*) > 1`, then subtract it by 1, hence we will get the number of how many the unique rows appeared again. After that, we will sum up all these duplicate rows.

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
FROM powerlift_data
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

As we can see some columns have 'inappropriate' data type:
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

Based on this [Powerlifting Sport Rules](https://media.specialolympics.org/resources/sports-essentials/sport-rules/Sports-Essentials-Powerlifting-Rules-2020-v2.pdf), the minimum age to compete is 14 years old, while there is no maximum age limit to compete. So let's count the age that below 14 years old.
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

### bodyweightkg Column <a href=validate_bodyweight></a>
Let's check range of the input data.
```sql
SELECT
    MIN(bodyweightkg),
    MAX(bodyweightkg)
FROM powerlift_data;
```
Output:
|min|max|
|---|---|
|10|300|

Both value seems doesn't make sense. It's little bit tricky to recognize whether it's valid input or not. Let's check it further.
```sql
WITH
bw_quartile AS (
    SELECT
        name,
        bodyweightkg,
        NTILE(4) OVER (ORDER BY bodyweightkg) AS quartile
    FROM powerlift_data
    WHERE bodyweightkg IS NOT NULL
),
quart_1_3 AS (
    SELECT
        quartile,
        MAX(bodyweightkg) AS bodyweightkg
    FROM bw_quartile
    WHERE quartile IN (1, 3)
    GROUP BY quartile
),
quart_filter AS (
    SELECT
        name,
        bodyweightkg,
        (SELECT bodyweightkg FROM quart_1_3 WHERE quartile = 1) AS quart_1,
        (SELECT bodyweightkg FROM quart_1_3 WHERE quartile = 3) AS quart_3,
        (SELECT bodyweightkg FROM quart_1_3 WHERE quartile = 3) - (SELECT bodyweightkg FROM quart_1_3 WHERE quartile = 1) AS inter_quart
    FROM powerlift_data
)

SELECT
    MIN(bodyweightkg),
    MAX(bodyweightkg)
FROM quart_filter
WHERE
    bodyweightkg > quart_1 - 1.5*inter_quart
    AND
    bodyweightkg < quart_3 + 1.5*inter_quart;
```
|min|max|
|---|---|
|20.14|146.2|

Based on the upper bound i.e. 146.2 kg, this bodyweight still possible for a heavy powerlifter, for example based on [this article](https://fitnessvolt.com/julius-maddox-profile/), Julius Maddox's weight is around 220 kg. So, for now let's ignore the upper outliers and focus on lower outliers.

To check whether it's a valid input or not, we will use this assumption:
1. Commonly invalid input occurs by accident, while accident usually occurs just once or twice, for this datasets let's assume it occurs just once. We also assume each participants name is unique, since there is no column/id that can be used as a `PRIMARY KEY`.
2. For each powerlifter name, there exists a powerlifter that participate more than one meet, so we will identify whether the lower bound bodyweightkg is a valid input or not based on another bodyweightkg in other meet for each person. We will query `name` and `MIN(bodyweightkg)AS bw_lower_bound`, then `GROUP BY name`, next we filter it by `HAVING COUNT(*) > 1`.
3. For each name, we will set a bodyweightkg threshold by `bw_lower_bound + epsilon AS threshold`, where epsilon is element of positive real numbers, it used as a tolerance.
4. Whenever there exists bodyweightkg that less than threshold (`bodyweightkg < threshold`), then we classify the `bw_lower_bound` rows as a valid input, and otherwise.

First, let's create a new table with a temporary id (`temp_id`).
```sql
CREATE TABLE with_temp_id (LIKE powerlift_data);

ALTER TABLE with_temp_id
ADD COLUMN temp_id INTEGER;

INSERT INTO with_temp_id (
    Name,
    Sex,
    Event,
    Equipment,
    Age,
    Division,
    BodyweightKg,
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
    MeetName,
    temp_id
)
SELECT
    *,
    ROW_NUMBER() OVER(ORDER BY bodyweightkg) AS temp_id
FROM powerlift_data
```
Output:
> CREATE TABLE

Next, we will implement the assumption on the new table (`with_temp_id`):
```sql
WITH
-- Table with lower bound on each participant name
lower_bound AS (
    SELECT
        name,
        MIN(bodyweightkg) AS bw_lower_bound
    FROM with_temp_id
    WHERE bodyweightkg IS NOT NULL
    GROUP BY name
    HAVING COUNT(*) > 1
),
-- Set threshold with tolerance of 50 from lower bound
threshold AS (
    SELECT
        with_temp_id.temp_id,
        with_temp_id.name,
        bodyweightkg,
        bw_lower_bound + 50 AS threshold
    FROM with_temp_id
    RIGHT JOIN lower_bound ON lower_bound.name = with_temp_id.name
    ORDER BY bw_lower_bound, bodyweightkg
),
-- Comparing each bodyweightkg and the threshold respectively with its participant name
compare_threshold AS (
    SELECT
        *,
        (bodyweightkg < threshold)::INTEGER AS less_than_threshold
    FROM threshold
),
-- Find whether there exists bodyweightkg that lies inside the threshold, we set it only for participant with bodyweightkg that less than 100 kg (since it prone to become invalid input)
filter_threshold AS (
    SELECT
        name,
        SUM(less_than_threshold) AS indicator
    FROM compare_threshold
    WHERE threshold - 50 < 50
    GROUP BY name
    HAVING SUM(less_than_threshold) < 2
),
-- Return the temp_id that is classified as invalid input
invalid_id AS (
    SELECT
        MIN(temp_id) AS temp_id
    FROM threshold
    RIGHT JOIN filter_threshold ON threshold.name = filter_threshold.name
    GROUP BY threshold.name
)

-- Delete temp_id based on invalid_id
DELETE FROM with_temp_id
WHERE temp_id IN (SELECT temp_id FROM invalid_id);
```
Output:
> DELETE successfully executed. 74 rows were affected.

Lastly, we will rename `with_temp_id` to the original table and rename the original one to the backup, just in cae something wrong happened.
```sql
ALTER TABLE powerlift_data
RENAME TO powerlift_backup;

ALTER TABLE with_temp_id
RENAME TO powerlift_data;
```
Output:
> ALTER successfully executed.

Remember, with this assumption we drop the rows which participants that participate more than one meet. Hence, we will set some threshold to drop participants name that only participate one meet.
```sql
WITH
meet_counted AS (
    SELECT
        COUNT(*) AS freq,
        name
    FROM powerlift_data
    GROUP BY name
),
invalid_id AS (
    SELECT
        temp_id
    FROM powerlift_data
    RIGHT JOIN meet_counted ON powerlift_data.name = meet_counted.name
    WHERE
        freq = 1
        AND
        bodyweightkg < 25
)

DELETE FROM powerlift_data
WHERE temp_id IN (SELECT temp_id FROM invalid_id);
```
Output:
> DELETE successfully executed. 32 rows were affected.

## Check Duplicate Data Once Again <a name=duplicate_data_2></a>
Since we drop some irrelevant column, we want to make sure if our data still doesn't contains duplicate rows.
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
    Division,
    BodyweightKg,
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
| 29 |

It contains duplicate rows, let's remove it
```sql
-- Drop temp_id
ALTER TABLE powerlift_data
DROP COLUMN temp_id;

-- Create temporary table
CREATE TABLE temp (LIKE powerlift_data);

-- Insert distinct row into temporary table
INSERT INTO temp (
    Name,
    Sex,
    Event,
    Equipment,
    Age,
    Division,
    BodyweightKg,
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

Let's move on to the case study.
# Case Study <a name=case_study></a>
1. Find the percentage of powerlifter's gender!

    Because some participants name occurs more than one, first we query the unique participant `name` and their `sex`, after that we use `COUNT(*)`.
    ```sql
    WITH
    unique_participants AS (
        SELECT
            DISTINCT name,
            sex
        FROM powerlift_data
    ),
    unique_gender AS (
        SELECT
            sex,
            COUNT(*) AS count_gender
        FROM unique_participants
        GROUP BY sex
    )

    SELECT
        sex,
        ROUND(count_gender / SUM(count_gender) OVER() * 100, 3) AS percentage
    FROM unique_gender
    ORDER BY percentage DESC;
    ```
    Output:
    |sex|percentage|
    |---|---|
    |M|75.171|
    |F|24.826|
    |Mx|0.004|

2. Find the percentage of each event respectively to the total event!
    ```sql
    WITH
    unique_event AS (
        SELECT
            event,
            COUNT(*) AS count_event
        FROM powerlift_data
        GROUP BY event
    )

    SELECT
        event,
        ROUND(count_event / SUM(count_event) OVER() * 100, 3) AS percentage
    FROM unique_event
    ORDER BY percentage DESC;
    ```
    Output:
    |event|percentage|
    |-----|----------|
    |SBD  |69.009    |
    |B    |22.586    |
    |D    |5.744     |
    |BD   |1.961     |
    |S    |0.533     |
    |SB   |0.102     |
    |SD   |0.064     |

3. How many percent successful lift in SBD (for each lift)?

    **Squat**
    ```sql
    WITH 
    squat_lift AS (
        SELECT
            squat1kg,
            squat2kg,
            squat3kg
        FROM powerlift_data
        WHERE
            event = 'SBD'
            AND
            squat1kg IS NOT NULL
            AND
            squat2kg IS NOT NULL
            AND
            squat3kg IS NOT NULL
    )

    SELECT
        ROUND((SELECT COUNT(squat1kg) FROM squat_lift WHERE squat1kg > 0)::NUMERIC / COUNT(squat1kg) * 100, 2) AS squat_1_percentage,
        ROUND((SELECT COUNT(squat2kg) FROM squat_lift WHERE squat2kg > 0)::NUMERIC / COUNT(squat2kg) * 100, 2) AS squat_2_percentage,
        ROUND((SELECT COUNT(squat3kg) FROM squat_lift WHERE squat3kg > 0)::NUMERIC / COUNT(squat3kg) * 100, 2) AS squat_3_percentage
    FROM squat_lift
    ```
    Output:
    |squat_1_percentage|squat_2_percentage|squat_3_percentage|
    |------------------|------------------|------------------|
    |85.14             |78.98             |61.82             |

    **Bench**
    ```sql
    WITH 
    bench_lift AS (
        SELECT
            bench1kg,
            bench2kg,
            bench3kg
        FROM powerlift_data
        WHERE
            event = 'SBD'
            AND
            bench1kg IS NOT NULL
            AND
            bench2kg IS NOT NULL
            AND
            bench3kg IS NOT NULL
    )

    SELECT
        ROUND((SELECT COUNT(bench1kg) FROM bench_lift WHERE bench1kg > 0)::NUMERIC / COUNT(bench1kg) * 100, 2) AS bench_1_percentage,
        ROUND((SELECT COUNT(bench2kg) FROM bench_lift WHERE bench2kg > 0)::NUMERIC / COUNT(bench2kg) * 100, 2) AS bench_2_percentage,
        ROUND((SELECT COUNT(bench3kg) FROM bench_lift WHERE bench3kg > 0)::NUMERIC / COUNT(bench3kg) * 100, 2) AS bench_3_percentage
    FROM bench_lift;
    ```
    Output:
    |bench_1_percentage|bench_2_percentage|bench_3_percentage|
    |---------------|---------------|---------------|
    |89.77          |77.52          |45.77          |

    **Deadlift**
    ```sql
    WITH 
    deadlift_lift AS (
        SELECT
            deadlift1kg,
            deadlift2kg,
            deadlift3kg
        FROM powerlift_data
        WHERE
            event = 'SBD'
            AND
            deadlift1kg IS NOT NULL
            AND
            deadlift2kg IS NOT NULL
            AND
            deadlift3kg IS NOT NULL
    )

    SELECT
        ROUND((SELECT COUNT(deadlift1kg) FROM deadlift_lift WHERE deadlift1kg > 0)::NUMERIC / COUNT(deadlift1kg) * 100, 2) AS deadlift_1_precentage,
        ROUND((SELECT COUNT(deadlift2kg) FROM deadlift_lift WHERE deadlift2kg > 0)::NUMERIC / COUNT(deadlift2kg) * 100, 2) AS deadlift_2_precentage,
        ROUND((SELECT COUNT(deadlift3kg) FROM deadlift_lift WHERE deadlift3kg > 0)::NUMERIC / COUNT(deadlift3kg) * 100, 2) AS deadlift_3_percentage
    FROM deadlift_lift
    ```
    Output:
    |deadlift_1_precentage|deadlift_2_precentage|deadlift_3_percentage|
    |---------------------|---------------------|---------------------|
    |94.92                |86.93                |58.65                |

4. How much is the average best lift for each 5 year (for each lift)?

    **Best Squat**
    ```sql
    SELECT
        CONCAT(MIN(DATE_PART('year', date))::VARCHAR, '-', MAX(DATE_PART('year', date))::VARCHAR) AS year_range,
        sex,
        ROUND(AVG(best3squatkg), 2) AS average_squat
    FROM powerlift_data
    WHERE
        best3squatkg > 0
    GROUP BY
        FLOOR(DATE_PART('year', date)/5),
        sex
    ORDER BY
        year_range,
        sex
    ```
    Output:
    |year_range|sex|average_squat|
    |----------|---|-------------|
    |1964-1964 |M  |190.29       |
    |1965-1969 |M  |208.90       |
    |1970-1974 |M  |199.12       |
    |1975-1979 |F  |84.07        |
    |1975-1979 |M  |197.73       |
    |1980-1984 |F  |101.96       |
    |1980-1984 |M  |201.43       |
    |1985-1989 |F  |122.06       |
    |1985-1989 |M  |222.01       |
    |1990-1994 |F  |124.99       |
    |1990-1994 |M  |223.54       |
    |1995-1999 |F  |127.06       |
    |1995-1999 |M  |221.22       |
    |2000-2004 |F  |128.13       |
    |2000-2004 |M  |218.80       |
    |2005-2009 |F  |128.58       |
    |2005-2009 |M  |224.29       |
    |2010-2014 |F  |110.13       |
    |2010-2014 |M  |189.90       |
    |2015-2019 |F  |111.25       |
    |2015-2019 |M  |193.27       |
    |2017-2019 |Mx |103.66       |
    |2020-2023 |F  |116.09       |
    |2020-2023 |M  |194.70       |
    |2020-2023 |Mx |105.55       |

    **Bench**
    ```sql
    SELECT
        CONCAT(MIN(DATE_PART('year', date))::VARCHAR, '-', MAX(DATE_PART('year', date))::VARCHAR) AS year_range,
        sex,
        ROUND(AVG(best3benchkg), 2) AS average_bench
    FROM powerlift_data
    WHERE
        best3benchkg > 0
    GROUP BY
        FLOOR(DATE_PART('year', date)/5),
        sex
    ORDER BY
        year_range,
        sex
    ```
    Output:
    |year_range|sex|average_bench|
    |----------|---|-------------|
    |1964-1964 |M  |127.32       |
    |1965-1969 |M  |143.14       |
    |1970-1974 |M  |134.55       |
    |1975-1979 |F  |47.09        |
    |1975-1979 |M  |132.10       |
    |1980-1984 |F  |54.30        |
    |1980-1984 |M  |134.09       |
    |1985-1989 |F  |64.60        |
    |1985-1989 |M  |143.55       |
    |1990-1994 |F  |67.23        |
    |1990-1994 |M  |144.40       |
    |1995-1999 |F  |71.59        |
    |1995-1999 |M  |150.00       |
    |2000-2004 |F  |73.59        |
    |2000-2004 |M  |149.55       |
    |2005-2009 |F  |75.39        |
    |2005-2009 |M  |158.10       |
    |2010-2014 |F  |64.52        |
    |2010-2014 |M  |134.88       |
    |2015-2019 |F  |61.61        |
    |2015-2019 |M  |135.13       |
    |2016-2019 |Mx |68.59        |
    |2020-2023 |F  |64.81        |
    |2020-2023 |M  |131.36       |
    |2020-2023 |Mx |60.47        |

    **Deadlift**
    ```sql
    SELECT
        CONCAT(MIN(DATE_PART('year', date))::VARCHAR, '-', MAX(DATE_PART('year', date))::VARCHAR) AS year_range,
        sex,
        ROUND(AVG(best3deadliftkg), 2) AS average_deadlift
    FROM powerlift_data
    WHERE
        best3deadliftkg > 0
    GROUP BY
        FLOOR(DATE_PART('year', date)/5),
        sex
    ORDER BY
        year_range,
        sex
    ```
    Output:
    |year_range|sex|average_deadlift|
    |----------|---|----------------|
    |1964-1964 |M  |238.46          |
    |1965-1969 |M  |241.39          |
    |1970-1974 |M  |232.62          |
    |1975-1979 |F  |112.73          |
    |1975-1979 |M  |222.92          |
    |1980-1984 |F  |123.76          |
    |1980-1984 |M  |220.25          |
    |1985-1989 |F  |138.71          |
    |1985-1989 |M  |232.56          |
    |1990-1994 |F  |138.53          |
    |1990-1994 |M  |230.77          |
    |1995-1999 |F  |139.25          |
    |1995-1999 |M  |230.26          |
    |2000-2004 |F  |137.00          |
    |2000-2004 |M  |225.93          |
    |2005-2009 |F  |134.97          |
    |2005-2009 |M  |225.78          |
    |2010-2014 |F  |123.86          |
    |2010-2014 |M  |201.58          |
    |2015-2019 |F  |125.46          |
    |2015-2019 |M  |211.99          |
    |2017-2019 |Mx |132.99          |
    |2020-2023 |F  |131.60          |
    |2020-2023 |M  |213.51          |
    |2020-2023 |Mx |126.29          |


## TEMPORARY ARCHIVED

First, we will create table that contains all successful lift and replace failed lift with `NULL` value. Now, we will try to use temporary table called `successful_lift` instead of CTE method.

```sql
CREATE TABLE success_lift (
    name VARCHAR,
    sex VARCHAR,
    date DATE,
    event VARCHAR,
    Squat1Kg NUMERIC,
    Squat2Kg NUMERIC,
    Squat3Kg NUMERIC,
    Squat4Kg NUMERIC,
    Best3SquatKg NUMERIC,
    Bench1Kg NUMERIC,
    Bench2Kg NUMERIC,
    Bench3Kg NUMERIC,
    Bench4Kg NUMERIC,
    Best3BenchKg NUMERIC,
    Deadlift1Kg NUMERIC,
    Deadlift2Kg NUMERIC,
    Deadlift3Kg NUMERIC,
    Deadlift4Kg NUMERIC,
    Best3DeadliftKg NUMERIC
);

INSERT INTO success_lift(
    name,
    sex,
    date,
    event,
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
    Best3DeadliftKg
)
SELECT
    name,
    sex,
    date,
    event,
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
    Best3DeadliftKg
FROM powerlift_data;
```
Output:
> INSERT successfully executed. 2855892 rows were affected.

Next, we will replace the failed lift with `NULL` value.
```sql
UPDATE success_lift SET squat1kg = NULL WHERE squat1kg < 0;

UPDATE success_lift SET squat2kg = NULL WHERE squat2kg < 0;

UPDATE success_lift SET squat3kg = NULL WHERE squat3kg < 0;

UPDATE success_lift SET squat4kg = NULL WHERE squat4kg < 0;

UPDATE success_lift SET best3squatKg = NULL WHERE best3squatKg < 0;

UPDATE success_lift SET bench1kg = NULL WHERE bench1kg < 0;

UPDATE success_lift SET bench2kg = NULL WHERE bench2kg < 0;

UPDATE success_lift SET bench3kg = NULL WHERE bench3kg < 0;

UPDATE success_lift SET bench4kg = NULL WHERE bench4kg < 0;

UPDATE success_lift SET best3benchkg = NULL WHERE best3benchkg < 0;

UPDATE success_lift SET deadlift1kg = NULL WHERE deadlift1kg < 0;

UPDATE success_lift SET deadlift2kg = NULL WHERE deadlift2kg < 0;

UPDATE success_lift SET deadlift3Kg = NULL WHERE deadlift3kg < 0;

UPDATE success_lift SET deadlift4kg = NULL WHERE deadlift4kg < 0;

UPDATE success_lift SET Best3deadliftKg = NULL WHERE best3deadliftkg < 0;
```
Output:
> UPDATE successfully executed. xxx rows were affected.