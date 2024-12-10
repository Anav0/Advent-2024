const std = @import("std");

const Operation = enum { Add, Mult };

pub fn printList(list: []Operation) void {
    for (list) |x| {
        switch (x) {
            .Add => std.debug.print("+ ", .{}),
            .Mult => std.debug.print("* ", .{}),
        }
    }
    std.debug.print("\n", .{});
}

fn generatePermutations(symbols: []const Operation, k: usize, index: usize, result: []Operation, all: *std.ArrayList([]Operation)) !void {
    if (index == k) {
        const result_clone = try std.heap.page_allocator.alloc(Operation, result.len);
        @memcpy(result_clone, result);
        try all.append(result_clone);
        return;
    }

    for (symbols) |ch| {
        result[index] = ch;
        try generatePermutations(symbols, k, index + 1, result, all);
    }
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("D:\\Projects\\advent\\2024\\day7_t.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var stream = buf_reader.reader();
    var buffer: [2048]u8 = undefined;

    while (true) {
        const line = try stream.readUntilDelimiterOrEof(&buffer, '\n');
        if (line == null) break;

        var split = std.mem.splitScalar(u8, line.?, ':');
        _ = split.next();
        const numbers_str = split.next();
        var numbers_iter = std.mem.splitScalar(u8, numbers_str.?, ' ');

        const allocator = std.heap.page_allocator;
        var numbers = std.ArrayList(i64).init(allocator);
        defer numbers.deinit();

        while (numbers_iter.next()) |v| {
            if (std.mem.eql(u8, v, "")) continue;
            const number = try std.fmt.parseInt(i64, v, 10);
            try numbers.append(number);
        }

        var total: i64 = 0;
        const operators: [2]Operation = .{ .Mult, .Add };

        var permutations = std.ArrayList([]Operation).init(allocator);
        const n = 4; //numbers.items.len - 1;
        const current = try allocator.alloc(Operation, n);
        try generatePermutations(&operators, n, 0, current, &permutations);

        std.debug.print("\n", .{});
        for (permutations.items) |perm| {
            printList(perm);
        }

        for (numbers.items) |x| {
            total += x;
        }
        return;
    }
}
