### dynamic_cast

**阅读并运行程序`src/step3/dynamic_cast.cpp`。回答以下问题：**

1. **`BasicBlock::print`函数62-73行的 for 循环在整个程序中的作用是什么？这段代码的什么地方用到了 RTTI 机制？**

   遍历链表values并分别计算能强制转换为UnaryInst\*、BinaryInst\*的类的个数。基类类型指针不可转换为派生类类型指针。

2. **如果没有 RTTI 机制（部分库会在编译时加上`fno-rtti`选项，因为 RTTI 会带来一定的开销），为了保持功能的一致性，应该如何实现`BasicBlock::print`函数？请在 `answer.md` 中简要描述你的思路（提示：利用 `name` 属性）。**

   由于基类类型指针不可转换为派生类类型指针，故可对list中的元素的类型进行判断，元素v的类型也就是v->getName()，判断其是否等于UnaryInst或BinaryInst，若相等，则再对应的计数器上加一，否则抛出absort()异常。

3. **在第二问的前提下，如果 `Instruction`有很多个子类（不同的指令），而且以后还会扩充现在不知道叫什么名字的新指令（这里的新指令是`Instruction`的直接子类），应该怎么实现`BasicBlock::print` 函数？请在 `answer.md` 中简要描述你的思路并在`static_cast.cpp`中实现，要求输出与第一问一致（提示：可以对该程序进行任何修改）。**

   与第二问类似，判断list中的元素的类型，及判断v->getName是否等于其子类的名字，若相等，则再对应的计数器上加一，否则抛出absort()异常。

   ### typeid

   **阅读并运行程序`src/step3/typeid.cpp`。回答以下问题：**

   1. **编译运行该程序并解释输出。**

      输出：

      class Value *
      class BasicBlock
      class Instruction *
      class BinaryInst

      因为v是Value类型的指针，故typeid(v).name==class Value*，而对于\*v，由于Value类具有多态性，故在计算typeid(\*v).name时是根据运行时v实际指向的对象的类型进行计算的，故typeid(\*v).name\==class BasicBlock。同理，由于多态性，typeid(inst).name\==class Instruction\*，typeid(\*inst).name\==class BinaryInst。

      

   2. **当去掉`Instruction`类的父类`Value`（删除`: public Value`）时，程序的输出是什么？对输出进行解释。**

      输出：

      class Value *
      class BasicBlock
      class Instruction *
      class Instruction

      由于BasicBlock仍是Value的子类，故typeid(v)、typeid(*v)的结果不变，而Instruction不再是Value的子类，且Instruction中没有虚函数，不能构成多态性，故\*inst采用编译时期来计算，故为class Instruction，而inst本身为Instruction\*类型的指针，故typeid(inst).name()\==class Instruction *。

