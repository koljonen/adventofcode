BEGIN;

-- For some reason variadic calls to the built-in least/greatest don't work
CREATE OR REPLACE FUNCTION public.least(variadic _nums int[])
RETURNS int
LANGUAGE SQL
AS $$ SELECT MIN(unnest) FROM  unnest($1) $$;

CREATE OR REPLACE FUNCTION public.greatest(variadic _nums int[])
RETURNS int
LANGUAGE SQL
AS $$ SELECT MAX(unnest) FROM  unnest($1) $$;

WITH Split AS (
    SELECT regexp_split_to_array(Lines, '\t') AS Split
    FROM read_file('/Users/joakimkoljonen/src/adventofcode/2017/2.input') Input
    , regexp_split_to_table(Input, '\n') Lines
    WHERE Lines <> ''
)
SELECT SUM(public.greatest(variadic Split::int[]) - public.least(variadic Split::int[]))
FROM Split;

ROLLBACK;
