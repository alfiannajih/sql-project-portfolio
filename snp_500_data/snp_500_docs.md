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

## Most profitable sectors and industries each year
```sql
WITH
industry_monthly_return AS (
    SELECT
        gics_sub_industry,
        year,
        ROUND(AVG((close - open)/open)*100, 2) AS monthly_return_percent
    FROM snp_500_prices
    GROUP BY
        gics_sub_industry,
        year
    ORDER BY monthly_return_percent DESC
),
max_return_year AS (
    SELECT
        year,
        MAX(monthly_return_percent) AS max_return
    FROM industry_monthly_return
    GROUP BY year
)

SELECT
    industry_monthly_return.year,
    industry_monthly_return.gics_sub_industry,
    industry_monthly_return.monthly_return_percent
FROM industry_monthly_return
INNER JOIN max_return_year
ON industry_monthly_return.year = max_return_year.year AND industry_monthly_return.monthly_return_percent = max_return_year.max_return
ORDER BY year;
```
Output:
|year                               |gics_sub_industry|monthly_return_percent|
|-----------------------------------|-----------------|----------------------|
|2018                               |Electronic Components|3.46                  |
|2019                               |Semiconductor Materials & Equipment|6.44                  |
|2020                               |Copper           |10.09                 |
|2021                               |Steel            |4.98                  |
|2022                               |Integrated Oil & Gas|4.99                  |
|2023                               |Broadcasting     |16.81                 |

3) What sectors and specific stocks have outperformed the S&P 500 index in each year?
4) Calculate the yearly Sharpe ratio: [Return - Risk-Free Rate] / StDev([Return - Risk-Free Rate]). For the Risk-Free rate you might want to use UST 10Y rates
5) What stocks and sectors have the best risk-adjusted returns (shape ratio) in each year?
6) What might be the reasons for observed trends? What trends should we expect for 2023?
7) What trading strategy would you choose regarding the S&P 500 stocks?