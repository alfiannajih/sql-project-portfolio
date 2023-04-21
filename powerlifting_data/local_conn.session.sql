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