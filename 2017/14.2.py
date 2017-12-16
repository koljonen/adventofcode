from operator import xor
from functools import reduce

input = 'stpzcrnm'

def binary_hash(input_str):
    lengths = [ord(n) for n in input_str] + [17, 31, 73, 47, 23]
    pos, skip_size = 0, 0
    listylist = list(range(256))
    for x in range(64):
        for length in lengths:
            end = min(pos + length, len(listylist))
            wrap_end  = max(pos + length - len(listylist), 0)
            selection = listylist[pos:end] + listylist[0:wrap_end]
            rev = selection[::-1]
            listylist[pos:end] = rev[:end - pos]
            listylist[0:wrap_end] = rev[end -pos:]
            pos = (pos + length + skip_size) % len(listylist)
            skip_size = skip_size + 1
    dense = [reduce(xor, listylist[i*16:i*16+16]) for i in range(16)]
    return ''.join(format(n, '08b') for n in dense)

data = [binary_hash(input + '-' + str(i)) for i in range(128)]

cnt = 0
visited = set()

def visit(row, col):
    if (row, col) in visited or data[row][col] != '1':
        return False
    visited.add((row, col))
    for (row2, col2) in ((row - 1, col), (row + 1, col), (row, col - 1), (row, col + 1)):
        if 0 <= row2 < len(data) and 0 <= col2 < len(data[0]):
            visit(row2, col2)
    return True

for row_num, row in enumerate(data):
    for col_num, col in enumerate(row):
        if visit(row_num, col_num):
            cnt += 1

print(cnt)
