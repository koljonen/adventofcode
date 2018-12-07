import re
from collections import defaultdict, namedtuple

Rule = namedtuple('Rule', ['before', 'after'])
NUM_WORKERS = 5

with open('/Users/joakimkoljonen/src/adventofcode/2018/7.input', 'r') as file:
    input = file.read()
lines = [line for line in input.split('\n') if line != '']

rules = [Rule(line[len('Step C') - 1], line[len('Step C must be finished before step A') - 1]) for line in lines]
ans = 0
in_progress = dict()
dependencies = defaultdict(set)
for rule in rules:
    if rule.before not in dependencies:
        dependencies[rule.before] = set()
    dependencies[rule.after].add(rule.before)
while dependencies:
    nxts = sorted(
        after
        for after, befores in dependencies.items()
        if not befores
        and after not in in_progress
    )[:NUM_WORKERS - len(in_progress)]
    for nxt in nxts:
        in_progress[nxt] = 61 + ord(nxt) - ord('A')
    
    for step, time_left in in_progress.items():
        if time_left == 1:
            del dependencies[step]
            del in_progress[step]
            for after, befores in dependencies.items():
                if step in befores:
                    befores.remove(step)
        else:
            in_progress[step] -= 1
    ans += 1
    
print 'ans', ans
