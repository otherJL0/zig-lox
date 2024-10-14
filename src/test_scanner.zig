const std = @import("std");
const token = @import("token.zig");
const Scanner = @import("scanner.zig").Scanner;

const TestCase = struct {
    source: []const u8,
    expected_tokens: []const token.Token,
};

fn testLoxTestCases(test_cases: []const TestCase) !void {
    for (test_cases) |test_case| {
        var scanner = Scanner.init(std.testing.allocator, test_case.source);
        defer scanner.deinit();
        scanner.scanTokens();
        try std.testing.expectEqual(test_case.expected_tokens.len, scanner.tokens.items.len);
        for (test_case.expected_tokens, scanner.tokens.items) |expected, actual| {
            try std.testing.expectEqual(expected.token_type, actual.token_type);
            try std.testing.expectEqualStrings(expected.lexeme, actual.lexeme);
        }
    }
}

test "simple expression" {
    const test_cases = &[_]TestCase{
        .{
            .source = "();",
            .expected_tokens = &[_]token.Token{
                .{ .token_type = .LEFT_PAREN, .lexeme = "(", .literal = "(", .line = 1 },
                .{ .token_type = .RIGHT_PAREN, .lexeme = ")", .literal = ")", .line = 1 },
                .{ .token_type = .SEMICOLON, .lexeme = ";", .literal = ";", .line = 1 },
            },
        },
        .{
            .source = "   (   )    ;",
            .expected_tokens = &[_]token.Token{
                .{ .token_type = .LEFT_PAREN, .lexeme = "(", .literal = "(", .line = 1 },
                .{ .token_type = .RIGHT_PAREN, .lexeme = ")", .literal = ")", .line = 1 },
                .{ .token_type = .SEMICOLON, .lexeme = ";", .literal = ";", .line = 1 },
            },
        },
        .{
            .source =
            \\
            \\(
            \\
            \\)
            \\
            \\;
            ,
            .expected_tokens = &[_]token.Token{
                .{ .token_type = .LEFT_PAREN, .lexeme = "(", .literal = "(", .line = 2 },
                .{ .token_type = .RIGHT_PAREN, .lexeme = ")", .literal = ")", .line = 4 },
                .{ .token_type = .SEMICOLON, .lexeme = ";", .literal = ";", .line = 6 },
            },
        },
    };
    try testLoxTestCases(test_cases);
}

test "numbers" {
    const test_cases = &[_]TestCase{
        .{ .source = "0", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "0", .literal = "0", .line = 1 }} },
        .{ .source = "1", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "1", .literal = "1", .line = 1 }} },
        .{ .source = "2", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "2", .literal = "2", .line = 1 }} },
        .{ .source = "3", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "3", .literal = "3", .line = 1 }} },
        .{ .source = "4", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "4", .literal = "4", .line = 1 }} },
        .{ .source = "5", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "5", .literal = "5", .line = 1 }} },
        .{ .source = "6", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "6", .literal = "6", .line = 1 }} },
        .{ .source = "7", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "7", .literal = "7", .line = 1 }} },
        .{ .source = "8", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "8", .literal = "8", .line = 1 }} },
        .{ .source = "9", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "9", .literal = "9", .line = 1 }} },
        .{ .source = "10", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "10", .literal = "10", .line = 1 }} },
        .{ .source = "0.0", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "0.0", .literal = "0.0", .line = 1 }} },
        .{ .source = "1.0", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "1.0", .literal = "1.0", .line = 1 }} },
        .{ .source = "2.0", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "2.0", .literal = "2.0", .line = 1 }} },
        .{ .source = "3.0", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "3.0", .literal = "3.0", .line = 1 }} },
        .{ .source = "4.0", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "4.0", .literal = "4.0", .line = 1 }} },
        .{ .source = "5.0", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "5.0", .literal = "5.0", .line = 1 }} },
        .{ .source = "6.0", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "6.0", .literal = "6.0", .line = 1 }} },
        .{ .source = "7.0", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "7.0", .literal = "7.0", .line = 1 }} },
        .{ .source = "8.0", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "8.0", .literal = "8.0", .line = 1 }} },
        .{ .source = "9.0", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "9.0", .literal = "9.0", .line = 1 }} },
        .{ .source = "10.0", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "10.0", .literal = "10.0", .line = 1 }} },
        .{ .source = "0000", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "0000", .literal = "0000", .line = 1 }} },
        .{ .source = "0001", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "0001", .literal = "0001", .line = 1 }} },
        .{ .source = "0002", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "0002", .literal = "0002", .line = 1 }} },
        .{ .source = "0003", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "0003", .literal = "0003", .line = 1 }} },
        .{ .source = "0004", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "0004", .literal = "0004", .line = 1 }} },
        .{ .source = "0005", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "0005", .literal = "0005", .line = 1 }} },
        .{ .source = "0006", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "0006", .literal = "0006", .line = 1 }} },
        .{ .source = "0007", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "0007", .literal = "0007", .line = 1 }} },
        .{ .source = "0008", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "0008", .literal = "0008", .line = 1 }} },
        .{ .source = "0009", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "0009", .literal = "0009", .line = 1 }} },
        .{ .source = "0000.0000", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "0000.0000", .literal = "0000.0000", .line = 1 }} },
        .{ .source = "0001.0000", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "0001.0000", .literal = "0001.0000", .line = 1 }} },
        .{ .source = "0002.0000", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "0002.0000", .literal = "0002.0000", .line = 1 }} },
        .{ .source = "0003.0000", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "0003.0000", .literal = "0003.0000", .line = 1 }} },
        .{ .source = "0004.0000", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "0004.0000", .literal = "0004.0000", .line = 1 }} },
        .{ .source = "0005.0000", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "0005.0000", .literal = "0005.0000", .line = 1 }} },
        .{ .source = "0006.0000", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "0006.0000", .literal = "0006.0000", .line = 1 }} },
        .{ .source = "0007.0000", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "0007.0000", .literal = "0007.0000", .line = 1 }} },
        .{ .source = "0008.0000", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "0008.0000", .literal = "0008.0000", .line = 1 }} },
        .{ .source = "0009.0000", .expected_tokens = &[_]token.Token{.{ .token_type = .NUMBER, .lexeme = "0009.0000", .literal = "0009.0000", .line = 1 }} },
    };
    try testLoxTestCases(test_cases);
}

