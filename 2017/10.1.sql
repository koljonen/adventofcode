CREATE OR REPLACE FUNCTION Step(_Nums int[], _Pos int, _Length int, _SkipSize int)
RETURNS TABLE(Nums int[], Pos int, SkipSize int)
LANGUAGE SQL
AS $$
SELECT
    array_agg(
        unnest ORDER BY
            CASE
                WHEN Ordinality BETWEEN _Pos AND _Pos + _Length - 1 THEN _Pos + _Pos + _Length - Ordinality - 2
                WHEN Ordinality BETWEEN 1 AND _Pos + _Length - cardinality(_Nums) - 1 THEN _Pos + _Pos + _Length - Ordinality - 2
                ELSE Ordinality -1
            END % cardinality(_Nums) + 1
    ) AS Nums,
    ((_Pos - 1 + _Length + _SkipSize) % cardinality(_Nums)) + 1 AS Pos,
    _SkipSize + 1 AS SkipSize
FROM unnest(_Nums) WITH ORDINALITY
$$;

WITH RECURSIVE Lengths AS (
    SELECT Unnest AS Length, Ordinality
    --FROM unnest(string_to_array('63,144,180,149,1,255,167,84,125,65,188,0,2,254,229,24')) WITH Ordinality
    FROM unnest('{63,144,180,149,1,255,167,84,125,65,188,0,2,254,229,24}'::int[]) WITH Ordinality
), Steps AS (
    SELECT Lengths.Ordinality AS Step, Lengths.Length, Step.*
    FROM Lengths
    CROSS JOIN LATERAL Step(
        _Nums     := (SELECT array_agg(n ORDER BY ORDINALITY) FROM Generate_Series(0, 255) WITH ORDINALITY n),
        _Pos      := 1,
        _Length   := Lengths.Length,
        _Skipsize := 0
    )
    WHERE Lengths.Ordinality = 1
    UNION ALL
    SELECT Lengths.Ordinality AS Step, Lengths.Length, Step.*
    FROM Steps
    JOIN Lengths ON Lengths.Ordinality = Steps.Step + 1
    CROSS JOIN LATERAL Step(
        _Nums     := Steps.Nums,
        _Pos      := Steps.Pos,
        _Length   := Lengths.Length,
        _Skipsize := Steps.SkipSize
    )
)
SELECT Nums[1] * Nums[2]
FROM Steps
ORDER BY Step DESC
LIMIT 1;
