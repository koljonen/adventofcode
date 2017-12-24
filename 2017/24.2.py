from collections import defaultdict, deque
import re

with open('/Users/joakimkoljonen/src/adventofcode/2017/24.input', 'r') as file:
    input = file.read()

test_input = '''0/2
2/2
2/3
3/4
3/5
0/1
10/1
9/10
'''
#input = test_input

components = [tuple(int(x) for x in i.split('/')) for i in input.split('\n') if i != '']
component_dict = defaultdict(list)
for component in components:
    component_dict[component[0]].append(component[1])
    component_dict[component[1]].append(component[0])

def bestbridge(current_end, used):
    max_score = 0
    max_len = 0
    for new_end in component_dict[current_end]:
        if (current_end, new_end) not in used:
            new_used = used | set([(current_end, new_end), (new_end, current_end)])
            score, length = bestbridge(new_end, new_used)
            score += current_end + new_end
            length += 1
            if (length, score) > (max_len, max_score):
                max_score = score
                max_len = length
    return max_score, max_len

def getans():
    return bestbridge(0, set())

ans = getans()
print(ans)
