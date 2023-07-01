%skeleton "lalr1.cc" /* -*- c++ -*- */
%require "3.0"
%defines
//%define parser_class_name {sysyfParser}
%define api.parser.class {sysyfParser}

%define api.token.constructor
%define api.value.type variant
%define parse.assert

%code requires
{
#include <string>
#include "SyntaxTree.h"
class sysyfDriver;
}

// The parsing context.
%param { sysyfDriver& driver }

// Location tracking
%locations
%initial-action
{
// Initialize the initial location.
@$.begin.filename = @$.end.filename = &driver.file;
};

// Enable tracing and verbose errors (which may be wrong!)
%define parse.trace
%define parse.error verbose

// Parser needs to know about the driver:
%code
{
#include "sysyfDriver.h"
#define yylex driver.lexer.yylex
}

// Tokens:
%define api.token.prefix {TOK_}

%token END
%token PLUS MINUS MULTIPLY DIVIDE MODULO
%token ASSIGN SEMICOLON
%token COMMA LPARENTHESE RPARENTHESE
%token LBRACE RBRACE
%token LBRACKET RBRACKET
%token CONST
%token INT FLOAT STRING BOOL RETURN VOID
%token <std::string>IDENTIFIER
%token <int>INTCONST
%token <float>FLOATCONST
%token EOL COMMENT
%token BLANK
%token EQ NEQ GT GTE LT LTE
%token IF ELSE WHILE BREAK CONTINUE

%expect 10
%left ASSIGN
%left EQ NEQ
%left GT GTE LT LTE
%left PLUS MINUS
%left MULTIPLY DIVIDE MODULO
%precedence UPLUS UMINUS

// Use variant-based semantic values: %type and %token expect genuine types
%type <SyntaxTree::Assembly*>CompUnit
%type <SyntaxTree::PtrList<SyntaxTree::GlobalDef>>GlobalDecl
%type <SyntaxTree::Type>BType
%type <SyntaxTree::PtrList<SyntaxTree::VarDef>>Decl
%type <SyntaxTree::PtrList<SyntaxTree::VarDef>>ConstDecl
%type <SyntaxTree::PtrList<SyntaxTree::VarDef>>ConstDefList
%type <SyntaxTree::VarDef*>ConstDef
%type <SyntaxTree::InitVal*>ConstInitVal
%type <SyntaxTree::PtrList<SyntaxTree::VarDef>>VarDecl
%type <SyntaxTree::PtrList<SyntaxTree::VarDef>>VarDefList
%type <SyntaxTree::Expr*>OptionConstExp
%type <SyntaxTree::Expr*>OptionExp
%type <SyntaxTree::VarDef*>VarDef
%type <SyntaxTree::InitVal*>InitVal
%type <SyntaxTree::PtrList<SyntaxTree::InitVal>>ExpList
%type <SyntaxTree::Type>FuncType
%type <SyntaxTree::FuncParam*>FuncFParam
%type <SyntaxTree::FuncFParamList*>FuncFParams
%type <SyntaxTree::FuncDef*>FuncDef
%type <SyntaxTree::BlockStmt*>Block
%type <SyntaxTree::PtrList<SyntaxTree::Stmt>>BlockItemList
%type <SyntaxTree::PtrList<SyntaxTree::Stmt>>BlockItem
%type <SyntaxTree::Stmt*>Stmt
%type <SyntaxTree::LVal*>LVal
%type <SyntaxTree::Expr*>Exp
%type <SyntaxTree::CondExpr*>Cond
%type <SyntaxTree::Expr*>PrimaryExp
%type <SyntaxTree::UnaryExpr*>UnaryExp
%type <SyntaxTree::UnaryOp>UnaryOp
%type <SyntaxTree::PtrList<SyntaxTree::Expr>>FuncRParams
%type <SyntaxTree::BinaryExpr*>MulExp
%type <SyntaxTree::AddExpr*>AddExp
%type <SyntaxTree::BinaryCondExpr*>RelExp
%type <SyntaxTree::BinaryCondExpr*>EqExp
%type <SyntaxTree::Expr*>ConstExp
%type <SyntaxTree::Literal*>Number



// No %destructors are needed, since memory will be reclaimed by the
// regular destructors.

// Grammar:
%start Begin 

%%
Begin: CompUnit END {
    $1->loc = @$;
    driver.root = $1;
    return 0;
  }
  ;

