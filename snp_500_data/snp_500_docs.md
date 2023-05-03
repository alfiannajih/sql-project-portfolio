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

## Most profitable sectors each year
```sql
WITH
sector_monthly_return AS (
    SELECT
        gics_sector,
        year,
        ROUND(AVG((close - open)/open)*100, 2) AS monthly_return_percent
    FROM snp_500_prices
    GROUP BY
        gics_sector,
        year
    ORDER BY monthly_return_percent DESC
),
max_return_year AS (
    SELECT
        year,
        MAX(monthly_return_percent) AS max_return
    FROM sector_monthly_return
    GROUP BY year
)

SELECT
    sector_monthly_return.year,
    sector_monthly_return.gics_sector,
    sector_monthly_return.monthly_return_percent
FROM sector_monthly_return
INNER JOIN max_return_year
ON sector_monthly_return.year = max_return_year.year AND sector_monthly_return.monthly_return_percent = max_return_year.max_return
ORDER BY year;
```
Output:
|year|gics_sector|monthly_return_percent|
|----|-----------|----------------------|
|2018|Health Care|0.55                  |
|2019|Information Technology|3.40                  |
|2020|Information Technology|3.67                  |
|2021|Real Estate|2.68                  |
|2022|Energy     |3.99                  |
|2023|Information Technology|4.49                  |

## Sectors that have outperformed the S&P 500 index in each year
```sql
WITH
index_yearly_return AS (
    SELECT
        year,
        ROUND(AVG((close-open)/open)*100, 2) AS yearly_return_percent
    FROM snp_500_index
    GROUP BY year
),
sector_yearly_return AS (
    SELECT
        year,
        gics_sector,
        ROUND(AVG((close-open)/open)*100, 2) AS yearly_return_percent
    FROM snp_500_prices
    GROUP BY
        year,
        gics_sector
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
|2018|Communication Services|-0.45                |
|2018|Real Estate           |-0.36                |
|2018|Information Technology|0.22                 |
|2018|Utilities             |0.32                 |
|2018|Health Care           |0.55                 |
|2019|Health Care           |2.18                 |
|2019|Communication Services|2.24                 |
|2019|Consumer Discretionary|2.26                 |
|2019|Industrials           |2.47                 |
|2019|Financials            |2.48                 |
|2019|Information Technology|3.40                 |
|2020|Industrials           |1.85                 |
|2020|Materials             |1.94                 |
|2020|Communication Services|2.14                 |
|2020|Health Care           |2.24                 |
|2020|Consumer Discretionary|3.21                 |
|2020|Information Technology|3.67                 |
|2021|Information Technology|1.91                 |
|2021|Energy                |2.58                 |
|2021|Real Estate           |2.68                 |
|2022|Materials             |-0.90                |
|2022|Financials            |-0.87                |
|2022|Industrials           |-0.86                |
|2022|Health Care           |-0.83                |
|2022|Consumer Staples      |0.03                 |
|2022|Utilities             |0.15                 |
|2022|Energy                |3.99                 |
|2023|Consumer Discretionary|2.98                 |
|2023|Communication Services|3.76                 |
|2023|Information Technology|4.49                 |

## Yearly Sharpe ratio: [Return - Risk-Free Rate] / StDev([Return - Risk-Free Rate]). Where the Risk-Free rate is US Treasure 10Y rates
```sql
WITH
yearly_risk_free AS (
    SELECT
        year,
        ROUND(AVG((close-open)/open), 3) AS risk_free_rate
    FROM us_treasure
    GROUP BY year
),
yearly_return_stock AS (
    SELECT
        year,
        ROUND(AVG((close-open)/open), 3) AS yearly_return
    FROM snp_500_prices
    GROUP BY year
)

SELECT
    yearly_return_stock.year,
    ROUND((yearly_return_stock.yearly_return - yearly_risk_free.risk_free_rate) / (STDDEV(yearly_return_stock.yearly_return - yearly_risk_free.risk_free_rate) OVER()), 2) AS sharpe_ratio
