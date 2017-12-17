WITH RECURSIVE Constants AS (
    SELECT 324 AS StepSize, 50000000 AS NumSteps
),
FindNum AS (
    SELECT 0 AS Pos, 0 AS Num, 1 AS Size
    UNION ALL
    SELECT (Pos + 1 + StepSize) % Size AS Pos, Num + 1 AS Num, Size + 1 AS Size
    FROM FindNum, Constants
    WHERE Num < NumSteps
)
SELECT Num
FROM FindNum
WHERE Pos = 0
ORDER BY Num DESC LIMIT 1;
