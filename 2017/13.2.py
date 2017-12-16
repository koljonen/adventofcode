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
lines = [tuple(int(x) for x in line.split(': ')) for line in input.split('\n')]
def has_hits(delay):
    for line in lines:
        depth = line[0]
        _range = line[1]
        if depth % (2 * _range - 2) == 0:
            return True
    return False

for delay in range(123456789):
    if not has_hits(delay):
        print(delay)
        break
