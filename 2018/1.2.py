with open('/Users/joakimkoljonen/src/adventofcode/2018/1.input', 'r') as file:
    input = file.read()
commands = [line for line in input.split('\n') if line != '']
def get_ans(commands):
    frequency = 0
    frequencies = set([0])
    while True:
        for command in commands:
            frequency += int(command)
            if frequency in frequencies:
                return frequency
            frequencies.add(frequency)

print 'ans', get_ans(commands)
assert get_ans('+3, +3, +4, -2, -4'.split(', ')) == 10
