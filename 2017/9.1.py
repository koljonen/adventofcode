import re
with open('9.input', 'r') as file:
    input = file.read()

input = re.sub('!.', '', input)
input = re.sub('<.*?>', '', input)
depth = 0
score = 0
for c in input:
    if c == '{':
        depth = depth + 1
    elif c == '}':
        score = score + depth
        depth = depth - 1
print(score)
