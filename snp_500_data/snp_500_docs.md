## Calculate monthly returns for each stock
Because there are 500 stocks, it would be too much to list all of them, so we will list top 5 the highest and lowest return.
```sql
(SELECT
    company,
    ROUND(AVG((close - open)/open)*100, 2) AS monthly_return_percent
FROM snp_500_prices
GROUP BY company
ORDER BY monthly_return_percent DESC
LIMIT 5)
UNION ALL
(SELECT
    company,
    ROUND(AVG((close - open)/open)*100, 2) AS monthly_return_percent
FROM snp_500_prices
GROUP BY company
ORDER BY monthly_return_percent DESC
LIMIT 5
OFFSET 496);
```
Output:
|company|monthly_return_percent|
|-------|----------------------|
|GEHC   |11.41                 |
|ENPH   |9.41                  |
|MRNA   |7.16                  |
|TSLA   |5.17                  |
|DXCM   |4.42                  |
|DISH   |-1.43                 |
|VFC    |-1.44                 |
|CCL    |-1.44                 |
|OGN    |-1.61                 |
|VTRS   |-1.95                 |

## Create yearly table
Before we move into next query, we will create table that contains yearly prices only, because most likely we will use this table frequently.

### Yearly stocks table
```sql
CREATE TABLE snp_500_yearly_stocks (
    company VARCHAR,
    security VARCHAR,
    gics_sector VARCHAR,
    gics_sub_industry VARCHAR,
    founded VARCHAR,
    open NUMERIC,
    close NUMERIC,
    year INTEGER
);

INSERT INTO snp_500_yearly_stocks(
    company,
    security,
    gics_sector,
    gics_sub_industry,
    founded,
    open,
    close,
    year
)
WITH
opening_filter AS (
    SELECT
        company,
        MIN(month) AS min_month,
        year
    FROM snp_500_prices
    GROUP BY company, year
),
opening_year AS (
    SELECT
        snp_500_prices.*
    FROM snp_500_prices
    INNER JOIN opening_filter ON
        snp_500_prices.company = opening_filter.company
        AND
        snp_500_prices.year = opening_filter.year
        AND
        snp_500_prices.month = opening_filter.min_month
),
closing_filter AS (
    SELECT
        company,
        MAX(month) AS max_month,
        year
    FROM snp_500_prices
    GROUP BY company, year
),
closing_year AS (
    SELECT
        snp_500_prices.*
    FROM snp_500_prices
    INNER JOIN closing_filter ON
        snp_500_prices.company = closing_filter.company
        AND
        snp_500_prices.year = closing_filter.year
        AND
        snp_500_prices.month = closing_filter.max_month
)
SELECT
    opening_year.company,
    opening_year.security,
    opening_year.gics_sector,
    opening_year.gics_sub_industry,
    opening_year.founded,
    opening_year.open,
    closing_year.close,
    opening_year.year
FROM opening_year
INNER JOIN closing_year ON
    opening_year.year = closing_year.year
    AND
    opening_year.company = closing_year.company;
```
Output:
> INSERT successfully executed. 2985 rows were affected.

### Yearly index table
```sql
CREATE TABLE snp_500_yearly_index (
    company VARCHAR,
    open NUMERIC,
    close NUMERIC,
    year INTEGER
);

INSERT INTO snp_500_yearly_index(
    company,
    open,
    close,
    year
)
WITH
opening_filter AS (
    SELECT
        company,
        MIN(month) AS min_month,
        year
    FROM snp_500_index
    GROUP BY company, year
),
opening_year AS (
    SELECT
        snp_500_index.*
    FROM snp_500_index
    INNER JOIN opening_filter ON
        snp_500_index.company = opening_filter.company
        AND
        snp_500_index.year = opening_filter.year
        AND
        snp_500_index.month = opening_filter.min_month
),
closing_filter AS (
    SELECT
        company,
        MAX(month) AS max_month,
        year
    FROM snp_500_index
    GROUP BY company, year
),
closing_year AS (
    SELECT
        snp_500_index.*
    FROM snp_500_index
    INNER JOIN closing_filter ON
        snp_500_index.company = closing_filter.company
        AND
        snp_500_index.year = closing_filter.year
        AND
        snp_500_index.month = closing_filter.max_month
)
SELECT
    opening_year.company,
    opening_year.open,
    closing_year.close,
    opening_year.year
FROM opening_year
INNER JOIN closing_year ON
    opening_year.year = closing_year.year
    AND
    opening_year.company = closing_year.company;
```
Output:
> INSERT successfully executed. 6 rows were affected.

