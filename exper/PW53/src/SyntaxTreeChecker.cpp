#include "SyntaxTreeChecker.h"

using namespace SyntaxTree;

bool funflag=false;
void SyntaxTreeChecker::visit(Assembly& node) {
	enter_scope();
    for (auto def : node.global_defs) {
        def->accept(*this);
    }
	exit_scope();
}

void SyntaxTreeChecker::visit(FuncDef& node) {
	enter_scope();
    funflag=true;
    if (!declare_functions(node.name, node.ret_type, node.param_list)) {
        err.error(node.loc, "Function duplicated!");
        exit(int(ErrorType::FuncDuplicated));
    }
    if(node.param_list){
        node.param_list->accept(*this);
    }
    if(node.body){
        node.body->accept(*this);
    }
    this->Expr_int=(node.ret_type==SyntaxTree::Type::INT);
	exit_scope();
}

void SyntaxTreeChecker::visit(BinaryExpr& node) {
    node.lhs->accept(*this);
    bool lhs_int = this->Expr_int;
    node.rhs->accept(*this);
    bool rhs_int = this->Expr_int;
    if (node.op == SyntaxTree::BinOp::MODULO) {
        if (!lhs_int || !rhs_int) {
            err.error(node.loc, "Operands of modulo should be integers.");
            exit(int(ErrorType::Modulo));
        }
    }
    this->Expr_int = lhs_int & rhs_int;
}

void SyntaxTreeChecker::visit(UnaryExpr& node) {
    node.rhs->accept(*this);
}

void SyntaxTreeChecker::visit(LVal& node) {
    if (!lookup_variable(node.name, this->Expr_int)) {
        err.error(node.loc, "variables unknown!");
        exit(int(ErrorType::VarUnknown));
    }
    for (auto arr : node.array_index) {
        arr->accept(*this);
    }
}

void SyntaxTreeChecker::visit(Literal& node) {
    this->Expr_int = (node.literal_type == SyntaxTree::Type::INT);
}

void SyntaxTreeChecker::visit(ReturnStmt& node) {
    if(node.ret.get()){
        node.ret->accept(*this);
    }
}

void SyntaxTreeChecker::visit(VarDef& node) {
    for (auto arr : node.array_length) {
        arr->accept(*this);
    }
    if (node.is_inited) {
        node.initializers->accept(*this);
    }
    if (!declare_variable(node.name, node.btype)) {
        err.error(node.loc, "variables duplicated!");
        exit(int(ErrorType::VarDuplicated));
    }
}

void SyntaxTreeChecker::visit(AssignStmt& node) {
    node.target->accept(*this);
    node.value->accept(*this);
}

void SyntaxTreeChecker::visit(FuncCallStmt& node) {
    SyntaxTreeChecker::PtrFunction fun=lookup_functions(node.name);
    int num=0,param_num;
    bool param_int;
    if (!fun) {
        err.error(node.loc, "function unknown!");
        exit(int(ErrorType::FuncUnknown));
    }
    param_num=fun->param_num();
    for (auto param : node.params) {
        param->accept(*this);
        param_int=this->Expr_int;
        ++num;
        if(num<=param_num){
            if(param_int!=fun->args_int[num-1]){
                err.error(node.loc, "type not the same!");
                exit(int(ErrorType::FuncParams));
            }
        }
        else{
            err.error(node.loc, "shican num is more!");
            exit(int(ErrorType::FuncParams));
        }
    }
    if(num!=param_num){
        err.error(node.loc, "xingcan num is more!");
        exit(int(ErrorType::FuncParams));
    }
    this->Expr_int=fun->ret_int;
}

void SyntaxTreeChecker::visit(BlockStmt& node) {
    bool isExit=false;
    if(!funflag){
        enter_scope();
        isExit=true;
    }
    else{
        funflag=false; 
    }
    for (auto b : node.body) {
        b->accept(*this);
    }
    if(isExit){
        exit_scope();
    }
}

void SyntaxTreeChecker::visit(EmptyStmt& node) {
    //node.accept(*this);
}

void SyntaxTreeChecker::visit(SyntaxTree::ExprStmt& node) {
    if(node.exp){
        node.exp->accept(*this);
    }
}

void SyntaxTreeChecker::visit(SyntaxTree::FuncParam& node) {
    for (auto array : node.array_index) {
        if(array!=nullptr){
            array->accept(*this);
        }
    }
    if(!declare_variable(node.name,node.param_type)){
        err.error(node.loc, "variables duplicated!");
        exit(int(ErrorType::VarDuplicated));
    }
    this->Expr_int=(node.param_type==SyntaxTree::Type::INT);
}

void SyntaxTreeChecker::visit(SyntaxTree::FuncFParamList& node) {
    for (auto param : node.params) {
        param->accept(*this);
    }
}

void SyntaxTreeChecker::visit(SyntaxTree::BinaryCondExpr& node) {
    node.lhs->accept(*this);
    node.rhs->accept(*this);
}

void SyntaxTreeChecker::visit(SyntaxTree::UnaryCondExpr& node) {
    node.rhs->accept(*this);
}

void SyntaxTreeChecker::visit(SyntaxTree::IfStmt& node) {
    node.cond_exp->accept(*this);
    if(node.if_statement!=nullptr){
		node.if_statement->accept(*this);
    }
	else{
		node.else_statement->accept(*this);
	}
}

void SyntaxTreeChecker::visit(SyntaxTree::WhileStmt& node) {
    if(node.cond_exp){
        node.cond_exp->accept(*this);
    }
    if(node.statement){
        node.statement->accept(*this);
    }
    
}

void SyntaxTreeChecker::visit(SyntaxTree::BreakStmt& node) {
    //node.accept(*this);
}
void SyntaxTreeChecker::visit(SyntaxTree::ContinueStmt& node) {
    //node.accept(*this);
}

void SyntaxTreeChecker::visit(SyntaxTree::InitVal& node) {
    if (node.isExp) {
        node.expr->accept(*this);
    } 
    else {
        for (auto element : node.elementList) {
            element->accept(*this);
        }
    }
}