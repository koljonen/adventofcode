BEGIN;

CREATE TYPE Direction AS ENUM('up', 'down', 'left', 'right');

CREATE TYPE InfectionStatus AS ENUM('weakened', 'infected', 'flagged');

CREATE TYPE Coordinates AS (
    RowNum int,
    ColNum int
);

CREATE TYPE CarrierState AS (
    Position Coordinates,
    Direction Direction
);

CREATE UNLOGGED TABLE Infections (
    Position Coordinates PRIMARY KEY,
    Status InfectionStatus NOT NULL
);

WITH Input AS (
    SELECT read_file('/Users/joakimkoljonen/src/adventofcode/2017/22.input') AS Input
    --SELECT read_file('/Users/joakimkoljonen/src/adventofcode/2017/22.test_input') AS Input
), Infected AS (
    SELECT Rows.RowNum - LENGTH(Row) / 2 - 1 AS RowNum, Cols.ColNum - LENGTH(Row) / 2 - 1 AS ColNum
    FROM Input
    , LATERAL regexp_split_to_table(Input, '\n') WITH ORDINALITY Rows(Row, RowNum)
    , LATERAL regexp_split_to_table(Rows.Row, '') WITH ORDINALITY Cols(Val, ColNum)
    WHERE Rows.Row <> '' AND Cols.Val <> '.'
)
INSERT INTO Infections (Position, Status)
SELECT (RowNum, ColNum)::Coordinates, 'infected'
FROM Infected;

CREATE FUNCTION GetDirection(_Direction Direction, _InfectionStatus InfectionStatus)
RETURNS Direction
LANGUAGE SQL
AS $$
SELECT CASE _InfectionStatus
    WHEN 'infected' THEN CASE _Direction
        WHEN 'left' THEN 'up'
        WHEN 'down' THEN 'left'
        WHEN 'right' THEN 'down'
        WHEN 'up' THEN 'right'
    END::Direction
    WHEN 'flagged' THEN CASE _Direction
        WHEN 'left' THEN 'right'
        WHEN 'down' THEN 'up'
        WHEN 'right' THEN 'left'
        WHEN 'up' THEN 'down'
    END::Direction
    WHEN 'weakened' THEN _Direction
    ELSE CASE _Direction
        WHEN 'up' THEN 'left'
        WHEN 'left' THEN 'down'
        WHEN 'down' THEN 'right'
        WHEN 'right' THEN 'up'
    END::Direction
END
$$;

CREATE FUNCTION GetNextState(_State CarrierState, _InfectionStatus InfectionStatus)
RETURNS CarrierState
LANGUAGE SQL
AS $$
SELECT
    (
        (_State.Position).RowNum + CASE GetDirection.Direction WHEN 'up' THEN -1 WHEN 'down' THEN 1 ELSE 0 END,
        (_State.Position).ColNum + CASE GetDirection.Direction WHEN 'left' THEN -1 WHEN 'right' THEN 1 ELSE 0 END
    )::Coordinates,
    GetDirection
FROM GetDirection((_State).Direction, _InfectionStatus)
$$;

CREATE FUNCTION Step(_State CarrierState, OUT State CarrierState, OUT NewInfection bool)
LANGUAGE SQL
AS $$
WITH Deletions AS (
    DELETE FROM Infections
    WHERE Position = _State.Position
    RETURNING Infections.*
), Insertions AS (
    INSERT INTO Infections(Position, Status)
    SELECT _State.Position, CASE Deletions.Status
        WHEN 'weakened' THEN 'infected'
        WHEN 'infected' THEN 'flagged'
        ELSE 'weakened'
    END::InfectionStatus AS Infected
    FROM (VALUES (NULL)) V(Dummy)
    LEFT JOIN Deletions ON Deletions.Position = _State.Position
    WHERE Deletions.Status IS DISTINCT FROM 'flagged'
    RETURNING Infections.*
)
SELECT
    GetNextState(_State, Deletions.Status) AS State,
    Deletions.Status IS NOT DISTINCT FROM 'weakened' AS NewInfection
FROM (VALUES (NULL)) V(Dummy)
LEFT JOIN Deletions ON TRUE;
$$;

WITH RECURSIVE CTE AS (
    SELECT ((0, 0)::Coordinates, 'up')::CarrierState AS State, 0 AS NumSteps, 0 AS NumInfections
    UNION ALL
    SELECT Step.State, NumSteps + 1, NumInfections + Step.NewInfection::int
    FROM CTE
    , LATERAL Step(State)
    WHERE NumSteps < 10000000
)
SELECT MAX(NumInfections)
FROM CTE;


ROLLBACK;
