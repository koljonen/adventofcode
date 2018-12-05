import re
from collections import defaultdict, namedtuple
with open('/Users/joakimkoljonen/src/adventofcode/2018/5.input', 'r') as file:
    input = file.read()
i = 0
while i < len(input) - 1:
    if input[i] == input[i + 1]:
        i += 1
    elif input[i].lower() == input[i + 1].lower():
        input = input[:i] + input[i+2:]
        i -= 1
    else:
        i += 1

ans = len(input) - 1
print(input[-1:])
print 'ans', ans
