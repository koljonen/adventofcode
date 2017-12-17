CREATE OR REPLACE FUNCTION Nxt(_Current bigint, _Multiplier bigint, _Divider bigint, _BitMask bigint)
RETURNS bigint
LANGUAGE SQL
AS $$
WITH RECURSIVE CTE AS (
    SELECT 1 AS Lvl, _Current * _Multiplier % _Divider AS Val
    UNION ALL
    SELECT Lvl + 1, Val * _Multiplier % _Divider
    FROM CTE
    WHERE Val & _BitMask <> 0
)
SELECT Val FROM CTE
ORDER BY Lvl DESC LIMIT 1;
$$;

WITH RECURSIVE CTE AS (
    SELECT
        289::bigint AS a,
        629::bigint AS b,
        1 AS Step
    UNION ALL
    SELECT
        Nxt(a, 16807, 2147483647, 3) AS a,
        Nxt(b, 48271, 2147483647, 7) AS b,
        Step + 1 AS Step
    FROM CTE
    WHERE Step < 5000000
)
SELECT COUNT(*)
FROM CTE
WHERE (a & 65535) = (b & 65535);
