from collections import defaultdict, deque
input = '''set i 31
set a 1
mul p 17
jgz p p
mul a 2
add i -1
jgz i -2
add a -1
set i 127
set p 826
mul p 8505
mod p a
mul p 129749
add p 12345
mod p a
set b p
mod b 10000
snd b
add i -1
jgz i -9
jgz a 3
rcv b
jgz b -1
set f 0
set i 126
rcv a
rcv b
set p a
mul p -1
add p b
jgz p 4
snd a
set a b
jgz 1 3
snd b
set f 1
add i -1
jgz i -11
snd a
jgz f -16
jgz a -19'''

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
print(sent)