CompUnit:CompUnit GlobalDecl{
		$1->global_defs.insert($1->global_defs.end(), $2.begin(), $2.end());
		$$=$1;
	} 
	| GlobalDecl{
		$$=new SyntaxTree::Assembly();
		$$->global_defs.insert($$->global_defs.end(), $1.begin(), $1.end());
  }
;

GlobalDecl:FuncDef{
    $$ = SyntaxTree::PtrList<SyntaxTree::GlobalDef>();
    $$.push_back(SyntaxTree::Ptr<SyntaxTree::GlobalDef>($1));
  }
  | Decl{
    $$ = $1;
  }
;
	

Decl:ConstDecl{
    $$ = $1;
  }
  | VarDecl{
    $$ = $1;
  }
;

BType:INT{
  $$=SyntaxTree::Type::INT;
  }
	| FLOAT{
	    $$ = SyntaxTree::Type::FLOAT;
  }
;

FuncType:VOID{
    $$=SyntaxTree::Type::VOID;  
  }
  | BType{
    $$=$1;
  }
;

ConstDecl:CONST BType ConstDefList SEMICOLON{
    $$ = $3;
    for(auto &node : $$){
      node->btype = $2;
      node->is_constant = true;
    }
}
;

ConstDef:IDENTIFIER OptionConstExp ASSIGN ConstInitVal{
    $$ = new SyntaxTree::VarDef();
    $$->is_constant = true;
    $$->name = $1;
    $$->initializers = SyntaxTree::Ptr<SyntaxTree::InitVal>($4);
    $$->is_inited = true;
    $$->array_length.push_back(SyntaxTree::Ptr<SyntaxTree::Expr>($2));
    $$->loc = @$;
  }
;

ConstDefList:ConstDefList COMMA ConstDef{
    $1.push_back(SyntaxTree::Ptr<SyntaxTree::VarDef>($3));
     $$=$1;
  }
  | ConstDef{
    $$=SyntaxTree::PtrList<SyntaxTree::VarDef>();
    $$.push_back(SyntaxTree::Ptr<SyntaxTree::VarDef>($1));
  }
;

ConstInitVal:ConstExp{
    $$ = new SyntaxTree::InitVal();
    $$->isExp = true;
    $$->expr = SyntaxTree::Ptr<SyntaxTree::Expr>($1);
    $$->loc = @$;
  }
  | LBRACE RBRACE{
    $$ = new SyntaxTree::InitVal();
    $$->isExp = false;
    $$->loc = @$;
  }
  | LBRACE ConstDefList RBRACE{
    $$ = new SyntaxTree::InitVal();
    $$->isExp = false;
    $$->elementList = SyntaxTree::PtrList<SyntaxTree::InitVal>();
    for(auto &node:$2){
      auto temp=new SyntaxTree::InitVal();
      temp->isExp=true;
      temp->expr=SyntaxTree::Ptr<SyntaxTree::expr>(node);
      $$->elementList.push_back(SyntaxTree::Ptr<SyntaxTree::InitVal>(temp));
    }
    $$->loc = @$;
  }
;

VarDecl:BType VarDefList SEMICOLON{
    $$=$2;
    for (auto &node : $$) {
      node->btype = $1;
    }
  }
;

VarDefList:VarDefList COMMA VarDef{
    $1.push_back(SyntaxTree::Ptr<SyntaxTree::VarDef>($3));
    $$=$1;
  }
	| VarDef{
    $$=SyntaxTree::PtrList<SyntaxTree::VarDef>();
    $$.push_back(SyntaxTree::Ptr<SyntaxTree::VarDef>($1));
  }
;

OptionConstExp:LBRACKET ConstExp RBRACKET{
  $$ = $2;
}
|%empty{
  $$ =new SyntaxTree::Expr();
}

VarDef:IDENTIFIER OptionConstExp{
    $$ = new SyntaxTree::VarDef();
    $$->name = $1;
    $$->array_length.push_back(SyntaxTree::Ptr<SyntaxTree::Expr>($2));
    $$->is_inited = false;
    $$->loc = @$;
}
	| IDENTIFIER OptionConstExp ASSIGN InitVal{
    $$ = new SyntaxTree::VarDef();
    $$->name = $1;
    $$->array_length.push_back(SyntaxTree::Ptr<SyntaxTree::Expr>($2));
    $$->initializers = SyntaxTree::Ptr<SyntaxTree::InitVal>($4);
    $$->is_inited = true;
    $$->loc = @$;
}
;

