WITH
total_count AS (
    SELECT
        CONCAT(MIN(DATE_PART('year', date))::VARCHAR, '-', MAX(DATE_PART('year', date))::VARCHAR) AS year_range,
        COUNT(*) AS count_participant
    FROM powerlift_data
    GROUP BY FLOOR(DATE_PART('year', date)/5)
),
disq_count AS (
    SELECT
        CONCAT(MIN(DATE_PART('year', date))::VARCHAR, '-', MAX(DATE_PART('year', date))::VARCHAR) AS year_range,
        COUNT(*) AS disq_participant
    FROM powerlift_data
    WHERE place IN ('DQ', 'DD')
    GROUP BY FLOOR(DATE_PART('year', date)/5)
)

SELECT
    disq_count.*,
    ROUND(disq_count.disq_participant / total_count.count_participant::NUMERIC * 100, 2)disq_percent
FROM disq_count
INNER JOIN total_count ON total_count.year_range = disq_count.year_range;
