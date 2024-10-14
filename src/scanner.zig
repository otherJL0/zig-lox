const std = @import("std");
const token = @import("token.zig");

pub const Scanner = struct {
    source: []const u8,
    tokens: std.ArrayList(token.Token),
    start: usize,
    current: usize,
    line: usize,

    pub fn init(allocator: std.mem.Allocator, source: []const u8) Scanner {
        return Scanner{
            .source = source,
            .tokens = std.ArrayList(token.Token).init(allocator),
            .start = 0,
            .current = 0,
            .line = 1,
        };
    }

    fn advance(self: *Scanner) u8 {
        const char = self.source[self.current];
        self.current += 1;
        return char;
    }

    fn match(self: *Scanner, expected: u8) bool {
        if (self.is_at_end()) {
            return false;
        }
        if (self.source[self.current] != expected) {
            return false;
        }
        self.current += 1;
        return true;
    }

    fn add_token(self: *Scanner, token_type: token.TokenType) void {
        const text = self.source[self.start..self.current];
        self.tokens.append(token.Token{
            .token_type = token_type,
            .lexeme = text,
            .literal = text,
            .line = self.line,
        }) catch |err| switch (err) {
            else => unreachable,
        };
    }

    fn peek(self: Scanner) u8 {
        return if (self.is_at_end()) 0 else self.source[self.current];
    }

    fn peekNext(self: Scanner) u8 {
        return if (self.current + 1 >= self.source.len) 0 else self.source[self.current + 1];
    }

    fn addNumber(self: *Scanner) void {
        while (std.ascii.isDigit(self.peek())) {
            _ = self.advance();
        }
        if (self.peek() == '.') {
            _ = self.advance();
            while (std.ascii.isDigit(self.peek())) {
                _ = self.advance();
            }
        }
        self.add_token(.NUMBER);
    }

    fn scan_token(self: *Scanner) void {
        const char: u8 = self.advance();
        switch (char) {
            '(' => self.add_token(.LEFT_PAREN),
            ')' => self.add_token(.RIGHT_PAREN),
            '{' => self.add_token(.LEFT_BRACE),
            '}' => self.add_token(.RIGHT_BRACE),
            ',' => self.add_token(.COMMA),
            '.' => self.add_token(.DOT),
            '-' => self.add_token(.MINUS),
            '+' => self.add_token(.PLUS),
            ';' => self.add_token(.SEMICOLON),
            '*' => self.add_token(.STAR),
            '!' => self.add_token(if (self.match('=')) .BANG_EQUAL else .BANG),
            '=' => self.add_token(if (self.match('=')) .EQUAL_EQUAL else .EQUAL),
            '<' => self.add_token(if (self.match('=')) .LESS_EQUAL else .LESS),
            '>' => self.add_token(if (self.match('=')) .GREATER_EQUAL else .GREATER),
            ' ', '\t', '\r' => {},
            '\n' => self.line += 1,
            else => {
                if (std.ascii.isDigit(char)) {
                    self.addNumber();
                } else {
                    std.debug.print("Invalid Character: {c}\n", .{char});
                }
            },
        }
    }

    pub fn scan_tokens(self: *Scanner) void {
        while (!self.is_at_end()) {
            self.start = self.current;
            self.scan_token();
        }
    }

    fn is_at_end(self: Scanner) bool {
        return self.current >= self.source.len;
    }

    pub fn deinit(self: *Scanner) void {
        self.tokens.deinit();
    }
};

test "simple expression" {
    const source = "();";
    const allocator = std.testing.allocator;
    var scanner = Scanner.init(allocator, source);
    defer scanner.deinit();
    try std.testing.expectEqualStrings(source, scanner.source);
    scanner.scan_tokens();
    try std.testing.expectEqual(3, scanner.tokens.items.len);
    const expected_tokens = [_]token.Token{
        .{ .token_type = .LEFT_PAREN, .lexeme = "(", .literal = "(", .line = 1 },
        .{ .token_type = .RIGHT_PAREN, .lexeme = ")", .literal = ")", .line = 1 },
        .{ .token_type = .SEMICOLON, .lexeme = ";", .literal = ";", .line = 1 },
    };
    for (scanner.tokens.items, expected_tokens) |actual, expected| {
        try std.testing.expectEqual(expected.token_type, actual.token_type);
        try std.testing.expectEqualStrings(expected.lexeme, actual.lexeme);
        try std.testing.expectEqualStrings(expected.literal, actual.literal);
        try std.testing.expectEqual(expected.line, actual.line);
    }
}

