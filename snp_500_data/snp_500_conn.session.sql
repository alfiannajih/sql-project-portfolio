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
ORDER BY year
