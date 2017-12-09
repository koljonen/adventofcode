import re
with open('9.input', 'r') as file:
    input = file.read()

input = re.sub('!.', '', input)
depth = 0
score = 0
inside = False
for c in input:
    if inside and c == '>':
        inside = False
    elif inside:
        score = score + 1
    elif c == '<':
        inside = True
print(score)
