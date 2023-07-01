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
    /**************�����������͵�ǿ������ת��******************/
    short m = 100;
    int n = static_cast<int>(m);  //��������
    int n = 100;
    char ch = static_cast<char>(n);  //խת��
    int* p1 = static_cast<int*>(malloc(10 * sizeof(int)));  //��voidָ��ת��Ϊ��������ָ��
    void* p2 = static_cast<void*>(p1);  //����������ָ��ת��Ϊvoidָ��

    // double* p3 = static_cast<double*>(p1);  //�����������������͵�ָ��֮�����ת��
    // p3 = static_cast<float*>(100);  //���ܽ�����ת��Ϊָ������

    AA* paa = new AA;
    A* pa = new AA;


    B b;
    BB d;
    BB* pbb = new BB;
    B* pb = new BB;

    /**************�����в����麯����ǿ������ת��******************/
    A* p2 = dynamic_cast<A*>(paa);  // ����ת��


    A* p1 = dynamic_cast<A*>(pa);
    // AA* p2 = dynamic_cast<AA*>(pa);  ���Ƕ�̬�࣬�޷���������ת��


    /**************�����к��麯����ǿ������ת��*******************/
    B* p3 = dynamic_cast<B*>(pbb);  // ����ת��

    BB* p4 = dynamic_cast<BB*>(pb);      // ����ת��
    // ���ຬ���麯����pbʵ��ָ�������������󣬹ʿ�ת�ͳɹ�

    B* p5 = dynamic_cast<B*>(pb);

    return 0;
}