from collections import defaultdict
import re

with open('/Users/joakimkoljonen/src/adventofcode/21.input', 'r') as file:
    input = file.read()

test_input = '''../.# => ##./#../...
.#./..#/### => #..#/..../..../#..#
'''
#input = test_input

pattern = '''.#.
..#
###'''.split('\n')

def parseline(line):
    return tuple(line.split(' => '))

parsed = [parseline(line) for line in input.split('\n') if line != '']

rules = dict(parsed)
matchcache = dict()

def getmatch(block):
    block = tuple(block)
    if block in matchcache:
        return matchcache[block]
    for variant in getvariants(block):
        output = rules.get(variant)
        if output:
            matchcache[block] = output.split('/')
            return output.split('/')

def rotate(block, n):
    for x in range(n):
        size = len(block)
        output = [[None for i in range(size)] for j in range(size)]
        for i in range(size):
            for j in range(size):
                output[i][j] = block[size - j - 1][i]
        block = [''.join(line) for line in output]
    return block

def rowinvert(block, doit):
    if not doit:
        return block
    return [line[::-1] for line in block]

def colinvert(block, doit):
    if not doit:
        return block
    return [line for line in block[::-1]]

def formatblock(block):
    return  '/'.join(''.join(row) for row in block)

def getvariants(block):
    variants = [
        rotate(
            rowinvert(
                colinvert(block, colinv),
                rowinv
            ),
            rotations
        )
        for rotations in range(4)
        for colinv in range(2)
        for rowinv in range(2)
    ] 
    return [formatblock(block) for block in variants]

def getblocks():
    size = len(pattern)
    blocksize = 2 if size % 2 == 0 else 3
    return [
        [
            getmatch([
                row[blocksize * colidx : blocksize * colidx + blocksize]
                for row in pattern[blocksize * rowidx : blocksize * rowidx + blocksize]
            ])
            for colidx in range(size / blocksize)
        ]
        for rowidx in range(size / blocksize)
    ]

def getans():
    global pattern
    for i in range(18):
        size = len(pattern)
        newblocks = getblocks()
        blocksize = len(newblocks[0][0])
        patternsize = len(newblocks[0]) * blocksize
        pattern = ['' for j in range(patternsize)]
        for blockrowidx, blockrow in enumerate(newblocks):
            for blockcolidx, blockcol in enumerate(blockrow):
                for subrowidx, char in enumerate(blockcol):
                    pattern[blockrowidx * blocksize + subrowidx] += char
    cnt = 0
    for row in pattern:
        for char in row:
            if char == '#':
                cnt += 1
    return cnt
print(getans())
