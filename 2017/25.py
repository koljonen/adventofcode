pos = 0
tape = set()
state = 'A'
for i in range(12794428):
    if state == 'A':
        if pos not in tape:
            tape.add(pos)
            pos += 1
            state = 'B'
        else:
            tape.remove(pos)
            pos -= 1
            state = 'F'
    elif state == 'B':
        if pos not in tape:
            pos += 1
            state = 'C'
        else:
            tape.remove(pos)
            pos += 1
            state = 'D'
    elif state == 'C':
        if pos not in tape:
            tape.add(pos)
            pos -= 1
            state = 'D'
        else:
            pos += 1
            state = 'E'
    elif state == 'D':
        if pos not in tape:
            pos -= 1
            state = 'E'
        else:
            tape.remove(pos)
            pos -= 1
            state = 'D'
    elif state == 'E':
        if pos not in tape:
            pos += 1
            state = 'A'
        else:
            pos += 1
            state = 'C'
    elif state == 'F':
        if pos not in tape:
            tape.add(pos)
            pos -= 1
            state = 'A'
        else:
            pos += 1
            state = 'A'

print(len(tape))
