WITH RECURSIVE CTE AS (
    SELECT
        289::bigint AS a,
        629::bigint AS b,
        1 AS Step
    UNION ALL
    SELECT
        a * 16807 % 2147483647 AS a,
        b * 48271 % 2147483647 AS b,
        Step + 1 AS Step
    FROM CTE
    WHERE Step < 40000000
)
SELECT COUNT(*)
FROM CTE
WHERE (a & 65535) = (b & 65535)
