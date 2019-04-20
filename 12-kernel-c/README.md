*你应该先google：C,ojbect code, linker, disassemble*
**目标：用C语言做底层汇编语言做的那些事**

## [Compile](https://github.com/cfenollosa/os-tutorial/tree/master/12-kernel-c#compile)

我们得研究研究C编译器如何编译代码，并且比较它与汇编器生成的机器码两者是否有所差别。

写一个只有一个简单函数的程序`function.c`。打开[function.c](https://github.com/cfenollosa/os-tutorial/blob/master/12-kernel-c/function.c)看一眼。
```
int my_function() {
    return 0xbaba;
}
```


编译与系统无关的代码时需要加`-ffreestanding`:

`i386-elf-gcc -ffreestanding -c function.c -o function.o`

研究研究编译器生成的机器码:

`i386-elf-objdump -d function.o`

```
function.o:     file format elf32-i386

Disassembly of section .text:

00000000 <my_function>:
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	b8 ba ba 00 00       	mov    $0xbaba,%eax
   8:	5d                   	pop    %ebp
   9:	c3                   	ret    
```

是不是有点似曾相识？

## [Link](https://github.com/cfenollosa/os-tutorial/tree/master/12-kernel-c#link)


最后，如果要生成二进制文件，我们需要使用 `linker`，中文也叫链接器。在这个时候，我们一定要搞明白高级语言是如何调用函数的标签的。其实我们不知道，程序在内存中的偏移地址(offset)是多少。我们将offset定为`0x0`并且使用`binary(二进制)`格式生成二进制码，而不包含任何标签或链接器需要的数据。

`i386-elf-ld -o function.bin -Ttext 0x0 --oformat binary function.o`

*注意：会有一个 `warning`(i386-elf-ld: warning: cannot find entry symbol _start; defaulting to 0000000000000000)，淡定的忽略掉它！*


使用`xxd`命令查看两个文件，我们发现`.bin`文件是机器码，而`.o`文件包含很多调试信息。
```bash
geyu@geyu-All-Series:~/workdir/os-dev/os-tutorial/12-kernel-c$ xxd function.bin 
00000000: 5589 e5b8 baba 0000 5dc3 0000 1400 0000  U.......].......
00000010: 0000 0000 017a 5200 017c 0801 1b0c 0404  .....zR..|......
00000020: 8801 0000 1c00 0000 1c00 0000 d4ff ffff  ................
00000030: 0a00 0000 0041 0e08 8502 420d 0546 c50c  .....A....B..F..
00000040: 0404 0000            
```

```
geyu@geyu-All-Series:~/workdir/os-dev/os-tutorial/12-kernel-c$ xxd function.o
00000000: 7f45 4c46 0101 0100 0000 0000 0000 0000  .ELF............
00000010: 0100 0300 0100 0000 0000 0000 0000 0000  ................
00000020: cc00 0000 0000 0000 3400 0000 0000 2800  ........4.....(.
00000030: 0a00 0700 5589 e5b8 baba 0000 5dc3 0047  ....U.......]..G
00000040: 4343 3a20 2847 4e55 2920 342e 392e 3100  CC: (GNU) 4.9.1.
00000050: 1400 0000 0000 0000 017a 5200 017c 0801  .........zR..|..
00000060: 1b0c 0404 8801 0000 1c00 0000 1c00 0000  ................
00000070: 0000 0000 0a00 0000 0041 0e08 8502 420d  .........A....B.
00000080: 0546 c50c 0404 0000 002e 7379 6d74 6162  .F........symtab
00000090: 002e 7374 7274 6162 002e 7368 7374 7274  ..strtab..shstrt
000000a0: 6162 002e 7465 7874 002e 6461 7461 002e  ab..text..data..
000000b0: 6273 7300 2e63 6f6d 6d65 6e74 002e 7265  bss..comment..re
000000c0: 6c2e 6568 5f66 7261 6d65 0000 0000 0000  l.eh_frame......
000000d0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
000000e0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
000000f0: 0000 0000 1b00 0000 0100 0000 0600 0000  ................
00000100: 0000 0000 3400 0000 0a00 0000 0000 0000  ....4...........
00000110: 0000 0000 0100 0000 0000 0000 2100 0000  ............!...
00000120: 0100 0000 0300 0000 0000 0000 3e00 0000  ............>...
00000130: 0000 0000 0000 0000 0000 0000 0100 0000  ................
00000140: 0000 0000 2700 0000 0800 0000 0300 0000  ....'...........
00000150: 0000 0000 3e00 0000 0000 0000 0000 0000  ....>...........
00000160: 0000 0000 0100 0000 0000 0000 2c00 0000  ............,...
00000170: 0100 0000 3000 0000 0000 0000 3e00 0000  ....0.......>...
00000180: 1200 0000 0000 0000 0000 0000 0100 0000  ................
00000190: 0100 0000 3900 0000 0100 0000 0200 0000  ....9...........
000001a0: 0000 0000 5000 0000 3800 0000 0000 0000  ....P...8.......
000001b0: 0000 0000 0400 0000 0000 0000 3500 0000  ............5...
000001c0: 0900 0000 0000 0000 0000 0000 f402 0000  ................
000001d0: 0800 0000 0800 0000 0500 0000 0400 0000  ................
000001e0: 0800 0000 1100 0000 0300 0000 0000 0000  ................
000001f0: 0000 0000 8800 0000 4300 0000 0000 0000  ........C.......
00000200: 0000 0000 0100 0000 0000 0000 0100 0000  ................
00000210: 0200 0000 0000 0000 0000 0000 5c02 0000  ............\...
00000220: 8000 0000 0900 0000 0700 0000 0400 0000  ................
00000230: 1000 0000 0900 0000 0300 0000 0000 0000  ................
00000240: 0000 0000 dc02 0000 1800 0000 0000 0000  ................
00000250: 0000 0000 0100 0000 0000 0000 0000 0000  ................
00000260: 0000 0000 0000 0000 0000 0000 0100 0000  ................
00000270: 0000 0000 0000 0000 0400 f1ff 0000 0000  ................
00000280: 0000 0000 0000 0000 0300 0100 0000 0000  ................
00000290: 0000 0000 0000 0000 0300 0200 0000 0000  ................
000002a0: 0000 0000 0000 0000 0300 0300 0000 0000  ................
000002b0: 0000 0000 0000 0000 0300 0500 0000 0000  ................
000002c0: 0000 0000 0000 0000 0300 0400 0c00 0000  ................
000002d0: 0000 0000 0a00 0000 1200 0100 0066 756e  .............fun
000002e0: 6374 696f 6e2e 6300 6d79 5f66 756e 6374  ction.c.my_funct
000002f0: 696f 6e00 2000 0000 0202 0000            ion. .......
```
## [Decompile](https://github.com/cfenollosa/os-tutorial/tree/master/12-kernel-c#decompile)
好奇不好奇机器码对应着怎样的汇编代码？
`ndisasm -b 32 function.bin`

## [More](https://github.com/cfenollosa/os-tutorial/tree/master/12-kernel-c#more)


强烈建议多谢几个小程序，就像以下这样：
*   Local variables `localvars.c`
*   Function calls `functioncalls.c`
*   Pointers `pointers.c`


仔细看一看[os-dev.pdf](http://www.cs.bham.ac.uk/~exr/lectures/opsys/10_11/lectures/os-dev.pdf)相关的章节，编译并反汇编上面的代码，对比研究它们的机器码。最后回答这个问题，`pointers.c`编译后为什么与我们预期不一致？"Hello"的ASCII码`0x48656c6c6f`在哪里？


[THE ORIGIN ARTICALE IN GITHUB:](https://github.com/cfenollosa/os-tutorial/blob/master/12-kernel-c/README.md)[^1]
------------------
*Concepts you may want to Google beforehand: C, object code, linker, disassemble*

**Goal: Learn to write the same low-level code as we did with assembler, but in C**

## [Compile](https://github.com/cfenollosa/os-tutorial/tree/master/12-kernel-c#compile)

Let's see how the C compiler compiles our code and compare it to the machine code generated with the assembler.

We will start writing a simple program which contains a function, `function.c`. Open the file and examine it.

To compile system-independent code, we need the flag `-ffreestanding`, so compile `function.c` in this fashion:

`i386-elf-gcc -ffreestanding -c function.c -o function.o`

Let's examine the machine code generated by the compiler:

`i386-elf-objdump -d function.o`

Now that is something we recognize, isn't it?

## [](https://github.com/cfenollosa/os-tutorial/tree/master/12-kernel-c#link)Link

Finally, to produce a binary file, we will use the linker. An important part of this step is to learn how high level languages call function labels. Which is the offset where our function will be placed in memory? We don't actually know. For this example, we'll place the offset at `0x0` and use the `binary` format which generates machine code without any labels and/or metadata

`i386-elf-ld -o function.bin -Ttext 0x0 --oformat binary function.o`

*Note: a warning may appear when linking, disregard it*

Now examine both "binary" files, `function.o` and `function.bin` using `xxd`. You will see that the `.bin` file is machine code, while the `.o` file has a lot of debugging information, labels, etc.

## [](https://github.com/cfenollosa/os-tutorial/tree/master/12-kernel-c#decompile)Decompile

As a curiosity, we will examine the machine code.

`ndisasm -b 32 function.bin`

## [](https://github.com/cfenollosa/os-tutorial/tree/master/12-kernel-c#more)More

I encourage you to write more small programs, which feature:

*   Local variables `localvars.c`
*   Function calls `functioncalls.c`
*   Pointers `pointers.c`

Then compile and disassemble them, and examine the resulting machine code. Follow the os-guide.pdf for explanations. Try to answer this question: why does the disassemblement of `pointers.c` not resemble what you would expect? Where is the ASCII `0x48656c6c6f` for "Hello"?

>参考资料：
>[1]:https://github.com/cfenollosa/os-tutorial/blob/master/12-kernel-c

版权注明：本文所有涉及到：`https://github.com/cfenollosa/os-tutorial/` git仓库的内容，全部对应以下开源协议声明：
[BSD 3-Clause License 
 Copyright (c) 2018, 
Carlos Fenollosa](https://github.com/cfenollosa/os-tutorial/blob/master/LICENSE)

