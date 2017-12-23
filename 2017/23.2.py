cnt = 0
b, c, f, h = 0, 0, 0, 0

b = 8100 + 100000
c = b
c += 17000

while True: ##jnz 1 -23
    f = 1
    for d in range(2, b // 2): #jnz g -13
        e = b // d
        if b == e * d:
            f = 0
            break
    if not f: #jnz f 2
        h += 1
    if not b - c: #jnz g 2
        break #jnz 1 3
    b += 17
    if not 1: #jnz 1 -23
        break


print h
