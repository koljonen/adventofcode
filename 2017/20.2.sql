WITH RECURSIVE Input AS (
    SELECT read_file('/Users/joakimkoljonen/src/adventofcode/2017/20.input') AS Input
), Particles AS (
    SELECT
        0 AS Step,
        Positions[1]::bigint AS Position1, Positions[2]::bigint AS Position2, Positions[3]::bigint AS Position3,
        Velocities[1]::bigint AS Velocity1, Velocities[2]::bigint AS Velocity2, Velocities[3]::bigint AS Velocity3,
        Accelerations[1]::bigint AS Acceleration1, Accelerations[2]::bigint AS Acceleration2, Accelerations[3]::bigint AS Acceleration3,
        FALSE AS Collision
    FROM Input
    CROSS JOIN LATERAL regexp_split_to_table(Input, '\n') Lines
    CROSS JOIN LATERAL regexp_split_to_array(Lines, ', ') Types
    CROSS JOIN LATERAL regexp_split_to_array(REPLACE(REPLACE(Types[1], 'p=<', ''), '>', ''), ',') Positions
    CROSS JOIN LATERAL regexp_split_to_array(REPLACE(REPLACE(Types[2], 'v=<', ''), '>', ''), ',') Velocities
    CROSS JOIN LATERAL regexp_split_to_array(REPLACE(REPLACE(Types[3], 'a=<', ''), '>', ''), ',') Accelerations
    WHERE Lines <> ''
    UNION ALL
    SELECT *
    FROM (
        WITH NewParticles AS (
            SELECT
                Step + 1,
                Position1 + Velocity1 + Acceleration1 AS Position1, Position2 + Velocity2 + Acceleration2 AS Position2, Position3 + Velocity3 + Acceleration3 AS Position3,
                Velocity1 + Acceleration1 AS Velocity1, Velocity2 + Acceleration2 AS Velocity2, Velocity3 + Acceleration3 AS Velocity3,
                Acceleration1, Acceleration2, Acceleration3
            FROM Particles
            WHERE Step < 1234 AND Collision IS FALSE
        )
        SELECT *, COUNT(*) OVER(PARTITION BY Position1, Position2, Position3) > 1 AS Collision
        FROM NewParticles
    ) CTE
)
SELECT COUNT(*)
FROM Particles
WHERE Step = (SELECT MAX(Step) FROM Particles);
