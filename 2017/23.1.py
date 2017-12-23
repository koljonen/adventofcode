from collections import defaultdict, deque
import re

with open('/Users/joakimkoljonen/src/adventofcode/23.input', 'r') as file:
    input = file.read()

'''
set X Y sets register X to the value of Y.
sub X Y decreases register X by the value of Y.
mul X Y sets register X to the result of multiplying the value contained in register X by the value of Y.
jnz X Y jumps with an offset of the value of Y, but only if the value of X is not zero. (An offset of 2 skips the next instruction, an offset of -1 jumps to the previous instruction, and so on.)
Only the instructions listed above are used. The eight registers here, named a through h, all start at 0.

The coprocessor is currently set to some kind of debug mode, which allows for testing, but prevents it from doing any meaningful work.

If you run the program (your puzzle input), how many times is the mul instruction invoked?
'''

test_input = '''..#
#..
...
'''
#input = test_input

instructions = [i.split(' ') for i in input.split('\n') if i != '']

def getval(registers, val):
    try:
        val = int(val)
    except:
        val = registers[val]
    return val

def run():
    cnt = 0
    registers = defaultdict(lambda: 0)
    registers['a'] = 1
    
    pos = 0
    while 0 <= pos < len(instructions):
        instruction = instructions[pos]
        typ = instruction[0]
        reg = instruction[1]
        val = None
        if len(instruction) > 2:
            val = getval(registers, instruction[2])
        #print(typ, reg, val, pos, instruction)
        if typ == 'snd':
            val = getval(registers, instruction[1])
            queues[not program_id].append(val)
            sent[program_id] += 1
        elif typ == 'set':
            registers[reg] = val
        elif typ == 'sub':
            registers[reg] -= val
        elif typ == 'mul':
            registers[reg] *= val
            cnt += 1
        elif typ == 'mod':
            registers[reg] %= val
            val = queues[program_id].popleft()
            registers[reg] = val
        elif typ == 'jnz':
            if getval(registers, reg) != 0:
                pos += val - 1
        pos += 1
    return cnt

ans = run()
print(ans)
