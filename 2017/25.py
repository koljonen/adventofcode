pos = 0
tape = defaultdict(lambda: 0)
state = 'A'
for i in range(12794428):
    if state == 'A':
        if tape[pos] == 0:
            tape[pos] = 1
            pos += 1
            state = 'B'
        elif tape[pos] == 1:
            tape[pos] = 0
            pos -= 1
            state = 'F'

    elif state == 'B':
        if tape[pos] == 0:
            tape[pos] = 0
            pos += 1
            state = 'C'
        elif tape[pos] == 1:
            tape[pos] = 0
            pos += 1
            state = 'D'

    elif state == 'C':
        if tape[pos] == 0:
            tape[pos] = 1
            pos -= 1
            state = 'D'
        elif tape[pos] == 1:
            tape[pos] = 1
            pos += 1
            state = 'E'

    elif state == 'D':
        if tape[pos] == 0:
            tape[pos] = 0
            pos -= 1
            state = 'E'
        elif tape[pos] == 1:
            tape[pos] = 0
            pos -= 1
            state = 'D'

    elif state == 'E':
        if tape[pos] == 0:
            tape[pos] = 0
            pos += 1
            state = 'A'
        elif tape[pos] == 1:
            tape[pos] = 1
            pos += 1
            state = 'C'

    elif state == 'F':
        if tape[pos] == 0:
            tape[pos] = 1
            pos -= 1
            state = 'A'
        elif tape[pos] == 1:
            tape[pos] = 1
            pos += 1
            state = 'A'

ans = sum(tape.values())
print(ans)