test "simple expression with whitespace" {
    const source = "   (  )  ;";
    const allocator = std.testing.allocator;
    var scanner = Scanner.init(allocator, source);
    defer scanner.deinit();
    try std.testing.expectEqualStrings(source, scanner.source);
    scanner.scan_tokens();
    try std.testing.expectEqual(3, scanner.tokens.items.len);
    const expected_tokens = [_]token.Token{
        .{ .token_type = .LEFT_PAREN, .lexeme = "(", .literal = "(", .line = 1 },
        .{ .token_type = .RIGHT_PAREN, .lexeme = ")", .literal = ")", .line = 1 },
        .{ .token_type = .SEMICOLON, .lexeme = ";", .literal = ";", .line = 1 },
    };
    for (scanner.tokens.items, expected_tokens) |actual, expected| {
        try std.testing.expectEqual(expected.token_type, actual.token_type);
        try std.testing.expectEqualStrings(expected.lexeme, actual.lexeme);
        try std.testing.expectEqualStrings(expected.literal, actual.literal);
        try std.testing.expectEqual(expected.line, actual.line);
    }
}

test "simple expression with linebreaks" {
    const source =
        \\
        \\(
        \\)
        \\;
    ;
    const allocator = std.testing.allocator;
    var scanner = Scanner.init(allocator, source);
    defer scanner.deinit();
    try std.testing.expectEqualStrings(source, scanner.source);
    scanner.scan_tokens();
    try std.testing.expectEqual(3, scanner.tokens.items.len);
    const expected_tokens = [_]token.Token{
        .{ .token_type = .LEFT_PAREN, .lexeme = "(", .literal = "(", .line = 2 },
        .{ .token_type = .RIGHT_PAREN, .lexeme = ")", .literal = ")", .line = 3 },
        .{ .token_type = .SEMICOLON, .lexeme = ";", .literal = ";", .line = 4 },
    };
    for (scanner.tokens.items, expected_tokens) |actual, expected| {
        try std.testing.expectEqual(expected.token_type, actual.token_type);
        try std.testing.expectEqualStrings(expected.lexeme, actual.lexeme);
        try std.testing.expectEqualStrings(expected.literal, actual.literal);
        try std.testing.expectEqual(expected.line, actual.line);
    }
}

test "numbers" {
    const sources = [_][]const u8{
        "0",
        "1",
        "2",
        "3",
        "4",
        "5",
        "6",
        "7",
        "8",
        "9",
        "10",
        "0.0",
        "1.0",
        "2.0",
        "3.0",
        "4.0",
        "5.0",
        "6.0",
        "7.0",
        "8.0",
        "9.0",
        "10.0",
        "0000",
        "0001",
        "0002",
        "0003",
        "0004",
        "0005",
        "0006",
        "0007",
        "0008",
        "0009",
        "0000.0000",
        "0001.0000",
        "0002.0000",
        "0003.0000",
        "0004.0000",
        "0005.0000",
        "0006.0000",
        "0007.0000",
        "0008.0000",
        "0009.0000",
    };
    for (sources) |source| {
        var scanner = Scanner.init(std.testing.allocator, source);
        defer scanner.deinit();
        scanner.scan_tokens();
        const expected = token.Token{ .token_type = .NUMBER, .lexeme = source, .literal = source, .line = 1 };
        try std.testing.expectEqual(1, scanner.tokens.items.len);
        try std.testing.expectEqual(expected.token_type, scanner.tokens.items[0].token_type);
        try std.testing.expectEqual(expected.lexeme, scanner.tokens.items[0].lexeme);
        try std.testing.expectEqual(expected.line, scanner.tokens.items[0].line);
    }
}

test "test comparisons" {
    const TestCase = struct {
        source: []const u8,
        expected_tokens: []const token.Token,
    };
    const test_cases = [_]TestCase{
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
    for (test_cases) |test_case| {
        var scanner = Scanner.init(std.testing.allocator, test_case.source);
        defer scanner.deinit();
        scanner.scan_tokens();
        try std.testing.expectEqual(test_case.expected_tokens.len, scanner.tokens.items.len);
        for (test_case.expected_tokens, scanner.tokens.items) |expected, actual| {
            try std.testing.expectEqual(expected.token_type, actual.token_type);
            try std.testing.expectEqualStrings(expected.lexeme, actual.lexeme);
        }
    }
}
