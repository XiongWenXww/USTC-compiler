#include <iostream>
#include <typeinfo>
using namespace std;

class A {
public:
    void fun() { cout << "base fun(no virtual function)" << endl; }
};

class AA :public A {
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

void printTypeinfo1(const char* n, const A* pb)
{
    cout << "typeid(*" << n << ") is " << typeid(*pb).name() << endl;
}

void printTypeinfo2(const char* n, const B* pb)
{
    cout << "typeid(*" << n << ") is " << typeid(*pb).name() << endl;
}

//测试类类型及其指针类型
void test2() {
    A a;
    AA aa;
    B b;
    BB bb;

    A* pa = new A;
    A* paa = new AA;
    B* pb = new B;
    B* pbb = new BB;

    cout << "基类A中没有虚函数:" << endl;
    printTypeinfo1("&a", &a);
    printTypeinfo1("&aa", &aa);
    printTypeinfo1("pa", pa);
    printTypeinfo1("paa", paa);
    //*paa，由于此时的基类不具有多态性，因而*paa将会采用编译期类型来计算，编译期*paa是A对象，故typeid(*paa).name为A

    cout << "typeid(pa) is " << typeid(pa).name() << endl;

    cout << "typeid(paa) is " << typeid(paa).name() << endl;
    //对于paa，由于paa是A*类型的指针，因此typeid(paa).name为A*

    cout << endl << "基类B中有虚函数:" << endl;
    printTypeinfo2("&b", &b);
    printTypeinfo2("&bb", &bb);
    printTypeinfo2("pb", pb);

    printTypeinfo2("pbb", pbb);
    //对于*pbb，由于基类B有虚函数，并且构成了多态性，故typeid(*pbb).name实际为*pbb指向的派生类对象BB

    cout << "typeid(pb) is " << typeid(pb).name() << endl;

    cout << "typeid(pbb) is " << typeid(pbb).name() << endl;
    //对于paa，由于pbb是B*类型的指针，因此typeid(pbb).name为B*
}

//基本数据类型及其指针类型
void test1()
{
    //基本数据类型
    bool b = true;
    char c = 'a';
    short s = 5;
    int i = 5;
    long l = 5;
    float f = 1.0;
    double d = 1.0;


    // get the type info
    const type_info& ti1 = typeid(b);
    const type_info& ti2 = typeid(c);

    const type_info& ti3 = typeid(s);
    const type_info& ti4 = typeid(i);
    const type_info& ti5 = typeid(l);

    const type_info& ti6 = typeid(f);
    const type_info& ti7 = typeid(d);


    cout << "ti1 is of type " << ti1.name() << endl;
    cout << "ti2 is of type " << ti2.name() << endl;
    cout << "ti3 is of type " << ti3.name() << endl;
    cout << "ti4 is of type " << ti4.name() << endl;
    cout << "ti5 is of type " << ti5.name() << endl;
    cout << "ti6 is of type " << ti6.name() << endl;
    cout << "ti7 is of type " << ti7.name() << endl;


    //指针类型

    int* pi = &i;
    double* pd = &d;

    const type_info& ti8 = typeid(pi);
    const type_info& ti9 = typeid(pd);


    // print the types

    cout << "ti8 is of type " << ti8.name() << endl;
    cout << "ti9 is of type " << ti9.name() << endl;

}

int main()
{
    cout << "测试基本数据类型及其指针类型:" << endl;
    test1();

    cout << endl << "测试类类型及其指针类型:" << endl << endl;
    test2();
    return 0;
}