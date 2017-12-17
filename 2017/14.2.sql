BEGIN;

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

CREATE OR REPLACE FUNCTION HashBits(_Text text)
RETURNS text
LANGUAGE sql
AS $$
WITH RECURSIVE Lengths AS (
    SELECT array_agg(ascii(Unnest) ORDER BY Ordinality) || array[17, 31, 73, 47, 23] AS Lengths
    FROM unnest(regexp_split_to_array(_Text, '')) WITH Ordinality
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
SELECT string_agg(xor::bit(8)::text, '' ORDER BY Ordinality)
FROM Blocks;
$$;

DROP TABLE Data;
CREATE TABLE Data(
    GroupID serial NOT NULL,
    FromRow int,
    FromCol int,
    ColNum int NOT NULL,
    RowNum int NOT NULL,
    PRIMARY KEY(ColNum, RowNum)
);
INSERT INTO Data(ColNum, RowNum)
WITH Input AS (
    SELECT 'stpzcrnm' AS Input
), Bits AS (
    SELECT generate_series + 1 AS RowNum, Cols.Ordinality AS ColNum, Cols AS Val
    FROM Input
    , LATERAL generate_series(0, 127)
    , LATERAL HashBits(Input || '-' || generate_series::text)
    , LATERAL regexp_split_to_table(HashBits, '') WITH Ordinality Cols
)
SELECT ColNum, RowNum
FROM Bits
WHERE Val = '1';

CREATE OR REPLACE FUNCTION Merge()
RETURNS int
LANGUAGE SQL
AS $$
WITH Updates AS (
    UPDATE Data SET GroupID = Neighbour.GroupID, FromCol = Neighbour.ColNum, FromRow = Neighbour.RowNum
    FROM Data Neighbour
    WHERE
        Neighbour.ColNum BETWEEN Data.ColNum - 1 AND Data.ColNum + 1 AND
        Neighbour.RowNum BETWEEN Data.RowNum - 1 AND Data.RowNum + 1 AND
        (Neighbour.RowNum = Data.RowNum) <> (Neighbour.ColNum = Data.ColNum) AND
        Neighbour.GroupID < Data.GroupID
    RETURNING Data.GroupID
)
SELECT COUNT(*)::int
FROM Updates;
$$;

WITH Recursive Merges AS (
    SELECT Merge() AS Merged, 1 AS Level
    UNION ALL
    SELECT Merge() AS Merged, Level + 1 AS Level
    FROM Merges
    WHERE Merged > 0
)
SELECT COUNT(*)
FROM Merges;

SELECT COUNT(DISTINCT GroupID)
FROM Data;

ROLLBACK;
