import re
from collections import defaultdict, namedtuple

PLAYERS = 403
LAST_MARBLE = 71920
#PLAYERS = 9
#LAST_MARBLE = 25
circle = [0]
scores = [0] * PLAYERS
pos = 0
player = 1
marble = 1
while marble < LAST_MARBLE:
    player = 1 if player == PLAYERS else player + 1
    if marble % 23 == 0:
        scores[player - 1] += marble
        pos = (pos - 7) % len(circle)
        scores[player - 1] += circle[pos]
        del circle[pos]
    else:
        pos = 1 if len(circle) == 1 else (pos + 2) % len(circle)
        circle.insert(pos, marble)
    marble += 1

print 'ans', max(scores)