### Yearly us treasure table
```sql
CREATE TABLE yearly_us_treasure (
    company VARCHAR,
    open NUMERIC,
    close NUMERIC,
    year INTEGER
);

INSERT INTO yearly_us_treasure(
    company,
    open,
    close,
    year
)
WITH
opening_filter AS (
    SELECT
        company,
        MIN(month) AS min_month,
        year
    FROM us_treasure
    GROUP BY company, year
),
opening_year AS (
    SELECT
        us_treasure.*
    FROM us_treasure
    INNER JOIN opening_filter ON
        us_treasure.company = opening_filter.company
        AND
        us_treasure.year = opening_filter.year
        AND
        us_treasure.month = opening_filter.min_month
),
closing_filter AS (
    SELECT
        company,
        MAX(month) AS max_month,
        year
    FROM us_treasure
    GROUP BY company, year
),
closing_year AS (
    SELECT
        us_treasure.*
    FROM us_treasure
    INNER JOIN closing_filter ON
        us_treasure.company = closing_filter.company
        AND
        us_treasure.year = closing_filter.year
        AND
        us_treasure.month = closing_filter.max_month
)
SELECT
    opening_year.company,
    opening_year.open,
    closing_year.close,
    opening_year.year
FROM opening_year
INNER JOIN closing_year ON
    opening_year.year = closing_year.year
    AND
    opening_year.company = closing_year.company;
```
Output:
> INSERT successfully executed. 6 rows were affected.

Next we will add new column called `yearly_return_percent` to each new table to avoid redundancy task in the next query.
```sql
ALTER TABLE snp_500_yearly_index
ADD COLUMN yearly_return_percent NUMERIC;

ALTER TABLE snp_500_yearly_stocks
ADD COLUMN yearly_return_percent NUMERIC;

ALTER TABLE yearly_us_treasure
ADD COLUMN yearly_return_percent NUMERIC;

UPDATE snp_500_yearly_index
SET yearly_return_percent = (
    SELECT (close-open)/open * 100
);

UPDATE snp_500_yearly_stocks
SET yearly_return_percent = (
    SELECT (close-open)/open * 100
);

UPDATE yearly_us_treasure
SET yearly_return_percent = (
    SELECT (close-open)/open * 100
);
```
Output:
> UPDATE successfully executed.

## Most profitable sectors each year
```sql
WITH
sector_yearly_return AS (
    SELECT
        gics_sector,
        year,
        AVG(yearly_return_percent) AS yearly_return_percent
    FROM snp_500_yearly_stocks
    GROUP BY
        gics_sector,
        year
),
max_yearly_return AS (
    SELECT
        year,
        MAX(yearly_return_percent) AS max_return_percent
    FROM sector_yearly_return
    GROUP BY year
)

SELECT
    sector_yearly_return.gics_sector,
    sector_yearly_return.year,
    ROUND(sector_yearly_return.yearly_return_percent, 2) AS yearly_return_percent
FROM sector_yearly_return
INNER JOIN max_yearly_return ON
    sector_yearly_return.year = max_yearly_return.year
    AND
    sector_yearly_return.yearly_return_percent = max_yearly_return.max_return_percent
ORDER BY year
```
Output:
|year|gics_sector           |yearly_return_percent|
|----|----------------------|---------------------|
|2018|Health Care           |6.82                 |
|2019|Information Technology|60.60                |
|2020|Information Technology|48.92                |
|2021|Energy                |61.83                |
|2022|Energy                |58.99                |
|2023|Information Technology|14.29                |

## Sectors that have outperformed the S&P 500 index in each year
```sql
WITH
index_yearly_return AS (
    SELECT
        year,
        ROUND((close-open)/open*100, 2) AS yearly_return_percent
    FROM snp_500_yearly_index
),
sector_yearly_return AS (
    SELECT
        gics_sector,
        year,
        ROUND(AVG((close - open)/open) * 100, 2) AS yearly_return_percent
    FROM snp_500_yearly_stocks
    GROUP BY
        gics_sector,
        year
)

SELECT
    sector_yearly_return.year,
    sector_yearly_return.gics_sector,
    sector_yearly_return.yearly_return_percent
FROM sector_yearly_return
INNER JOIN index_yearly_return
ON sector_yearly_return.year = index_yearly_return.year
WHERE sector_yearly_return.yearly_return_percent > index_yearly_return.yearly_return_percent
ORDER BY
    year,
    yearly_return_percent;
```
Output:
|year|gics_sector           |yearly_return_percent|
|----|----------------------|---------------------|
|2018|Consumer Staples      |-5.27                |
|2018|Consumer Discretionary|-4.58                |
|2018|Real Estate           |-3.19                |
|2018|Information Technology|3.72                 |
|2018|Utilities             |6.11                 |
|2018|Health Care           |6.82                 |
|2019|Real Estate           |30.57                |
|2019|Health Care           |32.00                |
|2019|Communication Services|32.54                |
|2019|Consumer Discretionary|33.17                |
|2019|Industrials           |38.20                |
|2019|Financials            |38.38                |
|2019|Information Technology|60.60                |
|2020|Industrials           |18.87                |
|2020|Materials             |18.89                |
|2020|Communication Services|20.79                |
|2020|Health Care           |28.86                |
|2020|Consumer Discretionary|32.23                |
|2020|Information Technology|48.92                |
|2021|Financials            |29.41                |
|2021|Materials             |30.91                |
|2021|Consumer Discretionary|31.57                |
|2021|Information Technology|36.43                |
|2021|Real Estate           |50.13                |
|2021|Energy                |61.83                |
|2022|Financials            |-9.55                |
|2022|Materials             |-9.21                |
|2022|Industrials           |-8.64                |
|2022|Health Care           |-7.60                |
|2022|Consumer Staples      |2.88                 |
|2022|Utilities             |5.21                 |
|2022|Energy                |58.99                |
|2023|Consumer Discretionary|8.36                 |
|2023|Communication Services|10.30                |
|2023|Information Technology|14.29                |

