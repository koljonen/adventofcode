input = '''10	3	15	10	5	15	5	15	9	2	5	8	5	2	3	6'''
#input = '''0	2	7	0'''

nums = [int(n) for n in input.split('\t')]

seen = set()

def getmax():
    pos = 1
    val = -1
    for n, v in enumerate(nums):
        if v > val:
            pos, val = n, v
    return pos, val

steps = 0
while tuple(nums) not in seen:
    seen.add(tuple(nums))
    maxpos, maxval = getmax()
    nums[maxpos] = 0
    for i in range(maxpos + 1, maxpos + maxval + 1):
        nums[i % len(nums)] += 1
    steps += 1

#print(seen)
print(len(seen))
