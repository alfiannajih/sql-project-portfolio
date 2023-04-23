SELECT
    CONCAT(MIN(DATE_PART('year', date))::VARCHAR, '-', MAX(DATE_PART('year', date))::VARCHAR) AS year_range,
    sex,
    ROUND(AVG(best3deadliftkg), 2) AS average_deadlift
FROM powerlift_data
WHERE
    best3deadliftkg > 0
GROUP BY
    FLOOR(DATE_PART('year', date)/5),
    sex
ORDER BY
    year_range,
    sex