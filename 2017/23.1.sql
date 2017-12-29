BEGIN;

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
    SELECT read_file('/Users/joakimkoljonen/src/adventofcode/2017/23.input') AS Input
), Commands AS (
    SELECT Parts[1] AS CommandType, Parts[2] AS Val1, Parts[3] AS Val2, Command.Ordinality, Command
    FROM Input
    , LATERAL regexp_split_to_table(Input, '\n') WITH ORDINALITY Command
    , LATERAL regexp_split_to_array(Command.Command, ' ') Parts
), Steps AS (
    SELECT NULL AS CommandType, 1::bigint AS Ordinality, hstore('') AS Registers, 0 AS StepNum
    UNION ALL
    SELECT
        Commands.CommandType,
        CASE
            WHEN Commands.CommandType = 'jnz' AND V1 <> 0 THEN Ordinality + V2
            ELSE Ordinality + 1
        END AS Ordinality,
        CASE Commands.CommandType
            WHEN 'set' THEN Registers || hstore(Val1, V2::text)
            WHEN 'sub' THEN Registers || hstore(Val1, (V1 - V2)::text)
            WHEN 'mul' THEN Registers || hstore(Val1, (V1 * V2)::text)
            ELSE Registers
        END AS Registers,
        StepNum + 1
    FROM Steps
    JOIN Commands USING(Ordinality)
    , LATERAL GetVal(Registers, Val1) V1
    , LATERAL GetVal(Registers, Val2) V2
)
SELECT COUNT(*)
FROM Steps
WHERE CommandType = 'mul';

ROLLBACK;
