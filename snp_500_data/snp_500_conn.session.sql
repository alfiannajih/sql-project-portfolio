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
LIMIT 5