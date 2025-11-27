# vstart虚拟起始地址

[[NASM汇编器]] [[MBR主引导记录]] [[段]]

## 什么是 vstart

`vstart` 是 NASM 的 section 修饰符，用来指定**虚拟起始地址** (virtual start address)。

```nasm
section code vstart=0x7c00
```

- 让编译器以 vstart 的值为起始计算该 section 内所有地址
- **注意**：这与 x86 CPU 开启分页后的虚拟地址是两码事！

## 为什么需要 vstart？

### 问题背景

```nasm
; 假设没有vstart
section code
    jmp start
    msg db "Hello"

start:
    mov ax, msg    ; msg的地址是多少？
```

默认情况下：
- NASM 从程序开头（地址0）开始计算
- `msg` 的地址 = 从文件开头的偏移量

### 实际情况

但程序会被加载到内存的特定位置（比如 MBR 加载到 0x7C00）：

```
文件中的地址     实际内存地址
0x0000    →     0x7C00  (jmp start)
0x0003    →     0x7C03  (msg)
```

如果直接用文件中的地址，就会访问错误的内存位置！
==程序运行时候，是直接按照程序里写的地址访问的，如果程序里的没有改成从7c00开始，但是真实情况是从7c00开始，那就乱套了。==




参见：[[MBR主引导记录]]

## 什么时候需要vstart

  需要 vstart 的情况：
  - 代码中用到了标签（label），比如 message、start 等
  - 这些标签代表内存地址
  - 需要 nasm 计算出"运行时的实际地址"

  不需要 vstart 的情况：
  - 立即数：mov ax, 100
  - 寄存器：mov ax, bx
  - 中断号：int 0x10
  - 这些都与"代码加载位置"无关

  - message 是标签（label），==代表一个内存地址==

-  message 是标签，代表地址
  - 类似 C 语言的指针：char *str = "1 MBR";

  - 意思是"把 message 的地址放入 ax"
  - 地址跟代码在内存中的位置有关

## vstart 的作用

```nasm
section code vstart=0x7c00
    jmp start
    msg db "Hello"

start:
    mov ax, msg    ; msg = 0x7C03（正确！）
```

使用 vstart 后：
- NASM 以 0x7C00 为起始计算地址
- `msg` 的地址 = 0x7C00 + 偏移量 = 0x7C03
- 正好对应实际内存位置

## 地址的概念

### 编译时地址 vs 运行时地址

- **编译时地址**：符号在源程序中的位置，距离文件开头的偏移量
- **运行时地址**：程序被加载到内存后的实际地址

### vstart 的本质

- 将**编译时地址**与**运行时地址**对齐
- 让编译器"假装"程序会被加载到 vstart 指定的位置

## 使用示例

### MBR 示例

```nasm
SECTION MBR vstart=0x7c00
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov sp, 0x7c00

    ; 显示消息
    mov ax, message
    mov bp, ax
    ; ... BIOS 中断显示 ...

message db "1 MBR"

    times 510-($-$$) db 0
    db 0x55, 0xaa
```

- `vstart=0x7c00`：告诉 NASM，MBR 会被加载到 0x7C00
- `mov ax, message`：NASM 会把 `message` 计算为 0x7C00 + 偏移量

### 多个 section 示例

```nasm
section code vstart=0x7c00
    ; 代码...

section data vstart=0x8000
    ; 数据...
```

每个 section 可以有自己的 vstart。

## vstart vs org

### org 伪指令

```nasm
org 0x7c00
; 程序代码...
```

- `org` 也是指定起始地址
- 但 `org` 是全局的，影响整个程序
- `vstart` 是 section 级别的

### 对比

| 伪指令 | 作用范围 | 用法 |
|-------|---------|------|
| `org` | 全局 | `org 0x7c00` |
| `vstart` | section 级别 | `section code vstart=0x7c00` |

### 推荐用法

在 MBR 中，推荐使用 `section ... vstart=` 更清晰：

```nasm
SECTION MBR vstart=0x7c00
    ; 代码...
```

参见：[[NASM汇编器]]

## 重要概念

### 1. vstart 只影响地址计算

vstart **不会改变程序被加载的位置**，它只是告诉 NASM 如何计算地址。

真正决定加载位置的是：
- BIOS（将 MBR 加载到 0x7C00）
- 你的 loader 代码（决定内核加载位置）

### 2. 虚拟 vs 物理

vstart 的"虚拟"是指：
- 地址不是从程序文件开头（0）算起
- 而是从 vstart 指定的地址算起

这与 x86 分页机制的"虚拟地址"**不是同一个概念**！

## 为什么叫"虚拟"？

因为：
- 以程序开头 0 算起的地址才是**真实存在的**（在文件中）
- 不以程序开头算起的地址，在文件内部**不存在**，是虚拟的

但这个"虚拟地址"对应的是程序**加载后在内存中的实际位置**。

## 实际应用

### MBR 为什么需要 vstart？

1. BIOS 将 MBR 加载到 `0x7C00`
2. MBR 中的代码要访问数据（如字符串）
3. 需要用正确的内存地址（0x7C00 + 偏移）

### Loader 的 vstart

```nasm
SECTION loader vstart=0x900
    ; loader代码...
```

- MBR 将 loader 加载到 0x900
- vstart=0x900 让地址计算正确

参见：[[Loader加载器]]

## NASM 的两遍扫描与 vstart

### 第一遍扫描

- 建立符号表
- 根据 vstart 计算每个标签的地址
- 记录 `message` = 0x7C00 + 偏移

### 第二遍扫描

- 遇到 `mov ax, message`
- 查符号表，得到 `message = 0x7C03`
- 生成机器码：`mov ax, 0x7C03`

参见：[[NASM汇编器]]

## 总结

vstart 的核心作用：

1. **对齐编译时地址和运行时地址**
2. **让编译器正确计算符号的内存地址**
3. **适用于加载到固定内存位置的程序**（如 MBR、loader）

关键理解：
- vstart 不改变程序加载位置
- vstart 只影响 NASM 如何计算地址
- vstart 的"虚拟"不等于分页机制的虚拟地址

参见：[[MBR主引导记录]] [[实模式]] [[段]]
