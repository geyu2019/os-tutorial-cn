[lesson 11](https://github.com/cfenollosa/os-tutorial/tree/master/11-kernel-crosscompiler)[^1]


*你需要google:cross-compiler*

**目标：配置可编译32位内核的开发环境**


如果你用Mac，你应该立即着手做，如果使用别的系统可以再等几节课。不过，当用c语言开发时，你一定得有交叉编译环境。[为什么？](http://wiki.osdev.org/Why_do_I_need_a_Cross_Compiler%3F)

我会稍微修改以下这个[ 指南](http://wiki.osdev.org/GCC_Cross-Compiler).


## [Required packages](https://github.com/cfenollosa/os-tutorial/tree/master/11-kernel-crosscompiler#required-packages)


第一步，你需要`安装`需求的库。在linux上，用你的包管理软件。在Mac上， [install brew](http://brew.sh/)，然后使用`brew install`下载下面的包。 

*   gmp
*   mpfr
*   libmpc
*   gcc
在ubuntu 18 上安装 gmp mpfr libmpc :
```
cd /usr/local/src
sudo curl -O ftp://gcc.gnu.org/pub/gcc/infrastructure/gmp-4.3.2.tar.bz2

tar xf gmp-4.3.2.tar.bz2
cd gmp-4.3.2 
./configure
make
make install

sudo curl -O ftp://gcc.gnu.org/pub/gcc/infrastructure/mpc-0.8.1.tar.gz
...同上
sudo curl -O ftp://gcc.gnu.org/pub/gcc/infrastructure/mpfr-2.4.2.tar.bz2
...同上

```


当然，我们需要`gcc`来建立交叉编译环境的`目标环境gcc`,特别是在替代`gcc`为`clang`的Mac上。


一旦安装好上面的包，找到你的gcc的路径，然后export 这个路径.例如：

```
export CC=/usr/local/bin/gcc-4.9
export LD=/usr/local/bin/gcc-4.9

```


我们需要编译binutils 与 cross-compiled gcc，而后我们将他们放在`/usr/local/i386elfgcc`，现在让我们export几个路径，当然你可以按照需求改变它们。

```
export PREFIX="/usr/local/i386elfgcc"
export TARGET=i386-elf
export PATH="$PREFIX/bin:$PATH"

```

## [binutils](https://github.com/cfenollosa/os-tutorial/tree/master/11-kernel-crosscompiler#binutils)


记住，从网上粘贴命令时要小心，建议你一行一样的复制。  

```source-shell
mkdir /tmp/src
cd /tmp/src
curl -O http://ftp.gnu.org/gnu/binutils/binutils-2.24.tar.gz # If the link 404's, look for a more recent version
tar xf binutils-2.24.tar.gz
mkdir binutils-build
cd binutils-build
../binutils-2.24/configure --target=$TARGET --enable-interwork --enable-multilib --disable-nls --disable-werror --prefix=$PREFIX 2>&1 | tee configure.log
make all install 2>&1 | tee make.log
```

## [gcc](https://github.com/cfenollosa/os-tutorial/tree/master/11-kernel-crosscompiler#gcc)

```source-shell
cd /tmp/src
curl -O https://ftp.gnu.org/gnu/gcc/gcc-4.9.1/gcc-4.9.1.tar.bz2
tar xf gcc-4.9.1.tar.bz2
mkdir gcc-build
cd gcc-build
../gcc-4.9.1/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --disable-libssp --enable-languages=c --without-headers
make all-gcc 
make all-target-libgcc 
make install-gcc 
make install-target-libgcc 
```

如果出现` error：configure: error: no termcap library found`
ubuntu 18:
```source-shell
apt-get install  libncurses5-dev 解决
```
fedora 28:
```source-shell
sudo curl -O https://ftp.gnu.org/gnu/texinfo/texinfo-6.6.tar.xz
./configure & make & make install
```



好了，你现在有了全套的GNU binutils 并且 交叉编译器在`/usr/local/i386elfgcc/bin`, 加上 `i386-elf-`前缀是为了避免与你系统现有的环境冲突。


你应该将这些命令添加到 `$PATH`中，在`.bashrc` 中export。以后当我们用到这些命令时都会添加这些前缀。 








[^1]:https://github.com/cfenollosa/os-tutorial/tree/master/11-kernel-crosscompiler
Copyright：[BSD 3-Clause License  Copyright (c) 2018, Carlos Fenollosa](https://github.com/cfenollosa/os-tutorial/blob/master/LICENSE)


版权注明：本文所有涉及到：`https://github.com/cfenollosa/os-tutorial/` 这个git仓库的内容，全部对应以下开源协议声明：
[BSD 3-Clause License  Copyright (c) 2018, Carlos Fenollosa](https://github.com/cfenollosa/os-tutorial/blob/master/LICENSE)