## Yearly Sharpe ratio: [Return - Risk-Free Rate] / StDev([Return - Risk-Free Rate]). Where the Risk-Free rate is US Treasure 10Y rates
```sql
SELECT
    snp_500_yearly_index.year,
    ROUND((snp_500_yearly_index.yearly_return_percent - yearly_us_treasure.yearly_return_percent) / (STDDEV(snp_500_yearly_index.yearly_return_percent - yearly_us_treasure.yearly_return_percent) OVER()), 2) AS sharpe_ratio
FROM snp_500_yearly_index
INNER JOIN yearly_us_treasure
ON snp_500_yearly_index.year = yearly_us_treasure.year
ORDER BY year;
```
Output:
|year|sharpe_ratio|
|----|------------|
|2018|-0.19       |
|2019|0.66        |
|2020|0.77        |
|2021|-0.40       |
|2022|-1.97       |
|2023|0.16        |

## Sectors that have the best sharpe ratio in each year
```sql
WITH
sector_yearly_return AS (
    SELECT
        gics_sector,
        year,
        AVG((close - open)/open) * 100 AS yearly_return_percent
    FROM snp_500_yearly_stocks
    GROUP BY
        gics_sector,
        year
),
sector_treasure_differ AS (
    SELECT
        gics_sector,
        sector_yearly_return.year,
        (sector_yearly_return.yearly_return_percent - yearly_us_treasure.yearly_return_percent) AS yearly_return_differ
    FROM sector_yearly_return
    INNER JOIN yearly_us_treasure ON
        sector_yearly_return.year = yearly_us_treasure.year
),
std_dev_sector_treasure_differ AS (
    SELECT
        gics_sector,
        STDDEV(yearly_return_differ) AS std_dev_yearly_return_differ
    FROM sector_treasure_differ
    GROUP BY
        gics_sector
),
sector_sharpe_ratio AS (
    SELECT
        sector_treasure_differ.year,
        sector_treasure_differ.gics_sector,
        sector_treasure_differ.yearly_return_differ/std_dev_sector_treasure_differ.std_dev_yearly_return_differ AS sharpe_ratio
    FROM sector_treasure_differ
    INNER JOIN std_dev_sector_treasure_differ ON
        sector_treasure_differ.gics_sector = std_dev_sector_treasure_differ.gics_sector
),
best_sharpe_ratio AS (
    SELECT
        year,
        MAX(sharpe_ratio) AS sharpe_ratio
    FROM sector_sharpe_ratio
    GROUP BY year
)

SELECT
    sector_sharpe_ratio.year,
    sector_sharpe_ratio.gics_sector,
    ROUND(sector_sharpe_ratio.sharpe_ratio, 3) AS sharpe_ratio
FROM sector_sharpe_ratio
INNER JOIN best_sharpe_ratio ON
    sector_sharpe_ratio.year = best_sharpe_ratio.year
    AND
    sector_sharpe_ratio.sharpe_ratio = best_sharpe_ratio.sharpe_ratio
ORDER BY year;
```
Output:
|year|gics_sector|sharpe_ratio                               |
|----|-----------|-------------------------------------------|
|2018|Health Care|-0.042                                     |
|2019|Information Technology|0.882                                      |
|2020|Information Technology|1.007                                      |
|2021|Energy     |0.003                                      |
|2022|Information Technology|-1.759                                     |
|2023|Information Technology|0.213                                      |


Insight: information technology is the sector with the best sharpe ratio at the most (4 times), which are in 2019, 2020, 2022, and 2023 (even though the year 2023 is not completed yet).

6) What might be the reasons for observed trends? What trends should we expect for 2023?
7) What trading strategy would you choose regarding the S&P 500 stocks?