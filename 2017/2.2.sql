WITH Split AS (
    SELECT regexp_split_to_array(Lines, '\t') AS Split
    FROM read_file('/Users/joakimkoljonen/src/adventofcode/2017/2.input') Input
    , regexp_split_to_table(Input, '\n') Lines
    WHERE Lines <> ''
), Vals AS (
    SELECT RANK() OVER(ORDER BY Split) AS RowNum, unnest(split)::int AS Val
    FROM Split
)
SELECT SUM(V2.Val / V1.Val)
FROM Vals V1
JOIn Vals V2 USING(RowNum)
WHERE V1.Val < V2.Val AND V2.Val % V1.Val = 0
