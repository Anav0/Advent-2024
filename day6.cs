using System.Collections.Generic;
using Vec2 = (int x, int y);

const char GUARD = '^';
const char OBSTACLE = '#';
const char EMPTY = '.';

var original_board = File.ReadLines("day6.txt").ToList().Select(x => x.ToCharArray()).ToList();
Vec2 guard_pos = GetGuardPos(original_board);
Vec2 guard_initial_pos = (guard_pos.x, guard_pos.y);

if (guard_pos.x == -1)
{
    Console.WriteLine("Could not find guards position on board");
    return 1;
}

var obstacles = new HashSet<Vec2>();

var potential_placments = GetPossibleObstaclePlacement(original_board.ConvertAll(x => x.ToArray()));
foreach (var (x, y) in potential_placments)
{
    var c = original_board[y][x];
    if (c == GUARD || c == OBSTACLE)
        throw new Exception("Cannot place obstacle in place of guard or other obstacle");

    guard_pos = guard_initial_pos;
    var board = original_board.ConvertAll(x => x.ToArray());
    var reference_board = original_board.ConvertAll(x => x.ToArray());
    reference_board[guard_pos.y][guard_pos.x] = EMPTY;

    board[y][x] = OBSTACLE;
    reference_board[y][x] = OBSTACLE;

    Vec2 direction = (0, -1);
    HashSet<PosAndDir> prev_pos_and_dir = [];
    for (; ; )
    {
        var current_pos_dir = new PosAndDir(guard_pos, direction);
        if (prev_pos_and_dir.Contains(current_pos_dir))
        {
            obstacles.Add((x, y));
            break;
        }
        prev_pos_and_dir.Add(current_pos_dir);

        while (IsObstacleInFront(board, guard_pos, direction))
        {
            direction = Turn(direction, Direction.RIGHT);
        }

        board[guard_pos.y][guard_pos.x] = reference_board[guard_pos.y][guard_pos.x];
        guard_pos = Move(guard_pos, direction);

        if (!IsInsideBoard(board, guard_pos))
            break;

        board[guard_pos.y][guard_pos.x] = GUARD;
    }
}

Console.WriteLine(obstacles.Count);

return 0;

//===============================
//===============================

List<Vec2> GetPossibleObstaclePlacement(List<char[]> board)
{
    var reference_board = board.ConvertAll(x => x.ToArray());
    Vec2 guard_pos = GetGuardPos(board);
    reference_board[guard_pos.y][guard_pos.x] = EMPTY;
    Vec2 direction = (0, -1);
    var placments = new List<Vec2>() { };
    for (; ; )
    {
        var x = guard_pos.x + direction.x;
        var y = guard_pos.y + direction.y;
        if ((x >= 0 && y >= 0) && (x < board[0].Length && y < board.Count) && original_board[y][x] != OBSTACLE && original_board[y][x] != GUARD)
            placments.Add((x, y));

        if (IsObstacleInFront(board, guard_pos, direction))
        {
            direction = Turn(direction, Direction.RIGHT);
        }

        board[guard_pos.y][guard_pos.x] = reference_board[guard_pos.y][guard_pos.x];
        guard_pos = Move(guard_pos, direction);

        x = guard_pos.x;
        y = guard_pos.y;
        if ((x >= 0 && y >= 0) && (x < board[0].Length && y < board.Count) && original_board[y][x] != OBSTACLE && original_board[y][x] != GUARD)
            placments.Add((x, y));

        if (!IsInsideBoard(board, guard_pos))
        {
            return placments;
        }

        board[guard_pos.y][guard_pos.x] = GUARD;
    }

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
    return dir switch
    {
        Direction.LEFT => (v.y, -v.x),
        Direction.RIGHT => (-v.y, v.x),
        _ => v,
    };
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

    if (x < 0 || y < 0 || x > board.Count - 1 || y > board[0].Length - 1)
        return false;

    return board[y][x] == OBSTACLE;
}
enum Direction
{
    LEFT,
    RIGHT
}
record PosAndDir(Vec2 pos, Vec2 dir);