test "comparisons" {
    const test_cases = &[_]TestCase{
        .{
            .source = "1 = 1",
            .expected_tokens = &[_]token.Token{
                .{ .token_type = .NUMBER, .lexeme = "1", .literal = "1", .line = 1 },
                .{ .token_type = .EQUAL, .lexeme = "=", .literal = "=", .line = 1 },
                .{ .token_type = .NUMBER, .lexeme = "1", .literal = "1", .line = 1 },
            },
        },
        .{
            .source = "1 == 1",
            .expected_tokens = &[_]token.Token{
                .{ .token_type = .NUMBER, .lexeme = "1", .literal = "1", .line = 1 },
                .{ .token_type = .EQUAL_EQUAL, .lexeme = "==", .literal = "==", .line = 1 },
                .{ .token_type = .NUMBER, .lexeme = "1", .literal = "1", .line = 1 },
            },
        },
        .{
            .source = "0 != 1",
            .expected_tokens = &[_]token.Token{
                .{ .token_type = .NUMBER, .lexeme = "0", .literal = "0", .line = 1 },
                .{ .token_type = .BANG_EQUAL, .lexeme = "!=", .literal = "!=", .line = 1 },
                .{ .token_type = .NUMBER, .lexeme = "1", .literal = "1", .line = 1 },
            },
        },
        .{
            .source = "0 <= 1",
            .expected_tokens = &[_]token.Token{
                .{ .token_type = .NUMBER, .lexeme = "0", .literal = "0", .line = 1 },
                .{ .token_type = .LESS_EQUAL, .lexeme = "<=", .literal = "<=", .line = 1 },
                .{ .token_type = .NUMBER, .lexeme = "1", .literal = "1", .line = 1 },
            },
        },
        .{
            .source = "0 < 1",
            .expected_tokens = &[_]token.Token{
                .{ .token_type = .NUMBER, .lexeme = "0", .literal = "0", .line = 1 },
                .{ .token_type = .LESS, .lexeme = "<", .literal = "<", .line = 1 },
                .{ .token_type = .NUMBER, .lexeme = "1", .literal = "1", .line = 1 },
            },
        },
        .{
            .source = "1 > 0",
            .expected_tokens = &[_]token.Token{
                .{ .token_type = .NUMBER, .lexeme = "1", .literal = "1", .line = 1 },
                .{ .token_type = .GREATER, .lexeme = ">", .literal = ">", .line = 1 },
                .{ .token_type = .NUMBER, .lexeme = "0", .literal = "0", .line = 1 },
            },
        },
        .{
            .source = "1 >= 0",
            .expected_tokens = &[_]token.Token{
                .{ .token_type = .NUMBER, .lexeme = "1", .literal = "1", .line = 1 },
                .{ .token_type = .GREATER_EQUAL, .lexeme = ">=", .literal = ">=", .line = 1 },
                .{ .token_type = .NUMBER, .lexeme = "0", .literal = "0", .line = 1 },
            },
        },
    };
    try testLoxTestCases(test_cases);
}

test "test comments" {
    const test_cases = &[_]TestCase{
        .{
            .source =
            \\// This is a comment
            \\1 / 1
            ,
            .expected_tokens = &[_]token.Token{
                .{ .token_type = .NUMBER, .lexeme = "1", .literal = "1", .line = 2 },
                .{ .token_type = .SLASH, .lexeme = "/", .literal = "/", .line = 2 },
                .{ .token_type = .NUMBER, .lexeme = "1", .literal = "1", .line = 2 },
            },
        },
    };
    try testLoxTestCases(test_cases);
}

test "strings" {
    const test_cases = &[_]TestCase{.{
        .source =
        \\"hello"
        ,
        .expected_tokens = &[_]token.Token{.{ .token_type = .STRING, .lexeme = "\"hello\"", .literal = "\"hello\"", .line = 1 }},
    }};
    try testLoxTestCases(test_cases);
}
