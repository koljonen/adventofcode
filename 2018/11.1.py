import re
from collections import defaultdict, namedtuple, deque

GRID_SIZE = 300
SERIAL = 1308

grid = []
for x in range(1, GRID_SIZE + 1):
    grid.append([])
    for y in range(1, GRID_SIZE + 1):
        rack_id = x + 10
        power = rack_id * y
        power += SERIAL
        power *= rack_id
        power = power // 100 % 10
        power -= 5
        grid[-1].append(power)

ans = max(
    (sum(sum(col[y-1:y+2]) for col in grid[x-1:x+2]), x, y)
    for x in range(1, GRID_SIZE - 2)
    for y in range(1, GRID_SIZE - 2)
)
            
print 'ans %s,%s' % (ans[1], ans[2])