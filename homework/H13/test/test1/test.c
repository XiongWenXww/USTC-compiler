#include<stdio.h>

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

int main(){
    struct node1 n1;
    struct node2 n2;
    printf("%p,%p,%p,%p\n", &n1.i1, &n1.c, &n1.s, &n1.i2);
    printf("%p,%p,%p,%p\n", &n2.i1, &n2.c, &n2.s, &n2.i2);
    printf("%ld,%ld\n", sizeof(n1), sizeof(n2));
}
