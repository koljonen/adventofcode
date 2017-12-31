with open('/Users/joakimkoljonen/src/adventofcode/2017/2.input', 'r') as file:
    input = file.read()
def getdiff(nums):
    return max(nums) - min(nums)
print sum(
    getdiff([int(num) for num in line.split('\t')])
    for line in input.split('\n') if line != ''
)
