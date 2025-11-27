# RET与CALL指令

[[栈与指针]] [[CSIP]] [[FLAGS寄存器]] [[实模式]]

## CALL 指令 - 函数调用

**CALL** 指令用于调用函数（子程序）。

### 基本格式

```nasm
call func    ; 调用函数func
```

### CALL 执行过程

1. **保存返回地址**
   - 将**下一条指令的地址**压入栈
   - 实模式：push IP（近调用）或 push CS, push IP（远调用）

2. **跳转到目标函数**
   - 修改 IP（近调用）或 CS:IP（远调用）
   - 开始执行函数代码

### 近调用 vs 远调用

| 类型 | 格式 | 压栈内容 | 跨段？ |
|-----|------|---------|-------|
| **近调用** | `call near func` | push IP | 否 |
| **远调用** | `call far func` | push CS, push IP | 是 |

#### 近调用（段内调用）

```nasm
call func    ; 默认是近调用

; CPU 执行：
; push IP
; jmp func
```

#### 远调用（段间调用）

```nasm
call far func

; CPU 执行：
; push CS
; push IP
; jmp far func
```

参见：[[CSIP]]

## RET 指令 - 函数返回

**RET** 指令用于从函数返回。

### 基本格式

```nasm
ret         ; 近返回
retf        ; 远返回
ret n       ; 返回并弹出n字节参数
```

### RET 执行过程

1. **从栈恢复返回地址**
   - pop IP（近返回）
   - pop IP, pop CS（远返回）

2. **跳转回调用处**
   - CPU 继续执行 call 的下一条指令

### 近返回 vs 远返回

| 类型 | 格式 | 弹栈内容 | 配合 |
|-----|------|---------|------|
| **近返回** | `ret` | pop IP | call near |
| **远返回** | `retf` | pop IP, pop CS | call far |

参见：[[栈与指针]]

## 为什么需要栈保存返回地址？

### 问题：返回地址存哪？

```nasm
call func    ; 调用函数
; <-- 返回地址（下一条指令）
mov ax, 1

func:
    ; 函数体...
    ret      ; 如何知道返回到哪里？
```

### 方案对比

| 方案 | 优点 | 缺点 |
|-----|------|------|
| 寄存器 | 简单 | 数量有限，函数嵌套调用会覆盖 |
| 固定内存 | 可以存多个 | 不支持递归，多线程冲突 |
| **栈** | 无限容量，支持嵌套和递归 | 需要管理 SP |

### 栈的优势

```nasm
; 嵌套调用
call func1
    call func2
        call func3
            ret    ; 返回到 func2
        ret        ; 返回到 func1
    ret            ; 返回到 main
```

栈的 **LIFO（后进先出）** 特性完美支持函数嵌套！

## 完整的函数调用示例

### 示例代码

```nasm
main:
    mov ax, 5
    call add_one     ; 调用函数
    ; <-- 返回地址
    mov bx, ax
    ; ...

add_one:
    add ax, 1
    ret
```

### 执行过程

```
1. call add_one
   → push IP (返回地址)
   → jmp add_one

2. add ax, 1
   → AX = AX + 1

3. ret
   → pop IP
   → 跳转到返回地址

4. mov bx, ax
   → 继续执行
```

### 栈的变化

```
调用前:
    SP → [...]

call add_one:
    SP → [返回地址]  ← 压入返回地址
         [...]

ret:
    SP → [...]       ← 弹出返回地址，SP恢复
```

## IP 寄存器的特殊性

### IP 不能直接赋值

```nasm
mov ip, 0x1234    ; ❌ 错误！不允许
```

### 为什么？

- **IP (Instruction Pointer)** 是 CPU 自动管理的
- 只能通过控制流指令间接改变：
  - `jmp`：无条件跳转
  - `call`：调用函数（压栈 + 跳转）
  - `ret`：返回（弹栈 + 跳转）
  - `jxx`：条件跳转

参见：[[CSIP]]

## RET 的变体

### ret n - 带参数清理

```nasm
func:
    ; 函数体...
    ret 4    ; 返回并将 SP += 4
```

用途：清理调用者压入的参数。

#### 示例：stdcall 调用约定

```nasm
; 调用者
push arg2
push arg1
call func
; <-- 返回后，SP 已恢复

func:
    ; 使用参数 [bp+4], [bp+6]
    ret 4    ; 清理2个参数（2×2=4字节）
```

参见：[[栈与指针]]

## CALL 和 RET 的配对

### 必须配对使用

```nasm
call near func
    ; ...
    ret        ; 近返回

call far func
    ; ...
    retf       ; 远返回
```

❌ **不配对会出错**：

```nasm
call near func
    retf       ; ❌ 错误！多弹一个CS
```

结果：
- 近调用只压了 IP
- 远返回弹了 IP 和 CS
- CS 被错误的值覆盖，程序崩溃

## 函数调用约定

### cdecl（C语言默认）

```nasm
; 调用者负责清理栈
push arg2
push arg1
call func
add sp, 4    ; 调用者清理参数
```

### stdcall（Win32 API）

```nasm
; 被调用者负责清理栈
push arg2
push arg1
call func    ; func内部会ret 4
```

### 参数传递

| 方式 | 优点 | 缺点 |
|-----|------|------|
| 寄存器 | 快 | 参数数量有限 |
| 栈 | 支持任意数量参数 | 稍慢，需要访问内存 |

参见：[[内核函数调用规定]]

## CALL/RET 与中断的区别

### CALL/RET

- **软件主动调用**
- 保存返回地址到栈
- 可以嵌套

### INT/IRET

- **触发中断**（硬件或软件）
- 保存 FLAGS + CS + IP
- 跳转到中断处理程序

参见：[[中断]]

## 实际应用示例

### 示例1：递归函数

```nasm
factorial:
    cmp ax, 1
    jle base_case

    push ax          ; 保存 AX
    dec ax
    call factorial   ; 递归调用
    pop bx           ; 恢复原 AX 到 BX
    mul bx           ; AX = AX * BX
    ret

base_case:
    mov ax, 1
    ret
```

### 示例2：保护寄存器

```nasm
func:
    push ax          ; 保存要用的寄存器
    push bx

    ; 函数体...
    mov ax, 10
    mov bx, 20

    pop bx           ; 恢复寄存器
    pop ax
    ret
```

### 示例3：局部变量

```nasm
func:
    push bp
    mov bp, sp       ; 建立栈帧
    sub sp, 4        ; 分配4字节局部变量

    mov [bp-2], ax   ; 局部变量1
    mov [bp-4], bx   ; 局部变量2

    ; 函数体...

    mov sp, bp       ; 恢复SP
    pop bp
    ret
```

参见：[[栈与指针]]

## 总结

### CALL 指令

1. **保存返回地址**（push IP 或 push CS, push IP）
2. **跳转到函数**

### RET 指令

1. **恢复返回地址**（pop IP 或 pop IP, pop CS）
2. **跳转回调用处**

### 关键点

- **栈**：用于保存返回地址
- **配对**：call near 配 ret，call far 配 retf
- **IP 不可直接赋值**：只能通过 jmp/call/ret 改变
- **支持嵌套和递归**：栈的 LIFO 特性

参见：[[栈与指针]] [[CSIP]] [[实模式]]
