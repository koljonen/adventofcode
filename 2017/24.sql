BEGIN;

CREATE TABLE Components(
    FromNum int,
    ToNum int,
    PRIMARY KEY(FromNum, ToNum)
);

WITH Input AS (
    SELECT read_file('/Users/joakimkoljonen/src/adventofcode/2017/24.input') AS Input
    --SELECT read_file('/Users/joakimkoljonen/src/adventofcode/2017/24.test_input') AS Input
), Parts AS (
    SELECT regexp_split_to_array(Lines, '/')::int[] Parts
    FROM Input
    , LATERAL regexp_split_to_table(Input, '\n') WITH ORDINALITY Lines
    WHERE Lines <> ''
)
INSERT INTO Components(FromNum, ToNum)
SELECT Parts[1], Parts[2]
FROM Parts
UNION DISTINCT
SELECT Parts[2], Parts[1]
FROM Parts;

CREATE FUNCTION BestBridge(
    -- Part2[1] is the length, Part2[2] the score
    INOUT Part2 int[] DEFAULT ARRAY[0,0],
    _FromNum int DEFAULT 0,
    _Used hstore DEFAULT ''
)
LANGUAGE SQL
AS $$
SELECT COALESCE(
    MAX(
        BestBridge(
            Part2       := ARRAY[Part2[1] + 1, Part2[2] + FromNum + ToNum],
            _FromNum    := ToNum,
            _Used       := _Used || hstore(ARRAY[LEAST(FromNum, ToNum), GREATEST(FromNum, ToNum)]::text, '')
        )
    ),
    Part2
)
FROM Components
WHERE FromNum = _FromNum
AND NOT _Used ? ARRAY[LEAST(FromNum, ToNum), GREATEST(FromNum, ToNum)]::text
$$;

SELECT
    (BestBridge())[2] AS Part2,
    -- Pretty haxxy – set the length to NULL so we'll just sort by score
    (BestBridge(Part2 := ARRAY[NULL, 0]))[2] AS Ans1;

ROLLBACK;
