from operator import xor
from functools import reduce
input = '63,144,180,149,1,255,167,84,125,65,188,0,2,254,229,24'
lengths = [ord(n) for n in input] + [17, 31, 73, 47, 23]
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
ans = ''.join(hex(num)[2:].zfill(2) for num in dense)
print(ans)