ExpList:ExpList COMMA Exp{
   $1.push_back(SyntaxTree::Ptr<SyntaxTree::InitVal>($3);
   $$ = $1;
  }
 	| Exp{
    $$ = SyntaxTree::PtrList<SyntaxTree::InitVal>();
    $$.push_back(SyntaxTree::Ptr<SyntaxTree::InitVal>($1));
  }
;

InitVal:Exp{
    $$ = new SyntaxTree::InitVal();
    $$->isExp = true;
    $$->expr = SyntaxTree::Ptr<SyntaxTree::Expr>($1);
    $$->loc = @$;
  }
	| LBRACE ExpList RBRACE{
    $$ = new SyntaxTree::InitVal();
    $$->isExp = false;
    for(auto &node:$2){
      auto temp=new SyntaxTree::InitVal();
      temp->isExp=true;
      temp->expr=SyntaxTree::Ptr<SyntaxTree::expr>(node);
      $$->elementList.push_back(SyntaxTree::Ptr<SyntaxTree::InitVal>(temp));
    }
    $$->loc = @$;
}
	| LBRACE RBRACE{
    $$ = new SyntaxTree::InitVal();
    $$->isExp = false;
    $$->loc = @$;
}
;

FuncFParam:BType IDENTIFIER{
    $$ = new SyntaxTree::FuncParam();
    $$->name = $2;
    $$->array_index=nullptr;
    $$->param_type = $1;
    $$->loc = @$;
  }
;

FuncFParams:FuncFParam{
    $$ = new SyntaxTree::FuncFParamList();
    $$->params.push_back(SyntaxTree::Ptr<SyntaxTree::FuncParam>($1));
  }
  | FuncFParams COMMA FuncFParam{
    $1->params.push_back(SyntaxTree::Ptr<SyntaxTree::FuncParam>($3));
    $$ = $1;
  }
;


FuncDef: FuncType IDENTIFIER LPARENTHESE RPARENTHESE Block{
    $$ = new SyntaxTree::FuncDef();
    $$->ret_type = $1;
    $$->param_list = SyntaxTree::Ptr<SyntaxTree::FuncFParamList>();
    $$->name = $2;
    $$->body = SyntaxTree::Ptr<SyntaxTree::BlockStmt>($5);
    $$->loc = @$;
  }
  | FuncType IDENTIFIER LPARENTHESE FuncFParams RPARENTHESE Block{
    $$ = new SyntaxTree::FuncDef();
    $$->ret_type = $1;
    $$->param_list = SyntaxTree::Ptr<SyntaxTree::FuncFParamList>($4);
    $$->name = $2;
    $$->body = SyntaxTree::Ptr<SyntaxTree::BlockStmt>($6);
    $$->loc = @$;
  }
  ;

Block:LBRACE BlockItemList RBRACE{
    $$ = new SyntaxTree::BlockStmt();
    $$->body = $2;
    $$->loc = @$;
  }
  ;

BlockItemList:BlockItemList BlockItem{
    $1.insert($1.end(), $2.begin(), $2.end());
    $$ = $1;
  }
  | %empty{
    $$ = SyntaxTree::PtrList<SyntaxTree::Stmt>();
  }
  ;

BlockItem:Decl{
    $$ = SyntaxTree::PtrList<SyntaxTree::Stmt>();
    $$.insert($$.end(), $1.begin(), $1.end());
  }
  | Stmt{
    $$ = SyntaxTree::PtrList<SyntaxTree::Stmt>();
    $$.push_back(SyntaxTree::Ptr<SyntaxTree::Stmt>($1));
  }
  ;

Stmt:LVal ASSIGN Exp SEMICOLON{
    auto temp = new SyntaxTree::AssignStmt();
    temp->target = SyntaxTree::Ptr<SyntaxTree::LVal>($1);
    temp->value = SyntaxTree::Ptr<SyntaxTree::Expr>($3);
    $$ = temp;
    $$->loc = @$;
  }
  | Exp SEMICOLON{
    auto temp = new SyntaxTree::ExprStmt();
    temp->exp = SyntaxTree::Ptr<SyntaxTree::Expr>($1);
    $$ = temp;
    $$->loc = @$;
  }
  | IF LPARENTHESE Cond RPARENTHESE Stmt{
    $$ = new SyntaxTree::IfStmt();
    $$->cond_exp = SyntaxTree::Ptr<SyntaxTree::Expr>($3);
    $$->if_statement = SyntaxTree::Ptr<SyntaxTree::Stmt>($5);
    $$->loc = @$;
  }
  | IF LPARENTHESE Cond RPARENTHESE Stmt ELSE Stmt{
    $$ = new SyntaxTree::IfStmt();
    $$->cond_exp = SyntaxTree::Ptr<SyntaxTree::Expr>($3);
    $$->if_statement = SyntaxTree::Ptr<SyntaxTree::Stmt>($5);
    $$->else_statement = SyntaxTree::Ptr<SyntaxTree::Stmt>($7);
    $$->loc = @$;
  }
  | WHILE LPARENTHESE Cond RPARENTHESE Stmt{
    $$ = new SyntaxTree::WhileStmt();
    $$->cond_exp = SyntaxTree::Ptr<SyntaxTree::Expr>($3);
    $$->statement = SyntaxTree::Ptr<SyntaxTree::Stmt>($5);
    $$->loc = @$;
  }
  | BREAK SEMICOLON{
    $$ = new SyntaxTree::BreakStmt();
    $$->loc = @$;
  }
  | CONTINUE SEMICOLON{
    $$ = new SyntaxTree::ContinueStmt();
    $$->loc = @$;
  }
  | RETURN SEMICOLON{
    auto temp = new SyntaxTree::ReturnStmt();
    $$ = temp;
    $$->loc = @$;
  }
  | RETURN  Exp SEMICOLON{
    $$ = new SyntaxTree::ReturnStmt();
    $$->ret = SyntaxTree::Ptr<SyntaxTree::Expr>($2);
    $$->loc = @$;
  }
  | Block{
    $$ = $1;
  }
  | SEMICOLON{
    $$ = new SyntaxTree::EmptyStmt();
    $$->loc = @$;
  }
  ;

OptionExp:LBRACKET Exp RBRACKET{
  $$ = $2;
 }
 | %empty{
   $$ = new SyntaxTree::Expr();
 }

LVal:IDENTIFIER OptionExp{
    $$ = new SyntaxTree::LVal();
    $$->name = $1;
    $$->array_index.push_back(SyntaxTree::Ptr<SyntaxTree::Expr>($2));
    $$->loc = @$;   
  }
  ;

Exp:AddExp{
    $$ = $1;
}
;

Cond:EqExp{
    $$ = $1;
}
;

PrimaryExp:LPARENTHESE Exp RPARENTHESE{
    $$ = $2;
  }
  | LVal{
    $$ = $1;
  }
  | Number{
    $$ = $1;
  }
;

UnaryExp:PrimaryExp{
    $$ = $1;
  }
  | IDENTIFIER LPARENTHESE RPARENTHESE{
    $$ = new SyntaxTree::FuncCallStmt();
    $$->name = $1;
    $$->params = SyntaxTree::PtrList<SyntaxTree::Expr>();
    $$->loc = @$;
  }
  | IDENTIFIER LPARENTHESE FuncRParams RPARENTHESE{
    $$ = new SyntaxTree::FuncCallStmt();
    $$->name = $1;
    $$->params = SyntaxTree::PtrList<SyntaxTree::Expr>($3);
    $$->loc = @$;
  }
  | UnaryOp UnaryExp{
    $$ = new SyntaxTree::UnaryExpr();
    $$-> UnaryOp = $1;
    $$->rhs = $2;
    $$->loc = @$;
  }
;

FuncRParams:ExpList{
  $$ = $1;
}
;

UnaryOp:PLUS %prec UPLUS{
    $$ = SyntaxTree::UnaryOp::PLUS;
  }
  | MINUS %prec UMINUS{
    $$ = SyntaxTree::UnaryOp::MINUS;
  }
;

MulExp:UnaryExp{
    $$ = $1;
  }
  | MulExp MULTIPLY UnaryExp{
    auto temp = new SyntaxTree::BinaryExpr();
    temp->op = SyntaxTree::BinOp::MUTIPLY;
    temp->lhs = SyntaxTree::Ptr<SyntaxTree::Expr>($1);
    temp->rhs = SyntaxTree::Ptr<SyntaxTree::Expr>($3);
    $$ = temp;
    $$->loc = @$;
  }
  | MulExp DIVIDE UnaryExp{
    auto temp = new SyntaxTree::BinaryExpr();
    temp->op = SyntaxTree::BinOp::DIVIDE;
    temp->lhs = SyntaxTree::Ptr<SyntaxTree::Expr>($1);
    temp->rhs = SyntaxTree::Ptr<SyntaxTree::Expr>($3);
    $$ = temp;
    $$->loc = @$;
  }
  | MulExp MODULO UnaryExp{
    auto temp = new SyntaxTree::BinaryExpr();
    temp->op = SyntaxTree::BinOp::MODULO;
    temp->lhs = SyntaxTree::Ptr<SyntaxTree::Expr>($1);
    temp->rhs = SyntaxTree::Ptr<SyntaxTree::Expr>($3);
    $$ = temp;
    $$->loc = @$;
  }
;

AddExp:MulExp{
    $$ = $1;
  }
  | AddExp PLUS MulExp{
    auto temp = new SyntaxTree::BinaryExpr();
    temp->op = SyntaxTree::BinOp::PLUS;
    temp->lhs = SyntaxTree::Ptr<SyntaxTree::Expr>($1);
    temp->rhs = SyntaxTree::Ptr<SyntaxTree::Expr>($3);
    $$ = temp;
    $$->loc = @$;
  }
  | AddExp MINUS MulExp{
    auto temp = new SyntaxTree::BinaryExpr();
    temp->op = SyntaxTree::BinOp::MINUS;
    temp->lhs = SyntaxTree::Ptr<SyntaxTree::Expr>($1);
    temp->rhs = SyntaxTree::Ptr<SyntaxTree::Expr>($3);
    $$ = temp;
    $$->loc = @$;
  }
;

RelExp:AddExp{
    $$ = new SyntaxTree::BinaryCondExpr();
    $$->lhs = SyntaxTree::Ptr<SyntaxTree::Expr>($1);
    $$->loc = @$;
  }
  | RelExp LT AddExp{
    auto temp = new SyntaxTree::BinaryCondExpr();
    temp->op = SyntaxTree::BinaryCondOp::LT;
    temp->lhs = SyntaxTree::Ptr<SyntaxTree::Expr>($1);
    temp->rhs = SyntaxTree::Ptr<SyntaxTree::Expr>($3);
    $$ = temp;
    $$->loc = @$;
  }
  | RelExp GT AddExp{
    auto temp = new SyntaxTree::BinaryCondExpr();
    temp->op = SyntaxTree::BinaryCondOp::GT;
    temp->lhs = SyntaxTree::Ptr<SyntaxTree::Expr>($1);
    temp->rhs = SyntaxTree::Ptr<SyntaxTree::Expr>($3);
    $$ = temp;
    $$->loc = @$;
  }
  | RelExp LTE AddExp{
    auto temp = new SyntaxTree::BinaryCondExpr();
    temp->op = SyntaxTree::BinaryCondOp::LTE;
    temp->lhs = SyntaxTree::Ptr<SyntaxTree::Expr>($1);
    temp->rhs = SyntaxTree::Ptr<SyntaxTree::Expr>($3);
    $$ = temp;
    $$->loc = @$;
  }
  | RelExp GTE AddExp{
    auto temp = new SyntaxTree::BinaryCondExpr();
    temp->op = SyntaxTree::BinaryCondOp::GTE;
    temp->lhs = SyntaxTree::Ptr<SyntaxTree::Expr>($1);
    temp->rhs = SyntaxTree::Ptr<SyntaxTree::Expr>($3);
    $$ = temp;
    $$->loc = @$;
  }
;

EqExp:RelExp{
    $$ = $1;
}
  | EqExp EQ RelExp{
    auto temp = new SyntaxTree::BinaryCondExpr();
    temp->op = SyntaxTree::BinaryCondOp::EQ;
    temp->lhs = SyntaxTree::Ptr<SyntaxTree::Expr>($1);
    temp->rhs = SyntaxTree::Ptr<SyntaxTree::Expr>($3);
    $$ = temp;
    $$->loc = @$;
  }
  | EqExp NEQ RelExp{
    auto temp = new SyntaxTree::BinaryCondExpr();
    temp->op = SyntaxTree::BinaryCondOp::NEQ;
    temp->lhs = SyntaxTree::Ptr<SyntaxTree::Expr>($1);
    temp->rhs = SyntaxTree::Ptr<SyntaxTree::Expr>($3);
    $$ = temp;
    $$->loc = @$;
  }
;

ConstExp:AddExp{
    $$ = $1;
}
;

Number: INTCONST {
    $$ = new SyntaxTree::Literal();
    $$->literal_type = SyntaxTree::Type::INT;
    $$->int_const = $1;
    $$->loc = @$;
  }
  |FLOATCONST{
    $$ = new SyntaxTree::Literal();
    $$->literal_type = SyntaxTree::Type::FLOAT;
    $$->float_const = $1;
    $$->loc = @$;
  }
  ;
%%

// Register errors to the driver:
void yy::sysyfParser::error (const location_type& l,
                          const std::string& m)
{
    driver.error(l, m);
}
