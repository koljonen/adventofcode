DROP TABLE Nums CASCADE;
CREATE TABLE Nums(Pos serial PRIMARY KEY, Val int NOT NULL);
DROP TABLE States;
CREATE TABLE States(Pos serial PRIMARY KEY, Vals int[] NOT NULL UNIQUE);
INSERT INTO Nums(Val)
WITH Input(Input) AS ( VALUES
('10	3	15	10	5	15	5	15	9	2	5	8	5	2	3	6')
--('0	2	7	0')
), Split AS (
    SELECT regexp_split_to_array(Input, '\t')::int[] AS Split
    FROM Input
)
SELECT unnest(Split) AS Val
FROM Split;

CREATE OR REPLACE FUNCTION Execute() RETURNS int LANGUAGE sql AS $$
WITH GetMax AS (
    SELECT *
    FROM Nums
    ORDER BY Val DESC, Pos ASC
    LIMIT 1
), GetIncrements AS (
    SELECT NewPos % (SELECT COUNT(*) FROM Nums) + 1 AS Pos, COUNT(*)
    FROM GetMax,
    LATERAL generate_series(Pos, Pos + GetMax.Val - 1) NewPos
    GROUP BY 1
), GetChanges AS (
    SELECT Pos, Count
    FROM GetIncrements
    UNION ALL
    SELECT GetMax.Pos, 0
    FROM GetMax
    LEFT JOIN GetIncrements USING(Pos)
    WHERE GetIncrements IS NULL
), DoIncrements AS (
    UPDATE Nums SET Val = CASE Nums.Pos WHEN GetMax.Pos THEN 0 ELSE Nums.Val END + COALESCE(GetChanges.Count, 0)
    FROM GetChanges, GetMax
    WHERE Nums.Pos = GetChanges.Pos
    RETURNING *
), State AS (
    SELECT array_agg(Val ORDER BY Pos)
    FROM Nums
    WHERE EXISTS(SELECT 1 FROM DoIncrements) -- Ensure execution order
)
INSERT INTO States(Vals)
SELECT * FROM State
ON CONFLICT DO NOTHING
RETURNING States.Pos
$$;

WITH RECURSIVE CTE AS (
    SELECT 1 AS Step, Execute() AS Pos
    UNION ALL
    SELECT Step + 1, Execute()
    FROM CTE
    WHERE Pos IS NOT NULL
)
SELECT *
FROM CTE
ORDER BY 1 DESC LIMIT 1 OFFSET 1;
