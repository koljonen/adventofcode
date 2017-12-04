CREATE OR REPLACE FUNCTION GetAns(int) RETURNS int LANGUAGE SQL AS $$
WITH RECURSIVE Levels AS (
    SELECT 0 AS Depth, 1 AS MaxNum, 0 AS InternalWidth, 1 AS ExternalWidth
    UNION ALL
    SELECT Depth + 1 AS Depth, 4 * (InternalWidth + 2) + MaxNum AS MaxNum, InternalWidth + 2 AS InternalWidth, ExternalWidth + 2 AS ExternalWidth
    FROM Levels
    WHERE MaxNum < $1
), GetLevel AS (
    SELECT * FROM Levels ORDER BY Depth DESC LIMIT 1
), SlicePos AS (
    SELECT *, $1 - MaxNum + 4 * InternalWidth - 1 AS SlicePos
    FROM GetLevel
), DistanceToCenter AS (
    SELECT *, (SlicePos - Depth + 1) % NULLIF(InternalWidth, 0) AS DistanceToCenter
    FROM SlicePos
)
SELECT DistanceToCenter + Depth
FROM DistanceToCenter;
$$;
SELECT * FROM GetAns(265149)
