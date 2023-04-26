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