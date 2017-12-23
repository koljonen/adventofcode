CREATE TEMPORARY TABLE Commands (
    CommandType text NOT NULL,
    Val1 text NOT NULL,
    Val2 text,
    Ordinality bigint PRIMARY KEY
);

WITH RECURSIVE Input AS (
    SELECT read_file('/Users/joakimkoljonen/src/adventofcode/2017/18.input') AS Input
), Cmds AS (
    SELECT Parts[1] AS CommandType, Parts[2] AS Val1, Parts[3] AS Val2, Command.Ordinality
    FROM Input
    , LATERAL regexp_split_to_table(Input, '\n') WITH ORDINALITY Command
    , LATERAL regexp_split_to_array(Command.Command, ' ') Parts
    WHERE Command <> ''
)
INSERT INTO Commands SELECT * FROM Cmds;

CREATE OR REPLACE FUNCTION GetVal(_Registers hstore, _Val text)
RETURNS bigint
LANGUAGE SQL
AS $$
SELECT CASE
    WHEN _Val BETWEEN 'a' AND 'z' THEN COALESCE(_Registers -> _Val, '0')
    ELSE _Val
END::bigint
$$;

CREATE TYPE ProgramState AS (
    Registers hstore,
    Pos bigint,
    Queue bigint[]
);

CREATE OR REPLACE FUNCTION Step(_ ProgramState)
RETURNS ProgramState
LANGUAGE SQL
AS $$
WITH RECURSIVE Steps AS (
    SELECT _.Pos AS Ordinality, _.Registers, '{}'::bigint[] AS QueueOut, FALSE AS Terminate, 1 AS QueuePos
    UNION ALL
    SELECT
        CASE
            WHEN Commands.CommandType = 'jgz' AND V1 > 0 THEN Ordinality + V2
            WHEN Commands.CommandType = 'rcv' AND QueuePos > cardinality(_.Queue) THEN Ordinality
            ELSE Ordinality + 1
        END AS Ordinality,
        CASE
            WHEN Commands.CommandType = 'set' THEN Registers || hstore(Val1, V2::text)
            WHEN Commands.CommandType = 'add' THEN Registers || hstore(Val1, (V1 + V2)::text)
            WHEN Commands.CommandType = 'mul' THEN Registers || hstore(Val1, (V1 * V2)::text)
            WHEN Commands.CommandType = 'mod' THEN Registers || hstore(Val1, (V1 % V2)::text)
            WHEN Commands.CommandType = 'rcv' AND QueuePos <= cardinality(_.Queue) THEN Registers || hstore(Val1, _.Queue[QueuePos]::text)
            ELSE Registers
        END AS Registers,
        CASE Commands.CommandType
            WHEN 'snd' THEN array_append(QueueOut, V1)
            ELSE QueueOut
        END AS QueueOut,
        Commands.CommandType = 'rcv' AND QueuePos > cardinality(_.Queue) AS Terminate,
        QueuePos + (Commands.CommandType = 'rcv')::int AS QueuePos
    FROM Steps
    JOIN Commands USING(Ordinality)
    , LATERAL GetVal(Registers, Val1) V1
    , LATERAL GetVal(Registers, Val2) V2
    WHERE NOT Terminate
)
SELECT Registers, Ordinality, QueueOut
FROM Steps
WHERE Terminate;
$$;

WITH RECURSIVE Run AS (
    SELECT 1 AS StepNum, Step((hstore(array['p', '0']), 1, '{}')) AS Program0, Step((hstore(array['p', '1']), 1, '{}')) AS Program1
    UNION ALL
    SELECT
        StepNum + 1,
        Step(((Run.Program0).Registers, (Run.Program0).Pos, (Run.Program1).Queue)) AS Program0,
        Step(((Run.Program1).Registers, (Run.Program1).Pos, (Run.Program0).Queue)) AS Program1
    FROM Run
    WHERE (Run.Program0).Queue <> '{}' OR (Run.Program1).Queue <> '{}'
)
SELECT SUM(cardinality((Program1).Queue))
FROM Run;
