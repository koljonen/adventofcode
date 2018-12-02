from collections import defaultdict

def count_diff(s1, s2):
    diffcount = 0
    for c1, c2 in zip(s1, s2):
        if c1 != c2:
            diffcount += 1
    return diffcount
with open('/Users/joakimkoljonen/src/adventofcode/2018/2.input', 'r') as file:
    input = file.read()
lines = [line for line in input.split('\n') if line != '']
for l1 in lines:
    for l2 in lines:
        if(count_diff(l1, l2) == 1):
            common = [c1 for c1, c2 in zip(l1, l2) if c1 == c2]
            print(''.join(common))
