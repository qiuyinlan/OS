# 任务门 (Task Gate)

**任务门**是x86架构（特别是IA-32[[保护模式]]）中一种特殊的[[门描述符]]，它用于实现**硬件任务切换**。

## 核心作用
- **硬件任务切换**: 任务门是CPU进行硬件任务切换的机制。当CPU通过任务门进行`CALL`、`JMP`或响应[[中断]]/[[异常 (Exception)]]时，它会自动完成以下操作：
    1.  保存当前[[任务 (Task)]]的完整上下文（所有[[寄存器]]的状态）到该[[任务 (Task)]]的[[TSS (Task State Segment)]]中。
    2.  加载新[[任务 (Task)]]的上下文。
    3.  切换到新[[任务 (Task)]]的[[栈]]和[[地址空间]]。
- **指向TSS**: 任务门本身不包含[[代码]]入口地址，它包含一个[[段选择子]]，指向[[GDT-GDTR-LGDT|GDT]]或[[LDT (Local Descriptor Table)]]中的一个[[TSS (Task State Segment)]]描述符。这个[[TSS (Task State Segment)]]描述符再指向实际的[[TSS (Task State Segment)]]。

## 结构
任务门描述符包含以下主要字段：
-   **TSS Selector (TSS选择子)**: 指向一个[[TSS (Task State Segment)]]描述符。
-   **DPL (Descriptor Privilege Level)**: 定义了访问此任务门所需的[[特权级]]。
-   **P (Present bit)**: 指示描述符是否有效。
-   **Type**: 指定为任务门类型（0b0101）。

## 现代操作系统的使用
- 尽管任务门被设计用于高效的硬件任务切换，但现代[[操作系统]]（如[[Linux]]和Windows）**很少使用**或完全不使用硬件任务切换。
- 相反，它们倾向于通过**软件方式**实现任务切换（例如，[[Linux]]的`schedule()`函数），这提供了更大的灵活性、可移植性，并且通常能获得更好的性能。
- 在x86-64架构中，硬件任务切换机制已被移除。

## 关联知识
- [[任务 (Task)]]
- [[TSS (Task State Segment)]]
- [[门描述符]]
- [[GDT-GDTR-LGDT]]
- [[LDT (Local Descriptor Table)]]
- [[进程调度]]
- [[上下文切换]]
- [[特权级]]
