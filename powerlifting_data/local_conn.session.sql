WITH
age_quartile AS (
    SELECT
        name,
        age,
        NTILE(4) OVER (ORDER BY age) AS quartile
    FROM powerlift_data
),
quart_1_3 AS(
    SELECT
        quartile,
        MAX(age) AS age
    FROM age_quartile
    WHERE quartile IN (1, 3)
    GROUP BY quartile
)
