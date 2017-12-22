from numpy import roots
from math import sqrt
from collections import defaultdict, namedtuple

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
test_input3 = '''p=<1,3,2>, v=< 2,0,0>, a=<3,0,2>
p=<10,0,-1>, v=< 0,1,0>, a=<2,0,3>
p=<1,0,-1>, v=< 2,1,0>, a=<3,0,3>
'''
test_input4 = '''p=< -5,0,0>, v=< 2,0,0>, a=<-1,0,0>
p=< 4,0,0>, v=< 0,0,0>, a=<-2,0,0>
'''
#input = test_input4

Particle = namedtuple('Particle', ['pos', 'vel', 'acc'])

def parseline(line):
    return Particle(*[parsestuff(thing) for thing in line.split(', ')])

def parsestuff(thing):
    return [int(x) for x in thing[3:-1].split(',')]

particles = [parseline(line) for line in input.split('\n') if line != '']

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
    vel = vel + acc / 2.0
    acc = acc / 2.0
    discriminant = (vel ** 2) - (4 * acc * pos)
    if discriminant < 0:
        return []
    sol1 = (-vel - sqrt(discriminant)) / (2.0 * acc)
    sol2 = (-vel + sqrt(discriminant)) / (2.0 * acc)
    return [s for s in (sol1, sol2) if s >= 0]

def getcommon(solutions):
    cands = [s for ss in solutions for s in ss]
    def check(cand, sols):
        return sols == 'ALL' or cand in sols
    return [c for c in cands if all(check(c, sols) for sols in solutions)]

def getcollisions():
    collisions = defaultdict(set)
    for idx1, p1 in enumerate(particles):
        for idx2, p2 in enumerate(particles):
            if idx2 <= idx1:
                continue
            sols = []
            for coordinate in range(3):
                p = [p1[i][coordinate] - p2[i][coordinate] for i in range(3)]
                csols = solvequadratic(*p)
                sols.append(csols)
            commonsols = getcommon(sols)
            for s in commonsols:
                collisions[s].add(idx1)
                collisions[s].add(idx2)
    return collisions


def getans():
    dead = set()
    for time, colliders in sorted(getcollisions().items()):
        colliders = [p for p in colliders if p not in dead]
        if len(colliders) > 1:
            dead.update(colliders)
    return len(particles) - len(dead)
print(getans())
