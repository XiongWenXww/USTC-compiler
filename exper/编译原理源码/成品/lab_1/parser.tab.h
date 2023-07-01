
/* A Bison parser, made by GNU Bison 2.4.1.  */

/* Skeleton interface for Bison's Yacc-like parsers in C
   
      Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */


/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     INT = 258,
     ID = 259,
     RELOP = 260,
     TYPE = 261,
     FLOAT = 262,
     CHAR = 263,
     DPLUS = 264,
     DMINUS = 265,
     LP = 266,
     RP = 267,
     LC = 268,
     RC = 269,
     LB = 270,
     RB = 271,
     SEMI = 272,
     COMMA = 273,
     PLUS = 274,
     MINUS = 275,
     STAR = 276,
     DIV = 277,
     ASSIGNOP = 278,
     AND = 279,
     OR = 280,
     NOT = 281,
     IF = 282,
     ELSE = 283,
     WHILE = 284,
     RETURN = 285,
     FOR = 286,
     BREAK = 287,
     CONTINUE = 288,
     SWITCH = 289,
     CASE = 290,
     COLON = 291,
     DEFAULT = 292,
     EXT_DEF_LIST = 293,
     EXT_VAR_DEF = 294,
     FUNC_DEF = 295,
     FUNC_DEC = 296,
     EXT_DEC_LIST = 297,
     PARAM_LIST = 298,
     PARAM_DEC = 299,
     VAR_DEF = 300,
     DEC_LIST = 301,
     DEF_LIST = 302,
     COMP_STM = 303,
     STM_LIST = 304,
     EXP_STMT = 305,
     IF_THEN = 306,
     IF_THEN_ELSE = 307,
     DPLUS_BEFORE = 308,
     DPLUS_AFTER = 309,
     DMINUS_BEFORE = 310,
     DMINUS_AFTER = 311,
     DIMENSION = 312,
     DIMENSION_LIST = 313,
     ARRAY = 314,
     ARRAY_LIST = 315,
     ARRAY_1 = 316,
     ARRAY_N = 317,
     FUNC_CALL = 318,
     ARGS = 319,
     FUNCTION = 320,
     PARAM = 321,
     ARG = 322,
     CALL = 323,
     LABEL = 324,
     GOTO = 325,
     JLT = 326,
     JLE = 327,
     JGT = 328,
     JGE = 329,
     EQ = 330,
     NEQ = 331,
     LCOMMA = 332,
     RM = 333,
     LM = 334,
     UMINUS = 335,
     LOWER_THEN_ELSE = 336
   };
#endif



#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 1676 of yacc.c  */
#line 17 "parser.y"

	int    type_int;
	float  type_float;
	char   type_char;
	char   type_id[32];
	struct ASTNode *ptr;



/* Line 1676 of yacc.c  */
#line 143 "parser.tab.h"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;

#if ! defined YYLTYPE && ! defined YYLTYPE_IS_DECLARED
typedef struct YYLTYPE
{
  int first_line;
  int first_column;
  int last_line;
  int last_column;
} YYLTYPE;
# define yyltype YYLTYPE /* obsolescent; will be withdrawn */
# define YYLTYPE_IS_DECLARED 1
# define YYLTYPE_IS_TRIVIAL 1
#endif

extern YYLTYPE yylloc;

