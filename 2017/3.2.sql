CREATE TEMPORARY TABLE Pos(
    XVal int NOT NULL,
    YVal int NOT NULL,
    Val int NOT NULL,
    PRIMARY KEY (XVal, YVal)
);
-- plpgsql version
CREATE OR REPLACE FUNCTION GetAns(int) RETURNS int LANGUAGE plpgsql AS $$
DECLARE
_XPos int := 1;
_YPos int := 0;
_Direction text := 'UP';
_Val int;
BEGIN

TRUNCATE TABLE Pos;

INSERT INTO Pos(XVal, YVal, Val)
VALUES(0, 0, 1), (1, 0, 1);

WHILE TRUE LOOP
    _Direction := CASE
        WHEN _XPos = _YPos AND _XPos < 0 THEN 'RIGHT'
        WHEN _XPos = _YPos AND _XPos > 0 THEN 'LEFT'
        WHEN _XPos = -_YPos AND _XPos < 0 THEN 'DOWN'
        WHEN _XPos = -_YPos + 1 AND _XPos > 0 THEN 'UP'
        ELSE _Direction
    END;
    _XPos := _XPos + CASE _Direction WHEN 'RIGHT' THEN 1 WHEN 'LEFT' THEN -1 ELSE 0 END;
    _YPos := _YPos + CASE _Direction WHEN 'UP' THEN 1 WHEN 'DOWN' THEN -1 ELSE 0 END;

    INSERT INTO Pos(XVal, YVal, Val)
    SELECT _XPos, _YPos, SUM(Val)
    FROM Pos
    WHERE
        XVal BETWEEN _XPos - 1 AND _XPos + 1 AND
        YVal BETWEEN _YPos - 1 AND _YPos + 1
    RETURNING Val INTO STRICT _Val;

    IF _Val > $1 THEN
        RETURN _Val;
    END IF;
END LOOP;
END;
$$;
SELECT * FROM GetAns(265149);

TRUNCATE TABLE Pos;

-- Pure SQL version
CREATE TEMPORARY TABLE Pos(
    XVal int NOT NULL,
    YVal int NOT NULL,
    Val int NOT NULL,
    PRIMARY KEY (XVal, YVal)
);

CREATE OR REPLACE FUNCTION GetNextPos(_X int, _Y int, _Dir text, OUT X int, OUT Y int, OUT Dir text) RETURNS record
LANGUAGE sql AS $$
SELECT
$1 + CASE Direction WHEN 'RIGHT' THEN 1 WHEN 'LEFT' THEN -1 ELSE 0 END,
$2 + CASE Direction WHEN 'UP' THEN 1 WHEN 'DOWN' THEN -1 ELSE 0 END,
Direction
FROM (
    SELECT CASE
        WHEN X = Y AND X < 0 THEN 'RIGHT'
        WHEN X = Y AND X > 0 THEN 'LEFT'
        WHEN X = -Y AND X < 0 THEN 'DOWN'
        WHEN X = -Y + 1 AND X > 0 THEN 'UP'
        ELSE Direction
    END AS Direction
    FROM ( SELECT $1 AS X, $2 AS Y, $3 AS Direction ) Meow
) D
$$;

CREATE OR REPLACE FUNCTION GetVal(_X int, _Y int) RETURNS int LANGUAGE sql AS $$
INSERT INTO Pos(XVal, YVal, Val)
SELECT $1, $2, COALESCE(SUM(Val), 1)
FROM Pos
WHERE
    XVal BETWEEN $1 - 1 AND $1 + 1 AND
    YVal BETWEEN $2 - 1 AND $2 + 1
RETURNING Val
$$;

CREATE OR REPLACE FUNCTION GetAns(int) RETURNS int LANGUAGE sql AS $$
WITH RECURSIVE CTE AS (
    SELECT 0 AS X, 0 AS Y, 'RIGHT' AS Direction, GetVal(0, 0) AS Z
    UNION ALL
    SELECT
        (GetNextPos(X, Y, Direction)).*,
        GetVal((GetNextPos(X, Y, Direction)).X, (GetNextPos(X, Y, Direction)).Y) AS Z
    FROM CTE
    WHERE Z <= $1
)
SELECT Z FROM CTE ORDER BY 1 DESC LIMIT 1
$$;
SELECT * FROM GetAns(265149);
