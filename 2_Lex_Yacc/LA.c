%
{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

    FILE *pif, *st;
    %
}

% option noyywrap

        % %
        /* Cuvinte cheie */
        "VAR" |
    "BEGIN" | "END" | "READ" | "WRITE" | "IF" | "THEN" | "ELSE" | "WHILE" | "DO"
{
    fprintf(pif, "KEYWORD %s\n", yytext);
}

/* Operatori */
":=" | "<=" | ">=" | "=" | "<" | ">" | "<>"
{
    fprintf(pif, "OPERATOR %s\n", yytext);
}
"+" | "-" | "*" | "/"
{
    fprintf(pif, "OPERATOR %s\n", yytext);
}

/* Separatori */
"[" | "]" | "{" | "}" | ":" | ";" | " "
{
    fprintf(pif, "SEPARATOR %s\n", yytext);
}

/* Identificatori */
[a - zA - Z][a - zA - Z0 - 9] *
{
    fprintf(pif, "IDENTIFIER %s\n", yytext);
    fprintf(st, "IDENTIFIER %s\n", yytext);
}

        /* Constante numerice */
        [+-]
    ? [0 - 9] +\.[0 - 9] +
{
    fprintf(pif, "FLOAT_CONST %s\n", yytext);
}
[+-] ? [0 - 9] +
{
    fprintf(pif, "INT_CONST %s\n", yytext);
}

/* Constante string */
\"[^\"]*\"                                                          {
    fprintf(pif, "STRING_CONST %s\n", yytext);
}

/* Erori lexicale */
.
{
    fprintf(stderr, "Eroare lexicală: %s\n", yytext);
}
% %

    int main(int argc, char **argv)
{
    if (argc != 2)
    {
        printf("Utilizare: ./scanner <fisier_intrare>\n");
        return 1;
    }

    FILE *input = fopen(argv[1], "r");
    if (!input)
    {
        printf("Nu se poate deschide fișierul %s\n", argv[1]);
        return 1;
    }

    pif = fopen("PIF.out", "w");
    st = fopen("ST.out", "w");
    yyin = input; // yyin este fișierul analizat de lex
    yylex();      // Pornim analiza lexicală

    fclose(input);
    fclose(pif);
    fclose(st);
    return 0;
}
