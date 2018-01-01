input = 265149
x, y, d = 0, 0, 'right'
for i in range(input - 1):
    x += {'left' : -1, 'right' : 1}.get(d, 0)
    y += {'down' : -1, 'up' : 1}.get(d, 0)
    if x == y and x < 0:
        d = 'right'
    if x == y and x > 0:
        d = 'left'
    if x == -y and x < 0:
        d = 'down'
    if x == -y + 1 and x > 0:
        d = 'up'
print(abs(x) + abs(y))
