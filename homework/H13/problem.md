## 目录

```
	|problem.md
	|test/
		|test1/
			|test.c
			|test.s
			|test.o
			|test
		|test2/
			|test2.c
			|test2.s
	|img/
		|1.png
		|2.png
```



## 配置

```
Linux version 5.11.0-40-generic (buildd@lgw01-amd64-010) (gcc (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0, GNU ld (GNU Binutils for Ubuntu) 2.34) #44~20.04.2-Ubuntu SMP Tue Oct 26 18:07:44 UTC 2021
```



## 题目

1.**对于如下两个结构体，给出其内存所占字节大小并分析原因**

```
struct node1{
    int i1;
    char c;
    short s;
    int i2;
};

struct node2{
    int i1;
    char c;
    int i2;
    short s;
};
```

**考察的知识点：字节对齐**

解答：

由于字节的对齐，第一个结构体占12字节，第二个结构体占16字节

```
int main(){
    struct node1 n1;
    struct node2 n2;
    printf("%p,%p,%p,%p\n", &n1.i1, &n1.c, &n1.s, &n1.i2);
    printf("%p,%p,%p,%p\n", &n2.i1, &n2.c, &n2.s, &n2.i2);
    printf("%ld,%ld\n", sizeof(n1), sizeof(n2));
}
```

对于此test.c文件，用gcc编译

![1](.\img\1.png)



<img src=".\img\2.png" alt="2" style="zoom:50%;" />

对于char类型数据，按1字节进行对齐；对于short类型数据，按2字节进行对齐；对于int类型数据，按4字节进行对齐

故对于n1，79处不存放short类型的数据s，s存放在地址7a处。

对于n2，由于i2按4字节对齐，故i2不会存放在d后面。



2.**编译如下程序，得到汇编代码，看看你的编译器是否做了优化，如果没有，说明可以怎样优化**

```
int a = 3;
int b = a;
int c = b + 4;
```

**考察的知识点：代码优化**

解答：

对 test/test2.c用gcc编译 : `gcc -S test2.c -o test2.s`，得到汇编代码test2.s，以下为部分代码

```
1 main:
2 .LFB0:
3 	.cfi_startproc
4 	endbr64
5 	pushq	%rbp
6 	.cfi_def_cfa_offset 16
7	.cfi_offset 6, -16
8	movq	%rsp, %rbp
9	.cfi_def_cfa_register 6
10	movl	$3, -12(%rbp)
11	movl	-12(%rbp), %eax
12	movl	%eax, -8(%rbp)
13	movl	-8(%rbp), %eax
14	addl	$4, %eax
15	movl	%eax, -4(%rbp)
16	movl	$0, %eax
17	popq	%rbp
18	.cfi_def_cfa 7, 8
19	ret
20	.cfi_endproc
```

可以看出，第12、13行的代码存在冗余，并未对其做出优化。

通过第11行代码`movl	-12(%rbp), %eax`，可以看出-12(%rbp)中的内容a已经放入了eax，对于c的赋值，只需`addl	$4, %eax`，再将结果存入c即可，故可以将第13行代码删除。

