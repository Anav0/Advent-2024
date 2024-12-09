using System.Diagnostics.CodeAnalysis;
using System.Diagnostics.Metrics;
using System.Xml;
using Vec2 = (int x, int y);

const char GUARD = '^';
const char OBSTACLE = '#';
const char MARKED = 'X';
const char EMPTY = '.';

var board = File.ReadLines("day6.txt").ToList().Select(x => x.ToCharArray()).ToList();
Vec2 guard_pos = GetGuardPos(board);

var reference_board = board.ConvertAll(x=>x.ToArray());
var visited_cells   = board.ConvertAll(x=>x.ToArray());

reference_board[guard_pos.y][guard_pos.x] = EMPTY;
visited_cells[guard_pos.y][guard_pos.x]   = MARKED;

if (guard_pos.x == -1)
{
    Console.WriteLine("Could not find guards position on board");
    return 1;
}

Vec2 direction = (0, -1); //UP
var x1 = Turn((0, -1), Direction.RIGHT);
var visited_counter = 1;
for (;;)
{
    if (IsObstacleInFront(board, guard_pos, direction))
    {
        direction = Turn(direction, Direction.RIGHT);
    }

    board[guard_pos.y][guard_pos.x] = reference_board[guard_pos.y][guard_pos.x];
    guard_pos = Move(guard_pos, direction);

    if (!IsInsideBoard(board, guard_pos))
        break;

    visited_cells[guard_pos.y][guard_pos.x] = MARKED;
    board[guard_pos.y][guard_pos.x] = GUARD;
    visited_counter++;
}

PrintBoard(visited_cells);
Console.WriteLine(CountCells(visited_cells, MARKED));

return 0;

//===============================
//===============================

int CountCells(List<char[]> board, char symbol)
{
    var counter = 0;
    for (int i = 0; i < board.Count; i++)
    {
        for (int j = 0; j < board[i].Length; j++)
        {
            if (board[i][j] == symbol)
                counter++;
        }
    }

    return counter;
}

bool IsInsideBoard(List<char[]> board, Vec2 guard_pos)
{
    return (guard_pos.x < board.Count && guard_pos.y < board[0].Length) && (guard_pos.x > -1 && guard_pos.y > -1);
}

Vec2 Move(Vec2 guard_pos, Vec2 direction)
{
    guard_pos.x += direction.x;
    guard_pos.y += direction.y;
    return guard_pos;
}

Vec2 Turn(Vec2 v, Direction dir)
{
    switch (dir)
    {
        case Direction.LEFT:
            return (v.y, -v.x);
        case Direction.RIGHT:
            return (-v.y, v.x);
        default:
            return v;
    }
}

Vec2 GetGuardPos(List<char[]> board)
{
    for (int i = 0; i < board.Count; i++)
    {
        for (int j = 0; j < board[i].Length; j++)
        {
            if (board[i][j] == GUARD)
            {
                return (j, i);
            }
        }
    }

    return (-1, -1);
}

bool IsObstacleInFront(List<char[]> board, Vec2 guard_pos, Vec2 facing)
{
    var x = guard_pos.x + facing.x;
    var y = guard_pos.y + facing.y;

    if(x < 0 || y < 0 || x > board.Count-1 || y > board[0].Length-1)
        return false;

    return board[y][x] == OBSTACLE;
}

void PrintBoard(List<char[]> board)
{
    for (int i = 0; i < board.Count; i++)
    {
        for (int j = 0; j < board[i].Length; j++)
        {
            Console.Write(board[i][j]);
        }
        Console.WriteLine();
    }
}

enum Direction
{
    LEFT,
    RIGHT
}
