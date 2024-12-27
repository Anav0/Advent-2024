module day10;

import std::io;
import std::io::file;
import std::collections::list;
import std::collections::map;
import std::hash::fnv32a;

const int BOARD_SIZE = 64;

struct Trailhead {
    int[2] starting_pos;
    int number_of_destinations;
}

def Trailheads = List(<Trailhead>);
def Board = int[BOARD_SIZE][BOARD_SIZE];
def Pos = int[2];
fn uint Pos.hash(Pos self) => fnv32a::encode(@as_char_view(self));
def Positions = List(<Pos>);

fn Board! read_board(String path, int[2]* board_size) {
    io::printfn("%s", path);
    File file = file::open(path, "r")!;
    defer file.close()!!;
    Board board = {};
    int[BOARD_SIZE] line = {};
    char[1] c = {};
    int i = 0;
    int row = 0;
    bool added = false;
    while(!file.eof()) {
        file.read(&c)!;
        if(c[0] != '\n') {
            added = true;
            line[i] = (int) (c[0] - '0');
            (*board_size)[1]++;
            i++;
        } else if (added && c[0] == '\n') {
            added = false;
            (*board_size)[0]++;
            board[row] = line;
            $$memset(&line, (char) 0, (usz) BOARD_SIZE, true, (usz) 1);
            i=0;
            row++;
        }
    }

    (*board_size)[1] /= (*board_size)[0];
    return board;
}

fn Trailheads find_all_trailheads(Board* board, int[2] board_size) {
    Trailheads trailheads;
    trailheads.new_init();

    for(int i = 0; i < board_size[0]; i++) {
        for(int j = 0; j < board_size[1]; j++) {
            int v = (*board)[i][j];
            if(v == 0) {
                Trailhead head = {
                    .starting_pos = {i, j}
                };
                 trailheads.push(head);
            }
        }
    }

    return trailheads;
}

fn void print_pos(Board board, int[2] board_size, Positions* ends) {
    foreach(pos : ends) {
        board[pos[0]][pos[1]] = -1;
    }
    for(int i = 0; i < board_size[0]; i++) {
        for(int j = 0; j < board_size[1]; j++) {
            int v = board[i][j];
            io::printf("%d ", v);
        }
        io::printn();
   }
}

fn void! calculate_trails(Trailheads* heads, Board* board, int[2] board_size) {
    const int DIRECTIONS_N = 4;
    int[2][DIRECTIONS_N] directions_to_check = {
        {0, 1},
        {0, -1},
        {1, 0},
        {-1, 0},
    };

    foreach(i, &trailhead : heads) {
        Positions queque = {  };
        Positions ends;
        queque.push(trailhead.starting_pos);
        HashMap(<Pos, bool>) seen = {};
        while(!queque.is_empty()) {
            Pos pos = queque.pop()!;
            for(int k = 0; k < DIRECTIONS_N; k++) {
                Pos dir = directions_to_check[k];
                Pos new_pos = { pos[0] + dir[0], pos[1] + dir[1]};

                if(new_pos[0] < 0 || new_pos[1] < 0) {
                   continue;
                }

                int v_prev = (*board)[pos[0]][pos[1]];
                int v = (*board)[new_pos[0]][new_pos[1]];

                if(v - v_prev == 1 && v != 9) {
                    queque.push(new_pos);
//                    io::printfn("From: '%d' at (%d %d) to: '%d' at (%d %d)", v_prev, pos[0], pos[1], v, new_pos[0], new_pos[1]);
                }
                if(v - v_prev == 1 && v == 9 && !seen.has_key(new_pos)) {
                    seen.set(new_pos, true);
                    (*trailhead).number_of_destinations++;
                    // ends.push(new_pos);
                    // io::printfn("Found end at (%d %d)", new_pos[0], new_pos[1]);
                }
            }
            // io::printn("New direction check!");
        }
        // print_pos(*board, board_size, &ends);
    }

}

fn void! main()
{
    int[2] board_size;
    Board board = read_board("./day10.txt", &board_size)!;
    Trailheads trailheads = find_all_trailheads(&board, board_size);
    calculate_trails(&trailheads, &board, board_size)!;

    int sum = 0;
    foreach(head : trailheads) {
        // io::printfn("%d", head.number_of_destinations);
        sum += head.number_of_destinations;
    }
    io::printfn("%d", sum);

}
