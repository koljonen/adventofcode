from collections import defaultdict

with open('/Users/joakimkoljonen/src/adventofcode/23.input', 'r') as file:
    input = file.read()

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
        val = getval(registers, instruction[2])
        if typ == 'set':
            registers[reg] = val
        elif typ == 'sub':
            registers[reg] -= val
        elif typ == 'mul':
            registers[reg] *= val
            cnt += 1
        elif typ == 'jnz':
            if getval(registers, reg) != 0:
                pos += val - 1
        pos += 1
    return cnt

ans = run()
print(ans)
