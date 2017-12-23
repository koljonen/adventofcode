CREATE TEMPORARY TABLE Map (
    RowNum int,
    ColNum int,
    Val    text NOT NULL,
    PRIMARY KEY(RowNum, ColNum)
);

WITH Input AS (
    SELECT read_file('/Users/joakimkoljonen/src/adventofcode/2017/19.input') AS Input
), _Map AS (
    SELECT Rows.Ordinality AS RowNum, Cols.Ordinality AS ColNum, Cols.Cols AS Val
    FROM Input
    , LATERAL regexp_split_to_table(Input, '\n') WITH ORDINALITY Rows
    , LATERAL regexp_split_to_table(Rows, '') WITH ORDINALITY Cols
)
INSERT INTO Map
SELECT *
FROM _Map
WHERE Val <> ' ';

CREATE OR REPLACE FUNCTION GetPos(_RowNum int, _ColNum int, _Direction text, OUT RowNum int, OUT ColNum int)
LANGUAGE SQL
AS
$$
SELECT
    _RowNum + CASE _Direction WHEN 'U' THEN - 1 WHEN 'D' THEN 1 ELSE 0 END,
    _ColNum + CASE _Direction WHEN 'L' THEN - 1 WHEN 'R' THEN 1 ELSE 0 END
$$;

CREATE OR REPLACE FUNCTION GetDirections(_Direction text)
RETURNS SETOF text
LANGUAGE SQL
AS $$
SELECT unnest(
    CASE _Direction
        WHEN 'U' THEN '{U,L,R}'
        WHEN 'D' THEN '{D,L,R}'
        WHEN 'L' THEN '{L,U,D}'
        WHEN 'R' THEN '{R,U,D}'
    END::text[]
)
$$;

CREATE OR REPLACE FUNCTION GetNext(_RowNum int, _ColNum int, _Direction text)
RETURNS TABLE (
    RowNum int,
    ColNum int,
    Direction text,
    Letter text
)
LANGUAGE SQL
AS
$$
SELECT RowNum, ColNum, GetDirections AS Direction, Val AS Letter
FROM GetDirections(_Direction) WITH ORDINALITY
, LATERAL GetPos(_RowNum, _ColNum, GetDirections)
JOIN Map USING(ColNum, RowNum)
ORDER BY Ordinality LIMIT 1
$$;

WITH RECURSIVE Steps AS (
    (
        SELECT 1 AS Step, RowNum, ColNum, 'D' AS Direction, Val AS Letter
        FROM Map
        ORDER BY RowNum, ColNum
        LIMIT 1
    )
    UNION ALL
    SELECT Step + 1, GetNext.*
    FROM Steps
    , LATERAL GetNext(RowNum, ColNum, Direction)    
)
SELECT string_agg(Letter, '' ORDER BY Step)
FROM Steps
WHERE Letter NOT IN ('|', '-', '+')
