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

    fn scan_token(self: *Scanner) void {
        const char: u8 = self.advance();
        switch (char) {
            '(' => self.add_token(token.TokenType.LEFT_PAREN),
            ')' => self.add_token(token.TokenType.RIGHT_PAREN),
            '{' => self.add_token(token.TokenType.LEFT_BRACE),
            '}' => self.add_token(token.TokenType.RIGHT_BRACE),
            ',' => self.add_token(token.TokenType.COMMA),
            '.' => self.add_token(token.TokenType.DOT),
            '-' => self.add_token(token.TokenType.MINUS),
            '+' => self.add_token(token.TokenType.PLUS),
            ';' => self.add_token(token.TokenType.SEMICOLON),
            '*' => self.add_token(token.TokenType.STAR),
            ' ', '\t', '\r' => {},
            '\n' => self.line += 1,
            else => {
                std.debug.print("Invalid Character: {c}\n", .{char});
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
        .{ .token_type = token.TokenType.LEFT_PAREN, .lexeme = "(", .literal = "(", .line = 1 },
        .{ .token_type = token.TokenType.RIGHT_PAREN, .lexeme = ")", .literal = ")", .line = 1 },
        .{ .token_type = token.TokenType.SEMICOLON, .lexeme = ";", .literal = ";", .line = 1 },
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
        .{ .token_type = token.TokenType.LEFT_PAREN, .lexeme = "(", .literal = "(", .line = 1 },
        .{ .token_type = token.TokenType.RIGHT_PAREN, .lexeme = ")", .literal = ")", .line = 1 },
        .{ .token_type = token.TokenType.SEMICOLON, .lexeme = ";", .literal = ";", .line = 1 },
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
        .{ .token_type = token.TokenType.LEFT_PAREN, .lexeme = "(", .literal = "(", .line = 2 },
        .{ .token_type = token.TokenType.RIGHT_PAREN, .lexeme = ")", .literal = ")", .line = 3 },
        .{ .token_type = token.TokenType.SEMICOLON, .lexeme = ";", .literal = ";", .line = 4 },
    };
    for (scanner.tokens.items, expected_tokens) |actual, expected| {
        try std.testing.expectEqual(expected.token_type, actual.token_type);
        try std.testing.expectEqualStrings(expected.lexeme, actual.lexeme);
        try std.testing.expectEqualStrings(expected.literal, actual.literal);
        try std.testing.expectEqual(expected.line, actual.line);
    }
}
