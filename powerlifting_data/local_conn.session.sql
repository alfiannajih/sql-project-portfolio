WITH 
squat_lift AS (
    SELECT
        squat1kg,
        squat2kg,
        squat3kg
    FROM powerlift_data
    WHERE
        event = 'SBD'
        AND
        squat1kg IS NOT NULL
        AND
        squat2kg IS NOT NULL
        AND
        squat3kg IS NOT NULL
)

SELECT
    ROUND((SELECT COUNT(squat1kg) FROM squat_lift WHERE squat1kg > 0)::NUMERIC / COUNT(squat1kg) * 100, 2) AS squat_1_precentage,
    ROUND((SELECT COUNT(squat2kg) FROM squat_lift WHERE squat2kg > 0)::NUMERIC / COUNT(squat2kg) * 100, 2) AS squat_2_precentage,
    ROUND((SELECT COUNT(squat3kg) FROM squat_lift WHERE squat3kg > 0)::NUMERIC / COUNT(squat3kg) * 100, 2) AS squat_3_percentage
FROM squat_lift