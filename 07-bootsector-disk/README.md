[lesson 7] (https://github.com/cfenollosa/os-tutorial/tree/master/07-bootsector-disk)

*你可能需要google一下：hard disk, cylinder, head, sector, carry bit*


**目标：令引导区加载硬盘数据，从而启动内核**


我们的系统不可能只有512字节那么小，所以肯定需要从硬盘里读数据，以启动内核。


幸运的是，我们不用自己去写硬盘驱动控制盘片转动与停止，只需要调用BIOS的例程，就像之前将字符打印到屏幕上一样。这样做：赋值`0x02`到`al`(别的寄存器存储有关cylinder, head and sector的信息)，然后调用`int 0x13` 中断。

13中断可以查阅 [a detailed int 13h guide here](http://stanislavs.org/helppc/int_13-2.html)。

这里，我们第一次遇见*carry bit*,它在寄存器计算中表示数据超出寄存器的存储范围，其实就是进位，比如寄存器最大能够存储256这个数字(1111 1111)，如果再加一个1，就变为了257(1 0000 0000)，此时`carry bit`中就会是1，寄存器中是0。

```source-assembly
mov ax, 0xFFFF
add ax, 1 ; ax = 0x0000 and carry = 1
```

`carry bit` 不能直接访问，只能作为别的操作指令判断依据，比如 `jc` (当进位被设置时跳转)。

BIOS将`al`的值设置为需要读取的扇区数，应该通常会比较它们的值是否一致。

## [Code](https://github.com/cfenollosa/os-tutorial/tree/master/07-bootsector-disk#code)

仔细看看 [boot_sect_disk.asm](https://github.com/cfenollosa/os-tutorial/blob/master/07-bootsector-disk/boot_sect_disk.asm)中读取硬盘的指令与流程。

[boot_sect_main.asm](https://github.com/cfenollosa/os-tutorial/blob/master/07-bootsector-disk/boot_sect_main.asm)中设置了读取硬盘(`disk_load`)所需的参数。注意我们写了一些不属于引导区的数据。

启动引导区实际上是hdd 0 的 head 0 的 cylinder 0 的 sector 1。

所以，在512字节后的512字节数据就是hdd 0 的 head 0 的 cylinder 0 的 sector 2。

`main`程序写入了一些简单数据，然后让引导区读取它们。

**注意：如果一直报错并且代码没什么问题，请确保qemu的启动磁盘的参数是正确的，并且`dl`设置的是正确的。**

BIOS 启动引导程序前，会将启动盘的编号写入`dl`中，不过当我从hdd启动qemu时遇到了一些问题

这里有两个解决办法：
1. `qemu -fda boot_sect_main.bin` ，加入`-fda`使`dl`的值为`0x00` ，貌似可以工作。
2. `qemu boot_sect_main.bin -boot c`，`-boot`会将`dl`设置为`0x80`，让引导程序读取数据。
