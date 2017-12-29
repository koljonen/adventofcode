from math import sqrt

print sum(
    any(b == b // d * d for d in range(2, int(sqrt(b))))
    for b in range(8100 + 100000, 8100 + 100000 + 17000 + 1, 17)
)
