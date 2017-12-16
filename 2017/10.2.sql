CREATE AGGREGATE xor(int) (
    sfunc = int4xor,
    stype = int,
    initcond = 0
);

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
    (_SkipSize + 1) % cardinality(_Nums) AS SkipSize
FROM unnest(_Nums) WITH ORDINALITY
$$;

CREATE OR REPLACE FUNCTION DoRound(_Nums int[], _Pos int, _Lengths int[], _SkipSize int)
RETURNS TABLE(Nums int[], Pos int, SkipSize int)
LANGUAGE SQL
AS $$
WITH RECURSIVE Lengths AS (
    SELECT unnest AS Length, Ordinality
    FROM unnest(_Lengths) WITH ORDINALITY
), Steps AS (
    SELECT Lengths.Ordinality AS Step, Lengths.Length, Step.*
    FROM Lengths
    CROSS JOIN LATERAL Step(
        _Nums     := _Nums,
        _Pos      := _Pos,
        _Length   := Lengths.Length,
        _Skipsize := _SkipSize
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
SELECT Nums, Pos, SkipSize
FROM Steps
ORDER BY Step DESC LIMIT 1;
$$;

WITH RECURSIVE Lengths AS (
    SELECT array_agg(ascii(Unnest) ORDER BY Ordinality) || array[17, 31, 73, 47, 23] AS Lengths
    FROM unnest(regexp_split_to_array('63,144,180,149,1,255,167,84,125,65,188,0,2,254,229,24', '')) WITH Ordinality
), Steps AS (
    SELECT 1 AS Step, DoRound.*
    FROM Lengths
    CROSS JOIN LATERAL DoRound(
        _Nums     := (SELECT array_agg(n ORDER BY ORDINALITY) FROM Generate_Series(0, 255) WITH ORDINALITY n),
        _Pos      := 1,
        _Lengths  := Lengths.Lengths,
        _Skipsize := 0
    )
    UNION ALL
    SELECT Steps.Step + 1 AS Step, DoRound.*
    FROM Steps
    CROSS JOIN Lengths
    CROSS JOIN LATERAL DoRound(
        _Nums     := Steps.Nums,
        _Pos      := Steps.Pos,
        _Lengths  := Lengths.Lengths,
        _Skipsize := Steps.SkipSize
    )
    WHERE Steps.Step < 64
), LastStep AS (
    SELECT *
    FROM Steps
    ORDER BY Step DESC
    LIMIT 1
), Blocks AS (
    SELECT (Ordinality - 1) / 16 AS Ordinality, xor(Unnest)
    FROM LastStep
    CROSS JOIN LATERAL unnest(Nums) WITH ORDINALITY
    GROUP BY 1
)
SELECT string_agg(CASE xor / 16 WHEN 0 THEN '0' ELSE '' END || to_hex(xor), '' ORDER BY Ordinality)
FROM Blocks;
