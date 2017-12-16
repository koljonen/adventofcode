WITH RECURSIVE Input AS (
    SELECT read_file('/Users/joakimkoljonen/src/adventofcode/2017/12.input') AS Input
), Connections AS (
    SELECT DISTINCT X.*
    FROM Input
    CROSS JOIN LATERAL regexp_split_to_table(Input, '\n') Lines
    CROSS JOIN LATERAL regexp_split_to_array(Lines, ' <-> ') Parts
    CROSS JOIN LATERAL regexp_split_to_table(Parts[2], ', ') ToNodes
    CROSS JOIN LATERAL (
        SELECT Parts[1]::int AS Frm, ToNodes::int AS ToNode
        UNION ALL
        SELECT ToNodes::int AS Frm, Parts[1]::int AS ToNode
    ) X
), RecursiveConnections AS (
    SELECT Connections.Frm, Connections_To.ToNode, array[Connections.Frm, Connections_To.ToNode] AS Path
    FROM Connections
    JOIN Connections Connections_To ON Connections_To.Frm = Connections.Frm
    WHERE Connections.Frm = 0
    UNION ALL
    SELECT RecursiveConnections.Frm, Connections_To.ToNode, RecursiveConnections.Path || array[Connections_To.ToNode] AS Path
    FROM RecursiveConnections
    JOIN Connections Connections_To ON Connections_To.Frm = RecursiveConnections.ToNode
    WHERE Connections_To.ToNode <> ALL(RecursiveConnections.Path)
)
SELECT COUNT(DISTINCT unnest)
FROM RecursiveConnections
CROSS JOIN LATERAL unnest(Path);
