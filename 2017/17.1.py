steps = 324

nums = [0]
pos = 0

for i in range(1, 5000000+1):
    pos = (pos + steps) % len(nums)
    nums = nums[:pos] + [i] + nums[pos:]
    pos += 1
print(nums[pos + 1])
