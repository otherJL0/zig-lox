const std = @import("std");

pub const TokenType = enum {
    // Single character tokens
    LEFT_PAREN,
    RIGHT_PAREN,
    LEFT_BRACE,
    RIGHT_BRACE,
    COMMA,
    DOT,
    MINUS,
    PLUS,
    SEMICOLON,
    SLASH,
    STAR,

    // One or two character tokens
    BANG,
    BANG_EQUAL,
    EQUAL,
    EQUAL_EQUAL,
    GREATER,
    GREATER_EQUAL,
    LESS,
    LESS_EQUAL,

    // Literals
    IDENTIFIER,
    STRING,
    NUMBER,

    // Keywords
    AND,
    CLASS,
    ELSE,
    FALSE,
    FUN,
    FOR,
    IF,
    NIL,
    OR,
    PRINT,
    RETURN,
    SUPER,
    THIS,
    TRUE,
    VAR,
    WHILE,

    EOF,
};

pub const Token = struct {
    token_type: TokenType,
    lexeme: []const u8,
    literal: []const u8,
    line: usize,

    pub fn init(token_type: TokenType, lexeme: []const u8, literal: []const u8, line: usize) Token {
        return Token{
            .token_type = token_type,
            .lexeme = lexeme,
            .literal = literal,
            .line = line,
        };
    }

    pub fn toString(self: Token) []const u8 {
        const formatted_string = @tagName(self.token_type) ++ " " ++ self.lexeme ++ " " ++ self.literal;
        return formatted_string;
    }
};
