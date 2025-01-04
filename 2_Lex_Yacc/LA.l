%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "y.tab.h" // Ensure this header matches your Bison/Yacc output for token definitions.

    extern int yylval;
    extern int yylineno; // Line number from Lex

    int st_index = 0; // Index for Symbol Table
    int yycolumn = 1; // Current column position in input line

    // Struct for Symbol Table
    typedef struct {
        char value[50]; // Value of the symbol (ID or Constant)
    } SymbolTableEntry;

    SymbolTableEntry symbolTable[100]; // Symbol Table

    // Keywords
    char *keywords[] = {
        "VAR", "BEGIN", "END", "READ", "WRITE", "IF", "THEN", "ELSE", 
        "WHILE", "DO", "int", "float", "char"
    };
    int num_keywords = 13;

    // Check if a word is a keyword
    int is_keyword(const char *str) {
        for (int i = 0; i < num_keywords; i++) {
            if (strcmp(str, keywords[i]) == 0) {
                return 1;
            }
        }
        return 0;
    }

    // Check if a symbol exists in the Symbol Table
    int is_in_symbol_table(const char *str) {
        for (int i = 0; i < st_index; i++) {
            if (strcmp(symbolTable[i].value, str) == 0) {
                return i; // Return position in ST
            }
        }
        return -1;
    }

    // Add a symbol to the Symbol Table
    void add_to_symbol_table(const char *str) {
        strcpy(symbolTable[st_index].value, str);
        st_index++;
    }
%}

%option noyywrap

%%
"VAR"|"BEGIN"|"END"|"READ"|"WRITE"|"IF"|"THEN"|"ELSE"|"WHILE"|"DO"|"int"|"float"|"char" {
    return KEYWORD; // Defined in y.tab.h
}

":="|"<="|">="|"="|"<"|">"|"<>" {
    return OPERATOR; // Defined in y.tab.h
}
\+|\-|\*|\/|\% {
    return OPERATOR; // Defined in y.tab.h
}

"["|"]"|"{"|"}"|":"|";"|"("|")" {
    return SEPARATOR; // Defined in y.tab.h
}

[a-zA-Z][a-zA-Z0-9_]* {
    if (!is_keyword(yytext)) { // Not a keyword
        int pos = is_in_symbol_table(yytext);
        if (pos == -1) { // If not in Symbol Table
            add_to_symbol_table(yytext);
            yylval = st_index - 1; // Assign symbol table index to yylval
            return ID; // Defined in y.tab.h
        } else {
            yylval = pos; // Assign existing position in Symbol Table to yylval
            return ID; // Defined in y.tab.h
        }
    } else {
        return KEYWORD; // Defined in y.tab.h
    }
}

[+-]?[0-9]+\.[0-9]+ {
    int pos = is_in_symbol_table(yytext);
    if (pos == -1) {
        add_to_symbol_table(yytext);
        yylval = st_index - 1; // Assign symbol table index to yylval
        return FLOAT_CONST; // Defined in y.tab.h
    } else {
        yylval = pos; // Assign existing position in Symbol Table to yylval
        return FLOAT_CONST; // Defined in y.tab.h
    }
}

[+-]?[0-9]+ {
    int pos = is_in_symbol_table(yytext);
    if (pos == -1) {
        add_to_symbol_table(yytext);
        yylval = st_index - 1; // Assign symbol table index to yylval
        return INT_CONST; // Defined in y.tab.h
    } else {
        yylval = pos; // Assign existing position in Symbol Table to yylval
        return INT_CONST; // Defined in y.tab.h
    }
}

\"[^\"]*\" {
    int pos = is_in_symbol_table(yytext);
    if (pos == -1) {
        add_to_symbol_table(yytext);
        yylval = st_index - 1; // Assign symbol table index to yylval
        return STRING_CONST; // Defined in y.tab.h
    } else {
        yylval = pos; // Assign existing position in Symbol Table to yylval
        return STRING_CONST; // Defined in y.tab.h
    }
}

. {
    fprintf(stderr, "Lexical error at line %d, column %d: %s\n", yylineno, yycolumn, yytext);
    return ERROR;
}
%%

int main(int argc, char **argv) {
    if (argc != 2) {
        printf("Usage: ./scanner <input_file>\n");
        return 1;
    }

    FILE *input = fopen(argv[1], "r");
    if (!input) {
        printf("Cannot open file %s\n", argv[1]);
        return 1;
    }

    yyin = input;
    yylex();

    fclose(input);
    return 0;
}
