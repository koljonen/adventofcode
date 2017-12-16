ROLLBACK;
BEGIN;

CREATE TEMPORARY TABLE Parse AS
SELECT Parts[1]::int AS Depth, Parts[2]::int AS Range
FROM read_file('/Users/joakimkoljonen/src/adventofcode/2017/13.input') Input
, LATERAL regexp_split_to_table(Input.Input, '\n') Lines
, LATERAL regexp_split_to_array(Lines, ': ') Parts
WHERE LINES <> '';

WITH RECURSIVE CTE AS (
    SELECT 0 AS Delay
    UNION ALL
    SELECT Delay + 1 AS Delay
    FROM CTE
    WHERE EXISTS(
        SELECT 1
        FROM Parse
        WHERE (Delay + Depth) % ((Range - 1) * 2) = 0
    )
)
SELECT *
FROM CTE
ORDER BY Delay DESC LIMIT 1;

ROLLBACK;
