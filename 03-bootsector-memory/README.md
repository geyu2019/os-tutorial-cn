*在开始前，你可能需要google一下： memory offsets, pointers*

**目标: 学习计算机的内存空间是如何分配，如何管理的。**

请打开[ 这本书](
http://www.cs.bham.ac.uk/~exr/lectures/opsys/10_11/lectures/os-dev.pdf)<sup>1</sup>的14页 ，看看图中的内存布局。

这节课的目标就是了解引导区的内容被加载到内存的什么位置。

直接告诉你吧，BIOS将它放在`0X7C00`，随后CPU从这个位置开始运行指令，下面举一个例子，你会很容易明白！

我们想在屏幕上打印X，下面有4种不同的方式，让我们看看哪一个可行，为什么？

**打开这个文件[boot_sect_memory.asm](https://github.com/cfenollosa/os-tutorial/blob/master/03-bootsector-memory/boot_sect_memory.asm)**


首先，在标签`the_secret`处写入了'X'：
```nasm
the_secret:
    db "X"
```


然后，用不同的方法尝试访问`the_secret`：

1. `mov al, the_secret`
2. `mov al, [the_secret]`
3. `mov al, the_secret + 0x7C00`
4. `mov al, 2d + 0x7C00`, `2d`是X在引导区的实际位置(从引导区开头数的字节数，比如之前写了100个字节，`2d`开始的位置就是第101字节，由于实际中内存是从0开始计数，这个位置可能是101-1=100)。 

看看代码和注释


编译运行代码，会看到`1[2¢3X4X`,在1与2后面的是随机无意义的字符


如果你加入或者移除一些指令，记得重新计算X的偏移地址(offset)，将`0x2d`替换为新值。


请不要在完全明白引导区的偏移地址与内存地址的关系前，继续学后面的内容。

global offset
-----------------

由于给每个地址加上`0x7c00`非常不方便，汇编语言允许定义一个"global offset",所有指令中的地址都会自动加上这个global offset，使用org 来定义global offset。

```nasm
[org 0x7c00]
```

继续打开 [boot_sect_memory_org.asm](https://github.com/cfenollosa/os-tutorial/blob/master/03-bootsector-memory/boot_sect_memory_org.asm),简化了上面加上0x7c00的处理方式。
编译运行这个代码，能够看到org的作用。

下面是附加部分：
我们用nasm编译boot_sect_memory_org.asm。用hexdump查看二进制文本
```bash
nasm -f bin boot_sect_memory_org.asm   -o   boot_sect_memory_org.bin
hexdump boot_sect_memory_org.bin
``` 
得到
```
0000000 0eb4 31b0 10cd 2db0 10cd 32b0 10cd 2da0
0000010 cd7c b010 cd33 bb10 7c2d c381 7c00 078a
0000020 10cd 34b0 10cd 2da0 cd7c eb10 58fe 0000
0000030 0000 0000 0000 0000 0000 0000 0000 0000
*
00001f0 0000 0000 0000 0000 0000 0000 0000 aa55
0000200
```
然后用BZ编辑器，把上面的字节抄过来。

![bz47.png](https://upload-images.jianshu.io/upload_images/9792557-16de1a587a643cde.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


-----

[1] This whole tutorial is heavily inspired on that document. Please read the
root-level README for more information on that.
