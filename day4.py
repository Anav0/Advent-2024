from enum import Enum
from collections import Counter

class Direction(Enum):
    FORWARD  = 1
    BACKWARD = 2

class Side(Enum):
    LEFT = 1
    RIGHT = 2

def index_to_row_col(index, num_columns):
    row = index // num_columns
    col = index % num_columns
    return row, col

def row_col_to_index(row, col, num_columns):
    if col < 0 or col > num_columns-1 or row <= -1:
        return -1
    index = (row * num_columns) + col
    return index

def vertical(index, letters, pattern, cols, direction):
    row, col = index_to_row_col(index, cols)
    for pattern_c in pattern:
        index = row_col_to_index(row, col, cols)
        if index == -1 or index > len(letters)-1 or letters[index] is not pattern_c:
            return 0
        if direction is Direction.FORWARD:
            row += 1
        else:
            row -= 1

    return 1

def diagonal(index, letters, pattern, cols, direction, side):
    row, col = index_to_row_col(index, cols)
    for pattern_c in pattern:
        index = row_col_to_index(row, col, cols)
        if index == -1 or index > len(letters)-1 or letters[index] is not pattern_c:
            return 0
        if direction is Direction.FORWARD:
            row += 1
        else:
            row -= 1
        if side is Side.LEFT:
            col -= 1
        else:
            col += 1

    return 1

def horizontal(index, letters, pattern, cols, side):
    row, col = index_to_row_col(index, cols)
    for pattern_c in pattern:
        index = row_col_to_index(row, col, cols)
        if index == -1 or index > len(letters)-1 or letters[index] is not pattern_c:
            return 0
        if side is Side.RIGHT:
            col += 1
        else:
            col -= 1

    return 1

def count_pattern(text, pattern):
    letters = [x for x in list(text) if x != "\n"]
    cols = len(text.split("\n")[2])
    found = 0
    for index, c in enumerate(letters):
        if c != pattern[0]:
            continue

        found += horizontal(index, letters, pattern, cols, Side.LEFT)
        found += horizontal(index,  letters, pattern, cols, Side.RIGHT)

        found += vertical(index, letters, pattern, cols, Direction.FORWARD)
        found += vertical(index,  letters, pattern, cols, Direction.BACKWARD)

        found += diagonal(index, letters, pattern, cols, Direction.FORWARD, Side.LEFT)
        found += diagonal(index, letters, pattern, cols, Direction.FORWARD, Side.RIGHT)
        found += diagonal(index,  letters, pattern, cols, Direction.BACKWARD, Side.LEFT)
        found += diagonal(index,  letters, pattern, cols, Direction.BACKWARD, Side.RIGHT)

    return found

def xmas_count(text):
    pattern = "MAS"
    letters = [x for x in list(text) if x != "\n"]
    cols = len(text.split("\n")[2])
    found = 0

    # Going clockwise
    known_patterns = {"MMSS","SMSM","SSMM","MSMS"}
    for index, c in enumerate(letters):
        if c != 'A':
            continue
        row, col = index_to_row_col(index, cols)

        tl = row_col_to_index(row-1, col-1,cols)
        tr = row_col_to_index(row-1, col+1,cols)
        bl = row_col_to_index(row+1, col-1,cols)
        br = row_col_to_index(row+1, col+1,cols)

        if tl ==-1 or tr ==-1 or bl==-1 or br == -1:
            continue

        max_len = len(letters)-1
        if tl > max_len or tr > max_len or bl > max_len or br > max_len:
            continue

        found_pattern = letters[tl]+letters[tr]+letters[bl]+letters[br]
        if found_pattern in known_patterns:
            found+=1

    return found

test_case = """
MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX"""

test_case_2 = """
.M.S......
..A..MSMS.
.M.S.MAA..
..A.ASMSM.
.M.S.M....
..........
S.S.S.S.S.
.A.A.A.A..
M.M.M.M.M.
.........."""

sample5 = """
XMASSAMX
......XM
....S...
...A.A..
..M...M.
.X.....X
"""
sample5 = """
M.S..S.S
.A....A.
M.S..M.M
........
........
........
"""
pattern = "XMAS"

with open("day4.txt", "r") as file:
    real_test = file.read()
    real_test = real_test.strip()

for (name, test) in [("test_case", test_case),("test_case_2",test_case_2), ("real", real_test),("sample5", sample5) ]:
    total  = count_pattern(test, pattern)
    xmases = xmas_count(test)
    print(name, total, xmases)
    print("==============")

cols = 8
for row, col, expected in [(1, 8, -1)]:
    print(f"row_col_to_index({row}, {col}) = {row_col_to_index(row,col,cols)} | {expected}")