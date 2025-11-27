# Loader加载器

[[MBR主引导记录]] [[0启动流程]] [[硬盘]] [[保护模式]]

## 什么是 Loader

**Loader（加载器）** 是操作系统启动过程中的第二阶段引导程序，负责加载操作系统内核。

```
BIOS → MBR → Loader → 操作系统内核
```

## 为什么需要 Loader？

### MBR 的限制

[[MBR主引导记录]] 只有 **512 字节**：
- 前 446 字节：引导代码
- 64 字节：分区表
- 2 字节：魔数 0x55AA

**512 字节太小**，无法完成复杂的启动任务：
- 加载内核到内存
- 切换到保护模式
- 设置页表
- 获取内存信息
- 解析 ELF 文件

参见：[[MBR主引导记录]]

### 两阶段引导

| 阶段 | 名称 | 位置 | 大小 | 作用 |
|-----|------|------|------|------|
| **Stage 1** | MBR | 硬盘第 0 扇区 | 512 字节 | 加载 Loader |
| **Stage 2** | Loader | 硬盘其他扇区 | 几十 KB | 加载内核 |

## Loader 的位置

### 在硬盘上

- Loader 通常放在 MBR 之后的扇区
- 例如：**第 2 扇区**开始（第 1 扇区有时留空）

### 在内存中

- MBR 将 Loader 读入内存的某个地址
- 例如：**0x900**

```nasm
; MBR 读取 Loader
mov eax, 2        ; 起始扇区号（第2扇区）
mov bx, 0x900     ; 加载到内存 0x900
mov cx, 1         ; 读取1个扇区
call rd_disk_m_16 ; 调用读硬盘函数

jmp 0x900         ; 跳转到 Loader
```

参见：[[0启动流程]]

## Loader 的作用

### 1. 加载内核到内存

- 从硬盘读取内核文件
- 加载到内存的指定位置
- 例如：加载到 0x10000

### 2. 切换到保护模式

实模式 → 保护模式：

1. **准备 GDT（全局描述符表）**
2. **打开 A20 地址线**
3. **设置 CR0 寄存器的 PE 位**
4. **加载段选择子**

参见：[[保护模式]] [[GDT-GDTR-LGDT]]

### 3. 获取内存信息

- 通过 BIOS 中断（INT 15h）获取内存布局
- 保存内存信息，供内核使用

参见：[[物理内存容量检测]]

### 4. 解析 ELF 文件

- 内核通常是 ELF 格式
- Loader 解析 ELF 头
- 将各个段加载到正确位置

参见：[[ELF文件]] [[ELF结构]]

### 5. 设置页表（可选）

- 有些 Loader 会建立基本的页表
- 开启分页机制
- 为内核准备虚拟内存环境

参见：[[分页机制&PDEPTE]]

### 6. 跳转到内核入口

- 设置栈指针
- 传递参数（如内存信息）
- 跳转到内核的入口地址

## Loader 的编写

### 基本结构

```nasm
SECTION loader vstart=0x900
    ; 1. 初始化段寄存器
    mov ax, 0
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x900

    ; 2. 显示消息
    mov byte [gs:160], '2'
    mov byte [gs:161], 0x07

    ; 3. 获取内存信息
    ; ...

    ; 4. 准备 GDT
    ; ...

    ; 5. 切换到保护模式
    ; ...

    ; 6. 加载内核
    ; ...

    ; 7. 跳转到内核
    jmp KERNEL_ENTRY

    times 512-($-$$) db 0
```

### 关键代码段

#### 1. 显示消息

```nasm
; 直接操作显存（文本模式 0xB8000）
mov ax, 0xB800
mov gs, ax
mov byte [gs:160], '2'    ; 显示字符 '2'
mov byte [gs:161], 0x07   ; 属性：白字黑底
```

#### 2. 准备 GDT

```nasm
GDT_BASE:
    dd 0x00000000
    dd 0x00000000    ; 空描述符

CODE_DESC:
    dd 0x0000FFFF    ; 段界限 + 段基址
    dd 0x00CF9A00    ; 属性

DATA_DESC:
    dd 0x0000FFFF
    dd 0x00CF9200

GDT_SIZE equ $ - GDT_BASE
GDT_LIMIT equ GDT_SIZE - 1

gdt_ptr:
    dw GDT_LIMIT
    dd GDT_BASE
```

参见：[[段描述符]] [[GDT-GDTR-LGDT]]

#### 3. 切换到保护模式

