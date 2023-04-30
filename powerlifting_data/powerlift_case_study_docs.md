# Case Study <a name=case_study></a>
**Disclaimer: Most of the query are separated by gender because there is some gap between each gender (male, female, and neutral gender) in average lift number.**
## Table of Contents
1. [Percentage of powerlifter's gender](#gender_count)
2. [The number of powerlifter that join the meet within 5 year range (Separated by the gender)](#count_powerlifter)
    1. [The Number of Male Powerlifter](#count_male)
    2. [The Number of Female Powerlifter](#count_female)
    3. [The Number of Neutral Gender Powerlifter](#count_neutral)
3. [Percentage of each event respectively to the total event](#count_event)
4. [Percentage of successful lift in SBD (for each lift)](#success_lift)
    1. [Successful Squat](#success_squat)
    2. [Successful Bench](#success_bench)
    3. [Successful Deadlift](#success_deadlift)
    4. [Compare All Lift](#all_lift)
5. [The average best lift for each 5 year (for each lift)](#avg_lift)
    1. [Average Best Squat](#avg_squat)
        1. [Average Best Squat for Male](#avg_squat_male)
        2. [Average Best Squat for Female](#avg_squat_female)
        3. [Average Best Squat for Neutral Gender](#avg_squat_neutral)
    2. [Average Best Bench](#avg_bench)
        1. [Average Best Bench for Male](#avg_bench_male)
        2. [Average Best Bench for Female](#avg_bench_female)
        3. [Average Best Bench for Neutral Gender](#avg_bench_neutral)
    3. [Average Best Deadlift](#avg_deadlift)
        1. [Average Best Deadlift for Male](#avg_deadlift_male)
        2. [Average Best Deadlift for Female](#avg_deadlift_female)
        3. [Average Best Deadlift for Neutral Gender](#avg_deadlift_neutral)
6. [Descriptive statistics bodyweight grouped by age within 5 year range](#desc_stat)
    1. [Descriptive Statistics for Male](#desc_stat_male)
    2. [Descriptive Statistics for Female](#desc_stat_female)
    3. [Descriptive Statistics for Neutral](#desc_stat_neutral)
7. [Place Query](#place_query)
    1. [The most number 1 place](#first_place)
        1. [Top 10 male powerlifter with the most number 1 place](#first_male)
        2. [Top 10 female powerlifter with the most number 1 place](#first_female)
        3. [Top 10 neutral gender powerlifter with the most number 1 place](#first_neutral)
    2. [Percentage of disqualified powerlifter grouped by year within 5 year range](#disq_percent)
    3. [Top 5 country with the most number 1 place](#country_first)
8. [Equipment QUery](#equipment_query)
    1. [Percentage of each equipment used by powerlifter](#equip_percent)
    2. [Top lift for each equipment](#top_lift_equip)
        1. [Top lift for male powerlifter group by equipment](#top_lift_equip_male)
            1. [Top squat](#top_squat_male)
            2. [Top bench](#top_bench_male)
            3. [Top deadlift](#top_deadlift_male)
        2. [Top lift for female powerlifter group by equipment](#top_lift_equip_female)
            1. [Top squat](#top_squat_female)
            2. [Top bench](#top_bench_female)
            3. [Top deadlift](#top_deadlift_female)
        3. [Top lift for neutral gender powerlifter group by equipment](#top_lift_equip_neutral)
            1. [Top squat](#top_squat_neutral)
            2. [Top bench](#top_bench_neutral)
            3. [Top deadlift](#top_deadlift_neutral)

## Percentage of powerlifter's gender <a name=gender_count></a>
Because some participants name occurs more than one, first we query the unique participant `name` and their `sex`, after that we use `COUNT(*)` grouped by `sex` column.
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
    count_gender,
    ROUND(count_gender / SUM(count_gender) OVER() * 100, 3) AS percentage
FROM unique_gender
ORDER BY percentage DESC;
```
Output:
|sex|count_gender|percentage|
|---|------------|----------|
|M  |563885      |75.171    |
|F  |186227      |24.826    |
|Mx |27          |0.004     |

It's clearly that male gender dominated the powerlifting meet, while neutral gender is not very common in powerlifting meet.

## The number of powerlifter that join the meet within 5 year range (Separated by the gender)<a name=count_powerlifter></a>
We will query the date when for each powerlifter join their first meet and grouped by 5 year range.

*Note: Since the minimum year of the datasets is 1964 and the maximum year is 2023, both of them can't divided by 5, we will classify them as 1964-1964 and 2020-2023. This will applied in other case study that requiring year range/age range.*
```sql
CREATE TABLE count_powerlifter(
    year_range VARCHAR,
    sex VARCHAR,
    total_powerlifter INTEGER
);

INSERT INTO count_powerlifter(
    year_range,
    sex,
    total_powerlifter
)
WITH
unique_powerlifter AS (
    SELECT
        DISTINCT name,
        sex,
        MIN(date)  AS join_year
    FROM powerlift_data
    GROUP BY
        name,
        sex
)
SELECT
    CONCAT(MIN(DATE_PART('year', join_year))::VARCHAR, '-', MAX(DATE_PART('year', join_year))::VARCHAR) AS year_range,
    sex,
    COUNT(*) AS total_powerlifter
FROM unique_powerlifter
GROUP BY
    FLOOR(DATE_PART('year', join_year)/5),
    sex;
```
Output:
> INSERT successfully executed. 25 rows were affected.

### The Number of Male Powerlifter <a name=count_male></a>
```sql
SELECT
    year_range,
    total_powerlifter
FROM count_powerlifter
WHERE sex = 'M'
ORDER BY year_range;
```
Output:
|year_range|total_powerlifter|
|----------|-----------------|
|1964-1964 |39               |
|1965-1969 |225              |
|1970-1974 |587              |
|1975-1979 |3426             |
|1980-1984 |41206            |
|1985-1989 |15702            |
|1990-1994 |15859            |
|1995-1999 |22158            |
|2000-2004 |33699            |
|2005-2009 |41029            |
|2010-2014 |116085           |
|2015-2019 |183392           |
|2020-2023 |90478            |

![Number of Male](plot_graph/count_powerlifter_M.png)

### The Number of Female Powerlifter <a name=count_female></a>
```sql
SELECT
    year_range,
    total_powerlifter
FROM count_powerlifter
WHERE sex = 'F'
ORDER BY year_range;
```
Output:
|year_range|total_powerlifter|
|----------|-----------------|
|1975-1979 |188              |
|1980-1984 |4427             |
|1985-1989 |2708             |
|1990-1994 |3292             |
|1995-1999 |5052             |
|2000-2004 |7199             |
|2005-2009 |7987             |
|2010-2014 |25286            |
|2015-2019 |86962            |
|2020-2023 |43126            |

![Number of Female](plot_graph/count_powerlifter_F.png)

### The Number of Neutral Gender Powerlifter <a name=count_neutral></a>
```sql
SELECT
    year_range,
    total_powerlifter
FROM count_powerlifter
WHERE sex = 'Mx'
ORDER BY year_range;
```
Output:
|year_range|total_powerlifter|
|----------|-----------------|
|2016-2019 |8                |
|2020-2023 |19               |

![Number of Neutral](plot_graph/count_powerlifter_Mx.png)

As we can see, the number of powerlifter is increased as the year increased. (We ignore the 1964-1964 and 2020-2023, since those year range is'nt in the 5 year range).

## Percentage of each event respectively to the total event <a name=count_event></a>
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
    count_event,
    ROUND(count_event / SUM(count_event) OVER() * 100, 3) AS percentage
FROM unique_event
ORDER BY percentage DESC;
```
Output:
|event|count_event|percentage|
|-----|-----------|----------|
|SBD  |1970821    |69.009    |
|B    |645043     |22.586    |
|D    |164047     |5.744     |
|BD   |56006      |1.961     |
|S    |15233      |0.533     |
|SB   |2922       |0.102     |
|SD   |1820       |0.064     |

## Percentage of successful lift in SBD (for each lift) <a name=success_lift></a>

First, we create table called `success_lift` that contains lift's name followed by lift percentage, then we will query each lift, one by one, and insert it into the table.

```sql
CREATE TABLE lift_percentage (
    lift VARCHAR,
    lift_1_percent NUMERIC,
    lift_2_percent NUMERIC,
    lift_3_percent NUMERIC
);
```
Output:
> CREATE successfully executed.

### Successful Squat <a name=success_squat></a>
```sql
INSERT INTO lift_percentage(
    lift,
    lift_1_percent,
    lift_2_percent,
    lift_3_percent
)
WITH
sbd_squat AS (
    SELECT
        squat1kg,
        squat2kg,
        squat3kg
    FROM powerlift_data
    WHERE event = 'SBD'
)
SELECT
    'squat' AS lift,
    ROUND(
        (SELECT
            COUNT(squat1kg) FROM sbd_squat WHERE squat1kg > 0
        ) / COUNT(squat1kg)::NUMERIC*100, 2
    ) AS lift_1_percent,
    
    ROUND(
        (SELECT
            COUNT(squat2kg) FROM sbd_squat WHERE squat2kg > 0
        ) / COUNT(squat2kg)::NUMERIC*100, 2
    ) AS lift_2_percent,

    ROUND(
        (SELECT
            COUNT(squat3kg) FROM sbd_squat WHERE squat3kg > 0
        ) / COUNT(squat3kg)::NUMERIC*100, 2
    ) AS lift_3_percent
FROM sbd_squat;
```
Output:
> INSERT successfully executed. 1 rows were affected.

### Successful Bench <a name=success_bench></a>
```sql
INSERT INTO lift_percentage(
    lift,
    lift_1_percent,
    lift_2_percent,
    lift_3_percent
)
WITH
sbd_bench AS (
    SELECT
        bench1kg,
        bench2kg,
        bench3kg
    FROM powerlift_data
    WHERE event = 'SBD'
)
SELECT
    'bench' AS lift,
    ROUND(
        (SELECT
            COUNT(bench1kg) FROM sbd_bench WHERE bench1kg > 0
        ) / COUNT(bench1kg)::NUMERIC*100, 2
    ) AS lift_1_percent,
    
    ROUND(
        (SELECT
            COUNT(bench2kg) FROM sbd_bench WHERE bench2kg > 0
        ) / COUNT(bench2kg)::NUMERIC*100, 2
    ) AS lift_2_percent,

    ROUND(
        (SELECT
            COUNT(bench3kg) FROM sbd_bench WHERE bench3kg > 0
        ) / COUNT(bench3kg)::NUMERIC*100, 2
    ) AS lift_3_percent
FROM sbd_bench;
```
Output:
> INSERT successfully executed. 1 rows were affected.

### Successful Deadlift <a name=success_deadlift></a>
```sql
INSERT INTO lift_percentage(
    lift,
    lift_1_percent,
    lift_2_percent,
    lift_3_percent
)
WITH
sbd_deadlift AS (
    SELECT
        deadlift1kg,
        deadlift2kg,
        deadlift3kg
    FROM powerlift_data
    WHERE event = 'SBD'
)
SELECT
    'deadlift' AS lift,
    ROUND(
        (SELECT
            COUNT(deadlift1kg) FROM sbd_deadlift WHERE deadlift1kg > 0
        ) / COUNT(deadlift1kg)::NUMERIC*100, 2
    ) AS lift_1_percent,
    
    ROUND(
        (SELECT
            COUNT(deadlift2kg) FROM sbd_deadlift WHERE deadlift2kg > 0
        ) / COUNT(deadlift2kg)::NUMERIC*100, 2
    ) AS lift_2_percent,

    ROUND(
        (SELECT
            COUNT(deadlift3kg) FROM sbd_deadlift WHERE deadlift3kg > 0
        ) / COUNT(deadlift3kg)::NUMERIC*100, 2
    ) AS lift_3_percent
FROM sbd_deadlift;
```
Output:
> INSERT successfully executed. 1 rows were affected.

### Compare All Lift <a name=all_lift></a>

```sql
SELECT *
FROM lift_percentage;
```
Output:
|lift|lift_1_percent|lift_2_percent|lift_3_percent|
|----|--------------|--------------|--------------|
|squat|85.19         |78.79         |61.87         |
|bench|89.60         |77.04         |45.85         |
|deadlift|94.53         |85.92         |58.68         |

All successful lift decrease proportionally to the lift attempt.

## The average best lift for each 5 year (for each lift) <a name=avg_lift></a>
First, we will create table that contains average best ift for each lift, so there will be 3 tables. After that we will query them by filtering based on `sex` for each lift, so there will be 9 query.

### Average Best Squat <a name=avg_squat></a>
```sql
CREATE TABLE avg_best_squat(
    year_range VARCHAR,
    sex VARCHAR,
    average_squat NUMERIC
);

INSERT INTO avg_best_squat(
    year_range,
    sex,
    average_squat
)
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
```
Output:
> INSERT successfully executed. 25 rows were affected.

#### Average Best Squat for Male <a name=avg_squat_male></a>
```sql
SELECT
    year_range,
    average_squat
FROM avg_best_squat
WHERE sex = 'M'
ORDER BY year_range;
```
Output:
|year_range|average_squat|
|----------|-------------|
|1964-1964 |190.29       |
|1965-1969 |208.90       |
|1970-1974 |199.12       |
|1975-1979 |197.73       |
|1980-1984 |201.43       |
|1985-1989 |222.01       |
|1990-1994 |223.54       |
|1995-1999 |221.22       |
|2000-2004 |218.80       |
|2005-2009 |224.29       |
|2010-2014 |189.90       |
|2015-2019 |193.27       |
|2020-2023 |194.70       |

![Average Best Squat for Male Powerlifter](plot_graph/avg_best_squat_M.png)

#### Average Best Squat for Female <a name=avg_squat_female></a>
```sql
SELECT
    year_range,
    average_squat
FROM avg_best_squat
WHERE sex = 'F'
ORDER BY year_range;
```
Output:
|year_range|average_squat|
|----------|-------------|
|1975-1979 |84.07        |
|1980-1984 |101.96       |
|1985-1989 |122.06       |
|1990-1994 |124.99       |
|1995-1999 |127.06       |
|2000-2004 |128.13       |
|2005-2009 |128.58       |
|2010-2014 |110.13       |
|2015-2019 |111.25       |
|2020-2023 |116.09       |

![Average Best Squat for Female Powerlifter](plot_graph/avg_best_squat_F.png)

#### Average Best Squat for Neutral Gender <a name=avg_squat_neutral></a>
```sql
SELECT
    year_range,
    average_squat
FROM avg_best_squat
WHERE sex = 'Mx'
ORDER BY year_range;
```
Output:
|year_range|average_squat|
|----------|-------------|
|2017-2019 |103.66       |
|2020-2023 |105.55       |

![Average Best Squat for Neutral Gender Powerlifter](plot_graph/avg_best_squat_Mx.png)

### Average Best Bench <a name=avg_bench></a>
```sql
CREATE TABLE avg_best_bench(
    year_range VARCHAR,
    sex VARCHAR,
    average_bench NUMERIC
);

INSERT INTO avg_best_bench(
    year_range,
    sex,
    average_bench
)
SELECT
    CONCAT(MIN(DATE_PART('year', date))::VARCHAR, '-', MAX(DATE_PART('year', date))::VARCHAR) AS year_range,
    sex,
    ROUND(AVG(best3benchkg), 2) AS average_bench
FROM powerlift_data
WHERE
    best3benchkg > 0
GROUP BY
    FLOOR(DATE_PART('year', date)/5),
    sex;
```
Output:
> INSERT successfully executed. 25 rows were affected.

#### Average Best Bench for Male <a name=avg_bench_male></a>
```sql
SELECT
    year_range,
    average_bench
FROM avg_best_bench
WHERE sex = 'M'
ORDER BY year_range;
```
Output:
|year_range|average_bench|
|----------|-------------|
|1964-1964 |127.32       |
|1965-1969 |143.14       |
|1970-1974 |134.55       |
|1975-1979 |132.10       |
|1980-1984 |134.09       |
|1985-1989 |143.55       |
|1990-1994 |144.40       |
|1995-1999 |150.00       |
|2000-2004 |149.55       |
|2005-2009 |158.10       |
|2010-2014 |134.88       |
|2015-2019 |135.13       |
|2020-2023 |131.36       |

![Average Best Bench for Male Powerlifter](plot_graph/avg_best_bench_M.png)

#### Average Best Bench for Female <a name=avg_bench_female></a>
```sql
SELECT
    year_range,
    average_bench
FROM avg_best_bench
WHERE sex = 'F'
ORDER BY year_range;
```
Output:
|year_range|average_bench|
|----------|-------------|
|1975-1979 |47.09        |
|1980-1984 |54.30        |
|1985-1989 |64.60        |
|1990-1994 |67.23        |
|1995-1999 |71.59        |
|2000-2004 |73.59        |
|2005-2009 |75.39        |
|2010-2014 |64.52        |
|2015-2019 |61.61        |
|2020-2023 |64.81        |

![Average Best Bench for Female Powerlifter](plot_graph/avg_best_bench_F.png)

#### Average Best Bench for Neutral Gender <a name=avg_bench_neutral></a>
```sql
SELECT
    year_range,
    average_bench
FROM avg_best_bench
WHERE sex = 'Mx'
ORDER BY year_range;
```
Output:
|year_range|average_bench|
|----------|-------------|
|2016-2019 |68.59        |
|2020-2023 |60.47        |

![Average Best Bench for Neutral Gender Powerlifter](plot_graph/avg_best_bench_Mx.png)

### Average Best Deadlift <a name=avg_deadlift></a>
```sql
CREATE TABLE avg_best_deadlift(
    year_range VARCHAR,
    sex VARCHAR,
    average_deadlift NUMERIC
);

INSERT INTO avg_best_deadlift(
    year_range,
    sex,
    average_deadlift
)

SELECT
    CONCAT(MIN(DATE_PART('year', date))::VARCHAR, '-', MAX(DATE_PART('year', date))::VARCHAR) AS year_range,
    sex,
    ROUND(AVG(best3deadliftkg), 2) AS average_deadlift
FROM powerlift_data
WHERE
    best3deadliftkg > 0
GROUP BY
    FLOOR(DATE_PART('year', date)/5),
    sex;
```
Output:
> INSERT successfully executed. 25 rows were affected.

#### Average Best Deadlift for Male <a name=avg_deadlift_male></a>
```sql
SELECT
    year_range,
    average_deadlift
FROM avg_best_deadlift
WHERE sex = 'M'
ORDER BY year_range;
```
Output:
|year_range|average_deadlift|
|----------|----------------|
|1964-1964 |238.46          |
|1965-1969 |241.39          |
|1970-1974 |232.62          |
|1975-1979 |222.92          |
|1980-1984 |220.25          |
|1985-1989 |232.56          |
|1990-1994 |230.77          |
|1995-1999 |230.26          |
|2000-2004 |225.93          |
|2005-2009 |225.78          |
|2010-2014 |201.58          |
|2015-2019 |211.99          |
|2020-2023 |213.51          |

![Average Best Deadlift for Male Powerlifter](plot_graph/avg_best_deadlift_M.png)

#### Average Best Deadlift for Female <a name=avg_deadlift_female></a>
```sql
SELECT
    year_range,
    average_deadlift
FROM avg_best_deadlift
WHERE sex = 'F'
ORDER BY year_range;
```
Output:
|year_range|average_deadlift|
|----------|----------------|
|1975-1979 |112.73          |
|1980-1984 |123.76          |
|1985-1989 |138.71          |
|1990-1994 |138.53          |
|1995-1999 |139.25          |
|2000-2004 |137.00          |
|2005-2009 |134.97          |
|2010-2014 |123.86          |
|2015-2019 |125.46          |
|2020-2023 |131.60          |

![Average Best Deadlift for Female Powerlifter](plot_graph/avg_best_deadlift_F.png)

#### Average Best Deadlift for Neutral Gender <a name=avg_deadlift_neutral></a>
```sql
SELECT
    year_range,
    average_deadlift
FROM avg_best_deadlift
WHERE sex = 'Mx'
ORDER BY year_range;
```
Output:
|year_range|average_deadlift|
|----------|----------------|
|2017-2019 |132.99          |
|2020-2023 |126.29          |

![Average Best Deadlift for Neutral Gender Powerlifter](plot_graph/avg_best_deadlift_Mx.png)

## Descriptive statistics for bodyweight grouped by age within 5 year range <a name=desc_stat></a>

```sql
CREATE TABLE desc_stat_age (
    sex VARCHAR,
    age_range VARCHAR,
    total_powerlifter INTEGER,
    mean_bw NUMERIC,
    median_bw NUMERIC,
    mode_bw NUMERIC,
    std_bw NUMERIC,
    range_bw NUMERIC
);

INSERT INTO desc_stat(
    sex,
    age_range,
    total_powerlifter,
    mean_bw,
    median_bw,
    mode_bw,
    std_bw,
    range_bw
)
SELECT
    sex,
    CONCAT(MIN(age)::VARCHAR, '-', MAX(age)::VARCHAR) AS age_range,
    COUNT(name) AS total_powerlifter,
    ROUND(AVG(bodyweightkg), 2)AS mean_bw,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY bodyweightkg) AS median_bw,
    MODE() WITHIN GROUP (ORDER BY bodyweightkg) AS mode_bw,
    ROUND(STDDEV(bodyweightkg), 2) AS std_bw,
    MAX(bodyweightkg) - MIN(bodyweightkg) AS range_bw
FROM powerlift_data
WHERE age IS NOT NULL
GROUP BY
    sex,
    FLOOR(age/5);
```
Output:
> INSERT successfully executed. 45 rows were affected.

### Descriptive Statistics for Male <a name=desc_stat_male></a>
```sql
SELECT
    age_range,
    total_powerlifter,
    mean_bw,
    median_bw,
    mode_bw,
    std_bw,
    range_bw
FROM desc_stat_age
WHERE sex = 'M';
```
Output:
|age_range|total_powerlifter|mean_bw|median_bw|mode_bw|std_bw|range_bw|
|---------|-----------------|-------|---------|-------|------|--------|
|14-14    |19243            |70.22  |66       |67.5   |18.85 |175.17  |
|15-19    |253578           |80.60  |78.2     |75     |18.97 |202.35  |
|20-24    |277445           |88.10  |86.3     |90     |18.72 |201.5   |
|25-29    |209055           |92.95  |89.95    |90     |19.78 |252.2   |
|30-34    |156042           |96.21  |93.2     |90     |20.91 |265.1   |
|35-39    |114549           |98.95  |97.7     |90     |21.43 |203.66  |
|40-44    |103069           |99.09  |98       |100    |21.32 |204.42  |
|45-49    |70144            |98.19  |97.3     |100    |20.85 |204.96  |
|50-54    |55274            |96.30  |94.1     |100    |20.39 |165.14  |
|55-59    |36016            |93.61  |90.3     |90     |19.53 |181.3   |
|60-64    |26674            |91.36  |89.5     |82.5   |18.38 |160.5   |
|65-69    |15731            |87.69  |85.68    |90     |17.29 |225.1   |
|70-74    |10616            |85.66  |83.73    |82.5   |15.73 |130.0   |
|75-79    |4592             |82.86  |81.19    |90     |15.39 |158.38  |
|80-84    |1475             |80.45  |79       |100    |14.63 |90.62   |
|85-89    |337              |79.75  |78.2     |82.5   |13.71 |77.15   |
|90-94    |60               |82.20  |79.95    |82.5   |11.39 |58.6    |
|95-97    |24               |76.80  |75       |75     |7.36  |35.5    |

### Descriptive Statistics for Female <a name=desc_stat_female></a>
```sql
SELECT
    age_range,
    total_powerlifter,
    mean_bw,
    median_bw,
    mode_bw,
    std_bw,
    range_bw
FROM desc_stat_age
WHERE sex = 'F'
```
Output:
|age_range|total_powerlifter|mean_bw|median_bw|mode_bw|std_bw|range_bw|
|---------|-----------------|-------|---------|-------|------|--------|
|14-14    |9144             |61.80  |57.6     |52     |16.29 |153.2   |
|15-19    |86570            |64.37  |60.42    |52     |16.42 |154.1   |
|20-24    |87778            |65.00  |62.36    |60     |14.27 |164.5   |
|25-29    |69921            |67.61  |64.9     |60     |16.21 |174.5   |
|30-34    |54018            |69.24  |65.8     |60     |17.92 |171.85  |
|35-39    |42118            |71.18  |67.1     |67.5   |18.70 |183     |
|40-44    |36308            |71.53  |67.5     |67.5   |18.28 |149.75  |
|45-49    |25152            |70.94  |67.5     |75     |17.53 |193.85  |
|50-54    |18230            |70.62  |67.3     |67.5   |17.52 |156.87  |
|55-59    |9893             |69.94  |67.2     |67.5   |16.43 |125.0   |
|60-64    |6192             |69.35  |66.8     |67.5   |16.08 |123.3   |
|65-69    |2947             |67.02  |64.4     |67.5   |14.41 |95.69   |
|70-74    |1604             |66.18  |63.41    |90     |13.95 |69.76   |
|75-79    |584              |65.22  |63.45    |67.5   |13.27 |74.4    |
|80-84    |168              |63.01  |60       |67.5   |13.80 |58.59   |
|85-89    |46               |60.42  |56.6     |55.9   |12.05 |44.95   |
|90-94    |28               |69.46  |69.675   |82.5   |8.79  |34.6    |
|95-98    |7                |67.83  |67.13    |64.35  |5.29  |13.5    |

### Descriptive Statistics for Neutral Gender <a name=desc_stat_neutral></a>
```sql
SELECT
    age_range,
    total_powerlifter,
    mean_bw,
    median_bw,
    mode_bw,
    std_bw,
    range_bw
FROM desc_stat_age
WHERE sex = 'Mx'
```
Output:
|age_range|total_powerlifter|mean_bw|median_bw|mode_bw|std_bw|range_bw|
|---------|-----------------|-------|---------|-------|------|--------|
|16-17    |6                |71.50  |74.05    |61     |8.05  |19.8    |
|21-24    |12               |81.64  |83.005   |51.9   |15.31 |59.6    |
|25-29    |9                |73.18  |73.92    |46.3   |13.89 |52.4    |
|30-33    |8                |91.43  |85.95    |76.9   |13.35 |38.6    |
|35-39    |4                |100.61 |100.15   |75.5   |24.11 |51.15   |
|43-43    |1                |79.70  |79.7     |79.7   |      |0.0     |
|49-49    |1                |111.00 |111      |111    |      |0       |
|53-54    |2                |85.70  |85.7     |83.6   |2.97  |4.2     |
|55-58    |2                |88.60  |88.6     |86.1   |3.54  |5.0     |

## Place query <a name='place_query'></a>
### The most number 1 place <a name='first_place'></a>
#### Top 10 male powerlifter with the most number 1 place <a name=first_male></a>
```sql
SELECT
    name,
    COUNT(*) AS total_first
FROM powerlift_data
WHERE
    place = '1'
    AND
    sex = 'M'
GROUP BY name
ORDER BY total_first DESC
LIMIT 10;
```
Output:
|name|total_first|
|----|-----------|
|Magomedamin Israpilov|270  |
|Evgeniy Svoboda|237        |
|Alan Aerts|219             |
|Gary Teeter|195            |
|Gordon Santee|180          |
|Sverre Paulsen|180         |
|Martin Drake|174           |
|Bob Legg|170               |
|Stefan Sochaňski|170       |
|Vladimir Kulakov|170       |

#### Top 10 female powerlifter with the most number 1 place <a name=first_female></a>
```sql
SELECT
    name,
    COUNT(*) AS total_first
FROM powerlift_data
WHERE
    place = '1'
    AND
    sex = 'F'
GROUP BY name
ORDER BY total_first DESC
LIMIT 10;
```
Output:
|name|total_first|
|----|-----------|
|Bonnie Aerts|225       |
|Judy Gedney|166        |
|Heena Patel|145        |
|Jenny Hunter|128       |
|Hana Takáčová|118      |
|Mary Anderson|117      |
|Jackie Blasbery|109    |
|Ellen Stein|108        |
|Mary Hetzel|107        |
|Betsy Spann|106        |

#### Top 10 neutral gender powerlifter with the most number 1 place <a name=first_neutral></a>
```sql
SELECT
    name,
    COUNT(*) AS total_first
FROM powerlift_data
WHERE
    place = '1'
    AND
    sex = 'Mx'
GROUP BY name
ORDER BY total_first DESC
LIMIT 10;
```
Output:
|name|total_first|
|----|-----------|
|Brett Richmond|6      |
|Ardel Thomas|4        |
|Val Schull|4          |
|Elaine Bradley|3      |
|Adam Henson #2|3      |
|Ryan Frankland|3      |
|Ashton Meaux|2        |
|Angel Flores #1|2     |
|Hannah Newman|2       |
|Andrew Pond|1         |

### Percentage of disqualified powerlifter grouped by year within 5 year range <a name='disq_percent'></a>
```sql
WITH
total_count AS (
    SELECT
        CONCAT(MIN(DATE_PART('year', date))::VARCHAR, '-', MAX(DATE_PART('year', date))::VARCHAR) AS year_range,
        COUNT(*) AS count_participant
    FROM powerlift_data
    GROUP BY FLOOR(DATE_PART('year', date)/5)
),
disq_count AS (
    SELECT
        CONCAT(MIN(DATE_PART('year', date))::VARCHAR, '-', MAX(DATE_PART('year', date))::VARCHAR) AS year_range,
        COUNT(*) AS disq_participant
    FROM powerlift_data
    WHERE place IN ('DQ', 'DD')
    GROUP BY FLOOR(DATE_PART('year', date)/5)
)

SELECT
    disq_count.*,
    ROUND(disq_count.disq_participant / total_count.count_participant::NUMERIC * 100, 2)disq_percent
FROM disq_count
INNER JOIN total_count ON total_count.year_range = disq_count.year_range;
```
Output:
|year_range|disq_participant|disq_percent|
|----------|----------------|------------|
|1964-1964 |3               |7.69        |
|1965-1969 |31              |8.81        |
|1970-1974 |104             |8.97        |
|1975-1979 |337             |5.65        |
|1980-1984 |7615            |6.15        |
|1985-1989 |2678            |5.35        |
|1990-1994 |3161            |5.80        |
|1995-1999 |4293            |5.31        |
|2000-2004 |8238            |6.16        |
|2005-2009 |15598           |8.42        |
|2010-2014 |42342           |7.98        |
|2015-2019 |66047           |5.78        |
|2020-2023 |28982           |5.30        |

### Top 5 country with the most number 1 place <a name='country_first'></a>
```sql
SELECT
    country,
    COUNT(*) AS total_first
FROM powerlift_data
WHERE
    country IS NOT NULL
GROUP BY
    country
ORDER BY total_first DESC
LIMIT 5;
```
Output:
|country|total_first|
|-------|-----------|
|USA    |736878     |
|Russia |272123     |
|Ukraine|83071      |
|Canada |62009      |
|England|50849      |

## Equipment Query <a name='equipment_query'></a>
### Percentage of each equipment used by powerlifter <a name='equip_percent'></a>
```sql
WITH
group_equip AS (
    SELECT
        equipment,
        COUNT(*) AS count_equip
    FROM powerlift_data
    GROUP BY equipment
)

SELECT 
    equipment,
    count_equip,
    ROUND(count_equip/(SELECT COUNT(*) FROM powerlift_data)::NUMERIC * 100, 2) AS percentage
FROM group_equip
ORDER BY percentage DESC;
```
Output:
|equipment |count_equip|percentage|
|----------|-----------|----------|
|Single-ply|1318852    |46.1800   |
|Raw       |1219842    |42.7132   |
|Wraps     |187573     |6.5679    |
|Multi-ply |121392     |4.2506    |
|Unlimited |8185       |0.2866    |
|Straps    |48         |0.0017    |

### Top lift for each equipment <a name='top_lift_equip'></a>
```sql
CREATE TABLE best_lift_equip (
    equipment VARCHAR,
    sex VARCHAR,
    max_squat NUMERIC,
    max_bench NUMERIC,
    max_deadlift NUMERIC
);

INSERT INTO best_lift_equip (
    equipment,
    sex,
    max_squat,
    max_bench,
    max_deadlift
)
SELECT
    equipment,
    sex,
    MAX(best3squatkg) AS max_squat,
    MAX(best3benchkg) AS max_bench,
    MAX(best3deadliftkg) AS max_deadlift
FROM powerlift_data
GROUP BY
    equipment,
    sex
```
Output:
> INSERT successfully executed. 14 rows were affected.

#### Top lift for male powerlifter group by equipment <a name='top_lift_equip_male'></a>
##### Top squat <a name='top_squat_male'></a>
```sql
SELECT
    equipment,
    max_squat
FROM best_lift_equip
WHERE sex = 'M'
ORDER BY max_squat DESC;
```
Output
|equipment |max_squat|
|----------|---------|
|Multi-ply |595      |
|Wraps     |525      |
|Single-ply|517.5    |
|Unlimited |515      |
|Raw       |490      |
|Straps    |265      |

##### Top bench <a name='top_bench_male'></a>
```sql
SELECT
    equipment,
    max_bench
FROM best_lift_equip
WHERE sex = 'M'
ORDER BY max_bench DESC;
```
Output:
|equipment |max_bench|
|----------|---------|
|Unlimited |612.5    |
|Single-ply|508.02   |
|Multi-ply |500      |
|Raw       |355      |
|Wraps     |306.17   |
|Straps    |150      |

##### Top deadlift <a name='top_deadlift_male'></a>
```sql
SELECT
    equipment,
    max_deadlift
FROM best_lift_equip
WHERE sex = 'M'
ORDER BY max_deadlift DESC;
```
Output:
|equipment |max_deadlift|
|----------|------------|
|Raw       |487.5       |
|Multi-ply |457.5       |
|Straps    |454.14      |
|Wraps     |442.5       |
|Single-ply|439.98      |
|Unlimited |385.55      |

Insight:
* Top squat by male powerlifter achieved when equipment is multi-ply, which is 595 kg.
* Top bench by male powerlifter achieved when equipment is unlimited, which is 612.5 kg.
* Top deadlift by male powerlifter achieved when equipment is raw, which is 487.5 kg.

#### Top lift for female powerlifter group by equipment <a name='top_lift_equip_female'></a>
##### Top squat <a name='top_squat_female'></a>
```sql
SELECT
    equipment,
    max_squat
FROM best_lift_equip
WHERE sex = 'F'
ORDER BY max_squat DESC NULLS LAST;
```
Output:
|equipment |max_squat|
|----------|---------|
|Multi-ply |419.57   |
|Single-ply|335      |
|Wraps     |320      |
|Unlimited |310.71   |
|Raw       |280      |
|Straps    |         |

##### Top bench <a name='top_bench_female'></a>
```sql
SELECT
    equipment,
    max_bench
FROM best_lift_equip
WHERE sex = 'F'
ORDER BY max_bench DESC NULLS LAST;
```
Output:
|equipment |max_bench|
|----------|---------|
|Unlimited |294.84   |
|Multi-ply |272.5    |
|Single-ply|242.5    |
|Raw       |207.5    |
|Wraps     |200      |
|Straps    |         |

##### Top deadlift <a name='top_deadlift_female'></a>
```sql
SELECT
    equipment,
    max_deadlift
FROM best_lift_equip
WHERE sex = 'F'
ORDER BY max_deadlift DESC;
```
Output:
|equipment |max_deadlift|
|----------|------------|
|Multi-ply |315         |
|Single-ply|295         |
|Raw       |290         |
|Wraps     |287         |
|Unlimited |235.87      |
|Straps    |187.5       |

Insight:
* Top squat by female powerlifter achieved when equipment is multi-ply, which is 419.57 kg.
* Top bench by female powerlifter achieved when equipment is unlimited, which is 294.84 kg.
* Top deadlift by female powerlifter achieved when equipment is multi-ply, which is 315 kg.

#### Top lift for neutral gender powerlifter group by equipment <a name='top_lift_equip_neutral'></a>
##### Top squat <a name='top_squat_neutral'></a>
```sql
SELECT
    equipment,
    max_squat
FROM best_lift_equip
WHERE sex = 'Mx'
ORDER BY max_squat DESC;
```
Output:
|equipment |max_squat|
|----------|---------|
|Wraps     |207.5    |
|Raw       |175      |

##### Top bench <a name='top_bench_neutral'></a>
```sql
SELECT
    equipment,
    max_bench
FROM best_lift_equip
WHERE sex = 'Mx'
ORDER BY max_bench DESC;
```
Output:
|equipment |max_bench|
|----------|---------|
|Wraps     |125      |
|Raw       |110      |

##### Top deadlift <a name='top_deadlift_neutral'></a>
```sql
SELECT
    equipment,
    max_deadlift
FROM best_lift_equip
WHERE sex = 'Mx'
ORDER BY max_deadlift DESC;
```
Output:
|equipment |max_deadlift|
|----------|------------|
|Wraps     |205         |
|Raw       |200         |

Insight:
* Top squat by neutral gender powerlifter achieved when equipment is wraps, which is 207.5 kg.
* Top bench by neutral gender powerlifter achieved when equipment is wraps, which is 125 kg.
* Top deadlift by neutral gender powerlifter achieved when equipment is wraps, which is 205 kg.