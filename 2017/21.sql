
BEGIN;

CREATE TEMPORARY TABLE Rules(
    FromBlock text NOT NULL PRIMARY KEY,
    ToBlock text NOT NULL
);

CREATE OR REPLACE FUNCTION GetVariants(_Pattern text)
RETURNS SETOF TEXT
LANGUAGE SQL
AS $$
WITH Split AS (
    SELECT *
    FROM Regexp_Split_To_Table(_Pattern, '/') WITH ORDINALITY Rows(Row, RowNumber)
    , LATERAL Regexp_Split_To_Table(Rows.Row, '') WITH ORDINALITY Cols(Val, ColNumber) 
)
SELECT DISTINCT string_agg(Val, '' ORDER BY ColsFirst * ColOrder * ColNumber, RowOrder * RowNumber, ColOrder * ColNumber)
FROM Split
CROSS JOIN (VALUES (1), (-1)) RO(RowOrder)
CROSS JOIN (VALUES (1), (-1)) CO(ColOrder)
CROSS JOIN (VALUES (0), ( 1)) CF(ColsFirst)
GROUP BY RowOrder, ColOrder, ColsFirst
$$;

WITH RECURSIVE Input AS (
    SELECT read_file('/Users/joakimkoljonen/src/adventofcode/2017/21.input') AS Input
), Split AS (
    SELECT SplitRule[1] AS RuleFrom, SplitRule[2] AS RuleTo
    FROM Input
    , LATERAL regexp_split_to_table(Input, '\n') Rules(Rule)
    , LATERAL regexp_split_to_array(Rules.Rule, ' => ') SplitRule
    WHERE Rules.Rule <> ''
)
INSERT INTO Rules(FromBlock, ToBlock)
SELECT GetVariants(RuleFrom) AS FromBlock, REPLACE(RuleTo, '/', '') AS ToBlock
FROM Split;

CREATE FUNCTION Sharpen(_Pic text)
RETURNS text
LANGUAGE SQL
AS $$
WITH Sizes AS (
    SELECT BlockSize, S.Size,  Size / BlockSize AS NumBlocks, S.Size * BS.BlockSize AS RowGroupSize
    FROM (SELECT sqrt(length(_Pic))::int AS Size) S
    , LATERAL (SELECT CASE Size % 2 WHEN 0 THEN 2 ELSE 3 END AS BlockSize) BS
), Blocks AS (
    SELECT (Ordinality - 1) / RowGroupSize * NumBlocks + (Ordinality - 1) / BlockSize % NumBlocks AS BlockNum, string_agg(Pixel, '' ORDER BY Ordinality) AS Block
    FROM Regexp_Split_To_Table(_Pic, '') WITH ORDINALITY Pixels(Pixel, Ordinality)
    CROSS JOIN Sizes
    GROUP BY 1
), NewBlocks AS (
    SELECT BlockNum, Rules.ToBlock
    FROM Blocks
    JOIN Rules ON Rules.FromBlock = Blocks.Block
), NewSizes AS (
    SELECT NumBlocks * NewBlockSize AS Size, NewBlockSize AS BlockSize, NumBlocks
    FROM Sizes
    , LATERAL (SELECT CASE BlockSize WHEN 2 THEN 3 ELSE 4 END AS NewBlockSize) NBS
)
SELECT string_agg(Pixel, '' ORDER BY BlockNum / NumBlocks * BlockSize, (Ordinality - 1) / BlockSize, BlockNum, Ordinality) AS New
FROM NewBlocks
CROSS JOIN NewSizes
, LATERAL regexp_split_to_table(NewBlocks.ToBlock, '') WITH ORDINALITY Pixels(Pixel, Ordinality)
$$;

CREATE OR REPLACE FUNCTION CountLights(_Steps int)
RETURNS int
LANGUAGE SQL
AS $$
WITH RECURSIVE Steps AS (
    SELECT 1 AS Step, Sharpen('.#...####') AS Pic
    UNION ALL
    SELECT Step + 1, Sharpen(Pic)
    FROM Steps
    WHERE Step < _Steps
), LastStep AS (
    SELECT *
    FROM Steps
    ORDER BY Step DESC LIMIT 1
)
SELECT length(pic) - length(replace(pic, '#', ''))
FROM LastStep;
$$;

SELECT CountLights(5) AS Ans1, CountLights(18) AS Ans2;

ROLLBACK;
