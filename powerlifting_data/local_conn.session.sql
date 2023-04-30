/*
SELECT
    equipment,
    max_squat
FROM best_lift_equip
WHERE sex = 'M'
ORDER BY max_squat DESC;

SELECT
    equipment,
    max_bench
FROM best_lift_equip
WHERE sex = 'M'
ORDER BY max_bench DESC;

SELECT
    equipment,
    max_deadlift
FROM best_lift_equip
WHERE sex = 'M'
ORDER BY max_deadlift DESC;
*/

SELECT
    equipment,
    max_deadlift
FROM best_lift_equip
WHERE sex = 'Mx'
ORDER BY max_deadlift DESC;