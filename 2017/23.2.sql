SELECT COUNT(*)
FROM generate_series(8100 + 100000, 8100 + 100000 + 17000 + 1, 17) b
WHERE EXISTS(
    SELECT 1
    FROM generate_series(2, sqrt(b)::int) d
    WHERE b / d * d = b
);
