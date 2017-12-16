WITH Input AS (
    SELECT read_file('/Users/joakimkoljonen/src/adventofcode/2017/13.input') AS Input
), Parse AS (
    SELECT Parts[1]::int AS Depth, Parts[2]::int AS Range
    FROM Input
    , LATERAL regexp_split_to_table(Input.Input, '\n') Lines
    , LATERAL regexp_split_to_array(Lines, ': ') Parts
    WHERE LINES <> ''
)
SELECT SUM(CASE Depth % ((Range - 1) * 2) WHEN 0 THEN Depth * Range END)
FROM Parse
