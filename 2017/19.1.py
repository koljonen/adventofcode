from collections import defaultdict
import re

with open('/Users/joakimkoljonen/src/adventofcode/2017/19.input', 'r') as file:
    input = file.read()

test_input = '''     |          
     |  +--+    
     A  |  C    
 F---|----E|--+ 
     |  |  |  D 
     +B-+  +--+ '''
#input = test_input
parsed = input.split('\n')
direction = 'd'
ans = ''

def getfirst():
    for col, char in enumerate(parsed[0]):
        if char == '|':
            return col

row, col = 0, getfirst()

def getnext(fromrow, fromcol, dir):
    if dir == 'd':
        fromrow += 1
    elif dir == 'u':
        fromrow -= 1
    elif dir == 'r':
        fromcol += 1
    elif dir == 'l':
        fromcol -= 1
    if 0 <= fromrow < len(parsed) and 0 <= fromcol < len(parsed[0]):
        pass
    else:
        return None, None
    if parsed[fromrow][fromcol] == ' ':
        return None, None
    return fromrow, fromcol

def getnewdir(row, col, dir):
    directions = {
        'd': ['l', 'r'],
        'u': ['l', 'r'],
        'l': ['d', 'u'],
        'r': ['d', 'u']
    }[dir]
    for newdir in directions:
        newrow, newcol = getnext(row, col, newdir)
        if newrow is None:
            continue
        else:
            return newdir


def getans():
    global row, col, direction, ans
    while True:
        newrow, newcol = getnext(row, col, direction)
        if newrow is None:
            direction = getnewdir(row, col, direction)
            if not direction:
                return
        row, col = getnext(row, col, direction)
        char = parsed[row][col]
        if char in ('-', '+', '|'):
            continue
        ans += char

getans()

print(ans)
