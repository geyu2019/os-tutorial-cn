*你可能需要google这几个知识点： control structures, function calling, strings*

**目标: 使用汇编编写基本的逻辑（循环、函数）**

越来越接近目标中的启动引导区了。

在https://github.com/cfenollosa/os-tutorial中的lesson 7中，我们会从硬盘中读取引导数据，而后便进入启动内核的步骤。不过目前我们还需要做些必要的准备：练习写一些控制结构、函数调用，读取字符串的代码。

## [Strings](https://github.com/cfenollosa/os-tutorial/tree/master/05-bootsector-functions-strings#strings)


像写入字节一样写入字符串，用空字节（像C语言一样）标识字符串的结尾。


```source-assembly
mystring:
    db 'Hello, World', 0
```


注意，被引号包围的文字会被编译器转义为ASCII码（'0' == `0x30`），而0就是`0x00`，代表空字节。
## [Control structures](https://github.com/cfenollosa/os-tutorial/tree/master/05-bootsector-functions-strings#control-structures)

我们之前使用过`jmp $`制造一个无限循环。

汇编语言的跳转位置由伪指令标识，例如：

```source-assembly
cmp ax, 4      ; if ax = 4
je ax_is_four  ; do something (by jumping to that label)
jmp else       ; else, do another thing
jmp endif      ; finally, resume the normal flow

ax_is_four:
    .....
    jmp endif

else:
    .....
    jmp endif  ; not actually necessary but printed here for completeness

endif:
```

用高级语言的语法思考一下上面程序的逻辑，再将它们用汇编语言的方式表达出来。

有很多判断`jmp`的方式，比如if equal,if less than。有时并不是很直观，但google一下总归会很快明白。

## [Calling functions](https://github.com/cfenollosa/os-tutorial/tree/master/05-bootsector-functions-strings#calling-functions)

你可能会认为调用函数就是跳转到对应label。

但处理参数是个棘手的事，需要两步：

1.程序员需要确定传递信息的的那个寄存器或者内存地址。

2.编写代码使程序通用并且没有副作用

步骤一简单，我们就让`al`（实际上使`ax`）来传递参数吧。

```source-assembly
mov al, 'X'
jmp print
endprint:

...

print:
    mov ah, 0x0e  ; tty code
    int 0x10      ; I assume that 'al' already has the character
    jmp endprint  ; this label is also pre-agreed
```

代码流程简单直接。`print`函数最后总会跳转到`endprint`，但是如果别的函数需要调用它呢？可以看出来，这段代码无法复用。

正确的解决方案会改进两个地方：

*   返回的地址是调用前便保存好的。

*   保存所有寄存器状态，使得子函数可以更改它们的状态。

CPU提供了保存返回地址的功能，不需要用`jmp`跳转到子例程，只需要用`call`来调用、`ret`来返回。

有一组特殊的命令可以使用堆栈保存或恢复寄存器的状态：`pusha` 可以自动保存所有寄存器状态，`popa`用于最终恢复寄存器调用函数前的状态，

## [Including external files](https://github.com/cfenollosa/os-tutorial/tree/master/05-bootsector-functions-strings#including-external-files)

我假设你是一个程序员，所以不再赘述程序源码组织的重要性。

语法如下：

```source-assembly
%include "file.asm"
```

## [Printing hex values](https://github.com/cfenollosa/os-tutorial/tree/master/05-bootsector-functions-strings#printing-hex-values)

下一节课，我们会从磁盘中读取数据，所以需要一个确认读取数据是否正确的途径，`boot_sect_print_hex.asm` 与`boot_sect_print.asm`配合，可以打印输入为16进制数字的文本，而不是ASCII码。例如输入0X12FE ，输出为'0X12FE'，
虽然看起来一样，但后者的实际ASCII码对应的16进制数为 '0'=0x30 'X'=0x58 '1'=0x31 '2'=0x32 'F'=0x46 'E'=0x45

## [Code!](https://github.com/cfenollosa/os-tutorial/tree/master/05-bootsector-functions-strings#code)

让我们回到代码，文件`boot_sect_print.asm` 是被main文件 通过`%include`包含进来的子文件。它用一个循环将字节打印到屏幕上，而后通过`print_nl`函数打印换行符`\n`，`\n`其实有两个字节，换行符`oX0A`和回车`0X0D`，试一试如果删掉回车会有什么影响！

如上所属，`boot_sect_print_hex.asm`可以打印


主文件 `boot_sect_main.asm`载入了一对字符串与几个字节的数据，调用了`print` 与 `print_hex` 后进入死循环，如果前面的文章都读了，这里很容易理解。
