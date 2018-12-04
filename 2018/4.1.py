import re
from collections import defaultdict, namedtuple
with open('/Users/joakimkoljonen/src/adventofcode/2018/4.input', 'r') as file:
    input = file.read()
lines = [line for line in input.split('\n') if line != '']

lines.sort()
guards_asleep = defaultdict(lambda: [0] * 60)

guard = None
asleep_since = None
for line in lines:
    if line[len('[1518-05-11 23:50] Guard #') - 1] == '#':
        guard = re.search('#(\d+)', line).group(1)
        asleep_since = None
    elif line[len('[1518-11-01 00:25] '):len('[1518-11-01 00:25] wakes up')] == 'wakes up':
        time = line[len('[1518-11-01 00:'):len('[1518-11-01 00:25')]
        for m in range(asleep_since, int(time)):
            guards_asleep[guard][m] += 1
        asleep_since = None
    elif line[len('[1518-11-01 00:25] '):len('[1518-11-01 00:25] falls asleep')] == 'falls asleep':
        asleep_since = int(line[len('[1518-11-01 00:'):len('[1518-11-01 00:25')])


most_asleep_guard = max((sum(ms), g) for g, ms in guards_asleep.items())[1]
most_asleep_minute = max((asleep, minute) for minute, asleep in enumerate(guards_asleep[most_asleep_guard]))[1]

ans = int(most_asleep_guard) * most_asleep_minute

print 'ans', ans
