#include<iostream>
int main() {
    const int a = 100;
    int * b = (int *)&a;
    *b = 200;
    printf("%d%d",a,*b);
}