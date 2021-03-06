from collections import defaultdict

with open('/Users/joakimkoljonen/src/adventofcode/2017/18.input', 'r') as file:
    input = file.read()

test_input = '''set a 1
add a 2
mul a a
mod a 5
snd a
set a 0
rcv a
jgz a -1
set a 1
jgz a -2'''
#input = test_input

instructions = [i.split(' ') for i in input.split('\n')]
registers = defaultdict(lambda: 0)
pos = 0
recoverable = None

#snd X plays a sound with a frequency equal to the value of X.
#set X Y sets register X to the value of Y.
#add X Y increases register X by the value of Y.
#mul X Y sets register X to the result of multiplying the value contained in register X by the value of Y.
#mod X Y sets register X to the remainder of dividing the value contained in register X by the value of Y (that is, it sets X to the result of X modulo Y).
#rcv X recovers the frequency of the last sound played, but only when the value of X is not zero. (If it is zero, the command does nothing.)
#jgz X Y jumps with an offset of the value of Y, but only if the value of X is greater than zero. (An offset of 2 skips the next instruction, an offset of -1 jumps to the previous instruction, and so on.)

while pos < len(instructions):
    instruction = instructions[pos]
    typ = instruction[0]
    reg = instruction[1]
    val = None
    if len(instruction) > 2:
        val = instruction[2]
        try:
            val = int(val)
        except:
            val = registers[val]
    if typ == 'snd':
        recoverable = registers[reg]
    elif typ == 'set':
        registers[reg] = val
    elif typ == 'add':
        registers[reg] += val
    elif typ == 'mul':
        registers[reg] *= val
    elif typ == 'mod':
        registers[reg] %= val
    elif typ == 'rcv':
        if registers[reg] != 0:
            print(recoverable)
            break
    elif typ == 'jgz':
        if registers[reg] > 0:
            pos += val - 1
    pos += 1
