from numpy import roots
from math import sqrt
from collections import defaultdict

with open('/Users/joakimkoljonen/src/adventofcode/20.input', 'r') as file:
    input = file.read()

test_input = '''p=<-2,2,6>, v=< -1,0,-1>, a=< 2,0,0>
p=<-2,2,3>, v=<0,0,0>, a=<1,0,0>
p=<-2,0,0>, v=<1,0,0>, a=<0,0,0>
p=<3,0,0>, v=<-1,0,0>, a=<0,0,0>
'''
test_input2 = '''p=<-6,0,0>, v=< 3,0,0>, a=< 0,0,0>
p=<-4,0,0>, v=<2,0,0>, a=<0,0,0>
p=<-2,0,0>, v=<1,0,0>, a=<0,0,0>
p=<3,0,0>, v=<1,0,0>, a=<0,0,0>
'''
#input = test_input2

def parseline(line):
    return [parsestuff(thing) for thing in line.split(', ')]

def parsestuff(thing):
    return [int(x) for x in thing[3:-1].split(',')]

points = [parseline(line) for line in input.split('\n') if line != '']

def solvequadratic(pos, vel, acc):
    if acc == 0 and vel == 0:
        if pos == 0:
            return 'ALL'
        return []
    if acc == 0:
        sol = - pos / vel
        if sol * vel + pos == 0 and sol >= 0:
            return [int(sol)]
        return []
    vel = vel - acc / 2.0
    acc = acc / 2.0
    discriminant = (vel ** 2) - (4* acc * pos)
    if discriminant < 0:
        return []
    sol1 = int((-vel - sqrt(discriminant)) / (2 * acc))
    sol2 = int((-vel + sqrt(discriminant)) / (2 * acc))
    return [s for s in (sol1, sol2) if pos + s * vel + acc * s * s == 0 and s >= 0]

def getcommon(solutions):
    cands = [s for ss in solutions for s in ss]
    def check(cand, sols):
        return sols == 'ALL' or cand in sols
    return [c for c in cands if all(check(c, sols) for sols in solutions)]

collisions = defaultdict(set)
for idx1, point1 in enumerate(points):
    for idx2, point2 in enumerate(points):
        if idx2 <= idx1:
            continue
        sols = []
        for coordinate in range(3):
            #print([point1[i][coordinate] for i in range(3)])
            #print([point2[i][coordinate] for i in range(3)])
            p = [point1[i][coordinate] - point2[i][coordinate] for i in range(3)]
            csols = solvequadratic(*p)
            sols.append(csols)
        commonsols = getcommon(sols)
        if sols[0] and sols[1] and sols[2]:
            print(sols)
            print(point1)
            print(point2)
            print [
                [point1[typ][coord] - point2[typ][coord] for coord in range(3)]
                for typ in range(3)
            ]
        for s in commonsols:
            collisions[s].add(idx1)
            collisions[s].add(idx2)


def getans():
    return collisions
print(getans())
