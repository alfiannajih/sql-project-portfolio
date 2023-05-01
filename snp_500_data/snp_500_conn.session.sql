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
