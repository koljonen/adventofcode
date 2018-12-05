import re
from collections import defaultdict, namedtuple
with open('/Users/joakimkoljonen/src/adventofcode/2018/5.input', 'r') as file:
    input = file.read()
def getans(str):
    i = 0
    while i < len(str) - 1:
        if str[i] == str[i + 1]:
            i += 1
        elif str[i].lower() == str[i + 1].lower():
            str = str[:i] + str[i+2:]
            i -= 1
        else:
            i += 1
    return len(str)
this_len = None
min_len = 1234567890
for c in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ':
    this_len = getans(input.replace(c, '').replace(c.lower(), ''))
    min_len = min(min_len, this_len)
ans = min_len - 1
print 'ans', ans
