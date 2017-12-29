BEGIN;

CREATE Type State AS (State char(1), Pos int, Tape hstore);

CREATE FUNCTION StepFunc(INOUT State State, _dummy int)
LANGUAGE SQL
AS $$
SELECT
    CASE (COALESCE(State.State, 'A'), COALESCE(State.Tape, '') ? COALESCE(State.Pos, 0)::text)
        WHEN ('A'::char(1), FALSE) THEN 'B'
        WHEN ('A'::char(1), TRUE)  THEN 'F'
        WHEN ('B'::char(1), FALSE) THEN 'C'
        WHEN ('B'::char(1), TRUE)  THEN 'D'
        WHEN ('C'::char(1), FALSE) THEN 'D'
        WHEN ('C'::char(1), TRUE)  THEN 'E'
        WHEN ('D'::char(1), FALSE) THEN 'E'
        WHEN ('D'::char(1), TRUE)  THEN 'D'
        WHEN ('E'::char(1), FALSE) THEN 'A'
        WHEN ('E'::char(1), TRUE)  THEN 'C'
        WHEN ('F'::char(1), FALSE) THEN 'A'
        WHEN ('F'::char(1), TRUE)  THEN 'A'
    END AS State,
    COALESCE(State.Pos, 0) + CASE (COALESCE(State.State, 'A'), COALESCE(State.Tape, '') ? COALESCE(State.Pos, 0)::text)
        WHEN ('A'::char(1), FALSE) THEN 1
        WHEN ('A'::char(1), TRUE)  THEN -1
        WHEN ('B'::char(1), FALSE) THEN 1
        WHEN ('B'::char(1), TRUE)  THEN 1
        WHEN ('C'::char(1), FALSE) THEN -1
        WHEN ('C'::char(1), TRUE)  THEN 1
        WHEN ('D'::char(1), FALSE) THEN -1
        WHEN ('D'::char(1), TRUE)  THEN -1
        WHEN ('E'::char(1), FALSE) THEN 1
        WHEN ('E'::char(1), TRUE)  THEN 1
        WHEN ('F'::char(1), FALSE) THEN -1
        WHEN ('F'::char(1), TRUE)  THEN 1
    END AS Pos,
    CASE (COALESCE(State.State, 'A'), COALESCE(State.Tape, '') ? COALESCE(State.Pos, 0)::text)
        WHEN ('A'::char(1), FALSE) THEN COALESCE(State.Tape, '') || hstore(COALESCE(State.Pos, 0)::text, '')
        WHEN ('A'::char(1), TRUE)  THEN COALESCE(State.Tape, '') - COALESCE(State.Pos, 0)::text
        WHEN ('B'::char(1), FALSE) THEN COALESCE(State.Tape, '')
        WHEN ('B'::char(1), TRUE)  THEN COALESCE(State.Tape, '') - COALESCE(State.Pos, 0)::text
        WHEN ('C'::char(1), FALSE) THEN COALESCE(State.Tape, '') || hstore(COALESCE(State.Pos, 0)::text, '')
        WHEN ('C'::char(1), TRUE)  THEN COALESCE(State.Tape, '')
        WHEN ('D'::char(1), FALSE) THEN COALESCE(State.Tape, '')
        WHEN ('D'::char(1), TRUE)  THEN COALESCE(State.Tape, '') - COALESCE(State.Pos, 0)::text
        WHEN ('E'::char(1), FALSE) THEN COALESCE(State.Tape, '')
        WHEN ('E'::char(1), TRUE)  THEN COALESCE(State.Tape, '')
        WHEN ('F'::char(1), FALSE) THEN COALESCE(State.Tape, '') || hstore(COALESCE(State.Pos, 0)::text, '')
        WHEN ('F'::char(1), TRUE)  THEN COALESCE(State.Tape, '')
    END AS Pos;
$$;

CREATE AGGREGATE Step(int) (
    sfunc = StepFunc,
    stype = State
);

SELECT cardinality(akeys((Step(1)).Tape))
FROM generate_series(
    1,
    12794428
);

ROLLBACK;
