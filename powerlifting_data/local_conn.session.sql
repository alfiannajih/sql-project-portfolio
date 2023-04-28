WITH
group_equip AS (
    SELECT
        equipment,
        COUNT(*) AS count_equip
    FROM powerlift_data
    GROUP BY equipment
)

SELECT 
    equipment,
    count_equip,
    ROUND(count_equip/(SELECT COUNT(*) FROM powerlift_data)::NUMERIC * 100, 4) AS percentage
FROM group_equip
ORDER BY percentage DESC;
