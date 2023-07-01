# 1

* 知识点：预处理器、内联

C/C++中，增加了 `inline`关键字的函数称为“内联函数”。内联函数和普通函数的区别在于：当编译器处理调用内联函数的语句时，会尝试不采用函数调用的形式，而是尝试直接将整个函数体的代码插人调用语句处.

## (1)

> 如果一个C/C++项目涉及到多个文件，通常的做法是，将函数声明放在.h中。将不建议将函数定义放在.cpp文件中？

编译器将每个.cpp文件当做一个编译单元。预编译阶段#include的作用是将所包含的文件复制到#include的位置，相当于是个展开为一个文件的宏。如果把函数定义放在头文件，则这个函数定义也会被复制到#include的位置。这个头文件被多次包含，则一个编译单元中会有多个该函数的定义，出现函数重复定义的错误。

## (2)

> `inline`函数的定义是否也应该遵循(1)中的原则？

`inline`函数的定义应当直接放在头文件中，因为内联函数如果要在调用点展开，编译器必须能够知道内联函数的定义。

例如，对于这样三个文件：

main.cpp

```c++
#include"1.h"
int main() {
    return fun();
}
```

1.h

```c++
inline int fun();
```

1.cpp

```c++
inline int fun()
{
    return 1;
}
```

使用`g++ 1.cpp main.cpp  -o main`进行编译，会报出如下error：

```
In file included from main.cpp:1:
1.h:1:12: warning: inline function ‘int fun()’ used but never defined
    1 | inline int fun();
      |            ^~~
/usr/bin/ld: /tmp/cc3AfgC5.o: in function `main':
main.cpp:(.text+0x9): undefined reference to `fun()'
collect2: error: ld returned 1 exit status
```

编译器将每个.cpp文件当做一个编译单元。处理main.cpp时，首先将头文件1.h的内容`inline int fun()`放入main中，编译阶段遇到`fun`，此时`fun`的定义在`1.cpp`中，不在当前的编译单元中，因此编译器不能看到该函数的定义，不能在调用点展开，所以报错。

因此，应该将添加了`inline`关键字的函数的定义放在头文件中：

1_.h

```c++
inline int fun()
{
    return 1;
} 
```

main.cpp

```c++
#include"1_.h"
int main() {
    return fun();
}
```

这样修改后，执行`g++ main.cpp  -o main`没有问题。

# 2

* 知识点：类型检查、存储分配、常量传播

## (1)

> wrong.cpp：
>
> ```c++
> #include<iostream>
> int main() {
>     const int a = 100;
>     a=200;
> }
> ```
>
> 上面的代码能否通过编译，为什么？编译器在什么阶段发现问题？

不能通过编译，执行`g++ wrong.cpp -o wrong`，得到如下error：

```
wrong.cpp: In function ‘int main()’:
wrong.cpp:4:6: error: assignment of read-only variable ‘a’
    4 |     a=200;
      |     ~^~~~
```

编译器在类型检查时，发现给常量类型的`a`赋值，所以报错。 

## (2)

> 用一个int*指针`b`指向`const int a`，尝试通过`b`修改`a`所在的内存空间的值。
>
> main.cpp：
>
> ```c++
> #include<iostream>
> int main() {
>     const int a = 100;
>     int * b = (int *)&a;
>     *b = 200;
>     printf("%d%d",a,*b);
> }
> ```
>
> 在我的本地环境下，该代码能够通过编译，但运行结果为100200，下面是源程序的部分汇编代码（完整代码见\2\main.s），根据汇编代码解释为什么输出的两个值不相同？
>
> ```assembly
> movl    $100, -20(%rbp)
> leaq   -20(%rbp), %rax
> movq   %rax, -16(%rbp)
> movq   -16(%rbp), %rax
> movl   $200, (%rax)
> movq   -16(%rbp), %rax
> movl   (%rax), %eax
> movl   %eax, %edx
> movl   $100, %esi
> leaq   .LC0(%rip), %rdi
> movl   $0, %eax
> call   printf@PLT
> ```

在栈中给`a`分配的空间为 `-20(%rbp)`，给`b`分配的空间为`-16(%rbp)`。

```assembly
leaq   -20(%rbp), %rax
movq   %rax, -16(%rbp)
movq   -16(%rbp), %rax
movl   $200, (%rax)
```

上面四条汇编代码将`a`的地址取出赋给`b`，然后将200赋值给`content(b)`，因此`a`所在的内存内容被修改成了200，所以输出的`*b`为200。

但在调用`printf`时，并未从`a`分配的内存中取值放到`printf`的参数中，而是直接将立即数100放入。

```
movl   $100, %esi
```

因此输出的第一个数仍为100，即使`a`分配的内存内容已经被改变了。也就是说，编译器在编译阶段就将常量表达式的值确定并替换好了，而不是在执行时计算。

# 环境

* 机器配置：x64架构 Intel Core i7-10870H 
* 操作系统：Ubuntu 20.04
* 编译器：GCC 9.3.0

# test目录

\1: 第一题中第二第三问的源代码

* 1.h
* 1.cpp
* 1_.h
* main.cpp

\2：第二题中的源代码

* wrong.cpp
* main.cpp
* main.s

