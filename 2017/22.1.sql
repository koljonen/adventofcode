BEGIN;

CREATE TYPE Direction AS ENUM('up', 'down', 'left', 'right');

CREATE TYPE Coordinates AS (
    RowNum int,
    ColNum int
);

CREATE TYPE CarrierState AS (
    Position Coordinates,
    Direction Direction
);


CREATE FUNCTION GetDirection(_Direction Direction, _Infected bool)
RETURNS Direction
LANGUAGE SQL
AS $$
SELECT CASE _Infected
    WHEN TRUE THEN CASE _Direction
        WHEN 'left' THEN 'up'
        WHEN 'down' THEN 'left'
        WHEN 'right' THEN 'down'
        WHEN 'up' THEN 'right'
    END
    WHEN FALSE THEN CASE _Direction
        WHEN 'up' THEN 'left'
        WHEN 'left' THEN 'down'
        WHEN 'down' THEN 'right'
        WHEN 'right' THEN 'up'
    END
END::Direction
$$;

CREATE FUNCTION GetNextState(_State CarrierState, _Infected bool)
RETURNS CarrierState
LANGUAGE SQL
AS $$
SELECT
    (
        (_State.Position).RowNum + CASE GetDirection.Direction WHEN 'up' THEN -1 WHEN 'down' THEN 1 ELSE 0 END,
        (_State.Position).ColNum + CASE GetDirection.Direction WHEN 'left' THEN -1 WHEN 'right' THEN 1 ELSE 0 END
    )::Coordinates,
    GetDirection
FROM GetDirection((_State).Direction, _Infected)
$$;

CREATE FUNCTION Step(_State CarrierState, _Infected hstore, OUT State CarrierState, OUT NewInfection bool, OUT Infected hstore)
LANGUAGE SQL
AS $$
SELECT GetNextState(_State, _Infected ? _State.Position::text), NOT _Infected ? _State.Position::text,
CASE _Infected ? _State.Position::text
    WHEN TRUE THEN _Infected - _State.Position::text
    WHEN FALSE THEN _Infected || hstore(_State.Position::text, TRUE::text)
END;
$$;

WITH RECURSIVE Input AS (
    SELECT read_file('/Users/joakimkoljonen/src/adventofcode/2017/22.input') AS Input
    --SELECT read_file('/Users/joakimkoljonen/src/adventofcode/2017/22.test_input') AS Input
), Infected AS (
    SELECT Rows.RowNum - LENGTH(Row) / 2 - 1 AS RowNum, Cols.ColNum - LENGTH(Row) / 2 - 1 AS ColNum
    FROM Input
    , LATERAL regexp_split_to_table(Input, '\n') WITH ORDINALITY Rows(Row, RowNum)
    , LATERAL regexp_split_to_table(Rows.Row, '') WITH ORDINALITY Cols(Val, ColNum)
    WHERE Rows.Row <> '' AND Cols.Val <> '.'
), OriginalInfected AS (
    SELECT hstore(array_agg((RowNum, ColNum)::Coordinates::text), array_agg(true::text)) AS Infected
    FROM Infected
), CTE AS (
    SELECT ((0, 0)::Coordinates, 'up')::CarrierState AS State, 0 AS NumSteps, 0 AS NumInfections, Infected
    FROM OriginalInfected
    UNION ALL
    SELECT Step.State, NumSteps + 1, NumInfections + Step.NewInfection::int, Step.Infected
    FROM CTE
    , LATERAL Step(State, Infected)
    WHERE NumSteps < 10000
)
SELECT MAX(NumInfections)
FROM CTE;


ROLLBACK;
