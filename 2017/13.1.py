from collections import defaultdict
input = '''0: 3
1: 2
2: 4
4: 4
6: 5
8: 6
10: 8
12: 8
14: 6
16: 6
18: 9
20: 8
22: 6
24: 10
26: 12
28: 8
30: 8
32: 14
34: 12
36: 8
38: 12
40: 12
42: 12
44: 12
46: 12
48: 14
50: 12
52: 12
54: 10
56: 14
58: 12
60: 14
62: 14
64: 14
66: 14
68: 14
70: 14
72: 14
74: 20
78: 14
80: 14
90: 17
96: 18'''

lines = input.split('\n')
ranges = dict()
severity = 0
def getseverity(delay):
    def getpos(_range, depth):
        direction = 1
        pos = severity
        for i in range(depth):
            if pos == 0 and direction == -1:
                direction = 1
            elif pos == _range - 1 and direction == 1:
                direction = -1
            pos += direction
        return pos
    for line in lines:
        split = line.split(': ')
        depth = int(split[0])
        _range = int(split[1])
        pos = getpos(_range, depth)
        if pos == 0:
            severity += depth * _range
    return severity

for delay in range(123456):
    if getseverity(delay) == 0
        print(delay)
        break
