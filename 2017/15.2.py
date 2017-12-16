a = 289
b = 629
cnt = 0
def nxt(num, multiplier, divider, checker):
    num = num * multiplier % divider
    while num % checker:
        num = num * multiplier % divider
    return num
for i in range(5000000):
    a = nxt(a, 16807, 2147483647, 4)
    b = nxt(b, 48271, 2147483647, 8)
    if (a & 65535) == (b & 65535):
        cnt += 1
print(cnt)
