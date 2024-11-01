const std = @import("std");
const token = @import("token.zig");

const Keyword = std.static_string_map.StaticStringMap(token.TokenType).initComptime(.{
    .{ "and", .AND },
    .{ "class", .CLASS },
    .{ "false", .FALSE },
    .{ "true", .TRUE },
    .{ "for", .FOR },
    .{ "fun", .FUN },
    .{ "if", .IF },
    .{ "nil", .NIL },
    .{ "or", .OR },
    .{ "print", .PRINT },
    .{ "return", .RETURN },
    .{ "super", .SUPER },
    .{ "this", .THIS },
    .{ "var", .VAR },
    .{ "while", .WHILE },
});

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
        if (self.isAtEnd()) {
            return false;
        }
        if (self.source[self.current] != expected) {
            return false;
        }
        self.current += 1;
        return true;
    }

    fn addToken(self: *Scanner, token_type: token.TokenType) void {
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
        return if (self.isAtEnd()) 0 else self.source[self.current];
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
        self.addToken(.NUMBER);
    }

    fn string(self: *Scanner) void {
        while (self.peek() != '"' and !self.isAtEnd()) {
            if (self.peek() == '\n') self.line += 1;
            _ = self.advance();
        }
        _ = self.advance();
        self.addToken(.STRING);
    }

    fn identifier(self: *Scanner) void {
        while (std.ascii.isAlphanumeric(self.peek()) or self.peek() == '_') {
            _ = self.advance();
        }
        const text = self.source[self.start..self.current];
        if (Keyword.get(text)) |keyword| {
            self.addToken(keyword);
        } else {
            self.addToken(.IDENTIFIER);
        }
    }

    fn scanToken(self: *Scanner) void {
        const char: u8 = self.advance();
        switch (char) {
            '(' => self.addToken(.LEFT_PAREN),
            ')' => self.addToken(.RIGHT_PAREN),
            '{' => self.addToken(.LEFT_BRACE),
            '}' => self.addToken(.RIGHT_BRACE),
            ',' => self.addToken(.COMMA),
            '.' => self.addToken(.DOT),
            '-' => self.addToken(.MINUS),
            '+' => self.addToken(.PLUS),
            ';' => self.addToken(.SEMICOLON),
            '*' => self.addToken(.STAR),
            '!' => self.addToken(if (self.match('=')) .BANG_EQUAL else .BANG),
            '=' => self.addToken(if (self.match('=')) .EQUAL_EQUAL else .EQUAL),
            '<' => self.addToken(if (self.match('=')) .LESS_EQUAL else .LESS),
            '>' => self.addToken(if (self.match('=')) .GREATER_EQUAL else .GREATER),
            '/' => {
                if (self.match('/')) {
                    while (self.peek() != '\n' and !self.isAtEnd()) {
                        _ = self.advance();
                    }
                } else {
                    self.addToken(.SLASH);
                }
            },
            ' ', '\t', '\r' => {},
            '\n' => self.line += 1,
            '"' => self.string(),
            else => {
                if (std.ascii.isDigit(char)) {
                    self.addNumber();
                } else if (std.ascii.isAlphanumeric(char) or char == '_') {
                    self.identifier();
                } else {
                    std.debug.print("Invalid Character: {c}\n", .{char});
                }
            },
        }
    }

    pub fn scanTokens(self: *Scanner) void {
        while (!self.isAtEnd()) {
            self.start = self.current;
            self.scanToken();
        }
        self.tokens.append(token.Token{
            .token_type = token.TokenType.EOF,
            .lexeme = "",
            .literal = null,
            .line = self.line,
        }) catch |err| switch (err) {
            else => unreachable,
        };
    }

    fn isAtEnd(self: Scanner) bool {
        return self.current >= self.source.len;
    }

    pub fn deinit(self: *Scanner) void {
        self.tokens.deinit();
    }
};
