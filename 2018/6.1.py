import re
from collections import defaultdict, namedtuple

Position = namedtuple('Position', ['x', 'y'])

with open('/Users/joakimkoljonen/src/adventofcode/2018/6.input', 'r') as file:
    input = file.read()
lines = [line for line in input.split('\n') if line != '']

def position(x, y):
    return Position(int(x), int(y))

positions = [position(*(l.split(', '))) for l in lines]
infinites = set()

xmax = max(p.x for p in positions)
ymax = max(p.y for p in positions)
xmin = min(p.x for p in positions)
ymin = min(p.y for p in positions)

map = dict()
counts = defaultdict(lambda: 0)
latest = [[]]
for n, p in enumerate(positions):
    map[p] = n
    counts[n] += 1
    latest[0].append(p)

def neighbours(p):
    yield position(p.x - 1, p.y)
    yield position(p.x + 1, p.y)
    yield position(p.x, p.y - 1)
    yield position(p.x, p.y + 1)

distance = 0
while latest[distance]:
    points = dict()
    for l in latest[distance]:
        origin = map[l]
        for p in neighbours(l):
            if p in map: # already found
                continue
            elif p in points and points[p] != origin: # found simultaneously
                del points[p]
                map[p] = None
            else:
                points[p] = origin
    for p, origin in points.items():
        map[p] = origin
        if p.x <= xmin or p.x >= xmax or p.y <= ymin or p.y >= ymax:
            if origin not in infinites:
                infinites.add(origin)
        else:
            counts[origin] += 1
    distance += 1
    latest.append([p for p in points if xmin < p.x < xmax and ymin < p.y < ymax])

ans = max((c, o) for o, c in counts.items() if o not in infinites)[0]

print 'ans', ans
