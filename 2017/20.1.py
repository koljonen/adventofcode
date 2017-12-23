from collections import defaultdict
import re

with open('/Users/joakimkoljonen/src/adventofcode/2017/20.input', 'r') as file:
    input = file.read()

test_input = '''p=< 3,0,0>, v=< 2,0,0>, a=<-1,0,0>
p=< 4,0,0>, v=< 0,0,0>, a=<-2,0,0>

'''
#input = test_input

def parseline(line):
    return [parsestuff(thing) for thing in line.split(', ')]

def parsestuff(thing):
    print(thing)
    return [int(x) for x in thing[3:-1].split(',')]

parsed = [parseline(line) for line in input.split('\n') if line != '']

def getfunctions(stuff):
    return [
        lambda t: stuff[0][i] + t * stuff[1][i] + stuff[2][i] * t * t
        for i in range(3)
    ]
funcs = [getfunctions(stuff) for stuff in parsed]


def getans():
    mini = 1234567890123456789
    mini_idx = None
    for idx, fs in enumerate(parsed):
        dist = sum(abs(x) for x in fs[2])
        if abs(dist) < abs(mini):
            mini = dist
            mini_idx = idx
    return mini_idx

print(getans())
