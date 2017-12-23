from collections import defaultdict
import re

with open('/Users/joakimkoljonen/src/adventofcode/2017/22.input', 'r') as file:
    input = file.read()

test_input = '''..#
#..
...
'''
#input = test_input

ROUNDS = 10000000
parsed = [line for line in input.split('\n') if line != '']
infected = set()
flagged = set()
weakened = set()
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
        if ROUNDS < 100:
            print(pos, direction, infections)
        if pos in infected:
            if ROUNDS < 100:
                print('infected, flagging')
            direction = {
                'l' : 'u',
                'd' : 'l',
                'r' : 'd',
                'u' : 'r',
            }[direction]
            infected.remove(pos)
            flagged.add(pos)
        elif pos in flagged:
            if ROUNDS < 100:
                print('flagged, cleaning')
            direction = {
                'l' : 'r',
                'd' : 'u',
                'r' : 'l',
                'u' : 'd',
            }[direction]
            flagged.remove(pos)
        elif pos in weakened:
            if ROUNDS < 100:
                print('weakened, infecting')
            weakened.remove(pos)
            infected.add(pos)
            infections += 1
        else:
            if ROUNDS < 100:
                print('clean, weakening')
            direction = {
                'u': 'l',
                'l': 'd',
                'd': 'r',
                'r': 'u',
            }[direction]
            weakened.add(pos)
        pos = {
            'l' : (pos[0], pos[1] - 1),
            'd' : (pos[0] + 1, pos[1]),
            'r' : (pos[0], pos[1] + 1),
            'u' : (pos[0] - 1, pos[1]),            
        }[direction]
    return infections

print(getans())
