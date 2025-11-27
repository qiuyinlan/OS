# NASM汇编器

[[MBR主引导记录]] [[0汇编语法]] [[vstart虚拟起始地址]]

## 什么是 NASM

**NASM (Netwide Assembler)** 是一个汇编语言编译器（assembler）。

- **类型**：汇编器
- **作用**：将汇编源代码 (.asm) 翻译成机器能执行的二进制文件
- **特点**：支持多种目标文件格式、两遍扫描机制

```bash
# 基本用法
nasm -f bin -o mbr.bin mbr.asm
```

## NASM vs Bochs

- **NASM**：在操作系统（Linux/Windows）里运行的程序，用来生成二进制文件
- **Bochs**：模拟一台虚拟机（x86 PC），运行你生成的二进制文件

## NASM 的伪指令

### $ 和 $$

- `$`：代表**当前行的地址**
- `$$`：代表**当前 section 的起始地址**
- **作用**：方便程序员计算偏移、填充空间
- **注意**：CPU 不认识这些符号，NASM 在编译时会替换成实际地址

#### 例子

```nasm
jmp $    ; 死循环（跳回自己）
```

意思是：每次执行 jmp 就跳回本行，实现死循环。

#### 填充示例

```nasm
times 510-($-$$) db 0    ; 用0填充到510字节
```

- `$`：当前地址
- `$$`：section 起始地址
- `$-$$`：已用字节数
- `510-($-$$)`：还需要填充多少字节

参见：[[MBR主引导记录]]

### section

用来给程序做"逻辑分类"的标签：

```nasm
section .text    ; 代码段（存放指令）
section .data    ; 数据段（存放已初始化变量）
section .bss     ; 未初始化数据段
```

#### vstart 修饰符

```nasm
section code vstart=0x7c00
```

- `vstart` = virtual start address（虚拟起始地址）
- 让编译器以 vstart 的值为起始计算地址
- **注意**：这与 x86 分页后的虚拟地址是两码事！

参见：[[vstart虚拟起始地址]]

### times

重复指令：

```nasm
times 10 db 0    ; 定义10个字节，都是0
```

格式：`times <重复次数> <指令>`

### db, dw, dd

定义数据：

| 指令 | 含义 | 大小 |
|-----|------|------|
| `db` | define byte | 1 字节 |
| `dw` | define word | 2 字节 |
| `dd` | define double word | 4 字节 |

#### 例子

```nasm
message db "1 MBR"    ; 定义字符串
number  dw 1234       ; 定义16位数
address dd 0x7c00     ; 定义32位数
```

## NASM 的两遍扫描机制

### 为什么需要两遍扫描？

在汇编中，标签可以**在定义之前就被引用**：

```nasm
mov ax, message    ; 这里引用了message
jmp start

message db "Hi"    ; message在后面才定义
start:
    ; ...
```

### 第一次扫描

- **目的**：建立符号表（Symbol Table）
- **作用**：
  - 扫描整个源代码文件
  - 记录所有标签（如 `message`, `start`, `$$`, `$`）及其地址
  - **不生成机器码**

### 第二次扫描

- **目的**：生成机器码并替换地址
- **作用**：
  - 利用第一次扫描建立的符号表
  - 遇到 `mov ax, message` 时，查表获取 `message` 的地址
  - 将地址代入指令，生成正确的机器码

## 常用编译命令

### 生成纯二进制文件

```bash
nasm -f bin -o mbr.bin mbr.asm
```

- `-f bin`：输出纯二进制格式（适合 MBR）
- `-o mbr.bin`：输出文件名

### 生成 ELF 格式（用于链接）

```nasm
nasm -f elf32 -o program.o program.asm
```

### 生成调试信息

```bash
nasm -f elf32 -g -F dwarf -o program.o program.asm
```

## NASM 语法特点

### 1. 大小写不敏感（对于指令）

```nasm
MOV ax, bx    ; 等同于
mov ax, bx    ; 等同于
Mov AX, BX
```

但**标签**是大小写敏感的：
```nasm
Message: db "Hi"
message: db "Bye"    ; 这是两个不同的标签
```

### 2. 立即数前缀

```nasm
mov ax, 10      ; 十进制
mov ax, 0x10    ; 十六进制
mov ax, 10h     ; 十六进制（另一种写法）
mov bx, 1010b   ; 二进制
mov cx, 12o     ; 八进制
```

### 3. 内存访问用方括号

```nasm
mov ax, [0x7c00]    ; 从内存地址0x7c00读取数据到ax
mov [bx], ax        ; 将ax的值写入bx指向的内存地址
```

## MBR 编译示例

```nasm
SECTION MBR vstart=0x7c00
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00

    ; 你的代码...

    times 510-($-$$) db 0    ; 填充
    db 0x55, 0xaa             ; 魔数
```

编译并写入虚拟硬盘：

```bash
# 编译
nasm -o mbr.bin mbr.asm

# 写入虚拟硬盘镜像
dd if=mbr.bin of=hd60M.img bs=512 count=1 conv=notrunc
```

参见：[[MBR主引导记录]]

## org 伪指令

```nasm
org 0x7c00    ; 告诉NASM代码会被加载到0x7c00
```

- `org` = origin（起始地址/原点）
- 告诉汇编器"这段代码在内存里会被放到哪个地址开始"
- **org 本身不占位置**，但影响后续代码的地址计算

### org vs vstart

| 伪指令 | 作用 |
|-------|------|
| `org` | 全局设定代码起始地址 |
| `vstart` | section 级别的虚拟起始地址 |

通常在 MBR 中使用 `section ... vstart=0x7c00` 更清晰。

参见：[[vstart虚拟起始地址]]

## 总结

NASM 是一个强大的汇编器，适合编写：
- [[MBR主引导记录]]
- [[Loader加载器]]
- 操作系统内核初始化代码
- 裸机程序

```
核心特点：
1. 两遍扫描 → 支持前向引用
2. 灵活的伪指令（$, $$, times, org, vstart）
3. 多种输出格式（bin, elf, coff...）
4. 清晰的语法
```




参见：[[0汇编语法]] [[实模式]]
