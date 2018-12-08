import re
from collections import defaultdict, namedtuple

Rule = namedtuple('Rule', ['before', 'after'])

with open('/Users/joakimkoljonen/src/adventofcode/2018/8.input', 'r') as file:
    input = file.read()
line = [line for line in input.split('\n') if line != ''][0]
ints = [int(s) for s in line.split(' ')]
def handle_node(idx):
    child_count = ints[idx]
    idx += 1
    meta_count = ints[idx]
    idx += 1
    children = []
    for _ in range(child_count):
        val, idx = handle_node(idx)
        children.append(val)
    if child_count == 0:
        val = sum(ints[idx:idx+meta_count])
    else:
        val = sum(children[i-1] for i in ints[idx:idx+meta_count] if 0 < i <= len(children))
    idx += meta_count
    return val, idx

ans = handle_node(0)[0]
print 'ans', ans
