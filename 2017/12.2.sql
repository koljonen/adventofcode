DROP TABLE IF EXISTS Connected;
CREATE TABLE Connected(Nodes int[]);
CREATE INDEX ON Connected USING gin(Nodes);
WITH Input AS (
    SELECT read_file('/Users/joakimkoljonen/src/adventofcode/2017/12.input') AS Input
)
INSERT INTO Connected(Nodes)
SELECT DISTINCT ToNodes::int[] || array[Parts[1]::int]
FROM Input
CROSS JOIN LATERAL regexp_split_to_table(Input, '\n') Lines
CROSS JOIN LATERAL regexp_split_to_array(Lines, ' <-> ') Parts
CROSS JOIN LATERAL regexp_split_to_array(Parts[2], ', ') ToNodes
WHERE Lines <> '';

CREATE FUNCTION MergeGroups(_Nodes int[])
RETURNS int[]
LANGUAGE SQL
AS $$
WITH Deletes AS (
    DELETE FROM Connected
    WHERE _Nodes && Nodes
    AND EXISTS (
        SELECT 1
        FROM Connected C
        WHERE C.Nodes && _Nodes
        HAVING COUNT(*) > 1
    )
    RETURNING Nodes
), Inserts AS (
    INSERT INTO Connected(Nodes)
    SELECT array_agg(DISTINCT unnest)
    FROM Deletes
    CROSS JOIN LATERAL unnest(Nodes)
    RETURNING Nodes
)
SELECT MergeGroups.*
FROM Inserts
CROSS JOIN LATERAL MergeGroups(Inserts.Nodes)
UNION ALL
SELECT _Nodes
WHERE NOT EXISTS(SELECT 1 FROM Inserts);
$$;

SELECT MergeGroups(Nodes)
FROM Connected;

SELECT COUNT(DISTINCT Nodes)
FROM Connected;
