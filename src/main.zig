const std = @import("std");
const scanner = @import("scanner.zig");
const MAX_INPUT_SIZE: usize = 8192;

fn runFile(filename: []u8) !void {
    std.debug.print("Inside runFile\n", .{});
    std.debug.print("filename {s}\n", .{filename});
}

fn runPrompt(allocator: std.mem.Allocator) !void {
    std.debug.print("Lox Interpretor\n", .{});

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();
    const stdin = std.io.getStdIn().reader();
    while (true) {
        try stdout.writeAll(">>> ");
        try bw.flush();
        const bare_line = try stdin.readUntilDelimiterAlloc(std.heap.page_allocator, '\n', MAX_INPUT_SIZE);
        defer std.heap.page_allocator.free(bare_line);
        const line = std.mem.trim(u8, bare_line, "\r");
        var _scanner = scanner.Scanner.init(allocator, line);
        _scanner.scanTokens();
        defer _scanner.deinit();
        for (_scanner.tokens.items) |token| {
            try stdout.writeAll(token.toString());
            try stdout.writeAll("\n");
        }
        if (std.mem.eql(u8, line, "exit")) {
            break;
        }
    }
}

pub fn main() !void {
    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    try switch (args.len) {
        1 => runPrompt(allocator),
        2 => runFile(args[1]),
        else => try stdout.print("\nUsage: lox [script].lox", .{}),
    };
    try bw.flush(); // don't forget to flush!
}
