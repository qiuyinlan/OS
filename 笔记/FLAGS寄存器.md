# FLAGS寄存器

[[寄存器]] [[CPU执行指令]] [[实模式]] [[条件跳转]]

## 什么是 FLAGS 寄存器

**FLAGS/EFLAGS** 是 CPU 的**标志寄存器**，用来记录指令执行后的**状态信息**。

- **实模式**：16 位 FLAGS
- **保护模式**：32 位 EFLAGS
- **长模式**：64 位 RFLAGS

## 为什么需要 FLAGS？

### 问题背景

CPU 执行指令后，不仅要得到"结果本身"，还要知道"结果的特征"：

- 有没有进位？
- 是不是负数？
- 是不是 0？
- 有没有溢出？

这些特征用于**条件判断**，决定下一步是否跳转。

### 如果没有 FLAGS

CPU 需要重新分析结果：

```nasm
add al, 1
jz target    ; 如何知道结果是否为0？
```

没有 FLAGS，CPU 要么：
1. 重新检查 AL 的值（慢！）
2. 从内存重新读取（更慢！）

### 有了 FLAGS

运算单元（ALU）在计算时顺手记录特征：

```
add al, 1
→ 结果 = 0 → ZF = 1
→ 有进位 → CF = 1
→ 无溢出 → OF = 0
```

`jz` 指令直接看 ZF 就知道了，快很多！

## FLAGS 寄存器的标志位

### 常用状态标志

| 位 | 标志 | 全称 | 含义 |
|----|------|------|------|
| 0 | **CF** | Carry Flag | 进位标志 |
| 2 | **PF** | Parity Flag | 奇偶标志 |
| 4 | **AF** | Auxiliary Carry | 辅助进位 |
| 6 | **ZF** | Zero Flag | 零标志 |
| 7 | **SF** | Sign Flag | 符号标志 |
| 11 | **OF** | Overflow Flag | 溢出标志 |

### 控制标志

| 位 | 标志 | 全称 | 含义 |
|----|------|------|------|
| 8 | **TF** | Trap Flag | 陷阱标志（单步调试）|
| 9 | **IF** | Interrupt Flag | 中断允许标志 |
| 10 | **DF** | Direction Flag | 方向标志（字符串操作）|

## 状态标志详解

### CF (Carry Flag) - 进位标志

**无符号数**加减法时的进位/借位。

#### 示例：无符号加法溢出

```nasm
mov al, 255    ; AL = 0xFF
add al, 1      ; AL + 1 = 256
```

结果：
- AL = 0（因为只能存 8 位）
- **CF = 1**（发生了进位）

| 二进制运算 | 说明 |
|----------|------|
| 1111 1111 | AL = 255 |
| 0000 0001 | +1 |
| 1 0000 0000 | 结果 = 256 (9位) |
| 0000 0000 | AL只能存8位 → AL = 0 |
| 进位 → 1 | **CF = 1** |

### ZF (Zero Flag) - 零标志

结果是否为 0。

```nasm
sub ax, ax    ; AX - AX = 0
              ; ZF = 1
```

用途：
- 判断相等：`cmp ax, bx` 后 `je` (jump if equal)
- 循环计数：`dec cx` 后 `jnz` (jump if not zero)

### SF (Sign Flag) - 符号标志

结果的**最高位**（符号位）。

- **SF = 1**：结果为负（有符号数）
- **SF = 0**：结果为正或 0

```nasm
mov al, -1     ; AL = 0xFF (二进制 1111 1111)
test al, al    ; 测试 AL
               ; SF = 1 (最高位是1)
```

### OF (Overflow Flag) - 溢出标志

**有符号数**运算是否超范围。

#### 示例：有符号溢出

```nasm
mov al, 127    ; 8位有符号数最大值
add al, 1      ; 127 + 1 = -128 (溢出！)
```

结果：
- AL = -128（0x80）
- **OF = 1**（有符号溢出）
- CF = 0（无进位，因为没超过255）

#### CF vs OF

| 标志 | 检测类型 | 示例 |
|-----|---------|------|
| **CF** | 无符号溢出 | 255 + 1 → CF=1 |
| **OF** | 有符号溢出 | 127 + 1 → OF=1 |

### PF (Parity Flag) - 奇偶标志

结果的**低 8 位**中"1"的个数是否为偶数。

```nasm
mov al, 0b00000011    ; 2个1 → 偶数
                      ; PF = 1

mov al, 0b00000111    ; 3个1 → 奇数
                      ; PF = 0
```

用途：简单的校验（现在很少用）。

### AF (Auxiliary Carry) - 辅助进位

**低 4 位**（半字节）运算时的进位。

主要用于 **BCD 运算**（二进制编码的十进制）。

```nasm
mov al, 0x0F    ; 低4位 = 1111
add al, 1       ; 低4位溢出
                ; AF = 1
```

## 条件跳转指令

### 基于 FLAGS 的跳转

条件跳转指令 **jxx** 根据 FLAGS 决定是否跳转：

