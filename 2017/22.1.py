from collections import defaultdict
import re

with open('/Users/joakimkoljonen/src/adventofcode/2017/22.input', 'r') as file:
    input = file.read()

test_input = '''..#
#..
...
'''
#input = test_input

ROUNDS = 10000
parsed = [line for line in input.split('\n') if line != '']
infected = set()
middle = len(parsed) // 2
for rowidx, row in enumerate(parsed):
    for colidx, col in enumerate(row):
        if col == '#':
            infected.add((rowidx - middle, colidx - middle))

def getans():
    pos = (0, 0)
    direction = 'u'
    infections = 0
    for _ in range(ROUNDS):
        print(pos, direction, infections)
        if pos in infected:
            direction = {
                'l' : 'u',
                'd' : 'l',
                'r' : 'd',
                'u' : 'r',
            }[direction]
            infected.remove(pos)
        else:
            direction = {
                'u': 'l',
                'l': 'd',
                'd': 'r',
                'r': 'u',
            }[direction]
            infected.add(pos)
            infections += 1
        pos = {
                'l' : (pos[0], pos[1] - 1),
                'd' : (pos[0] + 1, pos[1]),
                'r' : (pos[0], pos[1] + 1),
                'u' : (pos[0] - 1, pos[1]),            
        }[direction]
    return infections

print(getans())
