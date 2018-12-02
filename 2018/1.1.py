from collections import defaultdict
with open('/Users/joakimkoljonen/src/adventofcode/2018/1.input', 'r') as file:
    input = file.read()
frequency = 0
for line in input.split('\n'):
    if line != '':
        frequency += int(line)

print(frequency)
