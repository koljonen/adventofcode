from recordclass import recordclass

Particle = recordclass('Particle', 'x y dx dy')

with open('/Users/joakimkoljonen/src/adventofcode/2018/10.input', 'r') as file:
    input = file.read()
lines = [line for line in input.split('\n') if line != '']

particles = [
    Particle(
        x=int(line.split(',')[0].split('<')[1]),
        y=int(line.split(',')[1].split('>')[0]),
        dx=int(line.split(',')[1].split('<')[1]),
        dy=int(line.split(',')[2].split('>')[0])
    )
    for line in lines
]
    
def draw_stuff():
    minxdiff = float("inf")
    minydiff = float("inf")
    while True:
        for p in particles:
            p.x += p.dx
            p.y += p.dy
        xmax = max(p.x for p in particles)
        ymax = max(p.y for p in particles)
        xmin = min(p.x for p in particles)
        ymin = min(p.y for p in particles)
        xdiff = xmax - xmin
        ydiff = ymax - ymin
        minxdiff = min(xdiff, minxdiff)
        minydiff = min(ydiff, minydiff)
        if xdiff < 100 and ydiff < 100:
            found = True
            points = set()
            for p in particles:
                points.add((p.x,p.y))
            for y in range(ymin, ymax + 1):
                print ''.join('#' if (x, y) in points else '.' for x in range(xmin, xmax))
            print ''
        elif minxdiff < xdiff and minydiff < ydiff:
            return

draw_stuff()
