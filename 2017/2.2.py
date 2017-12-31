with open('/Users/joakimkoljonen/src/adventofcode/2017/2.input', 'r') as file:
    input = file.read()
def getdiff(nums):
    return sum (
        num // divider
        for num in nums
        for divider in nums
        if divider < num and num % divider == 0
    )
print sum(
    getdiff([int(num) for num in line.split('\t')])
    for line in input.split('\n') if line != ''
)
