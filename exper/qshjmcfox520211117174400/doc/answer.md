### 问题1-1 

`VarDef`、`InitVal`、`LVal`、`FuncDef`、`FuncFParamList`、`FuncParam`、`BlockStmt`等节点均继承了基类node，故基类node为抽象节点，而vardef、InitVal等节点则为具体节点，且这些节点都有accept函数，在accept函数中回调visit函数来实现对节点的访问。通过visit函数的多态，实现了对不同类型的节点采取了不同的访问操作。

### 问题1-2 

通过./build/sysYFParser -emit-ast testcase.sy 输出testcase中的语法树: int a = (2%3);

### 问题3-1

1.

遇到的困难：enter_scope、exit_scope的使用

解决方案：检查SyntaxTreeChecker.h中有哪些函数未使用

刚开始改了SyntaxTreeChecker.cpp编译testcase的时候就遇到了segmentation fault，用gdp查看位置出现了问号，查看栈帧等信息还是看不出来，调试了很久也没调试处来，后来检查代码的时候才发现是没有enter_scope。

2.

实验难点：区分函数的BlockStmt和单独的一个语句块。

考察倾向：符号表的建立以及变量、函数不能重复声明，不能出现未定义后使用的情形。

3.

实现思路：对SyntaxTree的数据结构里的各个属性进行访问，必要的时候要判断是否为空，对于函数实参形参相匹配，则通过遍历Function中的args_int与当前的函数调用的实参进行类型与个数的判断。

实现亮点：对于函数的语义检查，在函数调用时先查符号表得到函数的相关属性，再在遍历实参的过程中判断实参与形参的个数和类型是否相同。

### 问题3-2

（1） 若在Expr中添加属性，则还需对其他文件进行相关改动，如修改文法。

（2）语义错误有很多种，若拆除多个类进行处理，需要声明很多个类，较为复杂。