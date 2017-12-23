CREATE OR REPLACE FUNCTION GetVal(_Registers hstore, _Val text)
RETURNS bigint
LANGUAGE SQL
AS $$
SELECT CASE
    WHEN _Val BETWEEN 'a' AND 'z' THEN COALESCE(_Registers -> _Val, '0')
    ELSE _Val
END::bigint
$$;

WITH RECURSIVE Input AS (
    SELECT read_file('/Users/joakimkoljonen/src/adventofcode/2017/18.input') AS Input
), Commands AS (
    SELECT Parts[1] AS CommandType, Parts[2] AS Val1, Parts[3] AS Val2, Command.Ordinality, Command
    FROM Input
    , LATERAL regexp_split_to_table(Input, '\n') WITH ORDINALITY Command
    , LATERAL regexp_split_to_array(Command.Command, ' ') Parts
), Steps AS (
    SELECT NULL AS Cmd, 1::bigint AS Ordinality, hstore('') AS Registers, NULL::bigint AS Recoverable, FALSE AS Terminate
    UNION ALL
    SELECT
        Command,
        CASE
            WHEN Commands.CommandType = 'jgz' AND V1 > 0 THEN Ordinality + V2
            ELSE Ordinality + 1
        END AS Ordinality,
        CASE Commands.CommandType
            WHEN 'set' THEN Registers || hstore(Val1, V2::text)
            WHEN 'add' THEN Registers || hstore(Val1, (V1 + V2)::text)
            WHEN 'mul' THEN Registers || hstore(Val1, (V1 * V2)::text)
            WHEN 'mod' THEN Registers || hstore(Val1, (V1 % V2)::text)
            ELSE Registers
        END AS Registers,
        CASE Commands.CommandType
            WHEN 'snd' THEN V1
            ELSE Recoverable
        END AS Recoverable,
        Commands.CommandType ='rcv' AND V1 <> 0 AS Terminate
    FROM Steps
    JOIN Commands USING(Ordinality)
    , LATERAL GetVal(Registers, Val1) V1
    , LATERAL GetVal(Registers, Val2) V2
    WHERE NOT Terminate
)
SELECT Recoverable
FROM Steps
WHERE Terminate;
