from collections import defaultdict
with open('/Users/joakimkoljonen/src/adventofcode/2018/2.input', 'r') as file:
    input = file.read()
twocount = 0
threecount = 0
for line in input.split('\n'):
    if line != '':
        char_counts = defaultdict(lambda: 0)
        found_two = False
        found_three = False
        for char in line:
            char_counts[char] += 1
        for c, cc in char_counts.iteritems():
            if cc == 2 and not found_two:
                twocount += 1
                found_two = True
            if cc == 3 and not found_three:
                threecount += 1
                found_three = True

print(threecount * twocount)
