import re
from collections import defaultdict, namedtuple

MAX_DIST = 10000

Position = namedtuple('Position', ['x', 'y'])

with open('/Users/joakimkoljonen/src/adventofcode/2018/6.input', 'r') as file:
    input = file.read()
lines = [line for line in input.split('\n') if line != '']

def position(x, y):
    return Position(int(x), int(y))

positions = [position(*(l.split(', '))) for l in lines]

xmax = max(p.x for p in positions)
ymax = max(p.y for p in positions)
xmin = min(p.x for p in positions)
ymin = min(p.y for p in positions)

ans = 0
for x in range(xmin - MAX_DIST // len(positions), xmax + MAX_DIST // len(positions)):
    xdist = sum(abs(x - p.x) for p in positions)
    if xdist >= MAX_DIST:
        continue
    for y in range(ymin - MAX_DIST // len(positions), ymax + MAX_DIST // len(positions)):
        total = sum(abs(x - p.x) + abs(y - p.y) for p in positions)
        if total < MAX_DIST:
            ans += 1

print 'ans', ans
