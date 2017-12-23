from collections import defaultdict, deque

with open('/Users/joakimkoljonen/src/adventofcode/2017/18.input', 'r') as file:
    input = file.read()

test_input = '''snd 1
snd 2
snd p
rcv a
rcv b
rcv c
rcv d'''
#input = test_input

instructions = [i.split(' ') for i in input.split('\n')]

queues = [deque(), deque()]
sent = [0, 0]

def getval(registers, val):
    try:
        val = int(val)
    except:
        val = registers[val]
    return val

def step(program_id):
    registers = defaultdict(lambda: 0)
    registers['p'] = program_id
    pos = 0
    while 0 <= pos < len(instructions):
        instruction = instructions[pos]
        typ = instruction[0]
        reg = instruction[1]
        val = None
        if len(instruction) > 2:
            val = getval(registers, instruction[2])
        if typ == 'snd':
            val = getval(registers, instruction[1])
            queues[not program_id].append(val)
            sent[program_id] += 1
        elif typ == 'set':
            registers[reg] = val
        elif typ == 'add':
            registers[reg] += val
        elif typ == 'mul':
            registers[reg] *= val
        elif typ == 'mod':
            registers[reg] %= val
        elif typ == 'rcv':
            while not queues[program_id]:
                yield not program_id
            val = queues[program_id].popleft()
            registers[reg] = val
        elif typ == 'jgz':
            if getval(registers, reg) > 0:
                pos += val - 1
        pos += 1

executors = [step(i) for i in range(2)]
while True:
    for i in range(2):
        executors[i].next()
    if (not queues[0]) and (not queues[1]):
        break

print(sent[1])
