# LDT (Local Descriptor Table)

**LDT（局部描述符表）** 是x86[[保护模式]]下，[[中央处理器 (CPU)]]硬件支持的一种内存分段机制。它与[[GDT-GDTR-LGDT|GDT]]（全局描述符表）相对应。

## 作用与设计思想
- **任务私有**: Intel的原始设计是，每个任务（[[进程 (Process)]]）都拥有自己私有的[[LDT (Local Descriptor Table)]]。[[LDT (Local Descriptor Table)]]中存放的是该任务私有的段描述符（如该任务的代码段、数据段等）。
- **隔离**: 通过为每个任务提供独立的[[LDT (Local Descriptor Table)]]，可以实现任务间的地址空间隔离。一个任务无法访问另一个任务[[LDT (Local Descriptor Table)]]中定义的段。
- **GDT中的LDT描述符**: [[LDT (Local Descriptor Table)]]本身也是内存中的一个段，它的位置和大小由一个**LDT描述符**来描述，而这个LDT描述符必须存放在[[GDT-GDTR-LGDT|GDT]]中。

## LDTR 寄存器
- **LDTR (Local Descriptor Table Register)**: 这是一个16位的寄存器，它不直接存储[[LDT (Local Descriptor Table)]]的地址，而是存储指向[[GDT-GDTR-LGDT|GDT]]中LDT描述符的[[段选择子]]。
- **加载**: 通过`lldt`指令将LDT选择子加载到LDTR。[[中央处理器 (CPU)]]会根据LDTR中的选择子去[[GDT-GDTR-LGDT|GDT]]中找到LDT描述符，然后将[[LDT (Local Descriptor Table)]]的基地址、界限等信息缓存起来。

## 现代操作系统的选择
- **效率问题**: 为每个任务维护一个[[LDT (Local Descriptor Table)]]并在任务切换时切换LDTR，开销较大。
- **平坦模型**: 现代[[操作系统]]（如Linux和我们的系统）大多采用**平坦内存模型**。它们主要使用[[分页机制&PDEPTE|分页]]来实现内存隔离，而不是分段。系统中所有进程共享同一个[[GDT-GDTR-LGDT|GDT]]，并且通常不使用[[LDT (Local Descriptor Table)]]。

因此，在我们的项目中，**没有使用LDT**。我们所有的段描述符都定义在全局唯一的[[GDT-GDTR-LGDT|GDT]]中。

---
**关联知识**
- [[GDT-GDTR-LGDT]]
- [[段选择子]]
- [[段]]
- [[保护模式]]
- [[TSS]]