```nasm
; 1. 打开 A20 地址线
in al, 0x92
or al, 0x02
out 0x92, al

; 2. 加载 GDT
lgdt [gdt_ptr]

; 3. 设置 CR0 的 PE 位
mov eax, cr0
or eax, 0x00000001
mov cr0, eax

; 4. 跳转刷新流水线
jmp dword CODE_SELECTOR:p_mode_start

[bits 32]
p_mode_start:
    mov ax, DATA_SELECTOR
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, 0x9000
    ; ...
```

参见：[[保护模式]]

## Loader 的测试版本

### 简单 Loader

最初的 Loader 只是显示消息，验证 MBR 读取成功：

```nasm
SECTION loader vstart=0x900
    mov ax, 0xB800
    mov gs, ax

    mov byte [gs:160], '2'
    mov byte [gs:161], 0x07
    mov byte [gs:162], ' '
    mov byte [gs:163], 0x07
    mov byte [gs:164], 'l'
    mov byte [gs:165], 0x07
    mov byte [gs:166], 'o'
    mov byte [gs:167], 0x07
    mov byte [gs:168], 'a'
    mov byte [gs:169], 0x07
    mov byte [gs:170], 'd'
    mov byte [gs:171], 0x07
    mov byte [gs:172], 'e'
    mov byte [gs:173], 0x07
    mov byte [gs:174], 'r'
    mov byte [gs:175], 0x07

    jmp $    ; 死循环
```

参见：[[显卡]]

## MBR 如何加载 Loader

### rd_disk_m_16 函数

MBR 通过读硬盘函数将 Loader 读入内存：

```nasm
rd_disk_m_16:
    ; eax = 起始扇区号
    ; bx  = 内存地址
    ; cx  = 扇区数

    ; 1. 设置扇区数
    mov dx, 0x1F2
    mov al, cl
    out dx, al

    ; 2. 设置 LBA 地址
    ; ...（见硬盘章节）

    ; 3. 发送读命令
    mov dx, 0x1F7
    mov al, 0x20
    out dx, al

    ; 4. 等待硬盘就绪
    ; ...

    ; 5. 读取数据
    mov dx, 0x1F0
    mov cx, 256    ; 512字节 = 256字
    .read_loop:
        in ax, dx
        mov [bx], ax
        add bx, 2
        loop .read_loop

    ret
```

参见：[[硬盘]] [[端口与INOUT指令]]

## Loader 与内核的交接

### 1. 内核入口地址

Loader 需要知道内核的入口地址：

- 从 ELF 文件头读取入口地址
- 或使用约定的固定地址

### 2. 传递参数

Loader 可以通过寄存器或内存传递参数给内核：

```nasm
; 通过寄存器传递
mov ebx, memory_info_addr    ; 内存信息地址

; 跳转到内核
jmp KERNEL_ENTRY
```

### 3. 环境准备

Loader 要确保：
- 已切换到保护模式（或长模式）
- GDT 已设置好
- 栈已准备好
- 页表已设置（如果需要）

## 编译和安装 Loader

### 编译

```bash
nasm -o loader.bin loader.asm
```

### 写入硬盘

```bash
dd if=loader.bin of=hd60M.img bs=512 count=1 seek=2 conv=notrunc
```

参数说明：
- `seek=2`：跳过前 2 个扇区（MBR 占第 0 扇区）
- `count=1`：写入 1 个扇区
- `conv=notrunc`：不截断文件

## 真实 Bootloader 的例子

### GRUB (GRand Unified Bootloader)

- **Stage 1**：446 字节，写在 MBR
- **Stage 1.5**：几 KB，放在 MBR 之后
- **Stage 2**：几十 KB，提供菜单、加载内核

### Windows Boot Manager

- MBR → Windows Boot Manager → Windows 内核

## 总结

### Loader 的核心作用

1. **接力棒**：MBR 太小，Loader 继续启动过程
2. **环境准备**：切换保护模式、设置 GDT
3. **加载内核**：从硬盘读取内核到内存
4. **交接**：跳转到内核入口

### 启动流程

```
BIOS → MBR (0x7C00, 512B) → Loader (0x900, 几KB) → Kernel
```

### 关键点

- Loader 放在 MBR 之后的扇区
- MBR 读取 Loader 到内存（如 0x900）
- Loader 准备环境（保护模式、GDT、内存信息）
- Loader 加载内核并跳转

参见：[[MBR主引导记录]] [[0启动流程]] [[保护模式]] [[硬盘]]
