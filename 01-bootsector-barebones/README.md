*你需要自己去查: assembler, BIOS*

**目标：创建一个可以被BIOS识别为可启动介质的文件** 

我们要亲自写一个引导扇区，你会发现这很爽。

理论：
------

计算机启动时，BIOS会启动，它并不知道如何启动操作系统，它会把启动的
工作交给引导扇区中的指令。因此，引导扇区需要放在一个约定俗成的标准
位置上。这个位置就在磁盘最开始的位置 (cylinder 0, head 0, sector 0) 开始
的512字节。

为了确认这个磁盘是可启动的，BIOS会检查启动引导扇区的第511与512字节
处是否是“0xAA55”。

This is the simplest boot sector ever:
以下是一个简单例子：


```
e9 fd ff 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[ 29 more lines with sixteen zero-bytes each ]
00 00 00 00 00 00 00 00 00 00 00 00 00 00 55 aa
```
如果是在windows系统上，也可以用BZ这个软件直接编辑一个二进制文件，
保存为.bin文件
![BZ-bootbin.png](https://upload-images.jianshu.io/upload_images/9792557-97b1c7c38c538816.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

上面文件的内容，几乎都是0，并由16位的‘0xAA55’作为结尾（要注意X86是小端机）。
开头的三字节使程序进入无限循环。

最简单的引导扇区
------------------------
你可以像上面，用二进制编辑器写512个字节，也可以写一个
非常简单的汇编文件。

```nasm
; Infinite loop (e9 fd ff)
loop:
    jmp loop 

; Fill with 510 zeros minus the size of the previous code
times 510-($-$$) db 0
; Magic number
dw 0xaa55 
```

编译:
`nasm -f bin boot_sect_simple.asm -o boot_sect_simple.bin`

> 注意: 如果出现了错误，请重新阅读00章。

我知道你现在一定想看看，这个系统是否能够运行：

`qemu boot_sect_simple.bin`

> 在一些系统上，你可能要这样运行`qemu-system-x86_64 boot_sect_simple.bin` 如果出现 SDL error, 试试添加 --nographic 与 --curses flag(s)的组合.

你会看到打开的窗口仅仅显示了“Booting from Hard Disk...”。
我想知道，上一次是何时？你盯着一个死循环洋洋得意！;-)

windows 上你需要把那个.bin文件用FloppyWriter这个软件写入到一个img文件中，然后用vmware
创建一个未装系统的虚拟机，添加软盘硬件，向软盘中载入上面的img文件，然后启动虚拟机吧，
你会看到一个什么字都没有的死循环，那同样代表你成功了，如果没有成功，会出现未发现操作系统的
提示。
至于vmware的操作请自行百度，未来的学习道路中会出现各种各样的困难，vmware这样的商业软件已经
是友好至极了。

注，本文翻译自github上的开源项目https://github.com/cfenollosa/os-tutorial,其中windows部分由
本人添加，利于集思广益，但并不推荐使用windows系统学习后面的内容。
