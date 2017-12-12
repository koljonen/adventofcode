input = '63,144,180,149,1,255,167,84,125,65,188,0,2,254,229,24'
lengths = [int(n) for n in input.split(',')]
pos, skip_size = 0, 0
listylist = list(range(256))
for length in lengths:
    end = min(pos + length, len(listylist))
    wrap_end  = max(pos + length - len(listylist), 0)
    selection = listylist[pos:end] + listylist[0:wrap_end]
    rev = selection[::-1]
    listylist[pos:end] = rev[:end - pos]
    listylist[0:wrap_end] = rev[end -pos:]
    pos = (pos + length + skip_size) % len(listylist)
    skip_size = skip_size + 1
print(listylist[0] * listylist[1])
