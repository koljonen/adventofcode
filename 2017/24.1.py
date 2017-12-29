from collections import defaultdict

with open('/Users/joakimkoljonen/src/adventofcode/2017/24.input', 'r') as file:
    input = file.read()

with open('/Users/joakimkoljonen/src/adventofcode/2017/24.test_input', 'r') as file:
    test_input = file.read()
#input = test_input

components = [tuple(int(x) for x in i.split('/')) for i in input.split('\n') if i != '']
component_dict = defaultdict(list)
for component in (tuple(int(x) for x in line.split('/')) for line in input.split('\n') if line != ''):
    component_dict[component[0]].append(component[1])
    if component[0] != component[1]:
        component_dict[component[1]].append(component[0])

def bestbridge(current_end, used):
    return max(
        0 if (min(current_end, new_end), max(current_end, new_end)) in used
        else current_end + new_end + bestbridge(
            new_end,
            used | set(((min(current_end, new_end), max(current_end, new_end)),))
        )
        for new_end in component_dict[current_end]
    )

print(bestbridge(0, set()))
