WITH RECURSIVE Input AS (
    SELECT read_file('/Users/joakimkoljonen/src/adventofcode/2017/16.input') AS Input
), Commands AS (
    SELECT Command.Command, Command.Ordinality
    FROM Input
    , LATERAL regexp_split_to_table(Input, ',') WITH ORDINALITY Command
), DoStuff AS (
    SELECT 1::bigint AS Ordinality, 'abcdefghijklmnop' AS Str
    UNION ALL
    SELECT
        Ordinality + 1 AS Ordinality,
        CASE substring(Commands.Command FROM 1 FOR 1)
            WHEN 'x' THEN (
                SELECT string_agg(
                    Letter, ''
                    ORDER BY CASE Ordinality - 1
                        WHEN Idxs[1]::int THEN Idxs[2]::int
                        WHEN Idxs[2]::int THEN Idxs[1]::int
                        ELSE Ordinality - 1
                    END
                )
                FROM regexp_split_to_table(Str, '') WITH ORDINALITY Letter
            )
            WHEN 's' THEN substring(Str FROM Length - Idxs[1]::int + 1) || substring(Str FROM 1 FOR Length - Idxs[1]::int)
            WHEN 'p' THEN REPLACE(REPLACE(REPLACE(REPLACE(Str,
                Idxs[1], '2'),
                Idxs[2], '1'),
                '2', Idxs[2]),
                '1', Idxs[1]
            )
        END
    FROM DoStuff
    JOIN Commands USING(Ordinality)
    , LATERAL regexp_split_to_array(substring(Commands.Command FROM 2), '/') Idxs
    , LATERAL length(DoStuff.Str)
)
SELECT str
FROM DoStuff
ORDER BY Ordinality DESC LIMIT 1;
