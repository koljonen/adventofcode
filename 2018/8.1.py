import re
from collections import defaultdict, namedtuple

Rule = namedtuple('Rule', ['before', 'after'])

with open('/Users/joakimkoljonen/src/adventofcode/2018/8.input', 'r') as file:
    input = file.read()
line = [line for line in input.split('\n') if line != ''][0]
ints = [int(s) for s in line.split(' ')]
idx = 0
ans = 0
def handle_node():
    global idx
    global ans
    child_count = ints[idx]
    idx += 1
    meta_count = ints[idx]
    idx += 1
    for _ in range(child_count):
        handle_node()
    ans += sum(ints[idx:idx+meta_count])
    idx += meta_count

handle_node()
print 'ans', ans