| 指令 | 条件 | FLAGS | 含义 |
|-----|------|-------|------|
| **jz / je** | Zero / Equal | ZF = 1 | 等于0时跳转 |
| **jnz / jne** | Not Zero / Not Equal | ZF = 0 | 不等于0时跳转 |
| **js** | Sign | SF = 1 | 为负时跳转 |
| **jns** | Not Sign | SF = 0 | 非负时跳转 |
| **jc** | Carry | CF = 1 | 有进位时跳转 |
| **jnc** | Not Carry | CF = 0 | 无进位时跳转 |
| **jo** | Overflow | OF = 1 | 溢出时跳转 |
| **jno** | Not Overflow | OF = 0 | 未溢出时跳转 |

### 组合条件跳转

| 指令 | 条件 | FLAGS | 含义（无符号）|
|-----|------|-------|--------------|
| **ja** | Above | CF=0 && ZF=0 | 大于（无符号）|
| **jb** | Below | CF=1 | 小于（无符号）|
| **jae** | Above or Equal | CF=0 | 大于等于 |
| **jbe** | Below or Equal | CF=1 \|\| ZF=1 | 小于等于 |

| 指令 | 条件 | FLAGS | 含义（有符号）|
|-----|------|-------|--------------|
| **jg** | Greater | ZF=0 && SF=OF | 大于（有符号）|
| **jl** | Less | SF≠OF | 小于（有符号）|
| **jge** | Greater or Equal | SF=OF | 大于等于 |
| **jle** | Less or Equal | ZF=1 \|\| SF≠OF | 小于等于 |

参见：[[条件跳转]]

## FLAGS 使用示例

### 示例1：检查是否为0

```nasm
mov ax, 10
sub ax, 10    ; AX = 0, ZF = 1
jz is_zero    ; ZF=1，跳转

is_zero:
    ; 处理 AX = 0 的情况
```

### 示例2：无符号比较

```nasm
mov al, 255
add al, 1     ; AL = 0, CF = 1（进位）
jc overflow   ; CF=1，跳转

overflow:
    ; 处理溢出
```

### 示例3：有符号比较

```nasm
mov al, 127
add al, 1     ; AL = -128, OF = 1
jo overflow   ; OF=1，跳转

overflow:
    ; 处理有符号溢出
```

### 示例4：循环计数

```nasm
mov cx, 10

loop_start:
    ; 循环体...
    dec cx        ; CX--, 如果CX=0则ZF=1
    jnz loop_start ; ZF=0继续循环
```

## 为什么需要区分 CF 和 OF？

### 无符号 vs 有符号

```nasm
mov al, 255
add al, 1
```

解释1：**无符号数**
- 255 + 1 = 256
- 8位无符号数最大255，**溢出了**
- **CF = 1**（无符号溢出）

解释2：**有符号数**
- -1 + 1 = 0
- 符号位没有非法变化
- **OF = 0**（有符号未溢出）

### 不同场景使用不同标志

| 场景 | 使用标志 | 跳转指令 |
|-----|---------|---------|
| 无符号比较 | CF | ja, jb, jae, jbe |
| 有符号比较 | OF, SF | jg, jl, jge, jle |
| 相等判断 | ZF | je, jne |

## FLAGS 的读写

### 读取 FLAGS

```nasm
pushf          ; 将FLAGS压栈
pop ax         ; 弹出到AX
```

### 写入 FLAGS

```nasm
push ax        ; 将AX压栈
popf           ; 弹出到FLAGS
```

### 单独设置/清除标志

```nasm
stc            ; Set Carry - CF = 1
clc            ; Clear Carry - CF = 0

sti            ; Set Interrupt - IF = 1 (允许中断)
cli            ; Clear Interrupt - IF = 0 (禁止中断)

std            ; Set Direction - DF = 1 (字符串操作递减)
cld            ; Clear Direction - DF = 0 (字符串操作递增)
```

## FLAGS 在不同指令中的变化

### 算术指令

| 指令 | 影响的标志 |
|-----|-----------|
| add, sub | CF, OF, SF, ZF, PF, AF |
| mul, imul | CF, OF (其他未定义) |
| inc, dec | OF, SF, ZF, PF, AF (不影响CF!) |

### 逻辑指令

| 指令 | 影响的标志 |
|-----|-----------|
| and, or, xor | SF, ZF, PF (CF=0, OF=0) |
| test | SF, ZF, PF (CF=0, OF=0) |
| not | 不影响任何标志 |

### 比较指令

| 指令 | 影响的标志 |
|-----|-----------|
| cmp | CF, OF, SF, ZF, PF, AF (相当于sub) |

## 总结

### FLAGS 的核心作用

1. **记录运算结果的特征**
   - 进位、溢出、正负、零

2. **支持条件跳转**
   - jz, jnz, jc, jo, ja, jb, jg, jl...

3. **提高效率**
   - ALU 在运算时顺手记录，不需要重新计算

### 关键标志位

| 标志 | 用途 |
|-----|------|
| **CF** | 无符号溢出 |
| **ZF** | 结果为0 |
| **SF** | 结果为负 |
| **OF** | 有符号溢出 |

参见：[[寄存器]] [[CPU执行指令]] [[条件跳转]]
