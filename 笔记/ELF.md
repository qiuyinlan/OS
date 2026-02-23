# ELF (Executable and Linkable Format)

**ELF (Executable and Linkable Format)** 是一种用于可执行文件、目标文件、共享库和核心转储的标准文件格式。它是 Linux 和多种类UNIX系统中的标准格式。

## ELF 文件头 (`Elf32_Ehdr`)
[[ELF]]文件的开头是一个[[ELF]]文件头，它描述了整个文件的组织结构。
- **`e_ident`**: 文件的魔数，用于识别文件是否为[[ELF]]格式。开头的四个字节是 `0x7F` 和 `ELF`。
- **`e_type`**: 文件类型（如可执行文件 `ET_EXEC`）。
- **`e_machine`**: 体系结构（如 `EM_386` 表示 x86）。
- **`e_entry`**: 程序的入口地址。当[[操作系统]]加载完程序后，会从这个地址开始执行。
- **`e_phoff`**: 程序头表（Program Header Table）在文件中的偏移量。
- **`e_phnum`**: 程序头表中的条目数量。

## 程序头表 (Program Header Table)
程序头表描述了[[文件系统]]和[[操作系统]]如何创建进程映像。它包含一个或多个程序头（`Elf32_Phdr`）。

- **程序头 (`Elf32_Phdr`)**: 每个程序头描述了一个**段 (Segment)**。一个段通常由一个或多个属性相似的**节 (Section)** 组成。
    - **`p_type`**: 段的类型。我们最关心的是`PT_LOAD`，表示这是一个需要被加载到内存的段。
    - **`p_offset`**: 段在文件中的偏移量。
    - **`p_vaddr`**: 段被加载到内存中的虚拟地址。
    - **`p_filesz`**: 段在文件中的大小。
    - **`p_memsz`**: 段在内存中的大小。`p_memsz` 可能大于 `p_filesz`，例如对于`.bss`节。
    - **`p_flags`**: 段的权限（读、写、执行）。

## 加载 ELF 程序 (`load` 函数)
加载一个[[ELF]]格式的可执行文件到内存的过程如下：
1.  **打开文件**: `sys_open` 打开可执行文件。
2.  **读取ELF头**: `sys_read` 读取[[ELF]]文件头。
3.  **校验ELF头**: 检查`e_ident`魔数、`e_type`、`e_machine`等字段，确认是有效的、我们支持的可执行文件。
4.  **遍历程序头表**: 根据`e_phoff`和`e_phnum`，循环读取每个程序头。
5.  **加载段**: 对于每个类型为`PT_LOAD`的程序头：
    -   调用`segment_load`函数。
    -   `segment_load`为该段分配内存（`get_a_page`）。
    -   通过`sys_lseek`定位到段在文件中的`p_offset`位置。
    -   通过`sys_read`将大小为`p_filesz`的数据从文件加载到内存的`p_vaddr`处。
6.  **返回入口地址**: 加载完成后，返回[[ELF]]头中的`e_entry`。

---
**关联知识**
- [[exec]]
- [[文件系统]]
- [[虚拟内存-分页的原因|虚拟内存]]
- [[链接]]
