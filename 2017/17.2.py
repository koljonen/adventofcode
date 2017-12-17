steps = 324

numlen = 1
after0 = -1
pos = 0

for i in range(1, 50000000+1):
    pos = (pos + steps) % numlen
    numlen += 1
    pos += 1
    if pos == 1:
        after0 = i
        print(i)
print(after0, i, numlen)
