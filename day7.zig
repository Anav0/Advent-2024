const std = @import("std");

const Operation = enum { Add, Mult, Combine };

pub fn printList(list: []Operation) void {
    for (list) |x| {
        switch (x) {
            .Add => std.debug.print("+ ", .{}),
            .Mult => std.debug.print("* ", .{}),
            .Combine => std.debug.print("|| ", .{}),
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

fn operatorPrepass(numbers: std.ArrayList(i64), numbers_raw: std.ArrayList([]u8), operators: []Operation, new_operators: *std.ArrayList(Operation)) !std.ArrayList(i128) {
    const allocator = std.heap.page_allocator;
    var output = std.ArrayList(i128).init(allocator);

    var i: u32 = 0;
    var j: u32 = 0;

    while (i < numbers.items.len) {
        if (j < operators.len and operators[j] == .Combine) {
            std.debug.print("PHASE COMBINE:\n", .{});
            const a = numbers_raw.items[i];
            const b = numbers_raw.items[i + 1];
            var combined = try allocator.alloc(u8, a.len + b.len);
            @memcpy(combined[0..a.len], a);
            @memcpy(combined[a.len..], b);
            const combin = try std.fmt.parseInt(i128, combined, 10);
            numbers_raw.items[i + 1] = combined;
            try output.append(combin);
            i += 1;
            std.debug.print("A: {s} ", .{a});
            std.debug.print("B: {s} ", .{b});
            std.debug.print("Pushed to output: {d}, saved at: {d}\n", .{ combin, i });
        } else {
            std.debug.print("PHASE OTHER:\n", .{});
            if (j < operators.len) {
                std.debug.print("Pushed operator: {}\n", .{operators[j]});
                try new_operators.append(operators[j]);
            }
            const x = try std.fmt.parseInt(i128, numbers_raw.items[i], 10);
            std.debug.print("Pushed to output: {d}, taken from: {d}\n", .{ x, i });
            try output.append(x);
            i += 1;
        }
        std.debug.print("\n", .{});
        j += 1;
    }

    return output;
}

fn printSequencei64(perm: []Operation, numbers: std.ArrayList(i64)) void {
    var i: u32 = 0;
    var j: u32 = 0;

    while (i < numbers.items.len) {
        std.debug.print("{d} ", .{numbers.items[i]});
        if (j < perm.len) {
            const symbol = switch (perm[j]) {
                .Add => "+",
                .Mult => "*",
                .Combine => "||",
            };
            std.debug.print("{s} ", .{symbol});
        }
        i += 1;
        j += 1;
    }

    std.debug.print("\n", .{});
}
fn printSequence(perm: []Operation, numbers: std.ArrayList(i128)) void {
    var i: u32 = 0;
    var j: u32 = 0;

    while (i < numbers.items.len) {
        std.debug.print("{d} ", .{numbers.items[i]});
        if (j < perm.len) {
            const symbol = switch (perm[j]) {
                .Add => "+",
                .Mult => "*",
                .Combine => "||",
            };
            std.debug.print("{s} ", .{symbol});
        }
        i += 1;
        j += 1;
    }

    std.debug.print("\n", .{});
}

fn clone(src: std.ArrayList([]u8)) !std.ArrayList([]u8) {
    const allocator = std.heap.page_allocator;

    var c = std.ArrayList([]u8).init(allocator);

    for (src.items) |item| {
        const new_item = try allocator.alloc(u8, item.len);
        @memcpy(new_item, item);
        try c.append(new_item);
    }
    return c;
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("D:\\Projects\\advent\\2024\\day7_t.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var stream = buf_reader.reader();
    var buffer: [2048]u8 = undefined;

    var matches: i128 = 0;
    while (true) {
        const line = try stream.readUntilDelimiterOrEof(&buffer, '\n');
        if (line == null) break;

        var split = std.mem.splitScalar(u8, line.?, ':');
        const expected_total = try std.fmt.parseInt(i64, split.next().?, 10);
        const numbers_str = split.next();
        var numbers_iter = std.mem.splitScalar(u8, numbers_str.?, ' ');

        const allocator = std.heap.page_allocator;
        var numbers = std.ArrayList(i64).init(allocator);
        var numbers_raw = std.ArrayList([]u8).init(allocator);
        defer numbers.deinit();

        while (numbers_iter.next()) |v| {
            if (std.mem.eql(u8, v, "")) continue;
            const number = try std.fmt.parseInt(i64, v, 10);
            try numbers.append(number);
            const v_clone = try std.heap.page_allocator.alloc(u8, v.len);
            @memcpy(v_clone, v);
            try numbers_raw.append(v_clone);
        }

        const operators: [3]Operation = .{ .Mult, .Add, .Combine };

        var permutations = std.ArrayList([]Operation).init(allocator);
        const n = numbers.items.len - 1;

        const current = try allocator.alloc(Operation, n);
        try generatePermutations(&operators, n, 0, current, &permutations);

        std.debug.print("Numbers: '{s}', Number of permutations: {d}, Required number: {d}\n", .{ numbers_str.?, permutations.items.len, n });
        for (permutations.items) |perm| {
            std.debug.print("\n+++++++++++++++++++++++\n", .{});
            for (numbers_raw.items) |xxx| {
                std.debug.print("{s} ", .{xxx});
            }
            std.debug.print("\n+++++++++++++++++++++++\n", .{});
            std.debug.print("Before prepass: \n", .{});
            printSequencei64(perm, numbers);
            const numbers_raw_clone = try clone(numbers_raw);
            var processed_perm = std.ArrayList(Operation).init(allocator);
            const processed_numbers = try operatorPrepass(numbers, numbers_raw_clone, perm, &processed_perm);
            for (processed_perm.items) |xxx| {
                std.debug.print("DD: {}\n", .{xxx});
            }
            std.debug.print("After prepass: \n", .{});
            printSequence(perm, processed_numbers);
            var total: i128 = processed_numbers.items[0];
            var i: u32 = 1;
            var j: u32 = 0;
            while (j < processed_perm.items.len and i < processed_numbers.items.len) {
                const a = processed_numbers.items[i];
                switch (processed_perm.items[j]) {
                    .Add => {
                        std.debug.print("   {d} + {d}\n", .{ total, a });
                        total += a;
                    },
                    .Mult => {
                        std.debug.print("   {d} * {d}\n", .{ total, a });
                        total *= a;
                    },
                    .Combine => {
                        std.debug.print("   HUUUUUJ", .{});
                    },
                }
                i += 1;
                j += 1;
            }

            std.debug.print("{d} ", .{total});
            if (total == expected_total) {
                std.debug.print("== ", .{});
                matches += expected_total;
            } else {
                std.debug.print("!= ", .{});
            }
            std.debug.print("{d} ", .{expected_total});

            std.debug.print("\n-----\n", .{});

            if (total == expected_total) {}
        }
    }
    std.debug.print("{d}", .{matches});
}
