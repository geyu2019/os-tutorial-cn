[lesson 6](https://github.com/cfenollosa/os-tutorial/tree/master/06-bootsector-segmentation)
*你可能需要google这个概念：segmentation*

**目标: 学习16位实模式下的内存寻址**

如果非常了解segmentation，可以跳过这节课。

lesson3中我们用`[org]`定义了segmentation，其实它就是所有数据的偏移量。

CPU提供了几个特殊的寄存器：`cs`、`ds`、 `ss` 、 `es`，对应着代码段，数据段，堆栈以及其他段(用户指定)。

注意：它们由CPU隐式调用的，所以当你给`ds`赋值后，所有内存的访问都会以ds的值为偏移量。

进一步的说，计算真实地址并不能简单的将两个地址相加(地址与偏移量)，而是用`segment << 4 + address`这样的方式处理。比如如果`ds` 的值为 `0x4d`, 查询 `[0x20]` 地址的值实际上是查询 `0x4d0 + 0x20 = 0x4f0`。

理论讲的足够了，看一看代码，亲手试试。

注: 不能`mov`一个字面量到上面的寄存器，需要使用通用寄存器来`mov`。
