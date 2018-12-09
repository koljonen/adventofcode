import re
from collections import defaultdict, namedtuple, deque

PLAYERS = 403
LAST_MARBLE = 7192000
circle = deque([0])
scores = [0] * PLAYERS
player = 1
marble = 1
while marble < LAST_MARBLE:
    player = 1 if player == PLAYERS else player + 1
    if marble % 23 == 0:
        scores[player - 1] += marble
        circle.rotate(7)
        scores[player - 1] += circle.popleft()
    else:
        circle.rotate(-2)
        circle.appendleft(marble)
    marble += 1

print 'ans', max(scores)
