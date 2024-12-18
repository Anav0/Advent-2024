const std = @import("std");

const Operation = enum { Add, Mult, Combine };

fn generatePermutations(symbols: []const Operation, k: usize, index: usize, result: []Operation, all: *std.ArrayList([]Operation)) !void {
    const allocator = std.heap.page_allocator;
    if (index == k) {
        const result_clone = try allocator.alloc(Operation, result.len);
        @memcpy(result_clone, result);
        try all.append(result_clone);
        return;
    }

    for (symbols) |ch| {
        result[index] = ch;
        try generatePermutations(symbols, k, index + 1, result, all);
    }
}

fn clone(src: std.ArrayList([]u8)) !std.ArrayList([]u8) {
    const allocator = std.heap.page_allocator;

    var c = std.ArrayList([]u8).init(allocator);

    for (src.items) |item| {
        const new_item = try allocator.alloc(u8, item.len);
        defer allocator.free(new_item);
        @memcpy(new_item, item);
        try c.append(new_item);
    }
    return c;
}

fn getTotalForAllMatches(expected_total: i64, operators: []const Operation, numbers_raw: std.ArrayList([]u8), numbers: std.ArrayList(i64)) !i64 {
    const allocator = std.heap.page_allocator;
    var permutations = std.ArrayList([]Operation).init(allocator);
    defer permutations.deinit();
    defer for (permutations.items) |item| {
        allocator.free(item);
    };
    const n = numbers.items.len - 1;

    const current = try allocator.alloc(Operation, n);
    defer allocator.free(current);

    try generatePermutations(operators, n, 0, current, &permutations);

    var found_concat_match = false;
    var found_normal_match = false;
    for (permutations.items) |perm| {
        var isConcat = false;
        var total: i128 = numbers.items[0];
        var total_str = numbers_raw.items[0];
        var buffer: [512]u8 = undefined;
        var i: u32 = 1;
        var j: u32 = 0;

        while (j < perm.len and i < numbers.items.len) {
            const a = numbers.items[i];
            const a_str = numbers_raw.items[i];
            switch (perm[j]) {
                .Add => total += a,
                .Mult => total *= a,
                .Combine => {
                    isConcat = true;
                    var combined = try allocator.alloc(u8, total_str.len + a_str.len);
                    defer allocator.free(combined);
                    @memcpy(combined[0..total_str.len], total_str);
                    @memcpy(combined[total_str.len..], a_str);
                    total = try std.fmt.parseInt(i128, combined, 10);
                },
            }
            total_str = try std.fmt.bufPrint(&buffer, "{d}", .{total});
            i += 1;
            j += 1;
        }

        if (total == expected_total) {
            if (!isConcat) found_normal_match = true;
            if (isConcat) found_concat_match = true;

            if ((isConcat and found_concat_match) or (!isConcat and found_normal_match)) {
                return expected_total;
            }

            return 0;
        }
    }
    return 0;
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("./day7.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var stream = buf_reader.reader();
    var buffer: [2048]u8 = undefined;

    var matches: i128 = 0;
    const allocator = std.heap.page_allocator;
    while (true) {
        const line = try stream.readUntilDelimiterOrEof(&buffer, '\n');
        if (line == null) break;

        var split = std.mem.splitScalar(u8, line.?, ':');
        const expected_total = try std.fmt.parseInt(i64, split.next().?, 10);
        const numbers_str = split.next();
        var numbers_iter = std.mem.splitScalar(u8, numbers_str.?, ' ');

        var numbers = std.ArrayList(i64).init(allocator);
        var numbers_raw = std.ArrayList([]u8).init(allocator);
        defer numbers.deinit();
        defer numbers_raw.deinit();

        while (numbers_iter.next()) |v| {
            if (std.mem.eql(u8, v, "")) continue;

            const number = try std.fmt.parseInt(i64, v, 10);
            try numbers.append(number);
            const v_clone = try std.heap.page_allocator.alloc(u8, v.len);
            @memcpy(v_clone, v);
            try numbers_raw.append(v_clone);
        }

        const operators_wide: [3]Operation = .{ .Mult, .Add, .Combine };

        const total = try getTotalForAllMatches(expected_total, &operators_wide, numbers_raw, numbers);

        matches += total;
    }
    std.debug.print("\nmatches: {d}", .{matches});
}
