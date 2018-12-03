from collections import defaultdict, namedtuple
with open('/Users/joakimkoljonen/src/adventofcode/2018/3.input', 'r') as file:
    input = file.read()
lines = [line for line in input.split('\n') if line != '']
ParsedLine = namedtuple('ParsedLine', ['id', 'x0', 'y0', 'xd', 'yd'])

splitlines = [line.replace(' @ ', ' ').replace('#', '').replace(',', ' ').replace(':', '').replace('x', ' ').split(' ') for line in lines]
intlines = [(int(x) for x in l) for l in splitlines]
parsedlines = [ParsedLine(*s) for s in intlines]
maxx = maxy = 0
nonoverlapping = set()
for l in parsedlines:
    maxx = max(maxx, l.x0 + l.xd)
    maxy = max(maxy, l.y0 + l.yd)
    nonoverlapping.add(l.id)
map = []
for x in range(maxx + 1):
    map.append([])
    for y in range(maxy + 1):
        map[x].append([])
for l in parsedlines:
    for x in range(l.x0, l.x0 + l.xd):
        for y in range(l.y0, l.y0 + l.yd):
            map[x][y] += 1
ans = 0            
for l in map:
    for x in l:
        if x > 1:
            ans += 1
print 'ans', ans
