 ## 1-1
在demoDriver.h中，声明了demoFlexLexer类型的lexer，还声明的词法分析与语法分析的相关函数及变量，其中，bool类型的trace_scanning、trace_parsing用来判断是否可以进行相应的词法或语法分析，scan_begin、scan_end函数用于词法分析，parse函数用于语法分析。除此之外还声明了错误处理函数等。demoDriver.cpp则是对在demoDriver.h中声明的函数的定义。在parse函数中，先通过scan_begin()函数进行词法分析，再声明一个demoParser类型的对象parser，进而调用此对象的函数进行语法分析，最后结束扫描。

 ## 1-2

在Scanner.ll文件中加入形参为 (int argc, char *argv[]) 的main函数，并在Parser.yy的FuncDef中添加main的相应文法规则。

