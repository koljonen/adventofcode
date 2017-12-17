WITH RECURSIVE Constants AS (
    SELECT 324 AS StepSize, 2017 AS NumSteps
), Steps AS (
    SELECT array[0] AS Nums, 0 AS Pos, 1 AS Size
    UNION ALL
    SELECT
        Nums[:(Pos + StepSize + 1) % Size + 1] || array[Size] || Nums[(Pos + StepSize + 1) % Size + 2:],
        (Pos + StepSize + 1) % Size AS Pos,
        Size + 1 AS Size
    FROM Steps, Constants
    WHERE Size < NumSteps + 1
), LastStep AS (
    SELECT *
    FROM Steps
    ORDER BY SIze DESC
    LIMIT 1
)
SELECT LEAD(Num) OVER(ORDER BY Ordinality)
FROM LastStep
, LATERAL unnest(Nums) WITH ORDINALITY Num
ORDER BY Num = 2017 DESC LIMIT 1;