FROM yearly_return_stock
INNER JOIN yearly_risk_free
ON yearly_return_stock.year = yearly_risk_free.year
ORDER BY year;
```
Output:
|year|sharpe_ratio          |
|----|----------------------|
|2018|-0.15                 |
|2019|0.79                  |
|2020|1.00                  |
|2021|-0.52                 |
|2022|-1.70                 |
|2023|0.44                  |

## Sectors that have the best sharpe ratio in each year
```sql
WITH
yearly_risk_free AS (
    SELECT
        year,
        ROUND(AVG((close-open)/open), 3) AS risk_free_rate
    FROM us_treasure
    GROUP BY year
),
sector_yearly_return AS (
    SELECT
        year,
        gics_sector,
        ROUND(AVG((close-open)/open), 3) AS yearly_return
    FROM snp_500_prices
    GROUP BY
        year,
        gics_sector
),
sector_sharpe_ratio AS (
    SELECT
        sector_yearly_return.year,
        gics_sector,
        ROUND((sector_yearly_return.yearly_return - yearly_risk_free.risk_free_rate) / (STDDEV(sector_yearly_return.yearly_return - yearly_risk_free.risk_free_rate) OVER()), 2) AS sharpe_ratio
    FROM sector_yearly_return
    INNER JOIN yearly_risk_free
    ON sector_yearly_return.year = yearly_risk_free.year
),
best_sharpe_ratio AS (
    SELECT
        year,
        MAX(sharpe_ratio) AS max_sharpe_ratio
    FROM sector_sharpe_ratio
    GROUP BY year
)

SELECT
    sector_sharpe_ratio.*
FROM sector_sharpe_ratio
INNER JOIN best_sharpe_ratio ON
    sector_sharpe_ratio.year = best_sharpe_ratio.year
    AND
    sector_sharpe_ratio.sharpe_ratio = best_sharpe_ratio.max_sharpe_ratio
ORDER BY year;
```
Output:
|year|gics_sector|sharpe_ratio|
|----|-----------|------------|
|2018|Health Care|0.02        |
|2019|Information Technology|1.05        |
|2020|Information Technology|1.40        |
|2021|Real Estate|-0.35       |
|2022|Energy     |-0.96       |
|2023|Information Technology|1.07        |


Insight: information technology is the sector with the best sharpe ratio at the most (3 times), which are in 2019, 2020, and 2023 (even though the year 2023 is not completed yet). In fact it has sharpe ratio greater than 1, which is considered as good.

Let's analyze this sector further, first create table that contains only this sector in order to avoid redundancy.
```sql
CREATE TABLE it_stocks (LIKE snp_500_prices);

INSERT INTO it_stocks (
    sess_id,
    company,
    security,
    gics_sector,
    gics_sub_industry,
    founded,
    open,
    high,
    low,
    close,
    volume,
    dividends,
    stock_splits,
    year,
    month,
    day
)
SELECT * FROM snp_500_prices WHERE gics_sector ='Information Technology';
```
Output:
> INSERT successfully executed. 4154 rows were affected.

## Top 5 company from information technology with highest total return from the 2018 till now (Jan-2018 - March-2023)
```sql
WITH
open_year AS (
    SELECT
        company,
        MIN(year) AS min_year,
        MIN(month) AS min_month
    FROM it_stocks
    GROUP BY company
),
open_price_stocks AS (
    SELECT
        it_stocks.company,
        open
    FROM it_stocks
    INNER JOIN open_year ON
        it_stocks.year = open_year.min_year
        AND
        it_stocks.company = open_year.company
        AND
        it_stocks.month = open_year.min_month
),
close_year AS (
    SELECT
        company,
        MAX(year) AS max_year,
        3 AS max_month
    FROM it_stocks
    GROUP BY company
),
close_price_stocks AS (
    SELECT
        it_stocks.company,
        close
    FROM it_stocks
    INNER JOIN close_year ON
        it_stocks.year = close_year.max_year
        AND
        it_stocks.company = close_year.company
        AND
        it_stocks.month = close_year.max_month
)

SELECT
    open_price_stocks.company,
    ROUND((close-open)/open * 100, 2) AS total_return_percent
FROM open_price_stocks
INNER JOIN close_price_stocks ON
    open_price_stocks.company = close_price_stocks.company
ORDER BY total_return_percent DESC
LIMIT 5;
```
Output:
|company|total_return_percent|
|-------|--------------------|
|ENPH   |10400.00            |
|AMD    |880.00              |
|SEDG   |700.00              |
|FTNT   |633.33              |
|NVDA   |479.17              |

6) What might be the reasons for observed trends? What trends should we expect for 2023?
7) What trading strategy would you choose regarding the S&P 500 stocks?