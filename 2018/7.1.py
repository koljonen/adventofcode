import re
from collections import defaultdict, namedtuple

Rule = namedtuple('Rule', ['before', 'after'])

with open('/Users/joakimkoljonen/src/adventofcode/2018/7.input', 'r') as file:
    input = file.read()
lines = [line for line in input.split('\n') if line != '']

rules = [Rule(line[len('Step C') - 1], line[len('Step C must be finished before step A') - 1]) for line in lines]
ans = ""
dependencies = defaultdict(set)
for rule in rules:
    if rule.before not in dependencies:
        dependencies[rule.before] = set()
    dependencies[rule.after].add(rule.before)
while dependencies:
    nxt = sorted([after for after, befores in dependencies.items() if not befores])[0]
    del dependencies[nxt]
    for after, befores in dependencies.items():
        if nxt in befores:
            befores.remove(nxt)
    ans += nxt
    
print 'ans', ans
