%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    FILE *pif, *st, *errors;
    int st_index = 0; // Index pentru Symbol Table
    int yycolumn = 1; // Poziția curentă în linia de intrare

    // Structura pentru Symbol Table (ST)
    typedef struct {
        char value[50]; // Valoarea simbolului (ID sau Constanta)
    } SymbolTableEntry;

    SymbolTableEntry symbolTable[100]; // Tabelul simbolurilor

    // Cuvinte cheie (keywords)
    char *keywords[] = {
        "VAR", "BEGIN", "END", "READ", "WRITE", "IF", "THEN", "ELSE", 
        "WHILE", "DO", "int", "float", "char"
    };
    int num_keywords = 13;  // Numărul de cuvinte cheie

    // Funcție pentru a verifica dacă un cuvânt este cuvânt cheie
    int is_keyword(const char *str) {
        for (int i = 0; i < num_keywords; i++) {
            if (strcmp(str, keywords[i]) == 0) {
                return 1;
            }
        }
        return 0;
    }

    // Funcție pentru a verifica dacă un simbol este deja în Symbol Table
    int is_in_symbol_table(const char *str) {
        for (int i = 0; i < st_index; i++) {
            if (strcmp(symbolTable[i].value, str) == 0) {
                return i; // Returnăm poziția în ST
            }
        }
        return -1; // Nu a fost găsit
    }

    // Funcție pentru a adăuga un simbol în Symbol Table
    void add_to_symbol_table(const char *str) {
        strcpy(symbolTable[st_index].value, str);
        st_index++;
    }
%}

%option noyywrap

%%
"VAR"|"BEGIN"|"END"|"READ"|"WRITE"|"IF"|"THEN"|"ELSE"|"WHILE"|"DO"|"int"|"float"|"char" {
    fprintf(pif, "KEYWORD | %s | 0\n", yytext);
}

":="|"<="|">="|"="|"<"|">"|"<>" {
    fprintf(pif, "OPERATOR | %s | 0\n", yytext);
}
\+|\-|\*|\/|\% {
    fprintf(pif, "OPERATOR | %s | 0\n", yytext);
}

"["|"]"|"{"|"}"|":"|";"|"("|")" {
    fprintf(pif, "SEPARATOR | %s | 0\n", yytext);
}

[a-zA-Z][a-zA-Z0-9_]* {
    if (!is_keyword(yytext)) { // Nu este cuvânt cheie
        int pos = is_in_symbol_table(yytext);
        if (pos == -1) { // Dacă nu este deja în ST
            add_to_symbol_table(yytext);
            fprintf(pif, "ID | %d | %d\n", st_index - 1, st_index - 1);
        } else { // Dacă există deja
            fprintf(pif, "ID | %d | %d\n", pos, pos);
        }
    }
}

[+-]?[0-9]+\.[0-9]+ {
    int pos = is_in_symbol_table(yytext);
    if (pos == -1) {
        add_to_symbol_table(yytext);
        fprintf(pif, "CONST | %d | %d\n", st_index - 1, st_index - 1);
    } else {
        fprintf(pif, "CONST | %d | %d\n", pos, pos);
    }
}

[+-]?[0-9]+ {
    int pos = is_in_symbol_table(yytext);
    if (pos == -1) {
        add_to_symbol_table(yytext);
        fprintf(pif, "CONST | %d | %d\n", st_index - 1, st_index - 1);
    } else {
        fprintf(pif, "CONST | %d | %d\n", pos, pos);
    }
}

\"[^\"]*\" {
    int pos = is_in_symbol_table(yytext);
    if (pos == -1) {
        add_to_symbol_table(yytext);
        fprintf(pif, "CONST | %d | %d\n", st_index - 1, st_index - 1);
    } else {
        fprintf(pif, "CONST | %d | %d\n", pos, pos);
    }
}

. {
    fprintf(errors, "Eroare lexicală la linia %d, coloana %d: %s\n", yylineno, yycolumn, yytext);
}
%%

int main(int argc, char **argv) {
    if (argc != 2) {
        printf("Utilizare: ./scanner <fisier_intrare>\n");
        return 1;
    }

    FILE *input = fopen(argv[1], "r");
    if (!input) {
        printf("Nu se poate deschide fișierul %s\n", argv[1]);
        return 1;
    }

    pif = fopen("PIF.out", "w");
    st = fopen("ST.out", "w");
    errors = fopen("Errors.out", "w");

    // Scrierea antetului pentru Symbol Table
    fprintf(st, "ID/const | Poziție\n");

    yyin = input;
    yylex();

    // Scrierea conținutului pentru Symbol Table
    for (int i = 0; i < st_index; i++) {
        fprintf(st, "%s | %d\n", symbolTable[i].value, i);
    }

    fclose(input);
    fclose(pif);
    fclose(st);
    fclose(errors);

    return 0;
}
