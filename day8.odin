package main

import "core:fmt"
import "core:os"
import "core:strings"

EMPTY :: '.'
ANTI_NODE :: '#'

Vec2 :: struct {
    x: int,
    y: int,
}

printBoard :: proc(board: [dynamic] string) {
	for line in board {
		fmt.println(line)
	}
}

loadBoard:: proc(path: string) -> ([dynamic] string, bool) {
	data, ok := os.read_entire_file(path, context.allocator);

	if !ok {
		return nil, false
	}

	defer delete(data, context.allocator)

	it := strings.clone(string(data))

	board: [dynamic] string
	for line in strings.split_lines_iterator(&it) {
		append(&board, line)
	}
	return board, true
}

getAntenasPositions :: proc(board: [dynamic] string) -> map[rune][dynamic]Vec2 {
	antenas := make(map[rune][dynamic]Vec2)

	for row, y in board {
		for ch, x in row {
			if ch == EMPTY do continue

			list, has_element := antenas[ch]
			if !has_element {
				antenas[ch] = [dynamic]Vec2 { Vec2 { x, y } }
			}
			else {
				append(&list, Vec2 { x, y })
				antenas[ch] = list
			}
		}
	}

	return antenas
}

tryAddingAntiNode :: proc(board: [dynamic] string, x: int, y: int) ->
bool {
	width := len(board[0])
	height := len(board)

	if (x >= 0 && y >= 0) && (x < width && y < height) {
		row := raw_data(board[y])
		if row[x] != ANTI_NODE {
			row[x] = ANTI_NODE
			return true
		}
	}
	return false
}

getAllPossiblePairs:: proc(elements: [dynamic]Vec2) -> [dynamic][2]Vec2 {
	pairs: [dynamic][2] Vec2

	for a, i in elements {
		for b, j in elements {
			if i == j do continue
			append(&pairs, [2] Vec2 {a, b})
		}
	}

	return pairs
}

main :: proc() {
	board, ok := loadBoard("./day8.txt");
	if(!ok) {
		fmt.println("Failed to read input file!")
	}
	
	antenas := getAntenasPositions(board)

	total := 0
	for antena_key, positions in antenas {
		pairs := getAllPossiblePairs(positions)
		for pair in pairs {
			fst := pair[0]
			sec := pair[1]

			dist_x := fst.x - sec.x
			dist_y := fst.y - sec.y

			x := sec.x + dist_x + dist_x
			y := sec.y + dist_y + dist_y

			added := tryAddingAntiNode(board, x, y)

			if added {
				total += 1
			}
		}
	}
	fmt.println(total)
	//printBoard(board)
}
