## ELF 文件结构概览

ELF（Executable and Linkable Format）是 Linux、Unix 系统常用的可执行文件格式。它把程序分为逻辑结构方便加载和链接。主要结构如下：

文件头，程序头表，节区表
（开头，段，编译器）

```
ELF 文件
│
├─ ELF Header（文件头）
│   - 描述文件类型（可执行、共享库、目标文件）
│   - CPU 架构
│   - 程序入口点
│   - Program Header Table 偏移
│   - Section Header Table 偏移
│
├─ Program Header Table（程序头表）
│   - 描述要加载到内存的段（Segment）
│   - 指示每段在文件偏移、内存地址、大小、权限
│
├─ Section Header Table（节区表）
│   - 描述编译器生成的各个节（.text/.data/.bss/.rodata/.symtab 等）
│   - 主要用于链接器和调试器
│
├─ Segments / Sections
│   - Segments（段）：可执行文件加载时的单位
│   - Sections（节）：链接器和调试器使用

```


## 常见 Segment 类型

Program Header Table 中，每个段（Segment）有类型字段 `p_type`，最常见的有：

| Segment 类型   | 作用                      | 内存映射特点                                       |
| ------------ | ----------------------- | -------------------------------------------- |
| `PT_LOAD`    | ==可加载段==                | 由 Loader 映射到==虚拟地址空间==，通常对应 .text/.data/.bss |
| `PT_DYNAMIC` | 动态链接信息                  | 加载到内存，用于==动态链接器==                            |
| `PT_INTERP`  | 动态链接器路径                 | 加载动态链接器路径字符串                                 |
| `PT_NOTE`    | 调试/元信息                  | 映射到内存供调试器使用                                  |
| `PT_PHDR`    | Program Header Table 自身 | 可选，便于访问表信息                                   |

> 注意：ELF 中的 **Segment ≠ Section**
> 
> - Segment = Loader 关注的内存加载单位
>     
> - Section = 链接器/调试器关注的逻辑划分




## 1️⃣ ELF 的 PT_LOAD 段

- **PT_LOAD（可加载段）**：
    
    - ELF 文件里的 Program Header Table（程序头表）里的一个类型
        
    - 描述 **哪些数据要加载到内存**
        
    - 包含：
        
        - `p_offset`：文件偏移（在 ELF 文件里的位置）
            
        - `p_vaddr`：段要映射到虚拟地址空间的起始地址
            
        - `p_filesz`：文件中段的大小
            
        - `p_memsz`：内存中段的大小（包含 `.bss` 清零区域）
            
        - `p_flags`：权限（可执行/可读/可写）
            
- **作用**：告诉 Loader “把这块文件内容加载到哪个虚拟地址空间”。
    

---

## 2️⃣ 和 CPU 段机制的关系

- 之前我们说的 **段选择子 + 段描述符**：
    
    - 用于计算 **逻辑地址 → 线性地址**
        
    - 段描述符提供段基址（Base）和界限（Limit），线性地址 = Base + 偏移
        
- **PT_LOAD 段**：
    
    - 在 Loader 加载内核时，会把 ELF 文件里的 `.text/.data/.bss` 放到指定 **虚拟地址**（就是 `p_vaddr`）
        
    - 这个虚拟地址对应 CPU 的 **线性地址**
        
    - 如果启用段机制，Loader 还会设置段描述符，Base = `p_vaddr`，Limit = 段大小
        
    - CPU 访问时：
        
        `逻辑地址 (段选择子 + 偏移)       │       ▼ 段描述符 (Base + Limit)       │       ▼ 线性地址（虚拟地址）`
        

---

## 3️⃣ 总结

- **PT_LOAD 段** = ELF 文件中需要加载到内存的段
    
- 它最终 **落在虚拟地址空间**
    
- 如果使用段机制：
    
    - 段基址 = `p_vaddr`
        
    - 段界限 = `p_memsz`
        
    - 权限 = `p_flags`
        
- CPU 用段选择子 + 偏移访问这个虚拟地址 → 再通过分页映射到物理内存
    

> 所以可以说，**ELF 文件里的 PT_LOAD 段就是你之前说的可以算出虚拟地址的段**，它提供了 Base、大小和权限，CPU 访问时的线性地址就是它的虚拟地址。



