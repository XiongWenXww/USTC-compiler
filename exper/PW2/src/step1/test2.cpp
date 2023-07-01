#include <iostream>
#include <typeinfo>
using namespace std;

class A {
public:
    void fun() { cout << "base fun(no virtual function)" << endl; }
};

class AA : public A {
public:
    void fun() { cout << "derived fun(no virtual function)" << endl; }
};

class B {
public:
    virtual void fun() { cout << "base fun" << endl; }
};

class BB : public B {
public:
    void fun() { cout << "derived fun" << endl; }
};

void printTypeinfo(const char* n, const B* pb)
{
    cout << "typeid(*" << n << "pb) is " << typeid(*pb).name() << endl;
}

int main()
{
    /**************基本数据类型的强制类型转换******************/
    short m = 100;
    int n = static_cast<int>(m);  //整型提升
    int n = 100;
    char ch = static_cast<char>(n);  //窄转换
    int* p1 = static_cast<int*>(malloc(10 * sizeof(int)));  //将void指针转换为具体类型指针
    void* p2 = static_cast<void*>(p1);  //将具体类型指针转换为void指针

    // double* p3 = static_cast<double*>(p1);  //不能在两个具体类型的指针之间进行转换
    // p3 = static_cast<float*>(100);  //不能将整数转换为指针类型

    AA* paa = new AA;
    A* pa = new AA;


    B b;
    BB d;
    BB* pbb = new BB;
    B* pb = new BB;

    /**************基类中不含虚函数的强制类型转换******************/
    A* p2 = dynamic_cast<A*>(paa);  // 向上转型


    A* p1 = dynamic_cast<A*>(pa);
    // AA* p2 = dynamic_cast<AA*>(pa);  不是多态类，无法进行向下转型


    /**************基类中含虚函数的强制类型转换*******************/
    B* p3 = dynamic_cast<B*>(pbb);  // 向上转型

    BB* p4 = dynamic_cast<BB*>(pb);      // 向下转型
    // 基类含有虚函数，pb实际指向的是派生类对象，故可转型成功

    B* p5 = dynamic_cast<B*>(pb);

    return 0;
}